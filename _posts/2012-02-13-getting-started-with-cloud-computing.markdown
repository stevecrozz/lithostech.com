---
layout: post
status: publish
published: true
title: getting started with cloud computing
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 443
wordpress_url: http://lithostech.com/?p=443
date: '2012-02-13 23:54:27 -0800'
date_gmt: '2012-02-14 07:54:27 -0800'
categories:
- Uncategorized
tags: []
comments:
- id: 49163
  author: Viviana Driskell
  author_email: Gena_Acampora@gmail.com
  author_url: ''
  date: '2012-03-18 23:15:40 -0700'
  date_gmt: '2012-03-19 06:15:40 -0700'
  content: CloudBerry Lab is excited about Google announcements. Since we want to
    offer the most cost efficient product for our customers while allowing them to
    own their storage account we are considering to add an option to backup data to
    Google online storage in addition to Amazon S3. Stay tuned!
---
I was talking to a friend (lets call him Dave) the other day. He had a
good idea on how he could run his QuickBooks accounting software in the
cloud. By running the software in the cloud, he wouldn't need to ship
QuickBooks backup files back and forth to his accountants, he could just
launch a cloud instance and let the accountants RDP into the instance
and use the software.

It sounds great, but Dave is cheap and he wanted to run this on an EC2
t1.micro and the machine just couldn't handle it. So of course he wanted
to upgrade the instance. Being the cloud computing guy that I am, he
called me up and asked me how to do it. At first, I thought it was a
silly question, and I told him that of course it is impossible to
upgrade the memory on a running EC2 instance.

<!--more-->

Looking back now, I'm starting to think his question was actually a good
one because the answer forced him to confront one fundamental reality of
cloud computing. Think about it. It's logical to think that if your
machine is low on resources, a good solution might be to add more
resources to your running instance, but that's not the way things work
in the cloud. If you can't change your application, and you can't change
the load, and one instance of your application overwhelms the resources
on your machine, then you only have one option: throw away your machine
and get a larger one.

You may have heard this kind of advice before, but let it sink in. Your
server instances are completely disposable. You should be able to
terminate every last one of them, throw them completely away, and be
ready to rock again when you launch fresh ones. This isn't a new idea,
and it isn't brain surgery, but it is hard work and that's where you
need to spend your time when you're getting started with cloud
computing.

I work at [RightScale](http://www.rightscale.com), so I may be a little
biased, but we do have a nice set of tools to get you started on this
path. Do a quick Google search for
[servertemplate](https://www.google.com/search?q=servertemplate) to see
what I mean.
