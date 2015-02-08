---
layout: post
status: publish
published: true
title: lighten apache's load with nginx
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 77
date: '2009-05-27 22:59:58 -0700'
date_gmt: '2009-05-28 06:59:58 -0700'
categories:
- Uncategorized
tags:
- web server
- nginx
comments:
- id: 9
  author: HighBit
  author_email: ''
  author_url: ''
  date: '2009-06-03 02:43:12 -0700'
  date_gmt: ''
  content: "I don't have any experience with nginx (I've only used lighttpd and Apache),
    but based on nginx's wiki and my experience with lighttpd, I do have a couple
    of points...\r\n\r\nFirst, you mention that nginx is thread-safe; this would imply
    it uses threads, but I don't think that's the case; instead, its workers are using
    an epoll-based event loop, like lighttpd or Apache's new event MPM (although this
    MPM still uses threads to actually handle the request, which may or may not be
    a good thing).\r\n\r\nSecond, you mention you've got nginx configured to use multiple
    processes. This isn't necessary and in fact is probably slowing you down. I'd
    recommend configuring nginx to use *one* process. Make sure the file descriptor
    resource limit is set to at least twice the maximum number of simultaneous connections,
    but feel free to set the max connection setting to a large number, like 16384.
    With epoll, you only need to worry about running out of bandwidth :)\r\n\r\nUsing
    a single process will minimize context-switching and should provide as good or
    better performance compared to your current setup. Less context switching means
    more CPU time for serving dynamic requests.\r\n\r\nOne final point: to minimize
    memory usage on your dynamic backends, you want to do two things:\r\n\r\nFirst,
    ensure that you have a master process that, when it starts up, pre-compiles all
    the code you use to serve requests. This master process will fork off children
    that actually serve the requests. You do this for two reasons: first, you save
    CPU cycles by not recompiling code for each request. Second, this enables you
    to make the best use of Copy-On-Write (COW) memory for your dynamic code. This
    strategy is possible with most dynamic languages, except (maybe) PHP. With PHP,
    other op-code caching strategies, such as APC, are more popular. Python also uses
    compiled modules (pyc files). However, this type of op-code caching does not give
    you the same COW memory usage advantage that a forking master does.\r\n\r\nSecond,
    ensure that your dynamic processes die after serving some relatively low number
    of requests. If a dynamic service is infrequently accessed, it might only serve
    one request per process. It's usually advisable to serve at least 5 requests per
    process. After serving this low number of requests, the process will die and a
    new process will be forked off by the master. The reason you want to do this is
    to keep the memory usage per process low. As dynamic programs run, they will dirty
    existing COW memory and allocate new memory; they may even have leaks. By allowing
    the OS to reap processes frequently, your memory usage stays low. This is a trade-off,
    of course; it costs CPU cycles to reap old processes and fork off new ones. The
    more requests you serve per process, the less CPU you spend reaping and forking,
    so some fine-tuning to find the best trade-off is necessary.\r\n\r\nThe astute
    reader will note that simple CGI follows the model of fork, process a request,
    and then exit. However, using vanilla CGI is not advisable, because every request
    will require a fork, your dynamic language interpreter to start, your dynamic
    language program to be compiled or loaded into memory, and finally your program
    to be run. Doing all those things for each request burns a lot of CPU. FastCGI
    with a master process solves this by having the dynamic language program ready
    to run as soon as the request comes in. After the request is served, a new process
    can be forked to wait for the next request. Also, multiple children can be waiting
    for a request without each child using additional memory, since nearly all the
    child's memory will be shared via COW.\r\n\r\nHope this helps, and have fun :)\r\n"
- id: 10
  author: stevecrozz
  author_email: ''
  author_url: ''
  date: '2009-06-03 16:41:09 -0700'
  date_gmt: ''
  content: I'm going to make some more changes and run tests. I've just moved to a
    single worker configuration for nginx and haven't noticed any performance problems.
    I've also reconfigured mod_fcgid to handle only 20 requests per process (down
    from 500). I've definitely noticed certain applications that are awful with memory
    usage. mt-search.fcgi (mt-search.cgi) is about the worst offender I've seen yet.
    Its initial requests keep it under 50MiB, but as it runs it can expand by an order
    of magnitude fairly quickly.
- id: 50
  author: switched from drupal to wordpress &laquo; lithostech.com
  author_email: ''
  author_url: http://lithostech.com/2010/03/switched-from-drupal-to-wordpress/
  date: '2010-03-24 12:28:08 -0700'
  date_gmt: '2010-03-24 19:28:08 -0700'
  content: "[...] Drupal is a much more abstract system, useful for a million things,
    whereas Wordpress is decidedly a blogging platform. Drupal provides a lot more
    functionality out of the box like caching, css and javascript aggregation/minification,
    and extensible taxonomy come to mind. Wordpress offers more simplicity and still
    covers most of my use cases via pretty decent plugins. The migration itself was
    easy enough and I based it on some scripts I found at socialcmsbuzz. All the old
    URLs should still work thanks to a set of handwritten redirects in nginx. [...]"
---
{% picture thumbnail 2009/nginx-logo.png alt="nginx logo" style="float:left" %}

Since we've been on [slicehost](http://slicehost.com), I've been forced
to play the role of system administrator since we don't have a real one.
One problem I've run into is the long string of legacy applications that
I have to support. Some of them I wrote, and some of them I inherited.
For many reasons, they're often organized and run in sub-optimal ways.
Separating your static and dynamic content is a good habit to get into
when you're building scalable web applications. Static content is highly
portable because it can live without context. You can serve it from
anywhere and nobody knows the difference. When your site starts to get
huge traffic, you can easily offload your static content to a
[CDN](http://en.wikipedia.org/wiki/Content_Delivery_Network) if you host
it in an easy-to-separate way using an URL like static.domain.com or
domain.com/static.

<!--more-->

### the problem

But my applications blur that line with static and dynamic content
living together with sometimes no distinction. This is where
[nginx](http://wiki.nginx.org/Main) shines. Before I move on, I'll
mention that I do know that apache can do this exact same stuff, but
it's less turnkey to do it on Ubuntu because I'd need a second instance
of apache to make it work and even then I think I can squeeze out better
performance with this setup.

Let me first describe the setup I'm starting with. I have one 2048MiB
slice from slicehost running the [apache](http://www.apache.org/) web
server. Apache is configured with mpm_prefork because most of my
applications are not thread safe. Among others, I run all my
applications with mod_cgid, mod_fcgid, mod_passenger, mod_python. I have
applications written in perl, php, ruby and python. This setup makes for
somewhat large apache processes because all the modules plus many other
typical modules are loaded for every running process (even if the
process is only serving static content). In fact, the reason I started
looking at optimization is that during heavy request times, our server
was running out of memory and having to swap (a very [bad thing for web
servers](http://books.google.com/books?id=VNBlvt2UpUMC&amp;pg=PA301&amp;vq=never+swap&amp;dq=web+servers+%22never+swap%22&amp;source=gbs_search_s&amp;cad=0)).

### the solution

After the transition, I ended up with all my static content being served
by nginx. nginx is bound to ports 80 and 443 and handles all the
incoming requests. nginx checks the docroot to see if the requested file
exist on the filesystem. If it does, nginx serves them directly, if not
it acts as a reverse proxy and forwards the request to apache which is
now listening only on port 8080. Here's the heart and soul of my setup:

~~~ nginx
location / {
  proxy_set_header X-Real-IP  $remote_addr;
  if (-f $request_filename) {
    break;
  }
  if (-f $request_filename/index.html) {
    rewrite (.*) $1/index.html break;
  }
  if (!-f $request_filename) {
    proxy_pass http://fresnobeehive.com:8080;
    break;
  }
}
~~~

After some initial testing, I've found that in many cases my new setup
is actually a little slower than using apache to serve everything. The
difference, however, is in scalability. Since nginx is only serving
static content, its perfectly thread-safe and I can use worker processes
to handle requests. I have 4 worker processes that can handle 1024
simultaneous connections. Each worker is generally using no more than a
few MiB of memory which marks the most substantial difference over the
apache-only setup. Previously, under normal load, my server would be
using almost all of its 2048MiB of memory, and now I see humming along
regularly with 600-700MiB free. Swapping is now rare and I'm even
considering using some of that extra memory for running memcached which
should blow my old setup out of the water performance-wise.
