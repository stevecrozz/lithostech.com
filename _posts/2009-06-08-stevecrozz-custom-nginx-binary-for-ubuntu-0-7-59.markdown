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
{% responsive_image path: static/img/full/2009/nginx-logo.png alt:
"nginx logo" class: "img-float-left" %} The nginx build in the official
ubuntu package repository is somewhat out-of-date, so I built my own
package from source using
[0.7.59](http://www.nginx.eu/download/sources/nginx-0.7.59.tar.gz). I'm
going to provide it here in case anyone else would like it. One of the
new features I like is the
[try_files](http://wiki.nginx.org/NginxHttpCoreModule#try_files)
directive. Here's an example of what I'm doing using 0.6.35, the full
post is here
[http://lithostech.com/lighten-apaches-load-nginx](http://lithostech.com/lighten-apaches-load-nginx):

~~~ nginx
location / {
  root /var/www/fresnobeehive.com;
  proxy_set_header X-Forwarded-For  $remote_addr;
  if (-f $document_root/beehive$uri) {
    rewrite (.*) /beehive$1 break;
  }
  if (-f $request_filename) {
    break;
  }
  if (-f $request_filename/index.html) {
    rewrite (.*) $1/index.html break;
  }
  if (-f $document_root/beehive$uri/index.html) {
    rewrite (.*) /beehive$1/index.html break;
  }
  if (!-f $request_filename) {
    proxy_pass http://fresnobeehive.com:8080;
    break;
  }
}
~~~

<!--more-->

Here's the same thing using the new try_files syntax:

~~~ nginx
upstream backend {
  server fresnobeehive.com:8080;
}
location / {
  try_files /beehive/$uri /beehive/$uri/index.html $uri $uri/index.html @mt;
}
location @mt {
  proxy_pass http://backend;
  proxy_set_header X-Forwarded-For  $remote_addr;
  proxy_set_header Host $host;
}
~~~

Attached is a copy of my newer build of nginx, you are free to use my
version as long as you don't expect me to support it or provide any kind
of assurance that it actually works. Here's the configure line so you
can see what I have enabled/disabled. I have disabled a lot of things so
make sure you look it over.

~~~ bash
./configure $(CONFIGURE_OPTS) \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --with-http_flv_module \
    --with-http_ssl_module \
    --without-mail_pop3_module \
    --without-mail_smtp_module \
    --without-mail_imap_module \
    --without-http_ssi_module \
    --without-http_userid_module \
    --without-http_auth_basic_module \
    --without-http_autoindex_module \
    --without-http_browser_module
~~~

**Update**
I've removed the links to these files because newer and supported
versions of nginx are being distributed with with 9.10. You're much
better off using those anyway. This was only a stopgap.
