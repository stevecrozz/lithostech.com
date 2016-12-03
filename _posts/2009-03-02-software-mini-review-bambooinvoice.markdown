---
layout: post
status: publish
published: true
title: 'software mini-review: BambooInvoice'
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 71
date: '2009-03-02 04:33:54 -0800'
date_gmt: '2009-03-02 12:33:54 -0800'
categories:
- Uncategorized
tags:
- php
- software
- reviews
comments:
- id: 8
  author: ''
  author_email: ''
  author_url: ''
  date: '2009-05-24 18:19:25 -0700'
  date_gmt: ''
  content: It really is a great product, and it made me get into Code Igniter also.
    If you are a PHP person try it out. Oh, and I think your link to <a href="http://derekallard.com">Derek
    Allard</a> is broken.
- id: 12826
  author: nikhil
  author_email: niks.pajabi@gmail.com
  author_url: http://www.bmctmnews.com
  date: '2011-03-13 21:59:33 -0700'
  date_gmt: '2011-03-14 04:59:33 -0700'
  content: "hey please let me know how can i use it on  my desktop i hav installed
    apache and PHP both but i dont know how to work on it\r\n i want to use bamboo
    invoice please sort it out for me thanks \r\nNikhil, India"
- id: 16383
  author: billybob
  author_email: bell_tec@hotmail.com
  author_url: ''
  date: '2011-04-20 17:21:35 -0700'
  date_gmt: '2011-04-21 00:21:35 -0700'
  content: "This project is dead, it is another project that has been neglected under
    the excuse there is no time, the math in the program is not right, time always
    seems to be an excuse when someone reaches their level of understanding. Don't
    waste your time on this product, free doesn't have to mean it doesn't work.\r\n\r\nGive
    myclientbase a try at http://www.myclientbase.com/forums/index.php"
---
{% responsive_image path: static/img/full/2009/bamboo.jpg alt: "Bamboo
Bokeh (https://c2.staticflickr.com/2/1372/556746420_e05f2c8371_b.jpg)"
class: "img-float-left" %} For the longest time, I had no real invoicing
system for my independent contract work. I just never found anything
that I really liked and rarely found the inspiration to go looking. But
recently, I got in the mood to find a long-term solution. What I found
was a lot of hosted solutions, a lot of closed source 'for-purchase'
solutions, and a lot of second-rate software.

<!--more-->

- PHP Invoice looked nice, but its non-free and not open source
- cInvoice looked ugly and the licensing terms were unpleasant
- InvoiceMe is shareware, I didn't even see a demo
- PHP InvoiceIt is not open source, no demo
- gcdb might be good, but probably not since the latest release is from
  2001

I could keep going on, there are seemingly limitless half-assed,
incomplete or outdated projects available with friendly (GPL or BSD
style) licenses, a few great software packages that are available in
unfriendly licenses or not available to download at all, and a bunch
that are both bad and have ugly licenses. I was ready to break down and
build my own invoice system from scratch with python/django, until I
found BambooInvoice.

With BambooInvoice, I'm able to do my work on site, then log on remotely
to my invoice server, create an invoice and print a pdf before I leave.
You can add private notes to invoices, track payments, easily email the
invoices to your clients. You can easily create multiple accounts if you
have other staff that needs to manage invoices, and you can store
details on each of your clients. One feature that's missing is recurring
invoices, but I know that's on the radar. Perhaps if I have some time,
I'll add that feature. Overall, the system feels solid, and the sliding
ajaxy goodness makes it look sexy too. Plus, the whole package is
licensed under the GPL. It just makes you feel good all over.

The *only* package I found that could meet my needs was BambooInvoice,
and I've got nothing but good things to say about it. I already sent a
note of congratulations to the project developer [Derek
Allard](http://www.derekallard.com) and I wish this project continued
success.
