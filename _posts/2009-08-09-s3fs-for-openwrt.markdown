---
layout: post
status: publish
published: true
title: s3fs for openwrt
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "If you've been following along with my wifi radio posts, you may recall
  my problem of storage for the platform. I chose an ultra-low power and nearly zero
  storage device for my music collection because I planned to buy an external storage
  device and serve music from that device. I still think that's a good idea, but I'm
  too cheap to spring for the kind of device I really want. So I've been experimenting
  with cloud storage which has a number of big advantages which I won't get into here.\r\n\r\n"
wordpress_id: 79
date: '2009-08-09 20:53:23 -0700'
date_gmt: '2009-08-10 04:53:23 -0700'
categories:
- Uncategorized
tags:
- linux
- openwrt
- wifi
- cloud computing
comments:
- id: 46359
  author: Jurijs
  author_email: jurijst@gmail.com
  author_url: ''
  date: '2012-02-10 13:38:16 -0800'
  date_gmt: '2012-02-10 21:38:16 -0800'
  content: 'Could you please send Makefile to me, because this post don''t have one:
    s3fs for openwrt.'
- id: 46461
  author: stevecrozz
  author_email: stevecrozz@gmail.com
  author_url: ''
  date: '2012-02-11 17:08:15 -0800'
  date_gmt: '2012-02-12 01:08:15 -0800'
  content: It looks like I forgot to copy over some files when I migrated from Drupal
    to Wordpress back in 2010. I looked through some old backups and they just don't
    go back far enough. I guess it is lost.
- id: 47101
  author: mhpetiwala
  author_email: mhpetiwala@gmail.com
  author_url: ''
  date: '2012-02-20 12:58:31 -0800'
  date_gmt: '2012-02-20 20:58:31 -0800'
  content: Hi Steve - did you do any work on this project since the last update. I'm
    trying to implement something similar using s3fs over openwrt&#47;embedded linux
    board (beagleboard) any pointers on whether you were able to get this type of
    a setup to work. I'm also trying to extend it on the LAN side (of my natted gw)
    using Samba or something&#47;upnp that abstracts the remote file storage and makes
    it look like a simple folder from the client PC perspective...
- id: 47102
  author: stevecrozz
  author_email: stevecrozz@gmail.com
  author_url: ''
  date: '2012-02-20 13:09:32 -0800'
  date_gmt: '2012-02-20 21:09:32 -0800'
  content: |-
    I never was able to make this work with s3fs because the wireless card on my router did not have linux kernel 2.6 drivers at the time and I could not build s3fs without fuse which required kernel 2.6. I ended up running the system with plain NFS and that worked out, but it's not as cool as cloud storage. I would have liked to continue building a nicer interface and project enclosure, but I've lost interest in the project at this point.

    Let me know if you get any farther. I'd love to see what you can come up with.
- id: 47332
  author: mhpetiwala
  author_email: mhpetiwala@gmail.com
  author_url: ''
  date: '2012-02-23 10:46:52 -0800'
  date_gmt: '2012-02-23 18:46:52 -0800'
  content: "Hi Steve - so i was able to finally build fuse and get it working (at
    least the examples in the folder) on my embedded system. \r\n\r\nCan you provide
    me with the next steps - any specific dependencies i need to be aware of for building
    s3fs on my box? would like to get it build and working as the next step any help
    appreciated."
- id: 47335
  author: stevecrozz
  author_email: stevecrozz@gmail.com
  author_url: http://lithostech.com
  date: '2012-02-23 11:35:42 -0800'
  date_gmt: '2012-02-23 19:35:42 -0800'
  content: 'Sure, the main dependencies at the time I wrote this were: libcurl, libfuse,
    libxml2, uclibcxx, libpthread, libssl, libcrypto, and libz. Make sure you''ve
    got those libraries available and s3fs should be pretty easy to build. I''ll email
    you and see if I can be of any help. Maybe we can come up with a new Makefile
    that I can attach to this post since I lost my old one.'
- id: 47585
  author: mhpetiwala
  author_email: mhpetiwala@gmail.com
  author_url: ''
  date: '2012-02-27 08:27:35 -0800'
  date_gmt: '2012-02-27 16:27:35 -0800'
  content: "Hi Steve - i was able to build s3fs (finally) but not sure if there's
    some issue... I had to disable ssl when building curl etc as it was running into
    issues.\r\n\r\nIs there a specific order i need to build these libs in. ie build
    libz, then libxml2, etc... i've the standard thread, uclibcxx, etc as part of
    the toolchain.\r\n\r\nbut need the specific ones. you mentioned above."
- id: 47587
  author: stevecrozz
  author_email: stevecrozz@gmail.com
  author_url: ''
  date: '2012-02-27 09:09:28 -0800'
  date_gmt: '2012-02-27 17:09:28 -0800'
  content: 'I don''t remember having any issues building the dependent libraries.
    I was using the OpenWRT ncurses interface: make menuconfig. I just checked the
    boxes next to each library. Is that what you''re doing?'
- id: 48738
  author: MrR
  author_email: 35597@deadaddress.com
  author_url: http://na
  date: '2012-03-13 07:01:48 -0700'
  date_gmt: '2012-03-13 14:01:48 -0700'
  content: "Jurijs got it working on openwrt backfire\r\nif you interested pm on openwrt
    forum search s3fs"
---
<p>If you've been following along with my wifi radio posts, you may recall my problem of storage for the platform. I chose an ultra-low power and nearly zero storage device for my music collection because I planned to buy an external storage device and serve music from that device. I still think that's a good idea, but I'm too cheap to spring for the kind of device I really want. So I've been experimenting with cloud storage which has a number of big advantages which I won't get into here.<&#47;p><br />
<a id="more"></a><a id="more-79"></a></p>
<p>So I spent some time figuring out how to cross-compile s3fs properly for the openwrt platform. I was hoping my next post would be a success story of running mpd with an s3fs back end storage system, but I've run into trouble. s3fs relies on fuse 2.6 which has dropped support for Linux 2.4 kernels. But the drivers for my broadcom (integrated) wifi are binary-only and not compatible with Linux 2.6 kernels and no other working drivers exist.<&#47;p></p>
<p>I've just placed an order for a new device, an Asus WL-500g Premium which has basically the same broadcom wifi hardware, but in the form of a mini-PCI card. So in theory it could be swapped with an Atheros wifi card and I'd be good to go. In the mean time, I'll leave you with the Makefile which does compile and run. You'll need libcurl, libfuse, libxml2, uclibcxx, libpthread, libssl, libcrypto, and libz. My goal is to play music over wifi with an s3 backend on a low-cost embedded device <100USD. This is an open challenge for anyone to beat me to it.<&#47;p></p>
<p>Special thanks to Bartman007 from #openwrt-devel on freenode who helped me test this Makefile and cleaned up the code for me.<&#47;p></p>
