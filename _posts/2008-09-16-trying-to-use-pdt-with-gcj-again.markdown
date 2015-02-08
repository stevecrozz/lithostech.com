---
layout: post
status: publish
published: true
title: trying to use PDT with GCJ, again
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "After upgrading to Intrepid Ibex Alpha 5, I was presented with a familiar
  problem. I knew I had dealt with this at least a half-dozen times in the past, but
  I never seem to learn. It all happened when I tried to import a project I'd started
  from my subversion repository into eclipse on my laptop. I began to get very strange
  un-googlable Java errors that I knew I'd seen before. Here's two of them:\r\n\r\n<code
  type=\"java\">\r\njava.lang.nullpointerexception\r\njava.lang.NoClassDefFoundError:
  org.eclipse.emf.ecore.util.EcoreEMap$DelegateEObjectContainmentEList\r\n</code>\r\n\r\n"
wordpress_id: 48
date: '2008-09-16 19:10:36 -0700'
date_gmt: '2008-09-17 03:10:36 -0700'
categories:
- Uncategorized
tags:
- programming
- ubuntu
comments: []
---
<a href="http://lithostech.com/wp-content/uploads/2008/09/pdt.png"><img src="http://lithostech.com/wp-content/uploads/2008/09/pdt-300x222.png" alt="eclipse pdt screenshot" title="pdt" width="300" height="222" class="alignright size-medium wp-image-210" /></a>After upgrading to Intrepid Ibex Alpha 5, I was presented with a familiar problem. I knew I had dealt with this at least a half-dozen times in the past, but I never seem to learn. It all happened when I tried to import a project I'd started from my subversion repository into eclipse on my laptop. I began to get very strange un-googlable Java errors that I knew I'd seen before. Here's two of them:
<pre>
java.lang.nullpointerexception
java.lang.NoClassDefFoundError: org.eclipse.emf.ecore.util.EcoreEMap$DelegateEObjectContainmentEList
</pre><a id="more"></a><a id="more-48"></a>
When I made the distribution upgrade, I failed to notice that my symbolic link /etc/alternatives/java (pointed to by /usr/bin/java) had changed. Instead of using Sun Java, I was back to using GCJ. GCJ is a great effort, and if it could run PDT smoothly I would use it in a heartbeat. Until then, I'm forced to use Sun Java. Don't bother changing the symbolic links by hand, Ubuntu has a handy tool to do that for you. It would have been nice to have preserved my original configuration though.
<pre>
sudo update-java-alternatives --set java-6-sun
</pre>
Next time I get these messages maybe I'll remember to check which Java I'm using.
