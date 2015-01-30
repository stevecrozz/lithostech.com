---
layout: post
status: publish
published: true
title: upgrading movabletype-opensource on debian&#47;ubuntu
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: Since 2008, Debian has had a <a href="http://www.movabletype.org/2008/04/_aptget_install_movabletypeope.html">movabletype-opensource
  package</a> available in the <a href="http://packages.debian.org/unstable/web/movabletype-opensource">repository</a>.
  That's good news for people who like to make short work of system administration.
  Unfortunately, the package in the repository isn't the very latest and greatest.
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
<p>Since 2008, Debian has had a <a href="http:&#47;&#47;www.movabletype.org&#47;2008&#47;04&#47;_aptget_install_movabletypeope.html">movabletype-opensource package<&#47;a> available in the <a href="http:&#47;&#47;packages.debian.org&#47;unstable&#47;web&#47;movabletype-opensource">repository<&#47;a>. That's good news for people who like to make short work of system administration. Unfortunately, the package in the repository isn't the very latest and greatest. Even so, there are big benefits to using aptitude to install movable type, the main one being that it automatically installs all the various dependencies and offloads your job (maintaining those packages) to someone else. Plus the file locations are well-thought-out. Rather than throwing everything right into the web root the package maintainer put the cgi files into a common cgi-bin folder, the shared files into &#47;usr&#47;shared, the perl modules into the shared perl library, and the configuration files into &#47;etc.<&#47;p><a id="more"></a><a id="more-66"></a></p>
<p>Because I imagine I'll be upgrading my install of MT from time to time, I wrote this script so I can be even more lazy in the future, and I'll put it here in case anyone else wants to use it. It's only been tested on a brand new Ubuntu 8.10 install and the <a href="http:&#47;&#47;www.movabletype.org&#47;downloads&#47;stable&#47;MTOS-4.23-en.zip">MTOS-4.23-en.zip package<&#47;a>.<&#47;p></p>
<p>To use this script simply download your MT package and test it like this:<br />
bash upgrade-mt.sh --test MTOS-4.23-en.zip<br />
after you double-check all them commands it's going to run, run it without --test.<&#47;p></p>
<pre>
#!&#47;bin&#47;bash</p>
<p>if [ $1 == "--test" ]<br />
then<br />
TEST="echo "<br />
echo "This script will run the following commands when run without --test:"<br />
echo ""<br />
MT_PACKAGE_ZIP=$2<br />
else<br />
MT_PACKAGE_ZIP=$1<br />
fi</p>
<p>MT_PACKAGE_ZIP=$1<br />
MT_PACKAGE=${MT_PACKAGE_ZIP&#47;.zip&#47;&#47;}</p>
<p># Environment settings, change them if necessary<br />
PERL_LIB=&#47;usr&#47;share&#47;perl5&#47;<br />
MT_COMMON=&#47;usr&#47;share&#47;movabletype&#47;<br />
MT_CGI=&#47;usr&#47;lib&#47;cgi-bin&#47;movabletype&#47;</p>
<p>echo "Unzipping package:"<br />
$TEST unzip $MT_PACKAGE_ZIP<br />
echo ""</p>
<p>echo "Installing shared perl modules:"<br />
# Install shared perl modules<br />
$TEST cp -r -v ${MT_PACKAGE}lib&#47;* $PERL_LIB<br />
echo ""</p>
<p>echo "Installing MT common files:"<br />
# Install MT common files and the mt-static folder<br />
$TEST cp -r -v ${MT_PACKAGE}default_templates&#47; ${MT_COMMON}<br />
$TEST cp -r -v ${MT_PACKAGE}extlib&#47; ${MT_COMMON}<br />
$TEST cp -r -v ${MT_PACKAGE}plugins&#47; ${MT_COMMON}<br />
$TEST cp -r -v ${MT_PACKAGE}search_templates&#47; ${MT_COMMON}<br />
$TEST cp -r -v ${MT_PACKAGE}tmpl&#47; ${MT_COMMON}<br />
$TEST cp -r -v ${MT_PACKAGE}tools&#47; ${MT_COMMON}<br />
echo ""</p>
<p>echo "Setting up mt-static folder"<br />
$TEST cp -r -v ${MT_PACKAGE}mt-static&#47; ${MT_COMMON}<br />
echo ""</p>
<p>echo "Installing CGI files"<br />
# Install MT cgi files, making sure to keep the old mt.cgi with the correct path to the MT modules<br />
$TEST cp -r -v ${MT_CGI}mt.cgi $MT_PACKAGE<br />
$TEST cp -r -v ${MT_PACKAGE}*.cgi $MT_CGI<br />
echo ""</p>
<p>echo "Cleaning up"<br />
$TEST rm -R $MT_PACKAGE<br />
<&#47;pre></p>
