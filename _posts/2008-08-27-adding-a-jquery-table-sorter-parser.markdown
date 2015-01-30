---
layout: post
status: publish
published: true
title: adding a jQuery table sorter parser
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "We're getting ready to launch a new <a href=\"http://data.fresnobeehive.com/bulldogs/\">college
  football site</a> for the upcoming Fresno State Bulldogs season. The site uses a
  table to display a player roster. Adding sortable columns to the table is a snap
  with jQuery. All you have to do is load the <a href=\"http://tablesorter.com/\">tablesorter
  plugin</a>, and call it up when the page loads. This makes every table you have
  sortable:\r\n<code type=\"javascript\">\r\n$(document).ready( function() { \r\n
  \ $('table').tablesorter();\r\n});\r\n</code>\r\n\r\n"
wordpress_id: 40
date: '2008-08-27 18:55:58 -0700'
date_gmt: '2008-08-28 02:55:58 -0700'
categories:
- Uncategorized
tags:
- programming
comments: []
---
<p>We're getting ready to launch a new <a href="http:&#47;&#47;data.fresnobeehive.com&#47;bulldogs&#47;">college football site<&#47;a> for the upcoming Fresno State Bulldogs season. The site uses a table to display a player roster. Adding sortable columns to the table is a snap with jQuery. All you have to do is load the <a href="http:&#47;&#47;tablesorter.com&#47;">tablesorter plugin<&#47;a>, and call it up when the page loads. This makes every table you have sortable:<&#47;p></p>
<pre>
$(document).ready( function() {<br />
  $('table').tablesorter();<br />
});<br />
<&#47;pre><br />
<a id="more"></a><a id="more-40"></a></p>
<p>For most tables that's all you need to make it work beautifully, but in my case the plugin was having trouble sorting my height column. It looks like it was sorting that column as text, but that doesn't work because in the US we like to see our football player's heights in feet and inches such as 5' 11" for five feet and eleven inches. Thankfully the table sorter plugin allows you to define your own column types which it can automatically detect and sort for you.<&#47;p></p>
<pre>
$(document).ready( function() {<br />
  $.tablesorter.addParser({<br />
    id: 'height',<br />
    is: function(s) {<br />
      &#47;&#47;$.tablesorter uses this function to determine if this colum is of this type<br />
      return s.match(new RegExp(&#47;^\d{1}\' \d{1,2}\"&#47;));<br />
    },<br />
    format: function(s) {<br />
      &#47;&#47;now we'll just return the number of inches and $.tablesorter will sort them as integers<br />
      var matches = s.match(new RegExp(&#47;^(\d{1})\' (\d{1,2})\"&#47;), 'g');<br />
      return parseInt(matches[1]) * 12 + parseInt(matches[2]);<br />
    }<br />
  });<br />
  $('table').tablesorter();<br />
});<br />
<&#47;pre></p>
