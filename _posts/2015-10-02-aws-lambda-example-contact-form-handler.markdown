---
layout: post
published: true
title: AWS Lambda Example &mdash; Contact Form Handler
date: '2015-10-02 15:35:11 -0700'
tags:
- aws
- s3
- lambda
- nodejs
- cloud
---
AWS Lambda is unique among PaaS offerings. Lambda takes all the utility grid
analogies we use to explain the cloud and embraces them to the extreme.

Lambda runs a function you define in a Node.js or Java 8 runtime, although you
can execute a subshell to run other kinds of processes. Amazon charges you by
memory use and execution time in increments of 128 MiB of memory and 100ms. The
upper limit for memory use is 1.5GiB and your Lambda function cannot take more
than 60 seconds to complete, although you can set lower limits for both.

There is a pretty generous free tier, but if you exceed the free tier, pricing
is still very friendly. For usage that does exceed the free tier, you'll be
paying [$0.00001667 per GiB\*s](https://aws.amazon.com/lambda/pricing/) and
$0.20 for every 1M invocations.

To bring that down to earth, let's say you write a lambda function that takes
on average 500ms to run and uses 256MiB of memory. You could handle 3.2M
requests before exausting the free compute tier, but you would pay $0.40 to
handle the 2.2M requests beyond the 1M request free tier. Another 3.2M requests
would cost another $6.67 including both compute time and request count charges.

Since my company's new static web page
[brandedcrate.com](http://www.brandedcrate.com) needed a contact form handler,
I took the opportunity to learn about how Lambda can provide cheap, dynamic
service for a static site.

In the example below, I'll show you what I came up with. The idea is that I
would present a simple, static web form to my users and submitting a form would
activate some client-side JavaScript to validate and submit the contents to a
remote endpoint. The endpoint would connect to the [AWS API Gateway
service](https://aws.amazon.com/api-gateway/) and trigger a lambda function.
The lambda function would perform any required server-side validation and then
use the AWS SDK for Node.js to send an email using [AWS Simple Email
Service](https://aws.amazon.com/ses/). Just like any other API endpoint, the
Lambda function can return information about the result of its own execution in
an HTTP response back to the client:

~~~ javascript
var AWS = require('aws-sdk');
var ses = new AWS.SES({apiVersion: '2010-12-01'});

function validateEmail(email) {
  var tester = /^[-!#$%&'*+\/0-9=?A-Z^_a-z{|}~](\.?[-!#$%&'*+/0-9=?A-Z^_a-z`{|}~])*@[a-zA-Z0-9](-?\.?[a-zA-Z0-9])*(\.[a-zA-Z](-?[a-zA-Z0-9])*)+$/;
  if (!email) return false;

  if(email.length>254) return false;

  var valid = tester.test(email);
  if(!valid) return false;

  // Further checking of some things regex can't handle
  var parts = email.split("@");
  if(parts[0].length>64) return false;

  var domainParts = parts[1].split(".");
  if(domainParts.some(function(part) { return part.length>63; })) return false;

  return true;
}


exports.handler = function(event, context) {
  console.log('Received event:', JSON.stringify(event, null, 2));

  if (!event.email) { context.fail('Must provide email'); return; }
  if (!event.message || event.message === '') { context.fail('Must provide message'); return; }

  var email = unescape(event.email);
  if (!validateEmail(email)) { context.fail('Must provide valid from email'); return; }

  var messageParts = [];
  var replyTo = event.name + " <" + email + ">";

  if (event.phone) messageParts.push("Phone: " + event.phone);
  if (event.website) messageParts.push("Website: " + event.website);
  messageParts.push("Message: " + event.message);

  var subject = event.message.replace(/\s+/g, " ").split(" ").slice(0,10).join(" ");

  var params = {
    Destination: { ToAddresses: [ 'Branded Crate <hello@brandedcrate.com>' ] },
    Message: {
      Body: { Text: { Data: messageParts.join("\r\n"), Charset: 'UTF-8' } },
      Subject: { Data: subject, Charset: 'UTF-8' }
    },
    Source: "Contact Form <hello@brandedcrate.com>",
    ReplyToAddresses: [ replyTo ]
  };

  ses.sendEmail(params, function(err, data) {
    if (err) {
      console.log(err, err.stack);
      context.fail(err);
    } else {
      console.log(data);
      context.succeed('Thanks for dropping us a line');
    }
  });
};
~~~

Not bad, right? I've just added an element of dynamism to my static web site.
It's highly available, costs nothing, there's no servers manage and there's no
processes to monitor. AWS provides some basic monitoring and any script output
is available in [CloudWatch](https://aws.amazon.com/cloudwatch/) for
inspection. Now that basically all browsers support CORS, your users can make
cross-origin requests from anywhere on the web. [Setting this up in
AWS](http://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html)
is a bit ugly, but I'm willing to make the effort to get all the benefits that
come along with it.

I'm excited about the possibilities of doing much more with Lambda, especially
the work [Austen Collins](https://twitter.com/austencollins) is doing with his
new Lambda-based web framework, [JAWS](https://github.com/jaws-framework/JAWS).

The hardest part about this whole thing was properly setting up the API
Gateway. I tried in vain to get the API Gateway to accept url-encoded form
parameters, but that was a losing battle. Just stick with JSON.
