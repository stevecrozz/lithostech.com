---
layout: post
status: publish
published: true
title: serving up python with the quickness
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 251
wordpress_url: http://lithostech.com/?p=251
date: '2010-04-05 12:13:19 -0700'
date_gmt: '2010-04-05 19:13:19 -0700'
categories:
- Uncategorized
tags:
- python
- django
- nginx
- web development
- uwsgi
comments:
- id: 1556
  author: Robert Samurai
  author_email: online@robertsamurai.com
  author_url: ''
  date: '2010-08-13 15:56:30 -0700'
  date_gmt: '2010-08-13 22:56:30 -0700'
  content: "Aside from the domain names, I have this exact same configuration.  Except,
    my UWSGI_SCRIPT is set to \"app.wsgi\".  But I get uwsgi error saying that no
    application was found when I try to visit site.  My uwsgi.log says:\r\n\r\nImportError:
    No module named app.wsgi\r\n\r\nHowever all the information i find is very ambiguous
    and doesn't layout what the UWSGI_SCRIPT value is or where it suppose to be saved.
    \ Is this suppose to be \"app_wsgi.py\" instead?"
- id: 1557
  author: stevecrozz
  author_email: stevecrozz@gmail.com
  author_url: ''
  date: '2010-08-13 16:19:05 -0700'
  date_gmt: '2010-08-13 23:19:05 -0700'
  content: "Hey Robert,\r\n\r\nIt's my understanding that whatever you set UWSGI_SCRIPT
    to will be imported like a regular python module. In your case, uWSGI is looking
    in your application path for \"app/wsgi.py\" where \"app\" is a python module
    which simply means it has an __init__.py. If you can't get that to work you can
    try passing the script name directly to the binary which I've learned is faster
    anyway.\r\n\r\nIf you're still having trouble you should join the mailing list
    and ask again (http://lists.unbit.it/cgi-bin/mailman/listinfo/uwsgi)."
- id: 1607
  author: Robert Samurai
  author_email: online@robertsamurai.com
  author_url: ''
  date: '2010-08-16 16:17:15 -0700'
  date_gmt: '2010-08-16 23:17:15 -0700'
  content: "Thanks for pointing me in the right direction!\r\n\r\nThe pylons project
    and the nested module use the same name. So that was throwing me off when setting
    the paths.  Plus it appears I can't dynamically add pythonpaths to uwsgi from
    the environmental scripts in the nginx location block. Instead, I created an xml
    for uwsgi to load the paths from.  Everything works fine now."
- id: 8897
  author: cobalt
  author_email: barzegard@gmail.com
  author_url: ''
  date: '2011-01-25 14:44:23 -0800'
  date_gmt: '2011-01-25 22:44:23 -0800'
  content: "I get this: \r\n\r\nroot@ubuntu:/etc/apt# sudo -u www-data uwsgi
    -s :9001 -d /var/log/uwsgi.log\r\nroot@ubuntu:/etc/apt# open():
    Permission denied [utils.c line 148]\r\n\r\nAny ideas?"
- id: 8905
  author: stevecrozz
  author_email: stevecrozz@gmail.com
  author_url: ''
  date: '2011-01-25 17:09:20 -0800'
  date_gmt: '2011-01-26 01:09:20 -0800'
  content: Yes. You probably don't have permission to write to /var/log/uwsgi.log
    as www-data. Try creating a /var/log/uwsgi/ and chown it for www-data:www-data.
    Then point your logger to a new file in that path.
---
Inspired by [Justin Lilly](http://justinlilly.com/), I spent some time
looking at various ways of running python web applications with an eye
to performance. [Nicholas Piël](http://nichol.as/) has done some great
work testing and
[documenting](http://nichol.as/benchmark-of-python-web-servers) many of
them. Gevent looks like a great option as does CherryPy, but uWSGI
caught my eye because it provides an nginx module and I'm already
running lots of nginx. Since its fairly new, my stock nginx from the
Ubuntu Karmic repository doesn't come with uWSGI, but compiling it in is
trivial.

So I've added uwsgi and nginx + uwsgi to my [launchpad
ppa](https://launchpad.net/~stevecrozz/+archive/ppa) for anyone out
there who'd like to give it a spin on Karmic. My initial impressions are
very positive. If you want to try it out, you can add my ppa to your apt
sources and simply run:

~~~ bash
sudo apt-get install nginx uwsgi
~~~

<!--more-->

Starting up the wsgi server is easy. You can pass it a wsgi script to
run, or you can pass it later dynamically using an environment variable
'UWSGI_SCRIPT'. Here's how I'm starting it right now:

~~~ bash
sudo -u www-data uwsgi -s :9001 -d /var/log/uwsgi.log
~~~

This simply starts uwsgi as a background process and binds to TCP port
9001 on all interfaces. I'll probably write an upstart script to deal
with this at some point, but this is working well at the moment. That's
really all you need to do to run the uwsgi server. If that's all you
wanted, then you're done, but you probably still need to setup a method
to pass uwsgi requests to the uwsgi server. Here's how you do it with
nginx:

~~~ bash
server {
  listen 80;
  server_name badtranscript.com
  root /var/www/badtranscript.com;
  location /static/ {
    root /var/www/badtranscript.com/badtranscript/;
  }
  location / {
    uwsgi_pass   127.0.0.1:9001;
    uwsgi_param  UWSGI_SCRIPT  badtranscript.deploy.wsgi;
    include      uwsgi_params;
  }
}
~~~
