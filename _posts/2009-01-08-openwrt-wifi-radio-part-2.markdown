---
layout: post
status: publish
published: true
title: openwrt wifi radio part 2
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 65
date: '2009-01-08 18:56:00 -0800'
date_gmt: '2009-01-09 02:56:00 -0800'
categories:
- Uncategorized
tags:
- programming
- hardware
- openwrt
- wifi
comments:
- id: 11
  author: ''
  author_email: ''
  author_url: ''
  date: '2009-07-23 23:46:49 -0700'
  date_gmt: ''
  content: "Thanks, at last that has found that wished to read here. By the way, I
    have drawings on this theme.B&uuml;ro mobilyalari , Where it is possible to throw
    off? <a href=\"http://www.buromobilyafirmalari.com/\" title=\"buro
    mobilyalari\">buro mobilyalari</a>\r\n"
- id: 12
  author: ''
  author_email: ''
  author_url: ''
  date: '2009-07-26 18:49:26 -0700'
  date_gmt: ''
  content: I was wondering if you plan on adding any sort of physical input control
    to skip songs or playlists for you project since right now it looks like your
    serial on the asus is tied up with the lcd.
- id: 13
  author: ''
  author_email: ''
  author_url: ''
  date: '2009-08-01 19:24:42 -0700'
  date_gmt: ''
  content: I would like to add some inputs for switching tracks and such. [sparkfun.com](http://www.sparkfun.com)
    has some cool button pad sets, but I'd need to build the TTL serial interface
    for it. Anybody know of a ready-made component that does this? Thankfully, since
    serial communication uses 2 lines for communication, I'm able to run the display
    using only the Tx line from the mainboard. The Rx line is currently disconnected
    and could be used to receive user input even with the LCD connected.
- id: 2496
  author: Nate
  author_email: minnick@gmail.com
  author_url: ''
  date: '2010-09-14 16:31:36 -0700'
  date_gmt: '2010-09-14 23:31:36 -0700'
  content: "Could you go through specifically how you did this?  For those new to
    openwrt?\r\n\r\n\"I installed both of those packages and began setting up shared
    key authentication\"\r\n\r\nYou mean dropbear and dropbearkey?  Or the shfs?"
- id: 2661
  author: stevecrozz
  author_email: stevecrozz@gmail.com
  author_url: ''
  date: '2010-09-21 18:08:04 -0700'
  date_gmt: '2010-09-22 01:08:04 -0700'
  content: It's been a while, but I think I meant shfs and shfs-tools. openwrt has
    a ncurses type builder that allows you to select which packages get built.
---
{%
  responsive_image
    path: static/img/full/2009/usb-sound-card.jpg
    alt: "3D sound USB sound card"
    class: "img-float-left"
%} In [part 1](http://lithostech.com/openwrt-wifi-radio-part-1) of this
series, I took an Asus router and loaded openwrt onto it. I added an LCD
display and connected it to the serial port on the router board.  At
this point, I have a low-power, small form factor computer that I can
customize to my heart's content. As far as I/O, the computer still has
its original wifi antenna, 5 wired LAN interfaces, a serial port and a
USB port. My USB sound adapter still hasn't arrived from Hong Kong, so
I'm going to work on another piece of the puzzle.

{%
  responsive_image
    path: static/img/full/2009/buffalo-linkstation.jpg
    alt: "Buffalo LinkStation Duo"
    class: "img-float-left"
%} The first thing I did after joining this device to my wifi network
was telnet in and change my password. Now the project that I've been
following up to this point is mainly to be used for playing internet
radio stations as I understand it. My wifi radio is going to be used for
that too, but also for playing selections from my own music library. I
plan to get one of these Buffalo 1TB Linkstation NAS devices and put all
my media on it and leave it down in the basement. I've read that you can
really customize these devices, but all I need to do is add an ssh
server to it. Then I can mount the whole filesystem to a folder on my
wifi radio and have access to a full terabyte of storage space.

<!--more-->

For now, I only have my laptop, which has all my music in my home folder
so I'll set it up to connect to my laptop for now (setup should be
identical to a nas running an ssh daemon). The openwrt firmware that I
used from mightyohm had dropbear and dropbearkey already installed, but
not shfs and shfs-tools. I installed both of those packages and began
setting up shared key authentication (the device should be able to map
this filesystem automatically without entering a password). If you're
following along, then you'll need to create your own public/private
keypair with dropbearkey:

~~~ bash
root@OpenWrt:~# dropbearkey -t rsa -f /root/.ssh/id_rsa -s 1024 =y /root/.ssh/id_rsa.pub
~~~

If everything goes well, you should have two new files in /root/.ssh/.
Open up id_rsa.pub and delete the fingerprint (the one line with a bunch
of colons), you won't need it. Even though I'm not super concerned about
security for this application, it's always good practice to ensure that
only root has access to read the private key file. Now I'm going to
connect as myself to my own music directory because this is temporary.
When I set this up with the Linkstation down the road, I'll create a
user specifically for the wifi radio and grant it group read access to
all the media, but not write access because why would it need write
access? For now, I'll be using my own username because all the music is
in my own home directory on my laptop and I'm only testing it right now
anyway.

I copied my new public key from the wifi radio into
/home/stevecrozz/.ssh/authorized_keys on my laptop and tested the
connection with the ssh client on the wifi radio. If you're still
following along, you shouldn't have to enter a password. If you do, then
it's not working. Now comes the really cool part, I used a package from
shfs-tools to mount the remote filesystem over ssh. This part took me a
few tries to get it just how I wanted:

~~~ bash
root@OpenWrt:~# shfsmount --persistent \
  --cmd="ssh -i /root/.ssh/id_rsa %u@%h /bin/bash" \
  stevecrozz@10.10.0.100:/home/stevecrozz/Music /root/music
~~~

It takes a few seconds to finish, but now we have a whole lot of storage
space available plus a bunch of music. Try this:

~~~ bash
root@OpenWrt:~# du -hs /root/music
23.5G	music
~~~

That sure beats the hell out of the other stuff I've seen people doing
to increase storage space on these things. Now we can create a music
database for mpd.

~~~ bash
root@OpenWrt:~# mpd --create-db --stdout
~~~

If you have a lot of music, you might as well just go to bed at this
point. Mine seemed to be adding about two songs per second to the
database. When that's all done, you can connect to it from anywhere with
client software of your choosing. I found 'Gnome Music Player Client'
works well. I opened it up and viola, all my music was there. I tried to
play a file and got the message:

MPD Reported the following error: 'Problems opening the audio device'

Which makes sense, because my radio doesn't have an audio device yet.
I'm still waiting for it to come in. I can't wait to start playing with
the audio output.
