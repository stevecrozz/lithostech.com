---
layout: post
status: publish
published: true
title: Upload to YouTube Through Google API v3 and CORS
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "<p>Do a search on google for \"youtube api javascript upload\" and you'll
  get all kinds of results. There are a huge number of ways people try to get around
  the document <a href=\"https:&#47;&#47;developer.mozilla.org&#47;en-US&#47;docs&#47;Web&#47;JavaScript&#47;Same_origin_policy_for_JavaScript\">same
  origin policy<&#47;a> to make an HTTP request using JavaScript. Lets go through
  some of them:<&#47;p>\r\n\r\n<p>You can <a href=\"https:&#47;&#47;developers.google.com&#47;youtube&#47;2.0&#47;developers_guide_protocol_browser_based_uploading\">create
  a real HTML form and submit it with JavaScript<&#47;a>, and you can avoid the page
  refresh by submitting to an iframe. You can <a href=\"http:&#47;&#47;stackoverflow.com&#47;questions&#47;9310112&#47;why-am-i-seeing-an-origin-is-not-allowed-by-access-control-allow-origin-error\">use
  jsonp<&#47;a> to sneak by and load remote JavaScript using a script tag. You can
  fruitlessly attempt to muck with <a href=\"http:&#47;&#47;stackoverflow.com&#47;questions&#47;2404947&#47;same-origin-policy-workaround-using-document-domain-in-javascript\">document.domain<&#47;a>.
  There are all kinds of other crazy hacks people use to circumvent the same origin
  policy, but they are all either severely limited, or suffer in terms of your ability
  to control the HTTP request parameters and properly handle the response in failure
  scenarios.<&#47;p>\r\n\r\n<p>Another option is to skip the whole idea of submitting
  your requests directly from the browser to the remote server. You can install your
  own proxy server on the same domain as your client JavaScript application and make
  requests to your proxy which then makes the disallowed requests for you because
  your proxy server isn't governed by the same origin policy. This method gives you
  full control over the entire process, but setting up and maintaining a proxy server,
  paying for bandwidth and storage, and dealing with the added complexity might be
  too expensive and time consuming. It might also be totally unnecessary.<&#47;p>\r\n\r\n<p>CORS
  is here to save the day. CORS has existed for a long time, but for some reason (maybe
  browser compatibility reasons), it hasn't yet caught on in a big way. Many well-known
  APIs, including Google's <a href=\"https:&#47;&#47;developers.google.com&#47;youtube&#47;v3&#47;\">YouTube
  Data API v3<&#47;a> already support CORS. And chances are, the browser you're currently
  using supports CORS too.<&#47;p>\r\n\r\n"
wordpress_id: 572
wordpress_url: http://lithostech.com/?p=572
date: '2013-10-29 23:07:24 -0700'
date_gmt: '2013-10-30 06:07:24 -0700'
categories:
- Uncategorized
tags:
- google
- javascript
- api
- youtube
- cors
comments:
- id: 109527
  author: Gerry
  author_email: nt.gerry@gmail.com
  author_url: ''
  date: '2014-02-18 04:41:21 -0800'
  date_gmt: '2014-02-18 12:41:21 -0800'
  content: "I'm in trouble with creating token. What I need is to allow people upload
    video on my application account. But It's look like this is not possible. Am I
    wrong?\r\nThank you for your answer."
---
<p>Do a search on google for "youtube api javascript upload" and you'll get all kinds of results. There are a huge number of ways people try to get around the document <a href="https:&#47;&#47;developer.mozilla.org&#47;en-US&#47;docs&#47;Web&#47;JavaScript&#47;Same_origin_policy_for_JavaScript">same origin policy<&#47;a> to make an HTTP request using JavaScript. Lets go through some of them:<&#47;p></p>
<p>You can <a href="https:&#47;&#47;developers.google.com&#47;youtube&#47;2.0&#47;developers_guide_protocol_browser_based_uploading">create a real HTML form and submit it with JavaScript<&#47;a>, and you can avoid the page refresh by submitting to an iframe. You can <a href="http:&#47;&#47;stackoverflow.com&#47;questions&#47;9310112&#47;why-am-i-seeing-an-origin-is-not-allowed-by-access-control-allow-origin-error">use jsonp<&#47;a> to sneak by and load remote JavaScript using a script tag. You can fruitlessly attempt to muck with <a href="http:&#47;&#47;stackoverflow.com&#47;questions&#47;2404947&#47;same-origin-policy-workaround-using-document-domain-in-javascript">document.domain<&#47;a>. There are all kinds of other crazy hacks people use to circumvent the same origin policy, but they are all either severely limited, or suffer in terms of your ability to control the HTTP request parameters and properly handle the response in failure scenarios.<&#47;p></p>
<p>Another option is to skip the whole idea of submitting your requests directly from the browser to the remote server. You can install your own proxy server on the same domain as your client JavaScript application and make requests to your proxy which then makes the disallowed requests for you because your proxy server isn't governed by the same origin policy. This method gives you full control over the entire process, but setting up and maintaining a proxy server, paying for bandwidth and storage, and dealing with the added complexity might be too expensive and time consuming. It might also be totally unnecessary.<&#47;p></p>
<p>CORS is here to save the day. CORS has existed for a long time, but for some reason (maybe browser compatibility reasons), it hasn't yet caught on in a big way. Many well-known APIs, including Google's <a href="https:&#47;&#47;developers.google.com&#47;youtube&#47;v3&#47;">YouTube Data API v3<&#47;a> already support CORS. And chances are, the browser you're currently using supports CORS too.<&#47;p></p>
<p><a id="more"></a><a id="more-572"></a></p>
<p>The official YouTube API blog announced support for CORS in 2012 in an entry entitled <a href="http:&#47;&#47;apiblog.youtube.com&#47;2012&#47;05&#47;unlocking-javascripts-potential-with.html">Unlocking JavaScript&rsquo;s Potential with CORS<&#47;a>. Unfortunately, even here, the <a href="http:&#47;&#47;gdata-samples.googlecode.com&#47;svn&#47;trunk&#47;gdata&#47;youtube_upload_cors.html">example code they reference<&#47;a> doesn't actually use CORS in the final and most important step in a video upload: <strong>actually uploading the video<&#47;strong>. Instead, the example falls back to a regular old form submission:<&#47;p></p>
<p><code class="language-javascript"><br />
&#47;&#47; Submit the form to upload the file.<br />
&#47;&#47; This doesn't actually rely on CORS, but the previous step's metadata submission did.<br />
$('#upload-form').submit();<br />
<&#47;code></p>
<p>Weak!<&#47;p></p>
<p>But that's ok, because it is actually possible to do the same thing entirely using XMLHttpRequest without any special script tags, iframes or forms. You may wonder what special magic is required, and how can you avoid the dreaded:<&#47;p></p>
<blockquote><p>XMLHttpRequest cannot load http:&#47;&#47;remote.com&#47;. Origin http:&#47;&#47;local.com is not allowed by Access-Control-Allow-Origin<&#47;blockquote></p>
<p>Actually, there is nothing at all you need to do. As long as the remote server supports CORS, all you need to do is submit your request and your browser will handle the rest. If you're curious about specific implementation details, check out <a href="https:&#47;&#47;developer.mozilla.org&#47;en-US&#47;docs&#47;HTTP&#47;Access_control_CORS">developer.mozilla.org<&#47;a>.<&#47;p></p>
<p>Lets move on to some code, shall we?<&#47;p></p>
<p><code class="language-javascript"><br />
var invocation = new XMLHttpRequest();<br />
invocation.setRequestHeader('Authorization', 'Bearer ' + token);<br />
invocation.open('POST', "https:&#47;&#47;www.googleapis.com&#47;upload&#47;youtube&#47;v3&#47;videos?part=snippet", true);<br />
invocation.send(videoFile);<br />
<&#47;code></p>
<p>Assuming videoFile is an object described by the <a href="http:&#47;&#47;www.w3.org&#47;TR&#47;FileAPI&#47;#dfn-file">FileApi File interface<&#47;a>, the video should be smoothly transported to YouTube with no restrictions from the same origin policy. The Content-Type of this request is multipart&#47;form-data, just as if it were a regular upload form being submitted the old-fashioned way. The rest should be mostly self-explanatory for those of us familiar with XMLHttpRequest. Just like any other XMLHttpRequest, you have control over the request. You can specify the HTTP method and you can set arbitrary HTTP request headers too.<&#47;p></p>
<p>Uploading a video across domains using nothing but client-side javascript is pretty cool, but the YouTube documentation for <a href="https:&#47;&#47;developers.google.com&#47;youtube&#47;v3&#47;docs&#47;videos&#47;insert">inserting a video<&#47;a> claims that other parameters can be specified in the same call. The normal method of specifying additional parameters in a multipart&#47;form-data request is to use a new stanza for each additional parameter. That doesn't work with the YouTube Data API. The documentation doesn't really spell out exactly how to add additional parameters when using multipart&#47;form-data, so I turned to the official <a href="https:&#47;&#47;github.com&#47;google&#47;google-api-ruby-client">Google API Ruby Client gem<&#47;a> for answers.<&#47;p></p>
<p>I made an attempt to upload an empty file to YouTube while at the same time specifying the title and privacy status of the video. I observed the HTTP request using wireshark and found something very interesting:<&#47;p></p>
<pre>-------------RubyApiMultipartPost<br />
Content-Disposition: form-data; name=""; filename="file.json"<br />
Content-Length: 62<br />
Content-Type: application&#47;json<br />
Content-Transfer-Encoding: binary</p>
<p>{"snippet":{"title":"testing123"},"status":{"privacyStatus":"public"}}<br />
-------------RubyApiMultipartPost<br />
Content-Disposition: form-data; name=""; filename="fakevideo.ogv"<br />
Content-Length: 0<br />
Content-Type: video&#47;*<br />
Content-Transfer-Encoding: binary</p>
<p>-------------RubyApiMultipartPost--<&#47;pre></p>
<p>The official YouTube API client for Ruby adds parameters to a file upload by adding a second file to the request (file.json). The second file is not a real file. It doesn't exist anywhere on my hard disk. It's just a JSON blob whose sole purpose is to transfer additional parameters to YouTube using JSON instead of URL encoding them. Using JSON as opposed to URL encoded form parameters actually makes a lot of sense, but this method of attaching parameters to a file upload and sending them to Google's YouTube Data API v3 is not documented anywhere that I could find.<&#47;p></p>
<p>Making the browser behave the same way is simply a matter of making the same kind of request. The File API has Blob which can make a file-like object out of a regular string while FormData can transform our blob and our real file into multipart&#47;form-data format. All that's left is to send the whole thing to a remote server using XMLHttpRequest:<&#47;p></p>
<p><code class="language-javascript"><br />
var invocation = new XMLHttpRequest();<br />
invocation.setRequestHeader('Authorization', 'Bearer ' + token);<br />
invocation.open('POST', "https:&#47;&#47;www.googleapis.com&#47;upload&#47;youtube&#47;v3&#47;videos?part=snippet", true);</p>
<p>var parameters = JSON.stringify({<br />
  "snippet": { "title": "testing123"  },<br />
  "status": { "privacyStatus": "public"  }<br />
});</p>
<p>var jsonBlob = new Blob([ parameters ], { "type" : "application\&#47;json" });</p>
<p>var fd = new FormData();<br />
fd.append("snippet", jsonBlob, "file.json");<br />
fd.append("file", videoFile);</p>
<p>invocation.send(fd);<br />
<&#47;code></p>
<p>The result is a successful upload and the request looks very much like the one generated by the ruby gem. I wish Google had more documentation on this because it would have saved me a lot of time. I also ran into trouble fetching OAuth2 tokens for users with multiple Google accounts while using immediate mode authorization. Hopefully, I'll be writing about that in the future. But, in the end, I'm really happy with the finished product which I do plan to open source soon.<&#47;p></p>
