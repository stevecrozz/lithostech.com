---
layout: post
status: publish
published: true
title: migrating a movable type system, the replication way
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 67
date: '2009-02-03 06:11:43 -0800'
date_gmt: '2009-02-03 14:11:43 -0800'
categories:
- Uncategorized
tags:
- network adminstration
- migration
- blog
- movable type
- replication
comments: []
---
{% responsive_image path: static/img/full/2009/movable-type.jpg alt:
"movable type close up" class: "img-float-left" %} Lately, I've been in
the business of migrating between hosting providers. We're moving away
from the classic web host CentOS. The reason that CentOS became the web
host OS of choice in the middle of the decade still eludes. I just
imagine a some RHEL fan club being told to implement a linux web host
solution with no budget and CentOS was the fruit of that effort. Our new
host is of the new ultra-trendy VPS type.  We chose slicehost on some
recommendations from friends.  I host my own blog and some other stuff
on a VPS at vpslink.com. I fired it up with Intrepid Ibex (of course)
and started migrating stuff over the Ubuntu way.

That's all well and good, but the reason I'm writing this is because I
found a great way to move our largest system which is a family of blogs
related to fresnobeehive.com. We'd been using movable type to publish
blogs since version 2.x, and the new systems are running 4.x. Back then,
the only publishing option was to physically build every page for the
entire system ahead of time. That system works great when you have only
a few hundred entries, but when you start getting into the 10s of
thousands of entries, static publishing begins to break down a little.
It takes most of a day to publish the entire site if you make a global
template change. Combine this with the fact that we're attempting to
redesign the blogs during the move, and we've got a lot to juggle.

<!--more-->

So what's the best way to build movable type templates on a running
system so we can be sure to account for changing content during a
migration? The answer is through database replication. I set the old
server that lives on westhost do be a master replication server which
basically just means that it will log transactions in a binary log file
somewhere on the filesystem so another server(s) can read it and stay in
sync with the master. I set up the new VPS at slicehost to be a slave
and replication started flowing like magic. Watching database
replication work for the first time was actually much more fun than I
thought it would be. The only real problem with this solution is that if
you make changes to the slave, then the system is likely to fault when
the master makes related changes. But with movable type, all the changes
I want to make are template related. I then supplied a list of tables
that I want the slave to ignore with "replicate-ignore-table"
directives.

What did I gain out of this? I have two separate movable type
installations that live in different physical locations somewhere out in
the internet. They both share all the same live content, but they do not
share the same templates. I can independently change the tables on both
instances without affecting the other. This simply means that our
designer can log on to the new one and template to his heart's content
and watch the templates go live on the new system without affecting the
existing system. This makes for a much more convenient and testable
working environment than we're used to. When it comes time to make the
switch and the new templates are ready, all I have to do is make the DNS
switch and replication will likely just fail silently. Now that we've
switched to dynamic page building, there's really no reason to have any
down-time at all. Nothing needs to be archived and frozen in time, just
backed up securely. Next time we do a major redesign, I'll consider
doing this same thing even if we don't have a server migration.
