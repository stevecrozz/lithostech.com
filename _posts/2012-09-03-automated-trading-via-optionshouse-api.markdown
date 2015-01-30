---
layout: post
status: publish
published: true
title: automated trading via optionshouse api
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "[caption id=\"attachment_481\" align=\"alignright\" width=\"290\"]<a href=\"http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2012&#47;09&#47;trading.jpg\"><img
  src=\"http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2012&#47;09&#47;trading-290x194.jpg\"
  alt=\"Stock charts\" title=\"ADM8\" width=\"290\" height=\"194\" class=\"size-medium
  wp-image-481\" &#47;><&#47;a> <a href=\"http:&#47;&#47;www.flickr.com&#47;photos&#47;arselectronica&#47;7650332104&#47;\">http:&#47;&#47;www.flickr.com&#47;photos&#47;arselectronica&#47;7650332104&#47;<&#47;a>[&#47;caption]<p>Trading
  securities is a dangerous game. It can be difficult to develop a strategy and stick
  to it in the face of an emotional marketplace that stampedes from one extreme to
  the other. Sticking to a trading strategy takes time, discipline and serious balls
  far beyond the capacity of most human beings.<&#47;p>\r\n\r\n<p>One way rise above
  the impediments is to encode your strategy into an algorithm and instruct a machine
  to execute that strategy for you. You can still freak out and pull the plug at any
  time, but until you do, machines can execute your strategy without hesitation or
  emotion. Just the exercise of encoding potential trading strategies into machine
  instructions is enough to spot problems and potential weaknesses.<&#47;p>\r\n"
wordpress_id: 476
wordpress_url: http://lithostech.com/?p=476
date: '2012-09-03 14:41:13 -0700'
date_gmt: '2012-09-03 21:41:13 -0700'
categories:
- Uncategorized
tags:
- python
- api
- optionshouse
- github
- trading
comments:
- id: 78896
  author: bobby chamblee
  author_email: bjchamblee@gmail.com
  author_url: ''
  date: '2012-12-01 15:07:31 -0800'
  date_gmt: '2012-12-01 23:07:31 -0800'
  content: Been interested in finding someone who actually is using API interface
    to automate trades on Optionshouse. Wish I new more about java and python. Thanks
    for putting on web.  I have a special need that I think a canned robot trader
    could not do.  Not sure how I'll proceed on getting my trades to automate. Thanks
    for your time to do this web site.
- id: 91245
  author: APIUSER
  author_email: apiuser@gmail.com
  author_url: http://www.google.com
  date: '2013-04-01 18:40:47 -0700'
  date_gmt: '2013-04-02 01:40:47 -0700'
  content: I just looked at the API and it does not meet my programming needs.  It
    is too complicated to use.
- id: 109902
  author: Eryck
  author_email: eryck2352@gmail.com
  author_url: ''
  date: '2014-06-19 00:55:43 -0700'
  date_gmt: '2014-06-19 07:55:43 -0700'
  content: Hi steve. i also have an account with optionshouse, and am thinking about
    algo trading. I'd like to ask you a couple questions regarding on such issue.
    First of all, do they charge you extra for using api to interact with them?? secondly,
    is the api only works with python?
- id: 109982
  author: Adam
  author_email: realfutbol13@gmail.com
  author_url: ''
  date: '2014-07-23 16:06:26 -0700'
  date_gmt: '2014-07-23 23:06:26 -0700'
  content: "Hi Eryck - I can tell you that if you look at Optionshouses' api, it's
    designed to be interfaced with any language capable of sending web requests (POST&#47;GET
    etc.) via https. Python is one. You could use Java. Javascript. Literally any
    language will have some facility for it. Stephen just chose to use python as his
    language of choice for this - I've actually done the same. \r\n\r\nAnd no, they
    don't charge extra, but there are limits on the service. I'd suggest reaching
    out to them for more info."
- id: 110239
  author: trading algorithm &mdash; how to write and deploy &laquo; lithostech.com
  author_email: ''
  author_url: http://lithostech.com/2014/09/trading-algorithm-write-and-deploy/
  date: '2014-10-16 16:22:27 -0700'
  date_gmt: '2014-10-16 23:22:27 -0700'
  content: "[&#8230;] our work on the OptionsHouse API client, we&#039;ve somehow
    become known as trading algorithm experts. At least once a week, Branded Crate
    gets [&#8230;]"
---
<p>[caption id="attachment_481" align="alignright" width="290"]<a href="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2012&#47;09&#47;trading.jpg"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2012&#47;09&#47;trading-290x194.jpg" alt="Stock charts" title="ADM8" width="290" height="194" class="size-medium wp-image-481" &#47;><&#47;a> <a href="http:&#47;&#47;www.flickr.com&#47;photos&#47;arselectronica&#47;7650332104&#47;">http:&#47;&#47;www.flickr.com&#47;photos&#47;arselectronica&#47;7650332104&#47;<&#47;a>[&#47;caption]
<p>Trading securities is a dangerous game. It can be difficult to develop a strategy and stick to it in the face of an emotional marketplace that stampedes from one extreme to the other. Sticking to a trading strategy takes time, discipline and serious balls far beyond the capacity of most human beings.<&#47;p></p>
<p>One way rise above the impediments is to encode your strategy into an algorithm and instruct a machine to execute that strategy for you. You can still freak out and pull the plug at any time, but until you do, machines can execute your strategy without hesitation or emotion. Just the exercise of encoding potential trading strategies into machine instructions is enough to spot problems and potential weaknesses.<&#47;p><br />
<a id="more"></a><a id="more-476"></a></p>
<p>That's why my highest priority when choosing a stock broker was API quality. Strangely, I only found one broker who's trading API was even acceptable, OptionsHouse. The OptionsHouse API offers all the functionality you need to create simple trading algorithms, the documentation is acceptable and they offer paper trading accounts so you can easily test your algorithms without using any real money (an absolute requirement).<&#47;p></p>
<p>To get started learning how to use the API, I created a generic API client in Python. My aim was primarily to create something generic enough to be useful to anyone who wants to automate interaction with OptionsHouse, and secondarily to create something reliable with unit tests that guarantee certain functionality:<&#47;P></p>
<p><a href="https:&#47;&#47;github.com&#47;stevecrozz&#47;optionshouse-api-client">https:&#47;&#47;github.com&#47;stevecrozz&#47;optionshouse-api-client<&#47;a><&#47;p></p>
