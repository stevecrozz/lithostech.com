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
excerpt: Movable Type 4.2 introduced (among other things) built-in pagination. When
  you have a set of entries published to a dynamic index, you can auto-paginate them
  with some <a href="http://www.movabletype.org/documentation/designer/pagination.html">magical
  tags</a> and it works wonderfully. That is, it works unless you wanted to use Movable
  Type's built-in caching system for dynamic content. Movable Type's cache entries
  are unique to a given relative URL excluding the request parameters. In the case
  of pagination, request parameters make all the difference on what should be cached.
wordpress_id: 69
date: '2009-02-11 01:27:17 -0800'
date_gmt: '2009-02-11 09:27:17 -0800'
categories:
- Uncategorized
tags:
- movable type
comments: []
---
<p>Movable Type 4.2 introduced (among other things) built-in pagination. When you have a set of entries published to a dynamic index, you can auto-paginate them with some <a href="http:&#47;&#47;www.movabletype.org&#47;documentation&#47;designer&#47;pagination.html">magical tags<&#47;a> and it works wonderfully. That is, it works unless you wanted to use Movable Type's built-in caching system for dynamic content. Movable Type's cache entries are unique to a given relative URL excluding the request parameters. In the case of pagination, request parameters make all the difference on what should be cached. If you're not following, this means that the following URLs are identical as far as the MT cache is concerned:<&#47;p></p>
<pre>
&#47;<br />
&#47;?limit=10&amp;offset=10<br />
&#47;?whatever_its_all_the_same_to=MT<br />
<&#47;pre><br />
<a id="more"></a><a id="more-69"></a></p>
<p>Normally, having a blog that doesn't do any caching isn't a huge deal, but as soon as you start to get some traffic, it can really destroy your server. Our bloggers have been begging for paginated indices for years now and deploying our redesigned blogs without pagination was just not an option, so I began my quest for great caching.<&#47;p></p>
<p>I ended up using apache's built-in mod_disk_cache and a reverse proxy to get around mod_rewrite bugginess. mod_cache takes my caching woes right out of the loop because it provides a proper cache handle using the entire URI including GET parameters. Turning on caching makes all the static content cached instantly, which is not exactly what I'm going for. It misses the dynamic content because mod_cache stupidly steps all over itself with mod_rewrite. I got some advice on that in #apache@freenode from noodl who recommended setting up a reverse proxy to handle all the cache hits, then pass the misses to an internally accessible virtual host. That's exactly what I did and it speeds up my environment roughly tenfold. Here's an abridged version of my configuration:<&#47;p></p>
<pre>CacheEnable disk &#47;</p>
<p>ServerName myblogsite.com<br />
ProxyRequests Off</p>
<p>Order deny,allow<br />
Allow from all</p>
<p>ProxyPass &#47; http:&#47;&#47;myblogsite.local&#47;<br />
ProxyPassReverse &#47; http:&#47;&#47;myblogsite.local&#47;</p>
<p>ErrorLog &#47;var&#47;log&#47;apache2&#47;error.log<br />
LogLevel debug</p>
<p>CustomLog &#47;var&#47;log&#47;apache2&#47;access.log combined<br />
DocumentRoot &#47;var&#47;www&#47;myblogsite.com&#47;<br />
ServerName myblogsite.local</p>
<p>ScriptAlias &#47;admin &#47;usr&#47;lib&#47;cgi-bin&#47;movabletype&#47;mt.cgi<br />
Alias &#47;mt-static &#47;usr&#47;share&#47;movabletype&#47;static<br />
AllowOverride All</p>
<p>ErrorLog &#47;var&#47;log&#47;apache2&#47;error.log<br />
LogLevel warn</p>
<p>CustomLog &#47;var&#47;log&#47;apache2&#47;access.log combined<br />
<&#47;pre></p>
<p>As a rough comparison, my requests per second (RPS) were stuck at around 0.5 until I got this cache working. Here's the output of a simple test with apache bench:<&#47;p></p>
<pre>
stevecrozz@wxp-im-video:~$ ab -n 1000 -c 10 http:&#47;&#47;myblogsite.com&#47;<br />
This is ApacheBench, Version 2.3 <$Revision: 655654 $><br />
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http:&#47;&#47;www.zeustech.net&#47;<br />
Licensed to The Apache Software Foundation, http:&#47;&#47;www.apache.org&#47;</p>
<p>Benchmarking myblogsite.com (be patient)<br />
Completed 100 requests<br />
Completed 200 requests<br />
Completed 300 requests<br />
Completed 400 requests<br />
Completed 500 requests<br />
Completed 600 requests<br />
Completed 700 requests<br />
Completed 800 requests<br />
Completed 900 requests<br />
Completed 1000 requests<br />
Finished 1000 requests</p>
<p>Server Software:        Apache&#47;2.2.9<br />
Server Hostname:        myblogsite.com<br />
Server Port:            80</p>
<p>Document Path:          &#47;<br />
Document Length:        44954 bytes</p>
<p>Concurrency Level:      10<br />
Time taken for tests:   68.658 seconds<br />
Complete requests:      1000<br />
Failed requests:        0<br />
Write errors:           0<br />
Total transferred:      45396832 bytes<br />
HTML transferred:       44986422 bytes<br />
Requests per second:    14.57 [#&#47;sec] (mean)<br />
Time per request:       686.575 [ms] (mean)<br />
Time per request:       68.658 [ms] (mean, across all concurrent requests)</p>
<p>Transfer rate:          645.71 [Kbytes&#47;sec] received</p>
<p>Connection Times (ms)<br />
min  mean[+&#47;-sd] median   max<br />
Connect:       53  114 409.7     55    3069<br />
Processing:   332  569 243.9    474    2041<br />
Waiting:       55   61  24.8     56     334<br />
Total:        386  683 476.2    537    4472</p>
<p>Percentage of the requests served within a certain time (ms)<br />
50%    537<br />
66%    645<br />
75%    745<br />
80%    814<br />
90%   1009<br />
95%   1214<br />
98%   2095<br />
99%   3513<br />
100%   4472 (longest request)<br />
<&#47;pre></p>
