---
layout: post
status: publish
published: true
title: trading algorithm — how to write and deploy
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 668
wordpress_url: http://lithostech.com/?p=668
date: '2014-09-07 23:20:22 -0700'
date_gmt: '2014-09-08 06:20:22 -0700'
categories:
- Uncategorized
tags:
- finance
- trading
- algorithms
comments: []
---
Through our work on the [OptionsHouse API
client](http://lithostech.com/2012/09/automated-trading-via-optionshouse-api/),
we've somehow become known as trading algorithm experts. At least once a
week, Branded Crate gets a phone call or email from someone who wants to
automate trading activity. To even have a thought like this requires
some level of sophistication. Even so, many potential clients aren't
aware of what it takes to create and manage a system like this. That's
our area of expertise, so if you're considering trading automation, read
on to learn more about how we do it.

The very heart of any trading algorithm is the actual algorithm, written
using instructions a machine can understand (code). This is mainly what
clients think about when they talk to us. The idea generally seems
simple at first, but complexities emerge as you begin to consider
automation. Without even thinking, clients "just know" to do things a
certain way as they execute their trading strategies manually.
Computers, on the other hand, don't know anything.

Let's say a client wants to buy N shares of some stock when the current
price of that stock is lower than it was at the same time on the
previous trading day and sell when the current stock price is higher
than the same time on the previous trading day. This is probably a
terrible strategy, but ignore that because it can still serve as an
example of how and where complexities emerge.

<!--more-->

Consider the first condition of our algorithm: buy when the current
stock price is lower than it was yesterday. Checking the current stock
price is easy. Most of the APIs I've seen have a call specifically for
this purpose. You just send in the ticker symbol and get back the
current price. But how can the computer know what the price was
yesterday at a specific time? Unless an external service can provide
this information, the program will actually have to have run yesterday
and recorded price information at the right time. Storing data means
creating and managing a database and introduces statefulness because
database contents (state) affect the output of the algorithm. Adding a
database also introduces a new failure scenario that requires special
handling because when the database fails, the algorithm should probably
stop itself as safely as possible. It is possible for anything to fail.

Now you have a stateful algorithm, constantly recording price
information for your target security and it's capable of making the
decision to buy according to its instructions. Let's say it does so and
buys some stock at 10:00am. Now 10:05am comes and the same buy condition
is met again. As a human being, you probably understood the algorithm to
cover this scenario and you likely wouldn't buy again. But a computer
follows its instructions to the letter.  Unless the buy condition is
qualified, it will buy every time it sees the stock price lower than it
was yesterday. You can qualify the instruction by adding a condition
like 'buy only once per day,' but this condition is still ambiguous to a
computer. Is one day a trading day? or is it a 24 hour period? Computers
are unable to make assumptions, so this level of specificity is required
for all aspects of the program. Either way, the algorithm now has to
take into account the last time it made a purchase, which introduces
more state and more failure scenarios to account for.

There are many other scenarios to consider. You probably want to set
some overall limits on how much your algorithm should buy so it doesn't
exhaust your entire cash balance and start buying on margin. Even if you
want that, you probably still need a limit so the algorithm doesn't
start entering orders that your broker can't fill when you're out of
money. Likewise, you probably want to limit selling to some extent or
you could end up with a short position you never intended. And what
should the algorithm do when the market is unexpectedly closed? What if
your broker is having issues and failing to respond appropriately to
requests? What if your broker returns the wrong current price info? This
can happen and it's especially troublesome, but the algorithm can only
take input and follow instructions so it needs to be told how to
respond.

Speaking of input, algorithms generally require some kind of user input
so that program behavior can change without requiring a code change. For
this example algorithm, you could probably imagine wanting to change the
stock symbol or transaction size among other things. You may also want
to send signals to the running program giving it instructions to change
modes or stop altogether.  These are all program inputs or messages that
need to be relayed to your algorithm. For those of you familiar with
command line interfaces, this can be accomplished easily via command
line arguments. But most of the time, clients need a more user-friendly
way to manage their algorithm, and that means creating a user interface
and making it accessible somewhere like an internet web address.

In order to do much of anything useful, the algorithm will have to be
connected to the Internet, and as with anything on the Internet, there
are some important security considerations. In order to access your
broker, the program will need sufficient security credentials to do
whatever it does. Most brokers I've looked at require your one and only
account username and password to access their API. And in order for the
program to be remotely manageable, it will have to provide some kind of
remote interface. Putting your secret brokerage credentials on a
remotely accessible computer connected to the Internet is a security
risk to say the least. The risk can be managed to some degree, but that
takes some effort and the risk cannot be eliminated entirely.

If you have a trading algorithm, you'll probably want to be able to
check on it from time to time. You may want to know if it's running, and
if so, what it's doing. The program itself can be made to answer any
question about its current state, and it can create audit trails of what
it's done in the past. For simple programs, a daily email digest could
be sufficient. But more complex programs could require custom reports
with charts and graphs, and all that needs to be provided from a
remotely accessible interface.

Automated trading algorithms are generally computer programs. In order
to run, they need to be installed on a computer somewhere (the host).
The host needs to be on all the time, have an accurate and reliable
clock, and a reliable Internet connection. Generally, this is not
something you should plan on running on your desktop or laptop computer.
There are cloud computing companies that provide this exact service at a
reasonable price and we recommend using them. But generally, management
is not included. Computers and software programs can fail in all kinds
of ways. A smart program can recover from many failures on its own, but
not all. Some failures will require human intervention to diagnose and
fix, either from you or someone you trust.

Since trading algorithms are inherently dangerous things, it is
absolutely vital that they be tested rigorously. If your broker provides
a paper trading account, that's one good way to test, but it's not
enough. All the decision making and trading code must get special
scrutiny and extra attention from the developers including peer-review
wherever possible. It's important to take all the time needed to ensure
the safety of your algorithm to the best of your ability.

These considerations are just a minimum set for anyone thinking about
running a trading algorithm for any length of time. There are other
considerations like high availability and disaster recovery, but they're
not necessarily essential.  This may sound like a lot to deal with and
it is. But it's still doable and certainly worth the effort if the
algorithm pays off.
