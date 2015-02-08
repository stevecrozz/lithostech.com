---
layout: post
status: publish
published: true
title: worst javascript of the year award
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "I was looking at the bottomless pit of badly-written and malformed javascript
  that loads on fresnobee.com the other day and noticed a peculiar filename loading
  multiple times (of-course) in our advertisements: DocumentDotWrite.js. Since I loathe
  the overuse of document.write on our site, it piqued my interest. I had to see what
  on earth could be in this ridiculously named script.\r\n\r\n<code type=\"javascript\">\r\nfunction
  DocumentDotWrite(s){\r\n  document.write(s);\r\n}\r\n</code>\r\n\r\n"
wordpress_id: 61
date: '2008-12-08 21:27:57 -0800'
date_gmt: '2008-12-09 05:27:57 -0800'
categories:
- Uncategorized
tags:
- programming
comments:
- id: 7
  author: ''
  author_email: ''
  author_url: ''
  date: '2009-02-05 14:17:31 -0800'
  date_gmt: ''
  content: '"coding"'
- id: 15
  author: ''
  author_email: ''
  author_url: ''
  date: '2008-12-08 21:37:43 -0800'
  date_gmt: ''
  content: "More than likely this was in part a workaround for the whole <a href=\"http://en.wikipedia.org/wiki/Eolas#Browser_changes\">\"Click
    to activate this control\"</a> problem.\r\n\r\nIf I remember correctly, a
    document.write() call from the page itself was not sufficient to work around the
    problem, but any document.write() call from an external script was.\r\n\r\nAs
    for the script tag being written by a document.write() call in an iframe written
    by a call to document.write yadda yadda, I can't vouch for that."
- id: 16
  author: ''
  author_email: ''
  author_url: ''
  date: '2008-12-08 23:58:36 -0800'
  date_gmt: ''
  content: I write my best code when high on crack.
---
I was looking at the bottomless pit of badly-written and malformed javascript that loads on fresnobee.com the other day and noticed a peculiar filename loading multiple times (of-course) in our advertisements: DocumentDotWrite.js. Since I loathe the overuse of document.write on our site, it piqued my interest. I had to see what on earth could be in this ridiculously named script.
<pre>
function DocumentDotWrite(s){
  document.write(s);
}
</pre><a id="more"></a><a id="more-61"></a>
It didn't take long to figure out what this does, but I still haven't figured out the why. Why in the world would anyone need this? Is it one component of a basic abstraction pattern for different implementations of document.write? It's certainly not easier to type DocumentDotWrite so it couldn't be a shorthand. This is where context comes into play. The script tag itself is written by a document.write call which is contained within an iframe which is written by a call to document.write which is loaded by another remote script whose tag is written with a call to... take a wild guess.
If you don't believe me, <a href="http://rmd.atdmt.com/tl/DocumentDotWrite.js">here's the link</a>. I think it's most likely that the developer who wrote this fine gem was probably high on crack and shouldn't have been writing javascript in the first place. To the folks over at atdmt.com, and at doubleclick, I have nothing to say besides "I hate you" and you should maybe hire just one real developer. Also, start issuing random drug tests.
