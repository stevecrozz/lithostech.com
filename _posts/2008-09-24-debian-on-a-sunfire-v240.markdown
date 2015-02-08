---
layout: post
status: publish
published: true
title: debian on a sunfire v240
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "[flickr-photo:id=44648845,size=t]Recently I inherited a Sun Microsystems
  SunFire v240. This thing burns hot and loud (hence the name), quite a lot of fun.
  After plugging in a console cable and booting up the system, I was met with a very
  nice surprise on specs.\r\n\r\n<code>\r\nSun Fire V240, No Keyboard\r\nCopyright
  2007 Sun Microsystems, Inc.  All rights reserved.\r\nOpenBoot 4.22.33, 8192 MB memory
  installed, Serial #58631225.\r\nEthernet address 0:3:ba:7e:a4:39, Host ID: 837ea439.\r\n</code>\r\n\r\n"
wordpress_id: 52
date: '2008-09-24 20:53:07 -0700'
date_gmt: '2008-09-25 04:53:07 -0700'
categories:
- Uncategorized
tags:
- linux
- debian
comments: []
---
<p><a href="http://www.flickr.com/photos/rbitting/2941671464"><img src="http://lithostech.com/wp-content/uploads/2008/09/4136613234_dc76ee0d99_o2-290x217.jpg" alt="SunFires" width="290" height="217" class="alignleft size-medium wp-image-539" /></a>Recently I inherited a Sun Microsystems SunFire v240. This thing burns hot and loud (hence the name), quite a lot of fun. After plugging in a console cable and booting up the system, I was met with a very nice surprise on specs.</p></p>
<pre>
Sun Fire V240, No Keyboard<br />
Copyright 2007 Sun Microsystems, Inc.  All rights reserved.<br />
OpenBoot 4.22.33, 8192 MB memory installed, Serial #58631225.<br />
Ethernet address 0:3:ba:7e:a4:39, Host ID: 837ea439.<br />
</pre><a id="more"></a><a id="more-52"></a></p>
<p>Pretty well-specced-out for a hand-me-down. Unfortunately, I don't know the first thing about working with SunOS. It took me a while to even get the network up. Apparently, the network interface must be "plumbed" before it will work. I'm sure Sun makes a great operating system, but I didn't want to waste my time learning how to use it. My first thought, of course, was to install Ubuntu, but it looks like Ubuntu dropped support for Sparc somewhere around Gutsy Gibbon. Debian on the other hand, still fully supports Sparc and UltraSparc 64. Looks like I found a match.</p></p>
<p>After logging in, I hit "init 0" to drop down to standby mode and got the ok> prompt. My options for booting were limited to CD-ROM and network, but actually just network because this SunFire wasn't equipped with a CD-ROM drive. It took me a while to read through relevant documentation. Most of the instructions that I'd found required me to set up a DHCP or BOOTP server, RARP services, a TFTP server, and then use a magical filename for a boot image. I tried that for a while, but had no luck.</p></p>
<p>Then I found <a href="https://help.ubuntu.com/community/Installation/Sparc">these instructions</a> for installing Ubuntu for Sparc from the <a href="https://help.ubuntu.com/community/">Ubuntu community documentation site</a>. The instructions mentioned an OBP related firmware update that would allow me to specify arguments to the network boot script. That way, I could just tell it where to grab the boot image.</p></p>
<p>First I downloaded the <a href="http://sunsolve.sun.com/search/document.do?assetkey=1-21-121683-06-1">latest firmware</a> from Sun to my desktop, then I logged onto the SunFire and used SCP to transfer the zip file from my desktop to the SunFire. I unzipped it to / and headed back to standby mode. Then I entered "boot disk /flash-update-SunFire240" (the path to the firmware update) and when the machine rebooted, I was able to specify the additional arguments to boot net.</p></p>
<p>Supposedly this would work over plain http, but I already had the <a href="http://www.debian.org/ports/sparc/">boot image</a> ready to go on a TFTP server. Entering these lines from standby mode allowed me to boot the debian "net Install" image which weighs in at just over 8MiB.</p></p>
<pre>
ok> setenv network-boot-arguments host-ip=<<MY_IP>>,router-ip=<<MY_ROUTER>>,subnet=mask=<br />
<<MY_SUBNET>>,hostname=<<MY_HOSTNAME>>,file=tftp://<<TFTP_ADDRESS>>/boot.img</p>
<p>ok> boot net debconf/priority=low DEBIAN_FRONTEND=text<br />
</pre></p>
<p>As <a href="http://www.pbandjelly.org/2007/12/debian-on-sunfire-v120/">pointed out by michael</a> at pbandjelly.org while working on his SunFire v120, the network adapters are mislabeled by Debian during the install process. My 4 broadcom network adapters are labelled 0, 1, 2, and 3; the one mapped to eth0 by the installer is actually the one marked '2' on the back of my machine.</p></p>
<p>The only other major issue I ran into was this scary little SILO error which had me worried that I'd just wasted two hours on a botched install.</p></p>
<pre>
Rebooting with command: boot<br />
Boot device: disk  File and args:<br />
SILO Version 1.4.13<br />
boot:<br />
Allocated 8 Megs of memory at 0x40000000 for kernel<br />
Uncompressing image...<br />
Loaded kernel version 2.6.18<br />
Loading initial ramdisk (5266517 bytes at 0x127F802000 phys, 0x40C00000 virt)...<br />
ERROR: Last Trap: Illegal Instruction</p>
<p>{1} ok<br />
</pre></p>
<p>This <a href="https://bugs.launchpad.net/ubuntu/hoary/+source/silo/+bug/40119">bug report</a> reassured me slightly, so I restarted the SunFire using the power switch, and there it was in all its etchy glory!</p></p>
<pre>
Debian GNU/Linux 4.0 nipponensis ttyS0</p>
<p>nipponensis login:<br />
</pre></p>
