---
layout: post
status: publish
published: true
title: jQuery Deferreds and the jQuery Promise Method
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "<h3>jqXHR and the Promise Interface<&#47;h3>\r\n<p>jQuery 1.5 features a
  brand new mechanism for dealing with asynchronous event-driven processing. This
  system, called <em>deferreds<&#47;em>, was first implemented for jQuery's $.ajax
  method and so we'll be looking closely at that method.<&#47;p>\r\n\r\n<code class=\"language-javascript\">$.ajax({\r\n
  \ url: \"&#47;some&#47;url\",  \r\n  success: function(r){  \r\n    alert(\"Success:
  \" + r);  \r\n  },  \r\n  error: function(r){  \r\n    alert('Error: ' + r);  \r\n
  \ }  \r\n});<&#47;code>\r\n"
wordpress_id: 361
wordpress_url: http://lithostech.com/?p=361
date: '2011-04-27 09:53:50 -0700'
date_gmt: '2011-04-27 16:53:50 -0700'
categories:
- Uncategorized
tags:
- jquery
- javascript
- promises
- deferreds
comments:
- id: 40969
  author: JQuery Parsed Ajax Errors &laquo; Davissoft
  author_email: ''
  author_url: http://davissoft.wordpress.com/2011/12/15/jquery-parsed-ajax-errors/
  date: '2011-12-15 13:40:48 -0800'
  date_gmt: '2011-12-15 21:40:48 -0800'
  content: "[...] jQuery Deferreds and the jQuery Promise Method [...]"
- id: 50600
  author: 'jQuery : Exploring Deferred and Promise methods - Idle Brains'
  author_email: ''
  author_url: http://idlebrains.org/2012/02/jquery-exploring-deferred-and-promise.html
  date: '2012-04-07 02:35:48 -0700'
  date_gmt: '2012-04-07 09:35:48 -0700'
  content: "[...] http:&#47;&#47;lithostech.com&#47;2011&#47;04&#47;jquery-deferreds-and-the-jquery-promise-method&#47;&nbsp;(&nbsp;You
    might want to read about the ajaxPrefilter function in jQuery before you start
    reading this one.) [...]"
---
<h3>jqXHR and the Promise Interface<&#47;h3></p>
<p>jQuery 1.5 features a brand new mechanism for dealing with asynchronous event-driven processing. This system, called <em>deferreds<&#47;em>, was first implemented for jQuery's $.ajax method and so we'll be looking closely at that method.<&#47;p></p>
<p><code class="language-javascript">$.ajax({<br />
  url: "&#47;some&#47;url",<br />
  success: function(r){<br />
    alert("Success: " + r);<br />
  },<br />
  error: function(r){<br />
    alert('Error: ' + r);<br />
  }<br />
});<&#47;code><br />
<a id="more"></a><a id="more-361"></a></p>
<p>Most jQuery users will recognize this code as a typical jQuery ajax request. The code above dispatches an ajax request to &#47;some&#47;url and sets up two callbacks: a success handler and an error handler. Notice that if you're confined to this interface, the callbacks must be associated here and nowhere else. If you decide you want to add more callbacks, you're out of luck.<&#47;p></p>
<p>But as of jQuery 1.5, calls to $.ajax return a thing called a promise which in this case is a <a href="http:&#47;&#47;api.jquery.com&#47;jQuery.ajax&#47;#jqXHR">jqXHR object<&#47;a>. It would be more correct to call it a promise-like object, but I'll be calling it a promise for now because I want to focus on its promise interface.<&#47;p></p>
<p>So far we've seen that the familiar interface of providing callbacks as part of an argument to $.ajax continues to work. When you specify a callback like <em>success<&#47;em> in jQuery 1.5, $.ajax just passes that callback as an argument to the <em>success<&#47;em> method of its jqXHR object. In other words, the following two $.ajax calls are functionally equivalent.<&#47;p></p>
<p><code class="language-javascript">$.ajax({<br />
  url: "&#47;some&#47;url",<br />
  success: function(){ alert('success'); }<br />
});</p>
<p>$.ajax({ url: "&#47;some&#47;url" }).success(function(){<br />
  alert('success');<br />
});<&#47;code></p>
<p>The fact that $.ajax returns a promise means its now possible to interface with it from anywhere you have access to it. Thankfully, jQuery makes this promise available in any place you might want it. When you call <em>success<&#47;em> on a jqXHR object, or <em>done<&#47;em> on any promise, jQuery takes the function you pass and adds it to a stack of callbacks which will be executed when the underlying deferred is resolved. If the deferred is already resolved, your callback will be executed immediately.<&#47;p></p>
<h3>Generic Deferreds<&#47;h3></p>
<p>The jQuery team was kind enough to factor this whole subsystem out into a reusable component and so far both $.ajax and $.animate have been rewritten to make use of them. You can, of course, create your own deferred object using the $.Deferred method. You can also conveniently group multiple deferreds together under a new master deferred using $.when(x, y, z) which returns another promise. The underlying deferred is resolved when all the deferreds you passed in are resolved and it fails when only one of them fails.<&#47;p></p>
<h3>Making Promises from Other Promises<&#47;h3></p>
<p>Even more interestingly, you can push one deferred's promise interface onto any other object by calling the <em>promise<&#47;em> method with an object as its argument. This is exactly what jQuery does internally when it sets up the jqXHR object. $.ajax endows jqXHR with the promise interface to its internal deferred simply by calling deferred.promise(jqXHR). Essentially that just creates new promise interface bindings (<em>then<&#47;em>, <em>done<&#47;em>, <em>fail<&#47;em>, <em>isResolved<&#47;em>, <em>isRejected<&#47;em> and <em>promise<&#47;em>) on jqXHR that point to the promise interface functions on the deferred's existing promise. So you can easily setup a promise interface on any object by delegating its promise interface methods to an existing promise. If the object in questions happens to already have a promise interface, then its old interface bindings are discarded in favor of the new ones.<&#47;p></p>
<h3>Example Scenario<&#47;h3></p>
<p>Lets look at an example. jQuery automatically parses JSON in successful but not unsuccessful $.ajax responses. Sometimes there is important structured information in the payload and for whatever reason jQuery doesn't even pass the data bit as an argument to error callbacks. A coworker of mine had the opportunity to ask Julian Aubourg about this very problem while we were at the jQuery conference in Mountain View this year. Julian put this together in about 90 seconds:<&#47;p></p>
<p><code class="language-javascript">$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {<br />
  if ( options.parseError ) {<br />
    $.Deferred(function( defer ) {<br />
      jqXHR.done( defer.resolve )<br />
        .fail(function( jqXHR, statusText, errorMsg ) {<br />
        var parsed = $.parseJSON( jqXHR.responseText );<br />
        defer.rejectWith( this, [ jqXHR, statusText, parsed ] );<br />
      });<br />
    }).promise( jqXHR );<br />
    jqXHR.success = jqXHR.done;<br />
    jqXHR.error = jqXHR.fail;<br />
  }<br />
});<&#47;code></p>
<p>Have a close look at this code and see if you can figure out how it works. If you think you've got it, then look again because you probably haven't.<&#47;p></p>
<p>$.ajaxPrefilter is a cool new method that allows you to hook into the $.ajax internals before requests are dispatched. In the example above, we are making it possible to automatically parse and return JSON responses for responses with unsuccessful status codes.<&#47;p></p>
<p><code class="language-javascript">$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {<br />
  $.Deferred().promise( jqXHR );<br />
});<&#47;code></p>
<p>At the core this is done by creating a brand new deferred and redirecting jqXHR's promise interface to itself. After this, jqXHR's promise interface methods operate on our new deferred and the interface to the old deferred is overwritten. $.ajaxPrefilter gives you a handle on jqXHR before anything else happens, so anyone else who gets a reference to jqXHR and calls its promise interface functions will really be talking to the new deferred. That's all well and good, but nothing will happen unless we have a way to resolve this new deferred when when jqXHR is resolved.<&#47;p></p>
<p><code class="language-javascript">$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {<br />
  $.Deferred(function( defer ) {<br />
    jqXHR.done( defer.resolve );<br />
  }).promise( jqXHR );<br />
});<&#47;code></p>
<p>This is easy enough. All we're doing here is telling jqXHR that when it is resolved, it should also resolve our new deferred.<&#47;p></p>
<p><code class="language-javascript">$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {<br />
  $.Deferred(function( defer ) {<br />
    jqXHR.done( defer.resolve )<br />
      .fail(function( jqXHR, statusText, errorMsg ) {<br />
      var parsed = $.parseJSON( jqXHR.responseText );<br />
      defer.rejectWith( this, [ jqXHR, statusText, parsed ] );<br />
    });<br />
  }).promise( jqXHR );<br />
});<&#47;code></p>
<p>If we wanted to do the same with <em>fail<&#47;em>, we could just use .fail( defer.reject ), but we have the opportunity here to create our own <em>fail<&#47;em> interface. Our new interface will alter the third parameter in the callback from the normal jQuery one which has a pretty useless statusText argument to the far more useful document body itself. Because the standard jQuery promise interface doesn't include <em>success<&#47;em> and <em>error<&#47;em>, these methods still provide an interface to the old deferred. All we have to do is use the <em>done<&#47;em> and <em>fail<&#47;em> methods that already exist and already point to the new deferred.<&#47;p></p>
<p><code class="language-javascript">$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {<br />
  if ( options.parseError ) {<br />
    $.Deferred(function( defer ) {<br />
      jqXHR.done( defer.resolve )<br />
        .fail(function( jqXHR, statusText, errorMsg ) {<br />
        var parsed = $.parseJSON( jqXHR.responseText );<br />
        defer.rejectWith( this, [ jqXHR, statusText, parsed ] );<br />
      });<br />
    }).promise( jqXHR );<br />
    jqXHR.success = jqXHR.done;<br />
    jqXHR.error = jqXHR.fail;<br />
  }<br />
});<&#47;code></p>
<p>Now we have an $.ajaxPrefilter that alters the behavior of <em>error<&#47;em> and <em>fail<&#47;em> callbacks for anyone that uses $.ajax. This behavior would be unexpected for any caller that was using the old interface, but we can isolate the change to target only those callers that make calls to $.ajax with a 'parseError' argument.<&#47;p></p>
<p><strong>Update 2010-05-02<&#47;strong><&#47;p></p>
<p>I sent this entry to Julian and he mentioned it could be done with $.pipe. Here's the updated version:<&#47;p></p>
<p><code class="language-javascript">$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {<br />
  if ( options.parseError ) {<br />
    jqXHR.pipe( null, function( jqXHR, statusText, errorMsg ) {<br />
        var parsed = $.parseJSON( jqXHR.responseText );<br />
        return $.Deferred().rejectWith( this, [ jqXHR, statusText, parsed ] );<br />
    }).promise( jqXHR );<br />
    jqXHR.success = jqXHR.done;<br />
    jqXHR.error = jqXHR.fail;<br />
  }<br />
});<&#47;code></p>
