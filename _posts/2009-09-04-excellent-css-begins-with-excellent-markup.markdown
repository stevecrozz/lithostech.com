---
layout: post
status: publish
published: true
title: excellent css begins with excellent markup
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "[flickr-photo:id=1438778328,size=m]In the early days of the web (the early
  '90s), when the first HTML specification was being adopted, CSS did not exist. Web
  developers and webmasters (do those even exist anymore?) were responsible for delivering
  their content, design and layout in one package. It worked great and everything
  was right with the world. That is, until things became more complex. The roaring
  '90s of the Internet brought new revisions to the HTML specification and new innovations
  to web browsers which allowed for increasingly complicated design elements and content
  delivery methods. The ever-increasing complexity made it more difficult to maintain
  consistent design across large web sites. That's when big stupid web design suites
  became popular. Software like Microsoft FrontPage and Macromedia Dreamweaver became
  almost a necessity just to maintain page templates and edit pages in a wysiwyg format.\r\n"
wordpress_id: 80
date: '2009-09-04 17:24:46 -0700'
date_gmt: '2009-09-05 01:24:46 -0700'
categories:
- Uncategorized
tags:
- design
- web development
comments: []
---
<p><a href="http:&#47;&#47;www.flickr.com&#47;photos&#47;pickupjojo&#47;1438778328"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2009&#47;09&#47;4136613234_dc76ee0d99_o-290x217.jpg" alt="apple expo &#039;07" width="290" height="217" class="alignleft size-medium wp-image-497" &#47;><&#47;a>In the early days of the web (the early '90s), when the first HTML specification was being adopted, CSS did not exist. Web developers and webmasters (do those even exist anymore?) were responsible for delivering their content, design and layout in one package. It worked great and everything was right with the world. That is, until things became more complex. The roaring '90s of the Internet brought new revisions to the HTML specification and new innovations to web browsers which allowed for increasingly complicated design elements and content delivery methods. The ever-increasing complexity made it more difficult to maintain consistent design across large web sites. That's when big stupid web design suites became popular. Software like Microsoft FrontPage and Macromedia Dreamweaver became almost a necessity just to maintain page templates and edit pages in a wysiwyg format.<&#47;p><br />
<a id="more"></a><a id="more-80"></a></p>
<p>At some point, smart people got fed up with this crap and said, "Wouldn't it be great if HTML didn't even exist? Content could be delivered to users in an abstract format like XML and we'll use something separate to control the design." Following good programming practices, content and design should be completely separate beasts, and hence XHTML and CSS was born.<&#47;p></p>
<p>Unfortunately, web developers and designers had to follow a simple rule that still holds true today: If you want consistent support across all the major web browsers, you have to write your markup using old specifications. Web browser vendors also had to follow a similar rule: If you want your web browser to work against the whole of the Internet, you have to continue eternal support for the oldest specifications that still remain in use anywhere on the Internet. So the desire for consistent support from web developers and designers and browser vendors combined with a heaping helping of laziness gives us what we have today.<&#47;p></p>
<p>So instead of just blathering on for paragraphs on what good markup looks like, I'm going to break it down into a few short examples and write a short quip on each one.<&#47;p></p>
<ol>
<li>
<p>XHTML&#47;CSS allows you to separate your design from your content; try not to recombine them.<&#47;p></p>
<pre>
<strong>Bad:<&#47;strong><br />
<span style="color: red;">Password must contain at least 6 characters<&#47;span><br />
<strong>Good:<&#47;strong></p>
<style type="text&#47;css">form .error { color: red; }<&#47;style><br />
<span class="error">Password must contain at least 6 characters<&#47;span><br />
<&#47;pre><br />
<&#47;li></p>
<li>
This is just as bad, if not worse, because you went through the work of separating your design from your content only to combine them again in name. If you want to change the style of this form error to another color, you still have to change the stylesheet and the markup in order for it to semantically make sense.</p>
<pre>
<strong>Bad:<&#47;strong></p>
<style type="text&#47;css">.red { color: red; }<&#47;style><br />
<span class="red">Password must contain at least 6 characters<&#47;span><br />
<strong>Good:<&#47;strong></p>
<style type="text&#47;css">form .error { color: red; }<&#47;style><br />
<span class="error">Password must contain at least 6 characters<&#47;span><br />
<&#47;pre><br />
<&#47;li></p>
<li>
Even the oldest CSS specifications allow for inheritance, so write your markup in a way that allows you to really take advantage of that. This allows you to use the error class name in multiple contexts and specify exactly the style you want within a given context. Use inheritance.</p>
<pre>
<strong>Bad:<&#47;strong></p>
<style type="text&#47;css">.form-error { color: red; }<&#47;style><br />
<span class="form-error">Password must contain at least 6 characters<&#47;span><br />
<strong>Good:<&#47;strong></p>
<style type="text&#47;css">form .error { color: red; }<&#47;style><br />
<span class="error">Password must contain at least 6 characters<&#47;span><br />
<&#47;pre><br />
<&#47;li></p>
<li>
Never use the font tag, its not valid XHTML and for good reason. This tag embodies exactly what XHTML is trying overcome. I know your browser will render it properly, but your browser will also render it properly using XHTML&#47;CSS. If you are reading this and don't understand why this is bad and you plan on continuing with this type of markup, then you should probably just stop reading here.</p>
<pre>
<strong>Bad:<&#47;strong><br />
<font color="red">Password must contain at least 6 characters<&#47;font><br />
<&#47;pre><br />
<&#47;li></p>
<li>
Use valid built-in XHTML tags instead of a billion spans with custom class names. Do you think an h1 looks too big? Then make it smaller. As a side note, don't start with h3 and use up all the headline tags down to h6 and then think you ran out. Why would you do that? Don't want to start with an h1 just in case you need something bigger? If you need something bigger than a top level headline, then its not a headline so there's nothing to worry about because you won't be needing a headline tag. Start with h1 and style them all exactly how you want them. If you need more than 6, then you're probably doing it wrong. Try using inheritance to style your headlines within a certain context instead of creating new class names.</p>
<pre>
<strong>Bad:<&#47;strong></p>
<h3>A headline<&#47;h3></p>
<h4>Another headline<&#47;h4></p>
<h5>Yet Another headline<&#47;h5></p>
<h6 class="style-a">Tired of this yet?<&#47;h6></p>
<h6 class="i-ran-out">Headline!!<&#47;h6><br />
<strong>Good:<&#47;strong></p>
<h1>A headline<&#47;h1></p>
<h2>Another headline<&#47;h2></p>
<h3>Yet Another headline<&#47;h3></p>
<h4>Tired of this yet?<&#47;h4></p>
<h5>Still got one left!!<&#47;h5><br />
<&#47;pre><br />
<&#47;li></p>
<li>
Don't use bold tags for the same reason you shouldn't use font tags. Bold tags combine content and design. This one seems to be one of the most confusing for some people to grasp. I don't know why, maybe its because b seems so much quicker than strong. The problem is, your designer might decide to change the style, and good markup will allow him to make that change by editing stylesheets alone.</p>
<pre>
<strong>Bad:<&#47;strong><br />
<b>Some bold text<&#47;b><br />
<strong>Good:<&#47;strong><br />
<strong>Some possibly bold text<&#47;strong><br />
<&#47;pre><br />
<&#47;li><br />
<&#47;ol></p>
