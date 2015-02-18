---
layout: post
published: true
title: Goodbye Wordpress, Hello Jekyll
date: '2015-02-17 13:49:46 -0800'
tags:
- wordpress
- jekyll
- cms
- s3
---
As you probably do not recall, this blog was not always running on
Wordpress. In it's first incarnation, it was actually [running Drupal
]({% post_url 2010-03-24-switched-from-drupal-to-wordpress %}). And as
of yesterday, we can add Wordpress to the list of former lithostech.com
platforms. This site is now running on Jekyll, and since it seems to be
relatively unkown compared to wordpress, I thought I'd take the
opportunity to explore this change and explain the move. What follows
could be looked at as a comparison of Wordpress to Jekyll as a blogginb
platform.

## Theming

Wordpress has served me well. There are plenty of free, prebuilt themes
ready to rock. Sadly, if you're searching for Wordpress themes and you
only consider themes that are mobile-friendly, SEO-friendly, easy to
work on and not full of bloat, you've already elimated the vast majority
of both free and paid themes that are available. If you want something
visually appealing, you're really down to a small handful of available
themes which means your only real option is to use one of those and
extend it, or write your own.

This is a bit daunting, but totally possible, especially starting from
an example. Just read [theme development
docs](http://codex.wordpress.org/Theme_Development) and have a great
time. You can `<?php var_dump($foo); die(); ?> your way to a complete
theme if you have the time, but unless you're very familiar with this
theming API, it's going to take a while. It's possible to do just about
anything you can imagine, but I found it slow and painful and even
annoying.

Jekyll uses [liquid](http://liquidmarkup.org/) for templating which is
quite powerful and much more compact. Jekyll is a much simpler tool than
Wordpress, and for me that simplicity is a core strength. Have a look at
[this page's layout
](https://github.com/stevecrozz/lithostech.com/blob/master/_layouts/default.html)
to see what I mean.
