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
wordpress_id: 40
date: '2008-08-27 18:55:58 -0700'
date_gmt: '2008-08-28 02:55:58 -0700'
tags:
- programming
comments: []
---
We're getting ready to launch a new [college football
site](http://data.fresnobeehive.com/bulldogs/) for the upcoming Fresno
State Bulldogs season. The site uses a table to display a player roster.
Adding sortable columns to the table is a snap with jQuery. All you have
to do is load the [tablesorter plugin](http://tablesorter.com/), and
call it up when the page loads. This makes every table you have
sortable:

~~~ javascript
$(document).ready( function() {
  $('table').tablesorter();
});
~~~

For most tables that's all you need to make it work beautifully, but in
my case the plugin was having trouble sorting my height column. It looks
like it was sorting that column as text, but that doesn't work because
in the US we like to see our football player's heights in feet and
inches such as 5' 11" for five feet and eleven inches. Thankfully the
table sorter plugin allows you to define your own column types which it
can automatically detect and sort for you.

~~~ javascript
$(document).ready( function() {
  $.tablesorter.addParser({
    id: 'height',
    is: function(s) {
      //$.tablesorter uses this function to determine if this colum is of this type
      return s.match(new RegExp(/^\d{1}\' \d{1,2}\"/));
    },
    format: function(s) {
      //now we'll just return the number of inches and $.tablesorter will sort them as integers
      var matches = s.match(new RegExp(/^(\d{1})\' (\d{1,2})\"/), 'g');
      return parseInt(matches[1]) * 12 + parseInt(matches[2]);
    }
  });
  $('table').tablesorter();
});
~~~
