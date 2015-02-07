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
{% picture thumbnail 2010/wifi-radio/IMG_20101123_171932.jpg style="float:left;" %}

For this project, I wanted to build a device capable of displaying up to 8
digits on a seven segment display. Sounds easy, right? The catch is, I wanted
to retrieve these digits from the Internet over WiFi.

I took this opportunity to try out the ever-popular Arduino platform. Arduino
turned out to be a good choice for this project for several because it has:

- an easy to use, Arduino compatible WiFi adapter (WiShield) put out by [asynclabs](http://asynclabs.com/)
- a library available for talking to the WiShield with examples included
- a MAX7219 interface library
- an onboard USB programmer and a software programmer that works on Ubuntu

<!--more-->

This is the first electronics project I've attempted from scratch so I'm quite
pleased with the result. In fact, I'm looking for larger 7 segment digits to
build a much larger display.

I began this project by purchasing a MAX7219 display driver, an [Arduino
Uno](http://arduino.cc/en/Main/ArduinoBoardUno), 8 seven segment common cathode
LED digits, a breadboard, some jumper wires and A/B USB cable. It took me a few
hours to properly connect the displays to the display driver, but seeing the
test routine properly on the digits was satisfying enough to make it worth the
effort. One problem I ran into was in selecting the proper resistor for Rset
which sets the display brightness. After reading the datasheet, I selected a
10kΩ resistor which turned out to be wrong because the display would quickly
flicker off after a brief moment. Adding a second resistor in series seemed to
fix the problem.

Bolstered by my success in displaying hard-coded numbers, I ordered the
WiShield. It arrived a few weeks later and I dropped it right in. Getting a
simple WiFi enabled program running is as simple as cloning asynclab's WiShield
git repository, making a few modifications, and uploading one of the example
scripts. At this point, I had all the hardware I needed to make this device get
information from the Internet and display it. The final missing piece was the
software. This part took the longest, mostly because I have almost no
experience writing in C. I had the whole thing working with DHCP and DNS
resolution, but it was unstable for some reason. I ended up with the following
attrocity:

~~~ c
#include <WiShield.h>
#include <LedControl.h>
extern "C" {
   #include "uip.h"
}
#define ISO_nl       0x0a
#define ISO_cr       0x0d
// Wireless configuration parameters ----------------------------------------
unsigned char local_ip[]     = {10,10,0,91};   // IP address of WiShield
unsigned char gateway_ip[]   = {10,10,0,3};   // router or gateway IP address
unsigned char subnet_mask[]  = {255,255,255,0}; // subnet mask for the local network
char ssid[]                  = {"SOMESSID"};   // max 32 bytes
unsigned char security_type  = 3;               // 0 - open; 1 - WEP; 2 - WPA; 3 - WPA2
unsigned char  wireless_mode = 1;               // 1==Infrastructure, 2==Ad-hoc
unsigned char ssid_len;
unsigned char security_passphrase_len;
int           closedLoop     = 0;
// WPA/WPA2 passphrase
const prog_char security_passphrase[] PROGMEM = {"somewpapassphrase"};	// max 64 characters
// WEP 128-bit keys
prog_uchar wep_keys[] PROGMEM = {
   0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, // Key 0
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Key 1
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Key 2
   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // Key 3
};
// End of wireless configuration parameters ----------------------------------------
// global data
boolean connectAndSendTCP = true;
uip_ipaddr_t srvaddr;
LedControl lc=LedControl(5,6,7,1);
void setup()
{
   // Enable Serial output
   Serial.begin(57600);
   lc.shutdown(0,false);
   lc.setIntensity(0,9);
   initialize();
}
void initialize()
{
   Serial.println("Establishing WifFi Connection");
   WiFi.init();
   uip_sethostaddr(local_ip);
   uip_setdraddr(gateway_ip);
   uip_setnetmask(subnet_mask);
   delay(100);
}
unsigned long entryTimer = 12000;
void loop()
{
  if (entryTimer > 0 && entryTimer % 100 == 0) {
    Serial.println(entryTimer);
  }
  if (true == connectAndSendTCP) {
    entryTimer++;
    if ((entryTimer > 12000) && (true == connectAndSendTCP)) {
      connectAndSendTCP = false;
      entryTimer = 0;
      Serial.println("inside");
      // Address of server to connect to
      uip_ipaddr(&srvaddr, 173,203,98,126);
      uip_conn = uip_connect(&srvaddr, HTONS(80));
      if (NULL == uip_conn) {
        Serial.println("could not connect");
      }
    }
  }
  delay(10);
  WiFi.run();
}
void (*softReset) (void) = 0; //declare reset function @ address 0
extern "C" {
   void printx(char *stuff)
   {
     Serial.println(stuff);
   }
   // Process UDP UIP_APPCALL events
   void udpapp_appcall(void)
   {
      uip_dhcp_run();
   }
   // DHCP query complete callback
   void uip_dhcp_callback(const struct dhcp_state *s)
   {
   }
   char requestLine[] = "GET /some/path.txt HTTP/1.1\r\nUser-Agent: uIP/1.0\r\nHost: example.com\r\nConnection: Close\r\n\r\n";
   void socket_app_appcall(void)
   {
      struct socket_app_state *s = &(uip_conn->appstate);
      if(uip_closed() || uip_timedout()) {
         Serial.print("Closed loop: ");
         Serial.println(closedLoop);
         if (closedLoop > 2) {
           //initialize();
           softReset();
         }
         closedLoop++;
         Serial.println("SA: closed / timedout");
         connectAndSendTCP = true;
      }
      if(uip_poll()) {
      }
      if(uip_aborted()) {
        connectAndSendTCP = true;
        Serial.println("SA: aborted");
      }
      if(uip_connected()) {
         Serial.println("Sending:");
         Serial.println(requestLine);
         uip_send(requestLine, strlen(requestLine));
         closedLoop = 0;
      }
      if(uip_acked()) {
         Serial.println("SA: acked");
      }
      if(uip_newdata()) {
        Serial.println("SA: newdata");
        int len                      = uip_datalen();
        int pos                      = -1;
        int linenumber               = -1;
        int linepos                  = 0;
        boolean startresponsedata    = false;
        boolean newline              = false;
        char    emptyline[8]         = {0, 0, 0, 0, 0, 0, 0, 0};
        char    linezero[8]          = {0, 0, 0, 0, 0, 0, 0, 0};
        char    lineone[8]           = {0, 0, 0, 0, 0, 0, 0, 0};
        char    lastlineone[8]       = {0, 0, 0, 0, 0, 0, 0, 0};
        while(pos <= len){
          pos++;
          // if we have a \r followed by \n
          if (((char*)uip_appdata)[pos] == ISO_nl || ((char*)uip_appdata)[pos] == ISO_cr){
            if (((char*)uip_appdata)[pos] == ISO_nl || ((char*)uip_appdata)[pos-1] == ISO_cr){
              if (newline == true) {
                startresponsedata = true;
              }
              newline = true;
            }
            continue;
          }
          if (newline == true) {
            linenumber++;
            newline = false;
            linepos = 0;
          }
          if (startresponsedata == true && linenumber == 0) {
            linezero[linepos] = ((char*)uip_appdata)[pos];
            linepos++;
          }
          if (startresponsedata == true && linenumber == 1) {
            lineone[linepos] = ((char*)uip_appdata)[pos];
            linepos++;
          }
        }
        if (len == 7) {
          linezero[0] = '7';
          memcpy(lineone, uip_appdata, len);
        }
        Serial.print("Content length: ");
        Serial.println(linezero);
        Serial.print("Instances launched: ");
        Serial.println(lineone);
        if (len > 0 && *linezero == '7') {
          lc.setChar(0, 0, ' ', false);
          if (lineone[0] != lastlineone[0]) {
            lc.setChar(0, 1, lineone[0], false);
          }
          if (lineone[1] != lastlineone[1]) {
            lc.setChar(0, 2, lineone[1], false);
          }
          if (lineone[2] != lastlineone[2]) {
            lc.setChar(0, 3, lineone[2], false);
          }
          if (lineone[3] != lastlineone[3]) {
            lc.setChar(0, 4, lineone[3], false);
          }
          if (lineone[4] != lastlineone[4]) {
            lc.setChar(0, 5, lineone[4], false);
          }
          if (lineone[5] != lastlineone[5]) {
            lc.setChar(0, 6, lineone[5], false);
          }
          if (lineone[6] != lastlineone[6]) {
            lc.setChar(0, 7, lineone[6], false);
          }
          memcpy(lastlineone, lineone, sizeof(lineone));
        }
      }
      if(uip_rexmit()) {
         Serial.println("SA: rexmit");
         Serial.println(requestLine);
         uip_send(requestLine, strlen(requestLine));
      }
   }
   // These uIP callbacks are unused for the purposes of this simple DHCP example
   // but they must exist.
   void socket_app_init(void)
   {
     Serial.println("SAInit");
   }
   void udpapp_init(void)
   {
     Serial.println("UDPAPPINIT:");
   }
   void dummy_app_appcall(void)
   {
     Serial.println("DUMMYAPPAPPCALL");
   }
}
~~~
