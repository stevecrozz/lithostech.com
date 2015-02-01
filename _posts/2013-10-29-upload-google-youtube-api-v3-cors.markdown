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
Do a search on google for "youtube api javascript upload" and you'll get
all kinds of results. There are a huge number of ways people try to get
around the document [same origin
policy](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Same_origin_policy_for_JavaScript)
to make an HTTP request using JavaScript. Lets go through some of them:

You can [create a real HTML form and submit it with
JavaScript](https://developers.google.com/youtube/2.0/developers_guide_protocol_browser_based_uploading),
and you can avoid the page refresh by submitting to an iframe. You can
[use
jsonp](http://stackoverflow.com/questions/9310112/why-am-i-seeing-an-origin-is-not-allowed-by-access-control-allow-origin-error)
to sneak by and load remote JavaScript using a script tag. You can
fruitlessly attempt to muck with
[document.domain](http://stackoverflow.com/questions/2404947/same-origin-policy-workaround-using-document-domain-in-javascript).
There are all kinds of other crazy hacks people use to circumvent the
same origin policy, but they are all either severely limited, or suffer
in terms of your ability to control the HTTP request parameters and
properly handle the response in failure scenarios.

Another option is to skip the whole idea of submitting your requests
directly from the browser to the remote server. You can install your own
proxy server on the same domain as your client JavaScript application
and make requests to your proxy which then makes the disallowed requests
for you because your proxy server isn't governed by the same origin
policy. This method gives you full control over the entire process, but
setting up and maintaining a proxy server, paying for bandwidth and
storage, and dealing with the added complexity might be too expensive
and time consuming. It might also be totally unnecessary.

CORS is here to save the day. CORS has existed for a long time, but for
some reason (maybe browser compatibility reasons), it hasn't yet caught
on in a big way. Many well-known APIs, including Google's [YouTube Data
API v3](https://developers.google.com/youtube/v3/) already support CORS.
And chances are, the browser you're currently using supports CORS too.

<!--more-->
The official YouTube API blog announced support for CORS in 2012 in an
entry entitled [Unlocking JavaScript&rsquo;s Potential with
CORS](http://apiblog.youtube.com/2012/05/unlocking-javascripts-potential-with.html).
Unfortunately, even here, the [example code they
reference](http://gdata-samples.googlecode.com/svn/trunk/gdata/youtube_upload_cors.html)
doesn't actually use CORS in the final and most important step in a
video upload: <strong>actually uploading the video</strong>. Instead,
the example falls back to a regular old form submission:

~~~ javascript
// Submit the form to upload the file.
// This doesn't actually rely on CORS, but the previous step's metadata submission did.
$('#upload-form').submit();
~~~

Weak!

But that's ok, because it is actually possible to do the same thing
entirely using XMLHttpRequest without any special script tags, iframes
or forms. You may wonder what special magic is required, and how can you
avoid the dreaded:

> XMLHttpRequest cannot load http://remote.com/. Origin http://local.com
> is not allowed by Access-Control-Allow-Origin

Actually, there is nothing at all you need to do. As long as the remote
server supports CORS, all you need to do is submit your request and your
browser will handle the rest. If you're curious about specific
implementation details, check out
[developer.mozilla.org](https://developer.mozilla.org/en-US/docs/HTTP/Access_control_CORS).
Lets move on to some code, shall we?

~~~ javascript
var invocation = new XMLHttpRequest();
invocation.setRequestHeader('Authorization', 'Bearer ' + token);
invocation.open('POST', "https://www.googleapis.com/upload/youtube/v3/videos?part=snippet", true);
invocation.send(videoFile);
~~~

Assuming videoFile is an object described by the [FileApi File
interface](http://www.w3.org/TR/FileAPI/#dfn-file), the video should be
smoothly transported to YouTube with no restrictions from the same
origin policy. The Content-Type of this request is multipart/form-data,
just as if it were a regular upload form being submitted the
old-fashioned way. The rest should be mostly self-explanatory for those
of us familiar with XMLHttpRequest. Just like any other XMLHttpRequest,
you have control over the request. You can specify the HTTP method and
you can set arbitrary HTTP request headers too.

Uploading a video across domains using nothing but client-side
javascript is pretty cool, but the YouTube documentation for [inserting
a video](https://developers.google.com/youtube/v3/docs/videos/insert)
claims that other parameters can be specified in the same call. The
normal method of specifying additional parameters in a
multipart/form-data request is to use a new stanza for each additional
parameter. That doesn't work with the YouTube Data API. The
documentation doesn't really spell out exactly how to add additional
parameters when using multipart/form-data, so I turned to the official
[Google API Ruby Client
gem](https://github.com/google/google-api-ruby-client) for answers.

I made an attempt to upload an empty file to YouTube while at the same
time specifying the title and privacy status of the video. I observed
the HTTP request using wireshark and found something very interesting:

~~~
-------------RubyApiMultipartPost
Content-Disposition: form-data; name=""; filename="file.json"
Content-Length: 62
Content-Type: application/json
Content-Transfer-Encoding: binary
{"snippet":{"title":"testing123"},"status":{"privacyStatus":"public"}}
-------------RubyApiMultipartPost
Content-Disposition: form-data; name=""; filename="fakevideo.ogv"
Content-Length: 0
Content-Type: video/*
Content-Transfer-Encoding: binary
-------------RubyApiMultipartPost--
~~~

The official YouTube API client for Ruby adds parameters to a file
upload by adding a second file to the request (file.json). The second
file is not a real file. It doesn't exist anywhere on my hard disk. It's
just a JSON blob whose sole purpose is to transfer additional parameters
to YouTube using JSON instead of URL encoding them. Using JSON as
opposed to URL encoded form parameters actually makes a lot of sense,
but this method of attaching parameters to a file upload and sending
them to Google's YouTube Data API v3 is not documented anywhere that I
could find.

Making the browser behave the same way is simply a matter of making the
same kind of request. The File API has Blob which can make a file-like
object out of a regular string while FormData can transform our blob and
our real file into multipart/form-data format. All that's left is to
send the whole thing to a remote server using XMLHttpRequest:

~~~ javascript
var invocation = new XMLHttpRequest();
invocation.setRequestHeader('Authorization', 'Bearer ' + token);
invocation.open('POST', "https://www.googleapis.com/upload/youtube/v3/videos?part=snippet", true);
var parameters = JSON.stringify({
  "snippet": { "title": "testing123"  },
  "status": { "privacyStatus": "public"  }
});
var jsonBlob = new Blob([ parameters ], { "type" : "application\/json" });
var fd = new FormData();
fd.append("snippet", jsonBlob, "file.json");
fd.append("file", videoFile);
invocation.send(fd);
~~~

The result is a successful upload and the request looks very much like
the one generated by the ruby gem. I wish Google had more documentation
on this because it would have saved me a lot of time. I also ran into
trouble fetching OAuth2 tokens for users with multiple Google accounts
while using immediate mode authorization. Hopefully, I'll be writing
about that in the future. But, in the end, I'm really happy with the
finished product which I do plan to open source soon.
