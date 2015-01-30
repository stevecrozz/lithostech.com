---
layout: post
status: publish
published: true
title: stevecrozz' custom nginx binary for ubuntu 0.7.59
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "The nginx build in the official ubuntu package repository is somewhat out-of-date,
  so I built my own package from source using <a href=\"http://www.nginx.eu/download/sources/nginx-0.7.59.tar.gz\">0.7.59</a>.
  I'm going to provide it here in case anyone else would like it. One of the new features
  I like is the <a href=\"http://wiki.nginx.org/NginxHttpCoreModule#try_files\">try_files</a>
  directive. Here's an example of what I'm doing using 0.6.35, the full post is here
  <a href=\"http://lithostech.com/lighten-apaches-load-nginx\">http://lithostech.com/lighten-apaches-load-nginx</a>:\r\n\r\n"
wordpress_id: 78
date: '2009-06-08 19:45:36 -0700'
date_gmt: '2009-06-09 03:45:36 -0700'
categories:
- Uncategorized
tags:
- ubuntu
- web server
- nginx
comments: []
---
<p>Update:<&#47;p></p>
<p>I've removed the links to these files because newer and supported versions of nginx are being distributed with with 9.10. You're much better off using those anyway. This was only a stopgap.<&#47;p></p>
<p><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2009&#47;06&#47;nginx-logo-290x74.png" alt="nginx logo" width="290" height="74" class="aligncenter size-medium wp-image-499" &#47;>The nginx build in the official ubuntu package repository is somewhat out-of-date, so I built my own package from source using <a href="http:&#47;&#47;www.nginx.eu&#47;download&#47;sources&#47;nginx-0.7.59.tar.gz">0.7.59<&#47;a>. I'm going to provide it here in case anyone else would like it. One of the new features I like is the <a href="http:&#47;&#47;wiki.nginx.org&#47;NginxHttpCoreModule#try_files">try_files<&#47;a> directive. Here's an example of what I'm doing using 0.6.35, the full post is here <a href="http:&#47;&#47;lithostech.com&#47;lighten-apaches-load-nginx">http:&#47;&#47;lithostech.com&#47;lighten-apaches-load-nginx<&#47;a>:<&#47;p></p>
<pre>
location &#47; {<br />
  root &#47;var&#47;www&#47;fresnobeehive.com;<br />
  proxy_set_header X-Forwarded-For  $remote_addr;<br />
  if (-f $document_root&#47;beehive$uri) {<br />
    rewrite (.*) &#47;beehive$1 break;<br />
  }<br />
  if (-f $request_filename) {<br />
    break;<br />
  }<br />
  if (-f $request_filename&#47;index.html) {<br />
    rewrite (.*) $1&#47;index.html break;<br />
  }<br />
  if (-f $document_root&#47;beehive$uri&#47;index.html) {<br />
    rewrite (.*) &#47;beehive$1&#47;index.html break;<br />
  }<br />
  if (!-f $request_filename) {<br />
    proxy_pass http:&#47;&#47;fresnobeehive.com:8080;<br />
    break;<br />
  }<br />
}<br />
<&#47;pre></p>
<p>Here's the same thing using the new try_files syntax:<&#47;p></p>
<pre>
upstream backend {<br />
  server fresnobeehive.com:8080;<br />
}<br />
location &#47; {<br />
  try_files &#47;beehive&#47;$uri &#47;beehive&#47;$uri&#47;index.html $uri $uri&#47;index.html @mt;<br />
}<br />
location @mt {<br />
  proxy_pass http:&#47;&#47;backend;<br />
  proxy_set_header X-Forwarded-For  $remote_addr;<br />
  proxy_set_header Host $host;<br />
}<br />
<&#47;pre></p>
<p>Attached is a copy of my newer build of nginx, you are free to use my version as long as you don't expect me to support it or provide any kind of assurance that it actually works. Here's the configure line so you can see what I have enabled&#47;disabled. I have disabled a lot of things so make sure you look it over.<&#47;p></p>
<pre>
.&#47;configure $(CONFIGURE_OPTS) \<br />
    --conf-path=&#47;etc&#47;nginx&#47;nginx.conf \<br />
    --error-log-path=&#47;var&#47;log&#47;nginx&#47;error.log \<br />
    --pid-path=&#47;var&#47;run&#47;nginx.pid \<br />
    --lock-path=&#47;var&#47;lock&#47;nginx.lock \<br />
    --http-log-path=&#47;var&#47;log&#47;nginx&#47;access.log \<br />
    --http-client-body-temp-path=&#47;var&#47;lib&#47;nginx&#47;body \<br />
    --http-proxy-temp-path=&#47;var&#47;lib&#47;nginx&#47;proxy \<br />
    --http-fastcgi-temp-path=&#47;var&#47;lib&#47;nginx&#47;fastcgi \<br />
    --with-http_flv_module \<br />
    --with-http_ssl_module \<br />
    --without-mail_pop3_module \<br />
    --without-mail_smtp_module \<br />
    --without-mail_imap_module \<br />
    --without-http_ssi_module \<br />
    --without-http_userid_module \<br />
    --without-http_auth_basic_module \<br />
    --without-http_autoindex_module \<br />
    --without-http_browser_module<br />
<&#47;pre></p>
