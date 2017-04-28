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
{% responsive_image path: static/img/full/2008/wifi-radio-lcd.jpg alt:
"OpenWRT wifi radio + LCD" class: "img-float-left" %} I've been inspired
by [Jeff Keyzer](http://mightyohm.com/blog/about/) to build a wifi
radio. I've wanted for a long time to build a wifi radio to play
internet radio and music from an arbitrary remote filesystem. The low
cost of the platform he chose, the WL-520gu which I picked up for $35
shipped and is now even cheaper made the barrier to entry much lower
than I had thought. So I bought one and tore out the guts as soon as it
arrived.

[mightyOhm](http://mightyohm.com/blog/2008/10/building-a-wifi-radio-part-1-introduction/)
has a good series of blog entries for doing almost exactly what I want
to do. I skipped the first bit about hooking up a terminal because I
don't have a TTL-USB device lying around and flashed the router with
[openwrt](http://openwrt.org/). As I found out, TTL is not RS-232. You
can't just connect an RS-232 cable to your PC and solder the other end
to the serial pins on your router. I do have a TTL LCD panel that I
picked up last year on eBay (I've been planning to build a device like
this for some time). [Modern Device](http://moderndevice.com/LCD.shtml)
has these 20x4 character blue LCDs with a TTL serial interface for
around $30. Jeff built his own, but he's also an electrical engineer.

<!--more-->

{% responsive_image path:
static/img/full/2008/wifi-radio-lcd-serial-connections.jpg alt: "WiFi
radio closeup serial interface" class: "img-float-right" %} I installed
mine by soldering the backlight and lcd power lines to the +5V power
source on the underside of the router's board right next to the power
input jack. The Rx and ground serial lines from the LCD I soldered right
onto the Tx and ground lines on the board. The only hitch is that the
asus board talks at 115200 baud by default, but the LCD serial board
likes to talk at 9600 baud.  To make it work, create a new file at
/etc/init.d/tts with the following contents:

~~~ bash
#!/bin/ash
/bin/stty -F /dev/tts/0 speed 9600
echo '?c0?f' > /dev/tts/0
~~~

The second line sets the proper baud rate on the serial port and the
third line has some proprietary commands for the Modern Device serial
LCD module (set invisible cursor and clear the display).

Make it executable and make it load super early in the inittab by
creating a link to rc.d like this:

~~~ bash
chmod +x /etc/init.d/tts
cd /etc/rc.d
ln -s /etc/init.d/tts S01tts
~~~

Now when you restart your router, you should be able to watch all the
boot information scroll by and finish with a login prompt.

I haven't added any audio devices to mine yet so I'm going to test the
display with a simple script to display the time and wifi signal
strength. Create script at /root/display.sh:

~~~ bash
#!/bin/ash
# simple script for displaying the time and wifi signal strength
# on /dev/tts/0
# prints something like "Sun 04:12            38dBm"
while true
do
  echo '?a' > /dev/tts/0
  date +"%a %H:%M" > /dev/tts/0
  echo '?a?i?i?i?i?i?i?i?i?i?i?i?i?i' > /dev/tts/0
  iwconfig wl0 | grep 'Link Quality' | awk '{ print $4 }' | awk -F"=" '{ print $2 }' > /dev/tts/0
  echo ' dBm' > /dev/tts/0
  echo '?x20' > /dev/tts/0
  sleep 3
done
~~~

Now lets just make an init script to run this in the background at
/etc/init.d/display:

~~~ bash
#!/bin/ash
/root/display.sh &  #don't forget that "&"
~~~

We'll load this one up at the end of inittab by linking it to rc.d like
this:

~~~ bash
chmod +x /etc/init.d/display
cd /etc/rc.d
ln -s /etc/init.d/display S99display
~~~

{% responsive_image path:
static/img/full/2008/wifi-radio-lcd-closeup.jpg alt: "WiFi radio closeup
serial interface" class: "img-float-left" %} In the [next
update]({% post_url 2009-01-08-openwrt-wifi-radio-part-2 %}), I'll describe
how I increased the storage capacity of the radio to store my music
library.
