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
excerpt: "<p>Inspired by <a href=\"http:&#47;&#47;justinlilly.com&#47;\">Justin Lilly<&#47;a>,
  I spent some time looking at various ways of running python web applications with
  an eye to performance. <a href=\"http:&#47;&#47;nichol.as&#47;\">Nicholas Pi&euml;l<&#47;a>
  has done some great work testing and <a href=\"http:&#47;&#47;nichol.as&#47;benchmark-of-python-web-servers\">documenting<&#47;a>
  many of them. Gevent looks like a great option as does CherryPy, but uWSGI caught
  my eye because it provides an nginx module and I'm already running lots of nginx.
  Since its fairly new, my stock nginx from the Ubuntu Karmic repository doesn't come
  with uWSGI, but compiling it in is trivial.<&#47;p>\r\n\r\n<p>So I've added uwsgi
  and nginx + uwsgi to my <a href=\"https:&#47;&#47;launchpad.net&#47;~stevecrozz&#47;+archive&#47;ppa\">launchpad
  ppa<&#47;a> for anyone out there who'd like to give it a spin on Karmic. My initial
  impressions are very positive. If you want to try it out, you can add my ppa to
  your apt sources and simply run:<&#47;p>\r\n<pre>sudo apt-get install nginx uwsgi<&#47;pre>\r\n"
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
- id: 1294
  author: new opportunities at rightscale &laquo; lithostech.com
  author_email: ''
  author_url: http://lithostech.com/2010/08/new-opportunities-at-rightscale/
  date: '2010-08-01 19:19:46 -0700'
  date_gmt: '2010-08-02 02:19:46 -0700'
  content: "[...] enough, my small effort in packaging uWSGI for Ubuntu was what prompted
    some communication with a RightScale employee who encouraged me to apply for a
    [...]"
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
    in your application path for \"app&#47;wsgi.py\" where \"app\" is a python module
    which simply means it has an __init__.py. If you can't get that to work you can
    try passing the script name directly to the binary which I've learned is faster
    anyway.\r\n\r\nIf you're still having trouble you should join the mailing list
    and ask again (http:&#47;&#47;lists.unbit.it&#47;cgi-bin&#47;mailman&#47;listinfo&#47;uwsgi)."
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
  content: "I get this: \r\n\r\nroot@ubuntu:&#47;etc&#47;apt# sudo -u www-data uwsgi
    -s :9001 -d &#47;var&#47;log&#47;uwsgi.log\r\nroot@ubuntu:&#47;etc&#47;apt# open():
    Permission denied [utils.c line 148]\r\n\r\nAny ideas?"
- id: 8905
  author: stevecrozz
  author_email: stevecrozz@gmail.com
  author_url: ''
  date: '2011-01-25 17:09:20 -0800'
  date_gmt: '2011-01-26 01:09:20 -0800'
  content: Yes. You probably don't have permission to write to &#47;var&#47;log&#47;uwsgi.log
    as www-data. Try creating a &#47;var&#47;log&#47;uwsgi&#47; and chown it for www-data:www-data.
    Then point your logger to a new file in that path.
---
<p>Inspired by <a href="http:&#47;&#47;justinlilly.com&#47;">Justin Lilly<&#47;a>, I spent some time looking at various ways of running python web applications with an eye to performance. <a href="http:&#47;&#47;nichol.as&#47;">Nicholas Pi&euml;l<&#47;a> has done some great work testing and <a href="http:&#47;&#47;nichol.as&#47;benchmark-of-python-web-servers">documenting<&#47;a> many of them. Gevent looks like a great option as does CherryPy, but uWSGI caught my eye because it provides an nginx module and I'm already running lots of nginx. Since its fairly new, my stock nginx from the Ubuntu Karmic repository doesn't come with uWSGI, but compiling it in is trivial.<&#47;p></p>
<p>So I've added uwsgi and nginx + uwsgi to my <a href="https:&#47;&#47;launchpad.net&#47;~stevecrozz&#47;+archive&#47;ppa">launchpad ppa<&#47;a> for anyone out there who'd like to give it a spin on Karmic. My initial impressions are very positive. If you want to try it out, you can add my ppa to your apt sources and simply run:<&#47;p></p>
<pre>sudo apt-get install nginx uwsgi<&#47;pre><br />
<a id="more"></a><a id="more-251"></a>
<p>Starting up the wsgi server is easy. You can pass it a wsgi script to run, or you can pass it later dynamically using an environment variable 'UWSGI_SCRIPT'. Here's how I'm starting it right now:<&#47;p></p>
<pre>sudo -u www-data uwsgi -s :9001 -d &#47;var&#47;log&#47;uwsgi.log<&#47;pre></p>
<p>This simply starts uwsgi as a background process and binds to TCP port 9001 on all interfaces. I'll probably write an upstart script to deal with this at some point, but this is working well at the moment. That's really all you need to do to run the uwsgi server. If that's all you wanted, then you're done, but you probably still need to setup a method to pass uwsgi requests to the uwsgi server. Here's how you do it with nginx:<&#47;p></p>
<pre>server {<br />
  listen 80;<br />
  server_name badtranscript.com<br />
  root &#47;var&#47;www&#47;badtranscript.com;</p>
<p>  location &#47;static&#47; {<br />
    root &#47;var&#47;www&#47;badtranscript.com&#47;badtranscript&#47;;<br />
  }</p>
<p>  location &#47; {<br />
    uwsgi_pass&nbsp;&nbsp; 127.0.0.1:9001;<br />
    uwsgi_param&nbsp; UWSGI_SCRIPT&nbsp; badtranscript.deploy.wsgi;<br />
    include&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; uwsgi_params;<br />
  }<br />
}<&#47;pre></p>
