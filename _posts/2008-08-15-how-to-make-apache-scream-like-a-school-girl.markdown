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
excerpt: "I was investigating some web site slowness for a friend the other day. His
  company uses SugarCRM over https. He had been complaining about slowness for over
  a year and I finally decided to give it a thorough look. Since the sugar application
  makes heavy use of its database backend, I decided to start there.  Unfortunately
  mySQL's slow query log turned up nothing, except that the database was running about
  as fast as you could possibly expect with the whole database buffered in memory.
  I honestly didn't think to check the web server itself because I've never really
  had a measurable problem with that before, default web server settings have always
  suited me fine in the past. Apparently all bets are off when running under SSL...\r\n"
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
<p><a href="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2008&#47;08&#47;school-girl.jpg"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2008&#47;08&#47;school-girl-300x199.jpg" alt="screaming school girl" title="school girl" width="300" height="199" class="alignright size-medium wp-image-217" &#47;><&#47;a>I was investigating some web site slowness for a friend the other day. His company uses SugarCRM over https. He had been complaining about slowness for over a year and I finally decided to give it a thorough look. Since the sugar application makes heavy use of its database backend, I decided to start there.  Unfortunately mySQL's slow query log turned up nothing, except that the database was running about as fast as you could possibly expect with the whole database buffered in memory. I honestly didn't think to check the web server itself because I've never really had a measurable problem with that before, default web server settings have always suited me fine in the past. Apparently all bets are off when running under SSL...<&#47;p><br />
<a id="more"></a><a id="more-35"></a></p>
<p>On a whim, I downloaded <a href="http:&#47;&#47;developer.yahoo.com&#47;yslow&#47;">YSlow<&#47;a>, a firefox plugin developed by Yahoo! which I had heard about from a fellow developer a few months ago. It gives your site a letter grade based on a number of factors that contribute to site slowness. I had two major improvements I could easily make, plus a number of small ones that I'd like to do, but I'm not about to dive into sugar and restructure it.<&#47;p></p>
<p>This web server runs some version of CentOS which has somehow become very popular among hosting providers and apache 2.x with mod_php. Since this was my first major stab at apache performance tuning, I decided to fire up the <a href="http:&#47;&#47;httpd.apache.org&#47;docs&#47;2.0&#47;">official documentation<&#47;a> which incidentally has a section on performance tuning. With the documentation open in one window and httpd.conf open in another, I started systematically disabling modules that I didn't think were being used. After disabling a handful of modules, I'd force-reload apache and check to see if anything had broken. This is what I ended up with:<&#47;p></p>
<pre>LoadModule access_module modules&#47;mod_access.so<br />
#LoadModule auth_module modules&#47;mod_auth.so<br />
#LoadModule auth_anon_module modules&#47;mod_auth_anon.so<br />
#LoadModule auth_dbm_module modules&#47;mod_auth_dbm.so<br />
#LoadModule auth_digest_module modules&#47;mod_auth_digest.so<br />
#LoadModule ldap_module modules&#47;mod_ldap.so<br />
#LoadModule auth_ldap_module modules&#47;mod_auth_ldap.so<br />
#LoadModule include_module modules&#47;mod_include.so<br />
LoadModule log_config_module modules&#47;mod_log_config.so<br />
#LoadModule env_module modules&#47;mod_env.so<br />
LoadModule mime_magic_module modules&#47;mod_mime_magic.so<br />
#LoadModule cern_meta_module modules&#47;mod_cern_meta.so<br />
LoadModule expires_module modules&#47;mod_expires.so<br />
LoadModule deflate_module modules&#47;mod_deflate.so<br />
LoadModule headers_module modules&#47;mod_headers.so<br />
#LoadModule usertrack_module modules&#47;mod_usertrack.so<br />
LoadModule setenvif_module modules&#47;mod_setenvif.so<br />
LoadModule mime_module modules&#47;mod_mime.so<br />
#LoadModule dav_module modules&#47;mod_dav.so<br />
#LoadModule status_module modules&#47;mod_status.so<br />
LoadModule autoindex_module modules&#47;mod_autoindex.so<br />
#LoadModule asis_module modules&#47;mod_asis.so<br />
#LoadModule info_module modules&#47;mod_info.so<br />
#LoadModule dav_fs_module modules&#47;mod_dav_fs.so<br />
#LoadModule vhost_alias_module modules&#47;mod_vhost_alias.so<br />
#LoadModule negotiation_module modules&#47;mod_negotiation.so<br />
LoadModule dir_module modules&#47;mod_dir.so<br />
#LoadModule imap_module modules&#47;mod_imap.so<br />
#LoadModule actions_module modules&#47;mod_actions.so<br />
#LoadModule speling_module modules&#47;mod_speling.so<br />
#LoadModule userdir_module modules&#47;mod_userdir.so<br />
LoadModule alias_module modules&#47;mod_alias.so<br />
LoadModule rewrite_module modules&#47;mod_rewrite.so<br />
#LoadModule proxy_module modules&#47;mod_proxy.so<br />
#LoadModule proxy_ftp_module modules&#47;mod_proxy_ftp.so<br />
#LoadModule proxy_http_module modules&#47;mod_proxy_http.so<br />
#LoadModule proxy_connect_module modules&#47;mod_proxy_connect.so<br />
LoadModule cache_module modules&#47;mod_cache.so<br />
#LoadModule suexec_module modules&#47;mod_suexec.so<br />
LoadModule disk_cache_module modules&#47;mod_disk_cache.so<br />
LoadModule file_cache_module modules&#47;mod_file_cache.so<br />
LoadModule mem_cache_module modules&#47;mod_mem_cache.so<br />
LoadModule cgi_module modules&#47;mod_cgi.so<&#47;pre></p>
<p>I might be able to trim these run-time modules even further, but I was already feeling satisfied here since I cut it down by about 50%, at least in terms of sheer number of loaded modules. That was a good start, and improved the memory footprint on each spawned apache process, but didn't seem to make a noticeable performance difference which makes sense because the server wasn't ever low on memory.<&#47;p></p>
<p>Just for the sake of comparison I hard-refreshed the front page a number of times before running through the YSlow checklist. The page consistently took 15-25 seconds to load.<&#47;p></p>
<p>YSlow revealed the big problems. The first suggestion was excellent.<&#47;p></p>
<ol>
<li>
<p>Make fewer HTTP requests<&#47;p></p>
<p>This page has 19 external JavaScript files.<br />
This page has 7 external StyleSheets.<&#47;p></p>
<p>The problem is, sugarCRM handles all this internally. Best case scenario, this should really be done in only two requests, but we're making 26 separate HTTP requests just for local javascripts and stylesheets. Of course, this is nowhere near as bad as <a href="http:&#47;&#47;www.fresnobee.com">some sites I've seen<&#47;a>. So I skipped that one because it'll be hard for me to implement in this instance, hoping I could still make a major difference.<&#47;p><br />
<&#47;li></p>
<li>
<p>Use a CDN<&#47;p></p>
<p>
Good idea, but my friend's company is cheap, really cheap. There's no way they're about to shell out an extra dime for a good content delivery network.<&#47;p><br />
<&#47;li></p>
<li>
<p>Add an expires header<&#47;p></p>
<p>Now that's a practical and very easy thing to do. It turns out that many web browsers are not as liberal with their caching policy over the https schema. I added this snippet to the virtual host which informs the web browser that it can hold onto a cached copy of these files for a little while rather than requesting new ones on every page load. I decided on 7 days for javascript and stylesheets, and a month for images.<&#47;p></p>
<pre>ExpiresActive On<br />
ExpiresByType text&#47;css "access plus 7 days"<br />
ExpiresByType text&#47;javascript "access plus 7 days"<br />
ExpiresByType application&#47;x-javascript "access plus 7 days"<br />
ExpiresByType image&#47;gif "access plus 1 month"<br />
ExpiresByType image&#47;jpg "access plus 1 month"<br />
ExpiresByType image&#47;png "access plus 1 month"<br />
ExpiresByType image&#47;x-icon "access plus 1 month"<&#47;pre></p>
<p>That one change made a drastic difference. After logging in, the application home page used to weigh in at 704.8KiB in all. Most of this stuff was being loaded on every single page view. Now (after priming the cache), its only 199.7. That's a 353% decrease in the amount of data that must be loaded. That number alone is huge, but the performance increases are far beyond that because of the way browsers handle concurrent downloads, and especially concurrent javascript loading.<&#47;p><br />
<&#47;li></p>
<li>
<p>Gzip components<&#47;p></p>
<p>This is one that really suprised me. I had no idea that gzipping components could make such a drastic difference. I had always thought that gzipping site components was only for trying to squeeze every last ounce of performance out of low-bandwidth connections. It turns out that enabling gzip compression on a few key files took their effective sizes down by about an order of magnitude. Take for example the actual front html page which was 199.7KiB during testing. Gzip was able to take it down to 19.2KiB. Here are some magical statements straight from the apache documentation:<&#47;p></p>
<pre># Insert filter<br />
SetOutputFilter DEFLATE<br />
# Netscape 4.x has some problems...<br />
BrowserMatch ^Mozilla&#47;4 gzip-only-text&#47;html<br />
# Netscape 4.06-4.08 have some more problems<br />
BrowserMatch ^Mozilla&#47;4\.0[678] no-gzip<br />
# MSIE masquerades as Netscape, but it is fine<br />
BrowserMatch \bMSI[E] !no-gzip !gzip-only-text&#47;html<br />
# Don't compress images<br />
SetEnvIfNoCase Request_URI \<br />
\.(?:gif|jpe?g|png)$ no-gzip dont-vary<br />
# Make sure proxies don't deliver the wrong content<br />
Header append Vary User-Agent env=!dont-vary<&#47;pre></p>
<p>This basically instructs apache to gzip everything except images while respecting certain browser quirkiness. I don't care to research exactly what all that Netscape 4.x quirkiness is about; I think I'll just trust the apache doc writers. Maybe I'll just take that out actually because seriously, who's using Netscape 4.x anyway?<&#47;p></p>
<p>Now cache-primed 19.2KiB front page loads are minuscule in when compared with the former 704.8KiB behemoths, and let me tell you, this web site is screaming now. The front page loads take anywhere from 0.5-4 seconds. I'm not sure why that range is so large, but I am sure that the CRM users will be much happier the next time they log in.<&#47;p><br />
<&#47;li><br />
<&#47;ol></p>
