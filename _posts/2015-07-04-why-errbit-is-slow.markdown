---
layout: post
published: true
title: Why Errbit Is Slow
date: '2015-07-05 16:09:49 -0700'
tags:
- errbit
- mongo
- rails
---

## Round One

One of the first things I did when tracking down performance issues was
motivated by a lot of experience with Rails apps. A very common issue I've seen
with Rails applications comes down to a simple misuse of active_record. Errbit
doesn't use active_record, but it does use Mongoid which presents something
rather like an active_record interface for mongo-powered applications.

After spending some time with Errbit and some cursory analysis, I suspected the
performance problem was in the data layer (making unnecessary and expensive
queries). So I set out to record all mongo queries made while inserting
notices.

Here's the list of queries I collected from one notice insertion:

~~~ console
namespace=errbit_development.apps selector={"api_key"=>"acae731a1bd8cd2b0c0946f2a952027b"} flags=[:slave_ok] limit=0 skip=0 project=nil | runtime: 31.7640ms
namespace=errbit_development.backtraces selector={"fingerprint"=>"a6e12c6962939b955c0bf325c0cff0936ae0e98f"} flags=[:slave_ok] limit=0 skip=0 project=nil | runtime: 2.1269ms
namespace=errbit_development.backtraces selector={"_id"=><BSON::ObjectId:0x70012658875760 data=55748bb163726f67e4000004>} flags=[:slave_ok] limit=0 skip=0 project=nil | runtime: 1.8985ms
namespace=errbit_development.errs selector={"fingerprint"=>"ece6d74c1056b16c50ed3ba2f03dfc0bf6e5e7d2"} flags=[:slave_ok] limit=0 skip=0 project=nil | runtime: 0.4275ms
namespace=errbit_development.$cmd selector={:insert=>"notices", :documents=>[{"_id"=><BSON::ObjectId:0x70012660942640 data=5574c1a963726f7f89000000>, "message"=>"Whatever the mind of man can conceive and believe, it can achieve", "error_class"=>"ArgumentError", "backtrace_id"=><BSON::ObjectId:... flags=[] limit=-1 skip=0 project=nil | runtime: 0.6309ms
namespace=errbit_development.problems selector={"_id"=><BSON::ObjectId:0x70012665027820 data=55748bb563726f67e400008c>} flags=[:slave_ok] limit=0 skip=0 project=nil | runtime: 0.3846ms
namespace=errbit_development.$cmd selector={:update=>"problems", :updates=>[{:q=>{"_id"=><BSON::ObjectId:0x70012665383440 data=55748bb563726f67e400008c>}, :u=>{"$inc"=>{"notices_count"=>1}}, :multi=>false, :upsert=>false}], :writeConcern=>{:w=>1}, :ordered=>true} flags=[] limit=-1 skip=0 project=nil | runtime: 0.4282ms
namespace=errbit_development.$cmd selector={:update=>"problems", :updates=>[{:q=>{"_id"=><BSON::ObjectId:0x70012665383440 data=55748bb563726f67e400008c>}, :u=>{"$set"=>{"messages"=>{"cd4c2e0346474d0b2eb7f1a630309239"=>{"value"=>"Whatever the mind of man can conceive and believe, it can achieve... flags=[] limit=-1 skip=0 project=nil | runtime: 0.5181ms
namespace=errbit_development.apps selector={"_id"=>"55748b8463726f67e4000001"} flags=[:slave_ok] limit=0 skip=0 project=nil | runtime: 0.3517ms
~~~

While working on these queries, I noticed that Durran Jordan had recently
announced a [new chapter of mongoid
development](https://groups.google.com/forum/#!topic/mongoid/0QN06GBNnSo).
Upgrading to the latest version seemed like a nice, easy thing to try. So I did
that hoping to see a cheap improvement in Errbit. If anything, the performance
measurements were slightly worse than with Mongoid 4, but not enough to warrant
rolling back. I decided to stick with Mongoid 5 while continuing the
investigation.

I noticed by looking at this list that some of these queries are in fact
unnecessary. By making fewer queries, it should be possible to improve
performance because each query blocks the running thread from doing any other
work until the response comes in from the socket.

After a bunch of work, I was able to reduce the query count from nine to five:

~~~ console
namespace=errbit_development.apps selector={"api_key"=>"3777b363b3c03bc4e146f1e2523bf70b"} flags=[:slave_ok] limit=0 skip=0 project=nil | runtime: 0.4294ms
namespace=errbit_development.$cmd selector={:findandmodify=>"backtraces", :query=>{"fingerprint"=>"b8ff41db0f445d80a3a9c3ec91a2ecd9a06b1b56"}, :update=>{"$setOnInsert"=>{:fingerprint=>"b8ff41db0f445d80a3a9c3ec91a2ecd9a06b1b56", :lines=>[{"number"=>"425", "file"=>"[GEM_ROOT]/gems/activesupport-... flags=[:slave_ok] limit=-1 skip=0 project=nil | runtime: 2.0866ms
namespace=errbit_development.errs selector={"fingerprint"=>"155745cfe8d1e28f7485ce3236da5438f11d49df"} flags=[:slave_ok] limit=0 skip=0 project=nil | runtime: 0.4470ms
namespace=errbit_development.$cmd selector={:insert=>"notices", :documents=>[{"_id"=><BSON::ObjectId:0x69947441683300 data=557e0c9b63726f35570004c7>, "message"=>"Life is about making an impact, not making an income", "error_class"=>"ArgumentError", "request"=>{"url"=>"http://example.org/verify... flags=[] limit=-1 skip=0 project=nil | runtime: 0.3948ms
namespace=errbit_development.$cmd selector={:findandmodify=>"problems", :query=>{"_id"=><BSON::ObjectId:0x69947441715500 data=557dfdd763726f1d6d000031>}, :update=>{"$set"=>{"app_name"=>"test", "environment"=>"development", "error_class"=>"ArgumentError", "last_notice_at"=>Sun, 14 Jun 2015 23:2... flags=[:slave_ok] limit=-1 skip=0 project=nil | runtime: 0.6351ms
~~~

By making use of findandmodify, I was able to combine the operations to find
and modify backtraces and problems from five queries into just two. And I was
able to shave one more query from the end by caching the result of querying the
app record.

Expecting this to make a big difference in performance, I took some new
measurements. But in my next set of tests, I found no measurable impact.

## Round Two

Not to be deterred, I kept playing with Errbit until I noticed something
interesting that I hadn't before. While running my tests, I saw that the
request log seemed to flow in bursts, even though my server is running a single
process and a single thread. This burst-pause-burst behavior made me suspect
Ruby GC was somehow involved, so I instrumented Errbit with
[gc_tracer](https://github.com/ko1/gc_tracer) to see if I could confirm.

Here's a look at the server log during this test where I print GC!!!!!! on
every GC event:

~~~ console
$ bundle exec unicorn -c config/unicorn.default.rb > /dev/null
I, [2015-06-14T17:36:21.656538 #27248]  INFO -- : Refreshing Gem list
I, [2015-06-14T17:36:24.054633 #27248]  INFO -- : listening on addr=0.0.0.0:8080 fd=10
I, [2015-06-14T17:36:24.057564 #27248]  INFO -- : master process ready
I, [2015-06-14T17:36:24.058008 #27323]  INFO -- : worker=0 spawned pid=27323
I, [2015-06-14T17:36:24.060624 #27323]  INFO -- : worker=0 ready
127.0.0.1 - - [14/Jun/2015 17:36:29] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 1.0742
127.0.0.1 - - [14/Jun/2015 17:36:29] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0239
GC!!!!!!
127.0.0.1 - - [14/Jun/2015 17:36:29] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0910
127.0.0.1 - - [14/Jun/2015 17:36:29] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0273
127.0.0.1 - - [14/Jun/2015 17:36:29] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0400
127.0.0.1 - - [14/Jun/2015 17:36:29] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0267
127.0.0.1 - - [14/Jun/2015 17:36:29] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0253
127.0.0.1 - - [14/Jun/2015 17:36:29] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0266
127.0.0.1 - - [14/Jun/2015 17:36:30] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.7641
127.0.0.1 - - [14/Jun/2015 17:36:30] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0310
127.0.0.1 - - [14/Jun/2015 17:36:30] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0827
127.0.0.1 - - [14/Jun/2015 17:36:30] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0264
GC!!!!!!
127.0.0.1 - - [14/Jun/2015 17:36:30] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0952
127.0.0.1 - - [14/Jun/2015 17:36:30] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0313
127.0.0.1 - - [14/Jun/2015 17:36:30] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0236
127.0.0.1 - - [14/Jun/2015 17:36:30] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0262
127.0.0.1 - - [14/Jun/2015 17:36:31] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.7083
127.0.0.1 - - [14/Jun/2015 17:36:31] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0324
127.0.0.1 - - [14/Jun/2015 17:36:31] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.1000
127.0.0.1 - - [14/Jun/2015 17:36:31] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0381
127.0.0.1 - - [14/Jun/2015 17:36:31] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0689
127.0.0.1 - - [14/Jun/2015 17:36:31] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0357
GC!!!!!!
127.0.0.1 - - [14/Jun/2015 17:36:31] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0375
127.0.0.1 - - [14/Jun/2015 17:36:31] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.0266
127.0.0.1 - - [14/Jun/2015 17:36:32] "POST /notifier_api/v2/notices HTTP/1.1" 200 - 0.6870
...
~~~

The amount of time spent performing the actual GC is not negligible, but also
not immense. We're seeing one GC event for every 10 requests. We can tune
Ruby's GC parameters to change this behavior, but it will come at the expense
of memory. And increasing the time between GC events will likely increase the
time used to perform GC since in theory it should take more time to sweep more
memory space. Running into this many garbage collection events on a regular
basis indicates the process is steadily allocating chunks of memory.

It's worth pointing out that what we're seeing in these logs is not inherently
bad. It's merely indicative of a process that steadily allocates more garbage
collectible memory. Whether or not this is too much depends entirely on the
actual work that the process is doing. In this case, the process is basically
recording one error notification per request and I'm inclined to think there's
a large amount of unnecessary memory allocation which contributes in a sizable
way to Errbit's performance issues. Since allocating and garbage collecting
memory takes some amount of time, figuring out where all that memory is going
will be my next priority.
