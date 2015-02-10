---
layout: post
status: publish
published: true
title: infuriate linux users
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 51
date: '2008-09-22 20:25:07 -0700'
date_gmt: '2008-09-23 04:25:07 -0700'
categories:
- Uncategorized
tags:
- linux
comments:
- id: 2
  author: ''
  author_email: ''
  author_url: ''
  date: '2008-09-22 21:04:10 -0700'
  date_gmt: ''
  content: You have way too much free time, Crozz  *grin*
---
A fellow developer was burned today when an administrator ran a
so-called "kill script" to free up some system resources. It got me
thinking about another way to infuriate the users of the system. I
wanted it to be a one liner so it could be quickly placed in a cron
script. Here's what I came up with:

~~~ cron
# Joe Blo sucks --steve
*/15 * * * * ps aux | grep $(id --user jblo) | awk '{print $2}' | shuf | tail -1 | xargs kill -9 > /dev/null 2>&1
~~~

This effectively kills a random process belonging to target every 15 minutes. How infuriating is that? Make sure to leave a note so your victim knows who to blame.
