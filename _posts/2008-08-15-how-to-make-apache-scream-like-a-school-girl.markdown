---
layout: post
status: publish
published: true
title: how to make apache scream (like a school girl)
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 35
date: '2008-08-15 20:46:21 -0700'
date_gmt: '2008-08-16 04:46:21 -0700'
categories:
- Uncategorized
tags:
- network adminstration
comments:
- id: 1
  author: ''
  author_email: ''
  author_url: ''
  date: '2008-08-22 18:21:38 -0700'
  date_gmt: ''
  content: This is really great writing.  Easy to keep in your head what is going
    on, what the big takeaway points are, etc.  Nice job!
---
{% picture thumbnail-left 2008/school-girl.jpg alt="Young cheerleader screaming with hands in the air" %}

I was investigating some web site slowness for a friend the other day.
His company uses SugarCRM over https. He had been complaining about
slowness for over a year and I finally decided to give it a thorough
look. Since the sugar application makes heavy use of its database
backend, I decided to start there.  Unfortunately mySQL's slow query log
turned up nothing, except that the database was running about as fast as
you could possibly expect with the whole database buffered in memory. I
honestly didn't think to check the web server itself because I've never
really had a measurable problem with that before, default web server
settings have always suited me fine in the past. Apparently all bets are
off when running under SSL...

On a whim, I downloaded [YSlow](http://developer.yahoo.com/yslow/), a
firefox plugin developed by Yahoo! which I had heard about from a fellow
developer a few months ago. It gives your site a letter grade based on a
number of factors that contribute to site slowness. I had two major
improvements I could easily make, plus a number of small ones that I'd
like to do, but I'm not about to dive into sugar and restructure it.

<!--more-->

This web server runs some version of CentOS which has somehow become
very popular among hosting providers and apache 2.x with mod_php. Since
this was my first major stab at apache performance tuning, I decided to
fire up the [official documentation](http://httpd.apache.org/docs/2.0/)
which incidentally has a section on performance tuning. With the
documentation open in one window and httpd.conf open in another, I
started systematically disabling modules that I didn't think were being
used. After disabling a handful of modules, I'd force-reload apache and
check to see if anything had broken. This is what I ended up with:

~~~
LoadModule access_module modules/mod_access.so
#LoadModule auth_module modules/mod_auth.so
#LoadModule auth_anon_module modules/mod_auth_anon.so
#LoadModule auth_dbm_module modules/mod_auth_dbm.so
#LoadModule auth_digest_module modules/mod_auth_digest.so
#LoadModule ldap_module modules/mod_ldap.so
#LoadModule auth_ldap_module modules/mod_auth_ldap.so
#LoadModule include_module modules/mod_include.so
LoadModule log_config_module modules/mod_log_config.so
#LoadModule env_module modules/mod_env.so
LoadModule mime_magic_module modules/mod_mime_magic.so
#LoadModule cern_meta_module modules/mod_cern_meta.so
LoadModule expires_module modules/mod_expires.so
LoadModule deflate_module modules/mod_deflate.so
LoadModule headers_module modules/mod_headers.so
#LoadModule usertrack_module modules/mod_usertrack.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule mime_module modules/mod_mime.so
#LoadModule dav_module modules/mod_dav.so
#LoadModule status_module modules/mod_status.so
LoadModule autoindex_module modules/mod_autoindex.so
#LoadModule asis_module modules/mod_asis.so
#LoadModule info_module modules/mod_info.so
#LoadModule dav_fs_module modules/mod_dav_fs.so
#LoadModule vhost_alias_module modules/mod_vhost_alias.so
#LoadModule negotiation_module modules/mod_negotiation.so
LoadModule dir_module modules/mod_dir.so
#LoadModule imap_module modules/mod_imap.so
#LoadModule actions_module modules/mod_actions.so
#LoadModule speling_module modules/mod_speling.so
#LoadModule userdir_module modules/mod_userdir.so
LoadModule alias_module modules/mod_alias.so
LoadModule rewrite_module modules/mod_rewrite.so
#LoadModule proxy_module modules/mod_proxy.so
#LoadModule proxy_ftp_module modules/mod_proxy_ftp.so
#LoadModule proxy_http_module modules/mod_proxy_http.so
#LoadModule proxy_connect_module modules/mod_proxy_connect.so
LoadModule cache_module modules/mod_cache.so
#LoadModule suexec_module modules/mod_suexec.so
LoadModule disk_cache_module modules/mod_disk_cache.so
LoadModule file_cache_module modules/mod_file_cache.so
LoadModule mem_cache_module modules/mod_mem_cache.so
LoadModule cgi_module modules/mod_cgi.so
~~~

I might be able to trim these run-time modules even further, but I was
already feeling satisfied here since I cut it down by about 50%, at
least in terms of sheer number of loaded modules. That was a good start,
and improved the memory footprint on each spawned apache process, but
didn't seem to make a noticeable performance difference which makes
sense because the server wasn't ever low on memory.

Just for the sake of comparison I hard-refreshed the front page a number
of times before running through the YSlow checklist. The page
consistently took 15-25 seconds to load.

YSlow revealed the big problems. The first suggestion was excellent.

### Make fewer HTTP requests

- This page has 19 external JavaScript files.
- This page has 7 external StyleSheets.
- The problem is, sugarCRM handles all this internally. Best case
  scenario, this should really be done in only two requests, but
  we're making 26 separate HTTP requests just for local javascripts
  and stylesheets. Of course, this is nowhere near as bad as [some
  sites I've seen](http://www.fresnobee.com). So I skipped that one
  because it'll be hard for me to implement in this instance, hoping
  I could still make a major difference.
### Use a CDN

Good idea, but my friend's company is cheap, really cheap. There's no
way they're about to shell out an extra dime for a good content delivery
network.

### Add an expires header

Now that's a practical and very easy thing to do. It turns out that many
web browsers are not as liberal with their caching policy over the https
schema. I added this snippet to the virtual host which informs the web
browser that it can hold onto a cached copy of these files for a little
while rather than requesting new ones on every page load. I decided on 7
days for javascript and stylesheets, and a month for images.

~~~ bash
ExpiresActive On
ExpiresByType text/css "access plus 7 days"
ExpiresByType text/javascript "access plus 7 days"
ExpiresByType application/x-javascript "access plus 7 days"
ExpiresByType image/gif "access plus 1 month"
ExpiresByType image/jpg "access plus 1 month"
ExpiresByType image/png "access plus 1 month"
ExpiresByType image/x-icon "access plus 1 month"
~~~

That one change made a drastic difference. After logging in, the
application home page used to weigh in at 704.8KiB in all. Most of this
stuff was being loaded on every single page view. Now (after priming the
cache), its only 199.7. That's a 353% decrease in the amount of data
that must be loaded. That number alone is huge, but the performance
increases are far beyond that because of the way browsers handle
concurrent downloads, and especially concurrent javascript loading.

### Gzip components

This is one that really suprised me. I had no idea that gzipping
components could make such a drastic difference. I had always thought
that gzipping site components was only for trying to squeeze every last
ounce of performance out of low-bandwidth connections. It turns out that
enabling gzip compression on a few key files took their effective sizes
down by about an order of magnitude. Take for example the actual front
html page which was 199.7KiB during testing. Gzip was able to take it
down to 19.2KiB. Here are some magical statements straight from the
apache documentation:

~~~ bash
# Insert filter
SetOutputFilter DEFLATE
# Netscape 4.x has some problems...
BrowserMatch ^Mozilla/4 gzip-only-text/html
# Netscape 4.06-4.08 have some more problems
BrowserMatch ^Mozilla/4\.0[678] no-gzip
# MSIE masquerades as Netscape, but it is fine
BrowserMatch \bMSI[E] !no-gzip !gzip-only-text/html
# Don't compress images
SetEnvIfNoCase Request_URI \
\.(?:gif|jpe?g|png)$ no-gzip dont-vary
# Make sure proxies don't deliver the wrong content
Header append Vary User-Agent env=!dont-vary
~~~

This basically instructs apache to gzip everything except images while
respecting certain browser quirkiness. I don't care to research exactly
what all that Netscape 4.x quirkiness is about; I think I'll just trust
the apache doc writers. Maybe I'll just take that out actually because
seriously, who's using Netscape 4.x anyway?

Now cache-primed 19.2KiB front page loads are minuscule in when compared
with the former 704.8KiB behemoths, and let me tell you, this web site
is screaming now. The front page loads take anywhere from 0.5-4 seconds.
I'm not sure why that range is so large, but I am sure that the CRM
users will be much happier the next time they log in.
