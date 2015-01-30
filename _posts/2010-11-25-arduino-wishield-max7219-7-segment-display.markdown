---
layout: post
status: publish
published: true
title: Arduino WiShield + MAX7219 7 Segment Display
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "<a href=\"http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2010&#47;11&#47;IMG_20101123_171932.jpg\"><img
  src=\"http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2010&#47;11&#47;IMG_20101123_171932-300x225.jpg\"
  alt=\"\" title=\"arduino + wishield + 7 segment display\" width=\"300\" height=\"225\"
  class=\"alignright size-medium wp-image-294\" &#47;><&#47;a><p>For this project,
  I wanted to build a device capable of displaying up to 8 digits on a seven segment
  display. Sounds easy, right? The catch is, I wanted to retrieve these digits from
  the Internet over WiFi.<&#47;p>\r\n<p>I took this opportunity to try out the ever-popular
  Arduino platform. Arduino turned out to be a good choice for this project for several
  because it has:<&#47;p>\r\n<ul>\r\n<li>an easy to use, Arduino compatible WiFi adapter
  (WiShield) put out by <a href=\"http:&#47;&#47;asynclabs.com&#47;\">asynclabs<&#47;a><&#47;li>\r\n<li>a
  library available for talking to the WiShield with examples included<&#47;li>\r\n<li>a
  MAX7219 interface library<&#47;li>\r\n<li>an onboard USB programmer and a software
  programmer that works on Ubuntu<&#47;li>\r\n<&#47;ul>\r\n"
wordpress_id: 287
wordpress_url: http://lithostech.com/?p=287
date: '2010-11-25 21:11:10 -0800'
date_gmt: '2010-11-26 05:11:10 -0800'
categories:
- Uncategorized
tags:
- rightscale
- arduino
- wishield
- max7129
comments: []
---
<p><a href="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2010&#47;11&#47;IMG_20101123_171932.jpg"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2010&#47;11&#47;IMG_20101123_171932-300x225.jpg" alt="" title="arduino + wishield + 7 segment display" width="300" height="225" class="alignright size-medium wp-image-294" &#47;><&#47;a>
<p>For this project, I wanted to build a device capable of displaying up to 8 digits on a seven segment display. Sounds easy, right? The catch is, I wanted to retrieve these digits from the Internet over WiFi.<&#47;p></p>
<p>I took this opportunity to try out the ever-popular Arduino platform. Arduino turned out to be a good choice for this project for several because it has:<&#47;p></p>
<ul>
<li>an easy to use, Arduino compatible WiFi adapter (WiShield) put out by <a href="http:&#47;&#47;asynclabs.com&#47;">asynclabs<&#47;a><&#47;li>
<li>a library available for talking to the WiShield with examples included<&#47;li>
<li>a MAX7219 interface library<&#47;li>
<li>an onboard USB programmer and a software programmer that works on Ubuntu<&#47;li><br />
<&#47;ul><br />
<a id="more"></a><a id="more-287"></a></p>
<p>This is the first electronics project I've attempted from scratch so I'm quite pleased with the result. In fact, I'm looking for larger 7 segment digits to build a much larger display.<&#47;p></p>
<p>I began this project by purchasing a MAX7219 display driver, an <a href="http:&#47;&#47;arduino.cc&#47;en&#47;Main&#47;ArduinoBoardUno">Arduino Uno<&#47;a>, 8 seven segment common cathode LED digits, a breadboard, some jumper wires and A&#47;B USB cable. It took me a few hours to properly connect the displays to the display driver, but seeing the test routine properly on the digits was satisfying enough to make it worth the effort. One problem I ran into was in selecting the proper resistor for Rset which sets the display brightness. After reading the datasheet, I selected a 10kΩ resistor which turned out to be wrong because the display would quickly flicker off after a brief moment. Adding a second resistor in series seemed to fix the problem.<&#47;p></p>
<p>Bolstered by my success in displaying hard-coded numbers, I ordered the WiShield. It arrived a few weeks later and I dropped it right in. Getting a simple WiFi enabled program running is as simple as cloning asynclab's WiShield git repository, making a few modifications, and uploading one of the example scripts. At this point, I had all the hardware I needed to make this device get information from the Internet and display it. The final missing piece was the software. This part took the longest, mostly because I have almost no experience writing in C. I had the whole thing working with DHCP and DNS resolution, but it was unstable for some reason. I ended up with the following attrocity:<&#47;p><br />
<code class="language-c"><br />
#include <WiShield.h><br />
#include <LedControl.h><br />
extern "C" {<br />
   #include "uip.h"<br />
}</p>
<p>#define ISO_nl       0x0a<br />
#define ISO_cr       0x0d</p>
<p>&#47;&#47; Wireless configuration parameters ----------------------------------------<br />
unsigned char local_ip[]     = {10,10,0,91};   &#47;&#47; IP address of WiShield<br />
unsigned char gateway_ip[]   = {10,10,0,3};   &#47;&#47; router or gateway IP address<br />
unsigned char subnet_mask[]  = {255,255,255,0}; &#47;&#47; subnet mask for the local network<br />
char ssid[]                  = {"SOMESSID"};   &#47;&#47; max 32 bytes<br />
unsigned char security_type  = 3;               &#47;&#47; 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2<br />
unsigned char  wireless_mode = 1;               &#47;&#47; 1==Infrastructure, 2==Ad-hoc<br />
unsigned char ssid_len;<br />
unsigned char security_passphrase_len;<br />
int           closedLoop     = 0;</p>
<p>&#47;&#47; WPA&#47;WPA2 passphrase<br />
const prog_char security_passphrase[] PROGMEM = {"somewpapassphrase"};	&#47;&#47; max 64 characters</p>
<p>&#47;&#47; WEP 128-bit keys<br />
prog_uchar wep_keys[] PROGMEM = {<br />
   0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, &#47;&#47; Key 0<br />
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, &#47;&#47; Key 1<br />
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, &#47;&#47; Key 2<br />
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  &#47;&#47; Key 3<br />
};<br />
&#47;&#47; End of wireless configuration parameters ----------------------------------------</p>
<p>&#47;&#47; global data<br />
boolean connectAndSendTCP = true;<br />
uip_ipaddr_t srvaddr;</p>
<p>LedControl lc=LedControl(5,6,7,1);</p>
<p>void setup()<br />
{<br />
   &#47;&#47; Enable Serial output<br />
   Serial.begin(57600);<br />
   lc.shutdown(0,false);<br />
   lc.setIntensity(0,9);<br />
   initialize();<br />
}</p>
<p>void initialize()<br />
{<br />
   Serial.println("Establishing WifFi Connection");<br />
   WiFi.init();</p>
<p>   uip_sethostaddr(local_ip);<br />
   uip_setdraddr(gateway_ip);<br />
   uip_setnetmask(subnet_mask);</p>
<p>   delay(100);<br />
}</p>
<p>unsigned long entryTimer = 12000;</p>
<p>void loop()<br />
{<br />
  if (entryTimer > 0 && entryTimer % 100 == 0) {<br />
    Serial.println(entryTimer);<br />
  }<br />
  if (true == connectAndSendTCP) {<br />
    entryTimer++;<br />
    if ((entryTimer > 12000) && (true == connectAndSendTCP)) {<br />
      connectAndSendTCP = false;<br />
      entryTimer = 0;<br />
      Serial.println("inside");<br />
      &#47;&#47; Address of server to connect to<br />
      uip_ipaddr(&srvaddr, 173,203,98,126);<br />
      uip_conn = uip_connect(&srvaddr, HTONS(80));</p>
<p>      if (NULL == uip_conn) {<br />
        Serial.println("could not connect");<br />
      }<br />
    }<br />
  }<br />
  delay(10);<br />
  WiFi.run();<br />
}</p>
<p>void (*softReset) (void) = 0; &#47;&#47;declare reset function @ address 0</p>
<p>extern "C" {<br />
   void printx(char *stuff)<br />
   {<br />
     Serial.println(stuff);<br />
   }</p>
<p>   &#47;&#47; Process UDP UIP_APPCALL events<br />
   void udpapp_appcall(void)<br />
   {<br />
      uip_dhcp_run();<br />
   }</p>
<p>   &#47;&#47; DHCP query complete callback<br />
   void uip_dhcp_callback(const struct dhcp_state *s)<br />
   {<br />
   }</p>
<p>   char requestLine[] = "GET &#47;some&#47;path.txt HTTP&#47;1.1\r\nUser-Agent: uIP&#47;1.0\r\nHost: example.com\r\nConnection: Close\r\n\r\n";</p>
<p>   void socket_app_appcall(void)<br />
   {<br />
      struct socket_app_state *s = &(uip_conn->appstate);</p>
<p>      if(uip_closed() || uip_timedout()) {<br />
         Serial.print("Closed loop: ");<br />
         Serial.println(closedLoop);<br />
         if (closedLoop > 2) {<br />
           &#47;&#47;initialize();<br />
           softReset();<br />
         }<br />
         closedLoop++;<br />
         Serial.println("SA: closed &#47; timedout");<br />
         connectAndSendTCP = true;<br />
      }<br />
      if(uip_poll()) {<br />
      }<br />
      if(uip_aborted()) {<br />
        connectAndSendTCP = true;<br />
        Serial.println("SA: aborted");<br />
      }<br />
      if(uip_connected()) {<br />
         Serial.println("Sending:");<br />
         Serial.println(requestLine);<br />
         uip_send(requestLine, strlen(requestLine));<br />
         closedLoop = 0;<br />
      }<br />
      if(uip_acked()) {<br />
         Serial.println("SA: acked");<br />
      }<br />
      if(uip_newdata()) {<br />
        Serial.println("SA: newdata");</p>
<p>        int len                      = uip_datalen();<br />
        int pos                      = -1;<br />
        int linenumber               = -1;<br />
        int linepos                  = 0;<br />
        boolean startresponsedata    = false;<br />
        boolean newline              = false;<br />
        char    emptyline[8]         = {0, 0, 0, 0, 0, 0, 0, 0};<br />
        char    linezero[8]          = {0, 0, 0, 0, 0, 0, 0, 0};<br />
        char    lineone[8]           = {0, 0, 0, 0, 0, 0, 0, 0};<br />
        char    lastlineone[8]       = {0, 0, 0, 0, 0, 0, 0, 0};</p>
<p>        while(pos <= len){<br />
          pos++;<br />
          &#47;&#47; if we have a \r followed by \n<br />
          if (((char*)uip_appdata)[pos] == ISO_nl || ((char*)uip_appdata)[pos] == ISO_cr){<br />
            if (((char*)uip_appdata)[pos] == ISO_nl || ((char*)uip_appdata)[pos-1] == ISO_cr){<br />
              if (newline == true) {<br />
                startresponsedata = true;<br />
              }<br />
              newline = true;<br />
            }<br />
            continue;<br />
          }</p>
<p>          if (newline == true) {<br />
            linenumber++;<br />
            newline = false;<br />
            linepos = 0;<br />
          }</p>
<p>          if (startresponsedata == true && linenumber == 0) {<br />
            linezero[linepos] = ((char*)uip_appdata)[pos];<br />
            linepos++;<br />
          }<br />
          if (startresponsedata == true && linenumber == 1) {<br />
            lineone[linepos] = ((char*)uip_appdata)[pos];<br />
            linepos++;<br />
          }<br />
        }</p>
<p>        if (len == 7) {<br />
          linezero[0] = '7';<br />
          memcpy(lineone, uip_appdata, len);<br />
        }</p>
<p>        Serial.print("Content length: ");<br />
        Serial.println(linezero);<br />
        Serial.print("Instances launched: ");<br />
        Serial.println(lineone);</p>
<p>        if (len > 0 && *linezero == '7') {</p>
<p>          lc.setChar(0, 0, ' ', false);<br />
          if (lineone[0] != lastlineone[0]) {<br />
            lc.setChar(0, 1, lineone[0], false);<br />
          }<br />
          if (lineone[1] != lastlineone[1]) {<br />
            lc.setChar(0, 2, lineone[1], false);<br />
          }<br />
          if (lineone[2] != lastlineone[2]) {<br />
            lc.setChar(0, 3, lineone[2], false);<br />
          }<br />
          if (lineone[3] != lastlineone[3]) {<br />
            lc.setChar(0, 4, lineone[3], false);<br />
          }<br />
          if (lineone[4] != lastlineone[4]) {<br />
            lc.setChar(0, 5, lineone[4], false);<br />
          }<br />
          if (lineone[5] != lastlineone[5]) {<br />
            lc.setChar(0, 6, lineone[5], false);<br />
          }<br />
          if (lineone[6] != lastlineone[6]) {<br />
            lc.setChar(0, 7, lineone[6], false);<br />
          }</p>
<p>          memcpy(lastlineone, lineone, sizeof(lineone));<br />
        }<br />
      }<br />
      if(uip_rexmit()) {<br />
         Serial.println("SA: rexmit");<br />
         Serial.println(requestLine);<br />
         uip_send(requestLine, strlen(requestLine));<br />
      }<br />
   }</p>
<p>   &#47;&#47; These uIP callbacks are unused for the purposes of this simple DHCP example<br />
   &#47;&#47; but they must exist.<br />
   void socket_app_init(void)<br />
   {<br />
     Serial.println("SAInit");<br />
   }</p>
<p>   void udpapp_init(void)<br />
   {<br />
     Serial.println("UDPAPPINIT:");<br />
   }</p>
<p>   void dummy_app_appcall(void)<br />
   {<br />
     Serial.println("DUMMYAPPAPPCALL");<br />
   }<br />
}</p>
<p><&#47;code></p>
