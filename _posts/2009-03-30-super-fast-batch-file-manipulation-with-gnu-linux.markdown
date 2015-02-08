---
layout: post
status: publish
published: true
title: super fast batch file manipulation with GNU/Linux
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 73
date: '2009-03-30 18:10:52 -0700'
date_gmt: '2009-03-31 02:10:52 -0700'
categories:
- Uncategorized
tags:
- linux
comments: []
---
My first large foray into the world of GNU/Linux was with a tutorial for
replacing a machine's operating system (RHEL) with Debian over SSH. I
was successful even though I had no idea what I was doing, and since
then I've done a lot of my learning this way. One thing I've picked up
through reading tutorials is the varying styles of batch file
manipulation. Often times, you'll see something like this magic:

~~~ bash
for i in *.example; do cp $i|sed s/.example/.ini/; done
~~~

Anyone who's familiar with shell scripting will know what that does
almost instantly, but beginners reading along probably won't. Often
times the tutorial author is using this command for copying 3 or 4 files
and provides no explanation for what's actually happening. This makes it
seem less useful for doing actual work, and more useful for just showing
off cheap bash scripting tricks. I'm guilty of doing this too
occasionally.

<!--more-->

But this post is about doing real work with batch processing and some
things I discovered while trying different methods. I'm going to provide
minimal explanation because I think the numbers speak for themselves.
These tests are entirely unscientific, but still useful for general
comparison. I'm going to start with this test folder which contains
1,447 nodes. I'm going to use echo for each of my batch scripting
methods as a sample command for comparison.

### bare find
~~~ bash
~/test$ time find | wc
1447    1447   59243
real	0m0.026s
user	0m0.012s
sys	0m0.012s
~~~

### command on every found file
~~~ bash
~/test$ time for i in `find`; do echo $i; done | wc
1447    1447   59243
real	0m0.133s
user	0m0.092s
sys	0m0.036s
~/test$ time find -exec echo '{}' \; | wc
1447    1447   59243
real	0m4.294s
user	0m1.660s
sys	0m2.292s
~/test$ time find -exec echo '{}' + | wc
1    1447   59243
real	0m0.033s
user	0m0.012s
sys	0m0.016s
~/test$ time echo `find` | wc
1    1447   59243
real	0m0.091s
user	0m0.056s
sys	0m0.016s
~~~

Since I've piped the output of these commands through wc, you can see
that the first 2 process each node on its own line and from what I can
gather start a new process for each node. The last 2 process all 1,447
nodes at once and seem to be significantly faster than the first 2,
probably for that very reason. One of the most interesting things about
these results are the differences between the last two forms. The 3rd
form is smart enough to know when to break up the commands to avoid the
"too many arguments" shell error. Since it has to do this extra work, I
would have expected the final form to be fastest, but in my tests, the
third form is still the winner.
