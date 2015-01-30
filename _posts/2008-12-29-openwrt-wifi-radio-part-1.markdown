---
layout: post
status: publish
published: true
title: openwrt wifi radio part 1
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "[flickr-photo:id=3145072499,size=t]I've been inspired by <a href=\"http://mightyohm.com/blog/about/\">Jeff
  Keyzer</a> to build a wifi radio. I've wanted for a long time to build a wifi radio
  to play internet radio and music from an arbitrary remote filesystem. The low cost
  of the platform he chose, the WL-520gu which I picked up for $35 shipped and is
  now even cheaper made the barrier to entry much lower than I had thought. So I bought
  one and tore out the guts as soon as it arrived.\r\n\r\n"
wordpress_id: 64
date: '2008-12-29 00:19:40 -0800'
date_gmt: '2008-12-29 08:19:40 -0800'
categories:
- Uncategorized
tags:
- programming
- hardware
- openwrt
- wifi
comments:
- id: 6
  author: ''
  author_email: ''
  author_url: ''
  date: '2008-12-30 14:53:22 -0800'
  date_gmt: ''
  content: Wow. That's pretty kickass. When you get done with the series, I may just
    have to follow along. Wifi radio pretty much rokks my face off.
---
<p><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2009&#47;02&#47;4136613234_dc76ee0d99_o-290x217.jpg" alt="OpenWRT + LCD" width="290" height="217" class="alignleft size-medium wp-image-502" &#47;>I've been inspired by <a href="http:&#47;&#47;mightyohm.com&#47;blog&#47;about&#47;">Jeff Keyzer<&#47;a> to build a wifi radio. I've wanted for a long time to build a wifi radio to play internet radio and music from an arbitrary remote filesystem. The low cost of the platform he chose, the WL-520gu which I picked up for $35 shipped and is now even cheaper made the barrier to entry much lower than I had thought. So I bought one and tore out the guts as soon as it arrived.<&#47;p><a id="more"></a><a id="more-64"></a></p>
<p><a href="http:&#47;&#47;mightyohm.com&#47;blog&#47;2008&#47;10&#47;building-a-wifi-radio-part-1-introduction&#47;">mightyOhm<&#47;a> has a good series of blog entries for doing almost exactly what I want to do. I skipped the first bit about hooking up a terminal because I don't have a TTL-USB device lying around and flashed the router with <a href="http:&#47;&#47;openwrt.org&#47;">openwrt<&#47;a>. As I found out, TTL is not RS-232. You can't just connect an RS-232 cable to your PC and solder the other end to the serial pins on your router.<&#47;p></p>
<p>I do have a TTL LCD panel that I picked up last year on eBay (I've been planning to build a device like this for some time). <a href="http:&#47;&#47;moderndevice.com&#47;LCD.shtml">Modern Device<&#47;a>  has these 20x4 character blue LCDs with a TTL serial interface for around $30. Jeff built his own, but he's also an electrical engineer.<&#47;p></p>
<p><a href="http:&#47;&#47;www.flickr.com&#47;photos&#47;40909356@N00&#47;3145074191"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2008&#47;12&#47;4136613234_dc76ee0d99_o-290x217.jpg" alt="OpenWRT + LCD Close-up" width="290" height="217" class="alignleft size-medium wp-image-515" &#47;><&#47;a>I installed mine by soldering the backlight and lcd power lines to the +5V power source on the underside of the router's board right next to the power input jack. The Rx and ground serial lines from the LCD I soldered right onto the Tx and ground lines on the board. The only hitch is that the asus board talks at 115200 baud by default, but the LCD serial board likes to talk at 9600 baud.<&#47;p></p>
<p>To make it work, create a new file at &#47;etc&#47;init.d&#47;tts with the following contents:<&#47;p></p>
<pre>
#!&#47;bin&#47;ash<br />
&#47;bin&#47;stty -F &#47;dev&#47;tts&#47;0 speed 9600<br />
echo '?c0?f' > &#47;dev&#47;tts&#47;0<br />
<&#47;pre></p>
<p>The second line sets the proper baud rate on the serial port and the third line has some proprietary commands for the Modern Device serial LCD module (set invisible cursor and clear the display).<&#47;p></p>
<p>Make it executable and make it load super early in the inittab by creating a link to rc.d like this:<&#47;p></p>
<pre>
chmod +x &#47;etc&#47;init.d&#47;tts<br />
cd &#47;etc&#47;rc.d<br />
ln -s &#47;etc&#47;init.d&#47;tts S01tts<br />
<&#47;pre></p>
<p>Now when you restart your router, you should be able to watch all the boot information scroll by and finish with a login prompt.<&#47;p></p>
<p>I haven't added any audio devices to mine yet so I'm going to test the display with a simple script to display the time and wifi signal strength. Create script at &#47;root&#47;display.sh:<&#47;p></p>
<pre>
#!&#47;bin&#47;ash</p>
<p># simple script for displaying the time and wifi signal strength<br />
# on &#47;dev&#47;tts&#47;0<br />
# prints something like "Sun 04:12            38dBm"</p>
<p>while true<br />
do<br />
  echo '?a' > &#47;dev&#47;tts&#47;0<br />
  date +"%a %H:%M" > &#47;dev&#47;tts&#47;0<br />
  echo '?a?i?i?i?i?i?i?i?i?i?i?i?i?i' > &#47;dev&#47;tts&#47;0<br />
  iwconfig wl0 | grep 'Link Quality' | awk '{ print $4 }' | awk -F"=" '{ print $2 }' > &#47;dev&#47;tts&#47;0<br />
  echo ' dBm' > &#47;dev&#47;tts&#47;0<br />
  echo '?x20' > &#47;dev&#47;tts&#47;0<br />
  sleep 3<br />
done<br />
<&#47;pre></p>
<p>Now lets just make an init script to run this in the background at &#47;etc&#47;init.d&#47;display:<&#47;p></p>
<pre>
#!&#47;bin&#47;ash</p>
<p>&#47;root&#47;display.sh &  #don't forget that "&"<br />
<&#47;pre></p>
<p>We'll load this one up at the end of inittab by linking it to rc.d like this:<&#47;p></p>
<pre>
chmod +x &#47;etc&#47;init.d&#47;display<br />
cd &#47;etc&#47;rc.d<br />
ln -s &#47;etc&#47;init.d&#47;display S99display<br />
<&#47;pre></p>
<p><a href="http:&#47;&#47;www.flickr.com&#47;photos&#47;40909356@N00&#47;3145905414"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2008&#47;12&#47;4136613234_dc76ee0d99_o1-290x217.jpg" alt="OpenWRT + LCD Display Text" width="290" height="217" class="alignleft size-medium wp-image-516" &#47;><&#47;a>This entry will likely be part of an ongoing saga to create a great wifi radio. Many thanks to Jeff for the inspiration to actually get started and a great writeup of his own wifi radio. Thanks to Asus for making this easy, and for building a wifi router with usb and enough flash memory to load custom firmware. Thanks to the openwrt guys too.<&#47;p></p>
<p>In the <a href="http:&#47;&#47;lithostech.com&#47;openwrt-wifi-radio-part-2">next update<&#47;a>, I'll describe how I increased the storage capacity of the radio to store my music library.<&#47;p></p>
