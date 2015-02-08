---
layout: post
status: publish
published: true
title: Is UglifyJS Really Worth It?
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 622
wordpress_url: http://lithostech.com/?p=622
date: '2014-03-20 16:50:54 -0700'
date_gmt: '2014-03-20 23:50:54 -0700'
categories:
- Uncategorized
tags:
- javascript
- minification
- grunt
comments:
- id: 110022
  author: Rob
  author_email: admin@roae.me
  author_url: ''
  date: '2014-08-11 12:45:13 -0700'
  date_gmt: '2014-08-11 19:45:13 -0700'
  content: You can also take in account the reduction in http request that minifying
    multiple files saves you, it's not all about size, 4-5 files from your script
    and vendors means 4-5 calls back and forth from your server, if you minify it
    into 1 file it's just 1 request
---
Like the rest of the world, RightScale has been moving more and more of
its application from the server to the client. That means we've suddenly
found managing larger and larger piles of JavaScript. All that
JavaScript needs to be delivered to clients as quickly as possible in
order to minimize the time customers spend waiting for web pages to
load.

So we created a nice little build tool leveraging
[Grunt](http://gruntjs.com/) which among other things takes all that
JavaScript and compiles it into one big blob for each application. In
order to make that big blob as small as possible, we use
[UglifyJS](https://github.com/mishoo/UglifyJS).

Unfortunately, some of our apps are so big that running the uglify Grunt
task can take a long time. Ideally, this task would be fast enough to
where it could be run at or just before deploying. Fast enough is a
pretty subjective term, but we deploy code all the time to production
and various kinds of staging systems, so fast enough becomes however
long you want to wait for code deploys in addition to the time it
already takes. In my case, three extra minutes is not fast enough.

So I theorized about the virtue of using UglifyJS at all and my
reasoning went something like this: Any sane person who's delivering a
lot of JavaScript to clients on the web is going to be using some kind
of [HTTP compression](http://en.wikipedia.org/wiki/HTTP_compression)
algorithm like gzip or deflate. And hardcore file size optimizations
prior to compression seem like exactly the kind of things that would
make regular file compression less efficient. So wouldn't we be better
off with something fast and simple like Douglas Crockford's good old
[JSMin](http://www.crockford.com/javascript/jsmin.html)? We could just
rely more on the file compression than mifification or uglification to
reduce file size.

<!--more-->

If I were to separately process some JavaScript with UglifyJS and with
JSMin I could draw a comparison between these two minifiers. And if I
were to compress those files I could begin to say how valuable UglifyJS
is by comparing the final compressed file sizes. In one of our
applications, replacing UglifyJS with JSMin would cut build times down
by more than three minutes because JSMin is hundreds of times faster
than UglifyJS.

That's exactly what I did. I ran our regular build process using
UglifyJS and the whole process took 3 minutes and 45 seconds. I then ran
the same build process replacing UglifyJS with JSMin and that took only
25 seconds. The jsmin portion of the build really only takes a bout one
second. Here are the results before compression:

~~~ bash
$ ls -lAh uglified/package.js
-rw-r--r-- 1 stevecrozz stevecrozz 489K Mar 20 14:59 uglified/package.js
$ ls -lAh jsmin/package.js
-rw-r--r-- 1 stevecrozz stevecrozz 580K Mar 20 15:04 jsmin/package.js
~~~

Obviously, UglifyJS is doing a much better job at minifying my
JavaScript package. It managed to squeeze an extra 16% (91K) out of the
source files. But let's see what happens when I gzip them both:

~~~ bash
~/Projects/rs/skeletor-app-network-manager (master $%=)$ ls -lAh uglified/package.js.gz
-rw-r--r-- 1 stevecrozz stevecrozz 125K Mar 20 15:46 uglified/package.js.gz
~/Projects/rs/skeletor-app-network-manager (master $%=)$ ls -lAh jsmin/package.js.gz
-rw-r--r-- 1 stevecrozz stevecrozz 138K Mar 20 15:46 jsmin/package.js.gz
~~~

Now UglifyJS has less than a 10% advantage over JSMin, and that 10%
represents only 13K. But, UglifyJS's advantage is multiplied by the
number of times someone requests this package. If that number is
1,000,000, then you're potentially saving yourself and your users 13GB
of data transfer. Although, if you and your development team build this
project 20 times per day, then you're losing yourself 60 minutes every
day. Of course, you could be doing other things during that time, but
often I'm waiting for the build in order to test my code and task
switching is not my strong suit.

Whether or not that 13K is worth the added build time depends on how
often you build the project, how long it takes, how much traffic you
get, and of course, how much of that traffic is coming from users with
cached copies of your assets. A few KB hardly matter if most of the time
people are just hitting the cache. I think in our case, we'd be better
off with JSMin.

I realize this is not a complete picture. Real-world performance depends
on many factors that I haven't accounted for. But if you have a project
without hundreds of millions of users and it's under active development,
I'd consider skipping UglifyJS in favor of something that could save you
time. I'm probably going to make this change at some point.
