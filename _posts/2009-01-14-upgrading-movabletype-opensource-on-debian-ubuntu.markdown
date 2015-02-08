---
layout: post
status: publish
published: true
title: upgrading movabletype-opensource on debian/ubuntu
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 66
date: '2009-01-14 20:25:25 -0800'
date_gmt: '2009-01-15 04:25:25 -0800'
categories:
- Uncategorized
tags:
- ubuntu
- content management
comments:
- id: 97325
  author: queenofbirmingham.blog.com
  author_email: kaitlyn-russ@yahoo.com
  author_url: http://queenofbirmingham.blog.com/
  date: '2013-06-23 03:15:11 -0700'
  date_gmt: '2013-06-23 10:15:11 -0700'
  content: "Good day! Do you know if they make any plugins to help with \r\nSEO? I'm
    trying to get my blog to rank for some targeted keywords but I'm not \r\nseeing
    very good results. If you know of any please share.\r\nThank you!"
---
Since 2008, Debian has had a [movabletype-opensource
package](http://www.movabletype.org/2008/04/_aptget_install_movabletypeope.html)
available in the
[repository](http://packages.debian.org/unstable/web/movabletype-opensource).
That's good news for people who like to make short work of system
administration. Unfortunately, the package in the repository isn't the
very latest and greatest. Even so, there are big benefits to using
aptitude to install movable type, the main one being that it
automatically installs all the various dependencies and offloads your
job (maintaining those packages) to someone else. Plus the file
locations are well-thought-out. Rather than throwing everything right
into the web root the package maintainer put the cgi files into a common
cgi-bin folder, the shared files into /usr/shared, the perl modules into
the shared perl library, and the configuration files into /etc.

Because I imagine I'll be upgrading my install of MT from time to time,
I wrote this script so I can be even more lazy in the future, and I'll
put it here in case anyone else wants to use it. It's only been tested
on a brand new Ubuntu 8.10 install and the [MTOS-4.23-en.zip
package](http://www.movabletype.org/downloads/stable/MTOS-4.23-en.zip).

<!--more-->

To use this script simply download your MT package and test it like
this:

~~~ bash
bash upgrade-mt.sh --test MTOS-4.23-en.zip
~~~

after you double-check all them commands it's going to run, run it without --test.

~~~ bash
#!/bin/bash
if [ $1 == "--test" ]
then
TEST="echo "
echo "This script will run the following commands when run without --test:"
echo ""
MT_PACKAGE_ZIP=$2
else
MT_PACKAGE_ZIP=$1
fi
MT_PACKAGE_ZIP=$1
MT_PACKAGE=${MT_PACKAGE_ZIP/.zip//}
# Environment settings, change them if necessary
PERL_LIB=/usr/share/perl5/
MT_COMMON=/usr/share/movabletype/
MT_CGI=/usr/lib/cgi-bin/movabletype/
echo "Unzipping package:"
$TEST unzip $MT_PACKAGE_ZIP
echo ""
echo "Installing shared perl modules:"
# Install shared perl modules
$TEST cp -r -v ${MT_PACKAGE}lib/* $PERL_LIB
echo ""
echo "Installing MT common files:"
# Install MT common files and the mt-static folder
$TEST cp -r -v ${MT_PACKAGE}default_templates/ ${MT_COMMON}
$TEST cp -r -v ${MT_PACKAGE}extlib/ ${MT_COMMON}
$TEST cp -r -v ${MT_PACKAGE}plugins/ ${MT_COMMON}
$TEST cp -r -v ${MT_PACKAGE}search_templates/ ${MT_COMMON}
$TEST cp -r -v ${MT_PACKAGE}tmpl/ ${MT_COMMON}
$TEST cp -r -v ${MT_PACKAGE}tools/ ${MT_COMMON}
echo ""
echo "Setting up mt-static folder"
$TEST cp -r -v ${MT_PACKAGE}mt-static/ ${MT_COMMON}
echo ""
echo "Installing CGI files"
# Install MT cgi files, making sure to keep the old mt.cgi with the correct path to the MT modules
$TEST cp -r -v ${MT_CGI}mt.cgi $MT_PACKAGE
$TEST cp -r -v ${MT_PACKAGE}*.cgi $MT_CGI
echo ""
echo "Cleaning up"
$TEST rm -R $MT_PACKAGE
~~~
