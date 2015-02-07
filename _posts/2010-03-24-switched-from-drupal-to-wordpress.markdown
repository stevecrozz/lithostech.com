---
layout: post
status: publish
published: true
title: switched from drupal to wordpress
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 241
wordpress_url: http://lithostech.com/?p=241
date: '2010-03-24 12:27:47 -0700'
date_gmt: '2010-03-24 19:27:47 -0700'
categories:
- Uncategorized
tags:
- movable type
- drupal
- wordpress
- cms
comments:
- id: 52
  author: Jason Melgoza
  author_email: jasonmelgoza@fake.twitter.com
  author_url: http://twitter.com/jasonmelgoza
  date: '2010-03-24 15:22:44 -0700'
  date_gmt: '2010-03-24 22:22:44 -0700'
  content: Great post!
---
I'm not sure if anyone noticed this, but
[lithostech.com](http://lithostech.com) is using a drastically different
theme. It's just a canned theme like the old one because I'm not a
designer and also can't afford one. That's not the only difference
though. I've also switched from Drupal to Wordpress. Mainly, I made the
switch because we're considering moving to Wordpress from Movable Type
at work and I wanted to get a feel for how it works.

<!--more-->

### Drupal vs Wordpress
Drupal is a much more abstract system, useful for a million things,
whereas Wordpress is decidedly a *blogging* platform. Drupal provides a
lot more functionality out of the box like caching, css and javascript
aggregation/minification, and extensible taxonomy come to mind.
Wordpress offers more simplicity and still covers most of my use cases
via pretty decent plugins. The migration itself was easy enough and I
based it on some scripts I found at
[socialcmsbuzz](http://socialcmsbuzz.com/convert-import-a-drupal-6-based-website-to-wordpress-v27-20052009/).
All the old URLs should still work thanks to a set of handwritten
redirects in
[nginx](http://lithostech.com/2009/05/lighten-apaches-load-with-nginx/).

The Drupal community really had something great back in the days of 4.x.
Drupal was on track to change the world but fell flat on its face when
it crapped out 5.x and 6.x too fast. Then turned right back around and
kept 7.x in development for years. The poor community has been
balkanized across at least 3 major versions of Drupal for a long time
and that shows no signs of stopping. Instead of focusing resources on a
common platform and building something truly excellent, Drupal created a
confusing, sometimes painful development environment and *became* its
toughest critique rather than facing it: "Jack of all trades, master of
none"

### Movable Type vs Wordpress

One of my favorite things about wordpress is how easy it is to install
and upgrade plugins, themes and even wordpress itself. If your web
server has the rights to do it (which might be a huge security flaw
depending on whom you ask), it's as easy as clicking a button. One of my
least favorite thing about Wordpress has to be what it does to support
multiple blogs at the database level. So far its only found in Wordpress
μ in the wild, but it will be in Wordpress 3.0 (MultiSite). Wordpress
creates whole sets of tables for each new blog no matter how small. I've
heard all the arguments and done my reading, but I remain skeptical.
Database normalization is one area where Movable Type is the clear
winner. Here's the bottom line: If you don't want to use a relational
database, then don't. There's all kinds of good stuff going on in the
whole [NOSQL](http://nosql-database.org/) movement.  Maybe Wordpress
devs are just waiting for the technology to be more pervasive. I suppose
using MySQL in this way is a decent stopgap.

One big advantage Wordpress has over Movable Type is templates are on
the filesystem, like regular templates. This may just be a personal
preference, but I think whole templates should never be in the database.
I hate that about Movable Type. Other simple things like paginated pages
are built-in to wordpress so I don't have to spend hours messing with
templates to make it work.

Other than that, I'm really impressed with Wordpress, especially the
community. I've already submitted patches and talked to core developers
on IRC and they've all been really friendly and helpful (the total
opposite of my experience with the Movable Type community sorry to say).
I found free easy-to-configure plugins for all manner of things
including S3 integration, Twitter and Facebook integration (including
posting comments back to Twitter and Facebook). I've wanted to do this
stuff for a long time with Movable Type and found it impossible with
freely available plugins. Movable Type seems to be stuck in the days
where making things work the way you wanted involved a bunch of silly
hacks. Movable Type's best plugin site is aptly named
[mt-hacks.com](http://mt-hacks.com/).

### Why Wordpress?

I'm under no delusion. Wordpress is not the second coming and its really
not the most beautiful code I've ever seen. What it does is work and it
works well. It's also fun and has an active community of people aiming
at a common target. It takes care of a lot of the boring stuff like
maintaining plugins and allows me to do the fun stuff where I put it all
together and build cool web sites.
