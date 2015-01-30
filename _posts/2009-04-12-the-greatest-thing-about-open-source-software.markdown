---
layout: post
status: publish
published: true
title: the greatest thing about open source software
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "Most people who even know the term, think of open source software as software
  you don't have to pay for. I'd like to use my tiny blog as a platform to help eliminate
  that limited and even incorrect view. I think the best way to explain the reality
  of open source is to give an example of what makes it different from other types
  of software.\r\n\r\n"
wordpress_id: 74
date: '2009-04-12 05:27:08 -0700'
date_gmt: '2009-04-12 13:27:08 -0700'
categories:
- Uncategorized
tags:
- programming
- software
- open source
comments: []
---
<p>Most people who even know the term, think of open source software as software you don't have to pay for. I'd like to use my tiny blog as a platform to help eliminate that limited and even incorrect view. I think the best way to explain the reality of open source is to give an example of what makes it different from other types of software.<&#47;p><br />
<a id="more"></a><a id="more-74"></a></p>
<p>If you've been reading my entries lately, you'll see that I've been working on a MIPS-based network router turned music player. The hardware runs an operating system called <a href="openwrt.org">OpenWrt<&#47;a> which is a very lightweight linux distribution. I installed it and was able to turn my router+usb sound device into a dedicated music player.<&#47;p></p>
<p>As I was playing music from my library, I noticed the device wasn't able to play <a href="http:&#47;&#47;flac.sourceforge.net&#47;">FLAC<&#47;a> encoded sound files which is my preferred lossless audio file format. If instead of OpenWrt and <a href="http:&#47;&#47;mpd.wikia.com&#47;">MPD<&#47;a> (music player daemon), I had decided to use a closed source system, the best possible scenario would be to hope to find a plugin or at least be allowed to write one. That's a lot of work and in many cases isn't even possible. Next best would be to ask the authors to add support in the future. That's almost a guaranteed dead end unless you're bankrolling their operation. If you have a closed source device like an iPod, you're completely and utterly out of luck.<&#47;p></p>
<p>If, on the other hand, you're working with an open source project, you have a world of options. Often, you can file a feature request or a bug report with the authors of the project. If the authors agree to add the feature or fix the bug, then you're all set. If they don't, you can "post a bounty", which means you'll pay someone else to do the work. If you have the skills yourself, you can just jump right in and make the fix. The authors of the project will have to accept your code, but even if they don't, you can move forward with your plans anyway by creating a project fork. Imagine telling Microsoft that you're not happy with the direction of their Zune firmware and you'd like to submit a one-line patch or even fork their entire project codebase. It sounds incredible, but this is the power and freedom you have with open source software.<&#47;p></p>
<p>Back to my example. I  <a href="https:&#47;&#47;dev.openwrt.org&#47;ticket&#47;4927">filed an issue<&#47;a> with OpenWrt development, then decided to try to tackle the patch myself. The result is a <a href="https:&#47;&#47;dev.openwrt.org&#47;attachment&#47;ticket&#47;4927&#47;kamikaze-mpd-makefile-patch">working patch<&#47;a>. I'm happily listening to Sigur R&oacute;s encoded FLAC audio as I write.<&#47;p></p>
