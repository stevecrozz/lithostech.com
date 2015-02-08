---
layout: post
status: publish
published: true
title: 'how-to: cache the uncacheable (movable type dynamic paginated pages)'
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 69
date: '2009-02-11 01:27:17 -0800'
date_gmt: '2009-02-11 09:27:17 -0800'
categories:
- Uncategorized
tags:
- movable type
comments: []
---
Movable Type 4.2 introduced (among other things) built-in pagination.
When you have a set of entries published to a dynamic index, you can
auto-paginate them with some [magical
tags](http://www.movabletype.org/documentation/designer/pagination.html)
and it works wonderfully. That is, it works unless you wanted to use
Movable Type's built-in caching system for dynamic content. Movable
Type's cache entries are unique to a given relative URL excluding the
request parameters. In the case of pagination, request parameters make
all the difference on what should be cached. If you're not following,
this means that the following URLs are identical as far as the MT cache
is concerned:

~~~ bash
/
/?limit=10&amp;offset=10
/?whatever_its_all_the_same_to=MT
~~~

<!--more-->

Normally, having a blog that doesn't do any caching isn't a huge deal,
but as soon as you start to get some traffic, it can really destroy your
server. Our bloggers have been begging for paginated indices for years
now and deploying our redesigned blogs without pagination was just not
an option, so I began my quest for great caching.

I ended up using apache's built-in mod_disk_cache and a reverse proxy to
get around mod_rewrite bugginess. mod_cache takes my caching woes right
out of the loop because it provides a proper cache handle using the
entire URI including GET parameters. Turning on caching makes all the
static content cached instantly, which is not exactly what I'm going
for. It misses the dynamic content because mod_cache stupidly steps all
over itself with mod_rewrite. I got some advice on that in
#apache@freenode from noodl who recommended setting up a reverse proxy
to handle all the cache hits, then pass the misses to an internally
accessible virtual host. That's exactly what I did and it speeds up my
environment roughly tenfold. Here's an abridged version of my
configuration:

~~~ bash
CacheEnable disk /
ServerName myblogsite.com
ProxyRequests Off
Order deny,allow
Allow from all
ProxyPass / http://myblogsite.local/
ProxyPassReverse / http://myblogsite.local/
ErrorLog /var/log/apache2/error.log
LogLevel debug
CustomLog /var/log/apache2/access.log combined
DocumentRoot /var/www/myblogsite.com/
ServerName myblogsite.local
ScriptAlias /admin /usr/lib/cgi-bin/movabletype/mt.cgi
Alias /mt-static /usr/share/movabletype/static
AllowOverride All
ErrorLog /var/log/apache2/error.log
LogLevel warn
CustomLog /var/log/apache2/access.log combined
~~~

As a rough comparison, my requests per second (RPS) were stuck at around
0.5 until I got this cache working. Here's the output of a simple test
with apache bench:

~~~ bash
stevecrozz@wxp-im-video:~$ ab -n 1000 -c 10 http://myblogsite.com/
This is ApacheBench, Version 2.3 <$Revision: 655654 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/
Benchmarking myblogsite.com (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests
Server Software:        Apache/2.2.9
Server Hostname:        myblogsite.com
Server Port:            80
Document Path:          /
Document Length:        44954 bytes
Concurrency Level:      10
Time taken for tests:   68.658 seconds
Complete requests:      1000
Failed requests:        0
Write errors:           0
Total transferred:      45396832 bytes
HTML transferred:       44986422 bytes
Requests per second:    14.57 [#/sec] (mean)
Time per request:       686.575 [ms] (mean)
Time per request:       68.658 [ms] (mean, across all concurrent requests)
Transfer rate:          645.71 [Kbytes/sec] received
Connection Times (ms)
min  mean[+/-sd] median   max
Connect:       53  114 409.7     55    3069
Processing:   332  569 243.9    474    2041
Waiting:       55   61  24.8     56     334
Total:        386  683 476.2    537    4472
Percentage of the requests served within a certain time (ms)
50%    537
66%    645
75%    745
80%    814
90%   1009
95%   1214
98%   2095
99%   3513
100%   4472 (longest request)
~~~
