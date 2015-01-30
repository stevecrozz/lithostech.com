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
excerpt: "[flickr-photo:id=3019931749,size=t]In <a href=\"http://lithostech.com/openwrt-wifi-radio-part-1\">part
  1</a> of this series, I took an Asus router and loaded openwrt onto it. I added
  an LCD display and connected it to the serial port on the router board. At this
  point, I have a low-power, small form factor computer that I can customize to my
  heart's content. As far as I/O, the computer still has its original wifi antenna,
  5 wired LAN interfaces, a serial port and a USB port. My USB sound adapter still
  hasn't arrived from Hong Kong, so I'm going to work on another piece of the puzzle.\r\n\r\n"
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
    off? <a href=\"http:&#47;&#47;www.buromobilyafirmalari.com&#47;\" title=\"buro
    mobilyalari\">buro mobilyalari<&#47;a>\r\n"
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
  content: I would like to add some inputs for switching tracks and such. <a href="http:&#47;&#47;www.sparkfun.com">sparkfun.com<&#47;a>
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
<p><a href="http:&#47;&#47;www.flickr.com&#47;photos&#47;yohanes&#47;5404020984"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2009&#47;01&#47;4136613234_dc76ee0d99_o-290x193.jpg" alt="USB Sound Adapter" width="290" height="193" class="alignleft size-medium wp-image-512" &#47;><&#47;a>In <a href="http:&#47;&#47;lithostech.com&#47;openwrt-wifi-radio-part-1">part 1<&#47;a> of this series, I took an Asus router and loaded openwrt onto it. I added an LCD display and connected it to the serial port on the router board. At this point, I have a low-power, small form factor computer that I can customize to my heart's content. As far as I&#47;O, the computer still has its original wifi antenna, 5 wired LAN interfaces, a serial port and a USB port. My USB sound adapter still hasn't arrived from Hong Kong, so I'm going to work on another piece of the puzzle.<&#47;p><a id="more"></a><a id="more-65"></a></p>
<p><a href="http:&#47;&#47;www.flickr.com&#47;photos&#47;auxo&#47;4767148138"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2009&#47;01&#47;4136613234_dc76ee0d99_o1-290x193.jpg" alt="Buffalo LinkStation" width="290" height="193" class="alignleft size-medium wp-image-513" &#47;><&#47;a>The first thing I did after joining this device to my wifi network was telnet in and change my password. Now the project that I've been following up to this point is mainly to be used for playing internet radio stations as I understand it. My wifi radio is going to be used for that too, but also for playing selections from my own music library. I plan to get one of these Buffalo 1TB Linkstation NAS devices and put all my media on it and leave it down in the basement. I've read that you can really customize these devices, but all I need to do is add an ssh server to it. Then I can mount the whole filesystem to a folder on my wifi radio and have access to a full terabyte of storage space.<&#47;p></p>
<p>For now, I only have my laptop, which has all my music in my home folder so I'll set it up to connect to my laptop for now (setup should be identical to a nas running an ssh daemon). The openwrt firmware that I used from mightyohm had dropbear and dropbearkey already installed, but not shfs and shfs-tools. I installed both of those packages and began setting up shared key authentication (the device should be able to map this filesystem automatically without entering a password). If you're following along, then you'll need to create your own public&#47;private keypair with dropbearkey:<&#47;p></p>
<pre>
root@OpenWrt:~# dropbearkey -t rsa -f &#47;root&#47;.ssh&#47;id_rsa -s 1024 =y &#47;root&#47;.ssh&#47;id_rsa.pub<br />
<&#47;pre></p>
<p>If everything goes well, you should have two new files in &#47;root&#47;.ssh&#47;. Open up id_rsa.pub and delete the fingerprint (the one line with a bunch of colons), you won't need it. Even though I'm not super concerned about security for this application, it's always good practice to ensure that only root has access to read the private key file. Now I'm going to connect as myself to my own music directory because this is temporary. When I set this up with the Linkstation down the road, I'll create a user specifically for the wifi radio and grant it group read access to all the media, but not write access because why would it need write access? For now, I'll be using my own username because all the music is in my own home directory on my laptop and I'm only testing it right now anyway.<&#47;p></p>
<p>I copied my new public key from the wifi radio into &#47;home&#47;stevecrozz&#47;.ssh&#47;authorized_keys on my laptop and tested the connection with the ssh client on the wifi radio. If you're still following along, you shouldn't have to enter a password. If you do, then it's not working. Now comes the really cool part, I used a package from shfs-tools to mount the remote filesystem over ssh. This part took me a few tries to get it just how I wanted:<&#47;p></p>
<pre>
root@OpenWrt:~# shfsmount --persistent \<br />
  --cmd="ssh -i &#47;root&#47;.ssh&#47;id_rsa %u@%h &#47;bin&#47;bash" \<br />
  stevecrozz@10.10.0.100:&#47;home&#47;stevecrozz&#47;Music &#47;root&#47;music<br />
<&#47;pre></p>
<p>It takes a few seconds to finish, but now we have a whole lot of storage space available plus a bunch of music. Try this:<&#47;p></p>
<pre>
root@OpenWrt:~# du -hs &#47;root&#47;music<br />
23.5G	music<br />
<&#47;pre></p>
<p>That sure beats the hell out of the other stuff I've seen people doing to increase storage space on these things. Now we can create a music database for mpd.<&#47;p></p>
<pre>
root@OpenWrt:~# mpd --create-db --stdout<br />
<&#47;pre></p>
<p>If you have a lot of music, you might as well just go to bed at this point. Mine seemed to be adding about two songs per second to the database. When that's all done, you can connect to it from anywhere with client software of your choosing. I found 'Gnome Music Player Client' works well. I opened it up and viola, all my music was there. I tried to play a file and got the message:<br />
MPD Reported the following error: 'Problems opening the audio device'<&#47;p></p>
<p>Which makes sense, because my radio doesn't have an audio device yet. I'm still waiting for it to come in. I can't wait to start playing with the audio output.<&#47;p></p>
