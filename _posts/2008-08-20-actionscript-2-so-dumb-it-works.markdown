---
layout: post
status: publish
published: true
title: actionscript 2, so dumb it works
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 37
date: '2008-08-20 07:32:40 -0700'
date_gmt: '2008-08-20 15:32:40 -0700'
categories:
- Uncategorized
tags:
- programming
- actionscript
comments: []
---
There's something strangely satisfying about switching gears from a well
structured language like Ruby all the way back to the days of
actionscript 2. It brings me back a little. Actionscript 2 has a lot of
intricacies and subtle nuances that you wouldn't expect and that's one
thing that makes it fun. It's fun because it doesn't normally work as
expected. You have to delve deep into the minds of the poor people who
were forced to create it and outsmart them. It's fun because when you
finally get something to work, you can look at your code and say,
"there's no way that should work!" After a few hours of working with the
language you begin to anticipate the worst possible scenario. You would
think this for instance: If I want to create an array object called bar
with 3 elements, I'd do it like this:

~~~ java
var bar:Array = new Array('a', 'b', 'c');
~~~

but if I wanted only one element in the array, I'd do it like this:

~~~ java
var bar:Array = new Array(['a']);
~~~

Of course! It's so obvious. The square brackets are obvious because
actionscript 2 wants to make doubly sure that bar will actually be an
array and not just a string, whereas the commas give it away in the
first example so adding square brackets there would just create an array
containing an array.

<!--more-->

Let's take this example straight out of the documention:

~~~ java
var submitListener:Object = new Object();
submitListener.click = function(evt:Object) {
  var result_lv:LoadVars = new LoadVars();
  result_lv.onLoad = function(success:Boolean) {
    if (success) {
      result_ta.text = result_lv.welcomeMessage;
    } else {
      result_ta.text = "Error connecting to server.";
    }
  };
  var send_lv:LoadVars = new LoadVars();
  send_lv.name = name_ti.text;
  send_lv.sendAndLoad("http://www.flash-mx.com/mm/greeting.cfm", result_lv, "POST");
};
submit_button.addEventListener("click", submitListener);
~~~

Upon first glance you should automatically know that should greeting.cfm
return an empty document, result_ta.text will become "Error connecting
to server." *even if* there was no error connecting to the server.

Here's where actionscript 2 really shines, lets say that you want to
send an array of values to a remote server using
LoadVars::sendAndLoad(). The only info I could find about doing this was
to use xml, but I didn't really want to bother forming xml because
seriously, I'm using actionscript 2 here. send_lv will take any element
or property you assign and turn it into a data string which it sends to
the server. So in an ordinary environment you might expect to stick an
array into our LoadVars object like this:

~~~ java
send_lv['list'] = list; //where list is an Array
~~~

but of course that wouldn't work because its just not dumb enough,
here's where it helps to know a little bit about HTTP and exactly how
great actionscript 2 truly is:

~~~ java
for (var i in list) {
  send_lv['list[' + i + ']'] = list[i];
}
~~~

Viola! I truly believe that actionscript 2 can do anything. If you find
yourself resorting to trace(foo), the ever-popular flash 8 debugger,
reaching over your designer's keyboard to type code while you both
scratch your heads, just take a deep breath and think, "If I were
outrageously stupid and inconsistent, yet somehow still able to write
code, how would I do it?" I'll tell you how, you'd write in actionscript
2.
