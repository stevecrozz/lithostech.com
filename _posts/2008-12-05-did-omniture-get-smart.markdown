---
layout: post
status: publish
published: true
title: did omniture get smart?
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "[flickr-photo:id=2776816184,size=t]With my head buried in the daily grind
  of newspaper web development, I missed a very interesting twist in the story of
  Omniture, the stats tracking software we all love to hate.\r\n\r\nI haven't been
  in the field long enough to know exactly how Omniture did this, but somehow the
  company became the premier stats tracking provider for online journalism. It must
  be that Omniture has an amazing sales team. The Omniture situation seems to follow
  the pattern of things we pay a lot for when we could get a similar or even better
  service for free.\r\n\r\n"
wordpress_id: 60
date: '2008-12-05 05:46:49 -0800'
date_gmt: '2008-12-05 13:46:49 -0800'
categories:
- Uncategorized
tags:
- stats tracking
comments: []
---
<p><a href="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2008&#47;12&#47;4136613234_dc76ee0d99_o2.jpg"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2008&#47;12&#47;4136613234_dc76ee0d99_o2-290x217.jpg" alt="Omiture Smart Car" width="290" height="217" class="alignleft size-medium wp-image-521" &#47;><&#47;a>With my head buried in the daily grind of newspaper web development, I missed a very interesting twist in the story of Omniture, the stats tracking software we all love to hate.<&#47;p></p>
<p>I haven't been in the field long enough to know exactly how Omniture did this, but somehow the company became the premier stats tracking provider for online journalism. It must be that Omniture has an amazing sales team. The Omniture situation seems to follow the pattern of things we pay a lot for when we could get a similar or even better service for free.<&#47;p><a id="more"></a><a id="more-60"></a></p>
<p>Recently I made an attempt to get some very simple data out of Omniture in a format that could drive a top read stories module on our homepage. The SiteCatalyst software gave me all kinds of options for downloading a file such as Microsoft Word, Excel or even CSV format. I can even automate the delivery of those files to an email address of my choice. But I wanted to set up a pull system so I could have more control and that just wasn't going to be easy. I was nearly done with a Zend_Http_Client script to navigate the bizarre waters of SiteCatalyst v14 by following a maze of HTTP redirects, looking through REGEXing through javascript for strange tokens and submitting just the right request for the CSV report I wanted when I discovered through an acquaintance that Omniture has recently released an API.<&#47;p></p>
<p>It looks like they've seen the error of their ways and they're finally trying to reach out to the development community. They've even put up this <a href="http:&#47;&#47;developer.omniture.com&#47;">developer community<&#47;a> which happens to run on drupal if I'm not mistaken. On first glance it seems like they actually do have a small community started and a nice little SOAP API. It'll have to wait until after the December 9th launch of <a href="http:&#47;&#47;www.fresnobee.com&#47;">fresnobee.com<&#47;a>. While this doesn't make amends for years of pain, at least I don't equate omniture with the devil anymore.<&#47;p></p>
