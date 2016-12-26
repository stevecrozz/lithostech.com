---
layout: post
published: true
title: Serverless DDNS With Route53
date: '2016-12-26 12:34:11 -0800'
tags:
- aws
- lambda
- nodejs
- cloud
- ddns
---
Now that [TLS is free](https://letsencrypt.org/), there's very little
excuse to be running web services over plain HTTP. The easiest way to
add TLS to this blog was through [AWS Certificate
Manager](https://aws.amazon.com/certificate-manager/) and its native
CloudFront Support. But for a while, there was a problem. In order to
use a free, trusted certificate from Amazon, I needed to be using
CloudFront. In order to be using CloudFront, I needed to be able to
resolve the name 'lithostech.com' to a CloudFront distribution. Since
DNS doesn't support CNAME records on top level names, that meant
switching DNS service to Route53 where Amazon has a special solution for
this problem they call [alias
records](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html).

But there was a problem because Route53 doesn't have DDNS support and I
use DDNS to reach my home network's dynamic IP address when I'm out of
the house. And so I put this off for quite a while, mostly because I
didn't realize how simple DDNS really was and how easily it could be
done with AWS Lambda.

Turning to the [source code for
ddclient](https://sourceforge.net/p/ddclient/code/HEAD/tree/trunk/ddclient),
a popular DDNS client that ships with Debian, I found that DDNS amounts
to nothing more than calling a tiny web API to update a remote server
with your current IP address at regular intervals. Each vendor that
provides DDNS seems to implement it differently, and so it seems there
is no specific way to do this. But in all the implementations I saw, the
design was essentially a magic URL that anyone in the world can access
and use it to update the IP address of a DNS A record.

A picture was beginning to form on how this could be done with very low
cost on AWS:
- API Gateway (web accessible endpoint)
- Route53 (DNS host)
- Lambda (process the web request and update DNS)
- IAM Role (policy to allow the DNS changes)

On the client side, the only requirement is to be able to be able to
access the web with an HTTP(S) client. In my case, a CURL command in an
hourly cron job fit the bill. I enjoy the flexibility of being able to
implement and consume this as a tiny web service, but it could be made
simpler and more secure by having the client consume the AWS API to
invoke the lambda function directly rather than through the API Gateway.

I put some effort into making sure this Lambda function was as simple as
possible. Outside of aws-sdk, which is available by default in the
lambda node 4.3 execution environment, no other npm modules are
required. Source code and instructions are [available on
GitHub](https://github.com/stevecrozz/serverless-ddns-route53).
