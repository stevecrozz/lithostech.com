---
layout: post
status: publish
published: true
title: certificate authorities are organized crime
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "It sounds like an outrageous claim, but I'm going to describe why certificate
  authorities are like a crime syndicate and why we should all refuse to pay protection
  money to them.\r\n"
wordpress_id: 75
date: '2009-04-23 00:23:43 -0700'
date_gmt: '2009-04-23 07:23:43 -0700'
categories:
- Uncategorized
tags:
- security
- https
- certificate authority
comments: []
---
<p>It sounds like an outrageous claim, but I'm going to describe why certificate authorities are like a crime syndicate and why we should all refuse to pay protection money to them.<&#47;p><br />
<a id="more"></a><a id="more-75"></a></p>
<h3>bare minimum https primer<&#47;h3></p>
<p>We all use online web sites where security is a top concern. That's why many of these sites have adopted http over ssl, which is now known as the https schema. This schema has proven to be a reliable way to enable secure communication over the web. Https provides more than data security, which is simply the guarantee that all of the information in transit cannot be easily read by a third party, it also provides data integrity in that you know exactly who is on the other end of your communication... hopefully. <&#47;p></p>
<p>This is where I it gets more complicated. Https integrity works by involving a third-party certificate authority. This was supposed to be a good thing because now you have someone else to guarantee your bank is actually your bank and not an evil imposter trying to steal your account information. This is a great idea, except this isn't how it actually works in practice. Here's how it really works:<&#47;p></p>
<p>Your bank decides it wants to allow account access online over https. It has two options. First, it can become its own x509 certificate authority and self sign its certificates which you are forced to accept if you want to connect to your account online. That used to work great, but it scared lots of people because most people don't understand what https is let alone certificate authorities. Second, the bank can buy a certificate from a "trusted" certificate authority which basically guarantees that as long as they're using a current certificate, users won't be shown any scary dialog boxes.<&#47;p></p>
<p>Obviously your bank doesn't want its users to be afraid, so it takes the second option which is basically forced because of the way browsers handle https. As long as users can see the little green padlock icon, everything will be alright and nobody will freak out. Whether or not a secure site cares about authenticity, it must purchase a certificate to quell users' fear arising from poor browser implementations and plain old nativity.<&#47;p></p>
<h3>So what's the problem?<&#47;h3></p>
<p>You might think that this is fine, users won't be given scary dialog boxes because they already trust the certificate issuer. Its not a stretch to imagine trusting any site that's been granted a certificate by an organization that you've already chosen to trust. The problem is, users haven't chosen to trust any of these certificate authorities at all. It turns out that most web browsers ship with a list of certificate authorities already trusted. So now we're actually another layer deep in this web of trust. I don't know what Microsoft's policy is, but Mozilla installs root certificates for certificate authorities that pass a security audit by "an independent" third party (yet another link in this chain). Do you automatically trust all the certificate authorities that Microsoft and Mozilla trust? What about all the organizations they trust? How many layers deep would you like that to go?<&#47;p></p>
<p>The problem is, your bank may enjoy the fact that you don't have scary dialog boxes to weed through on their web site, and your tech support guy may enjoy fewer calls, but the information you send and receive is not any more secure for it. The only benefit you get is the third (or fourth, or fifth) party authentication. Which is not much benefit at all because you really should trust your bank directly rather than by proxy. I won't get into the fact that it takes little more than a credit card and an email address to get a valid certificate from one of these "trusted certificate authorities". These certificate authorities provide no more benefit than a two-bit gang offering protection to your corner store. You pay them for the privilege of being able to do business. If you don't pay them, they'll scare off your customers with tales of phishing scams and frightening dialog boxes about your certificate being invalid even if they really are valid. The added security is only an illusion.<&#47;p></p>
<p>If you're a home user trying to figure out what to do about it. Find the list of trusted root authorities in your browser and make sure you actually trust every single one. I'll give you a pointer: If you've never heard of them, then you don't trust them. You're better off without them because honestly, why would you trust them? If you run your own web site and you can handle a few scared users, sign your own certificates or use one of the numerous free certificate authorities out there such as cacert.org.<&#47;p></p>
