---
layout: post
status: publish
published: true
title: improved javascript dependency injection framework
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 690
wordpress_url: http://lithostech.com/?p=690
date: '2014-11-20 15:57:52 -0800'
date_gmt: '2014-11-20 23:57:52 -0800'
categories:
- Uncategorized
tags:
- javascript
- dependency injection
comments: []
---
JavaScript dependency injection is all the rage these days. But after
looking through all the options, I just haven't found the perfect
framework. That's why I'm introducing my own framework to provide the
best possible interface, helping you to inject exactly the dependency
you need.

First, I want to introduce the problem we're trying to solve. Let's say
you have a JavaScript function that has a dependency, but the client
knows too much about the dependency. This is what smarty-pants engineers
call "tight coupling":

~~~ javascript
function Dependency1(say){
  alert(say);
}

function Client(){
  new Dependency1('hi'); // bad! tightly coupled interface
}

new Client();
~~~

<!--more-->

When this program executes, it works, but Client is tightly coupled to
Dependency1 because it references Dependency1 directly. It would be much
better if Client didn't have to reference Dependency1. To see why,
imagine Client could be written like this instead:

~~~ javascript
new dependency('hi'); // instead of new Dependency1('hi');
~~~

All of a sudden, Client would have no direct knowledge of Dependency1.
As long as the call to dependency and the object it refers to are
interface compatible, then everything will continue to work. Client is
now more testable, more maintainable and more reusable. It has less
knowledge of the outside world. All it knows is that it can refer to an
object called 'dependency' and that object implements a particular
interface.

So how can we achieve this state of total nirvana? By using my new
dependency injection framework. Let me show you how it works with an
example:

~~~ javascript
function Dependency1(say){
  alert(say);

}

dependency            =                Dependency1;
/* ^                  ^                    ^
  binding   dependency injection      object to bind
            framework registration
            operator                              */

function Client(dependency){
  new dependency('hi'); // amazing! loosely coupled greatness
}

new Client(dependency);
~~~

You can see the new operator I've used on line 5 which I'm calling the
'dependency injection framework registration operator' (DIFRO). When you
use this operator, you are essentially registering the object on the
right-hand side with the name (or binding) on the left-hand side. In the
above example, I've registered Dependency1 using the name 'dependency'.
After you've registered a dependency like this one, it can be injected
into any function just by using the name you already gave it using an
advanced concept called "passing an argument".

You might be thinking, "That's cool, but now the binding 'dependency'
has leaked out of the current scope. What if I want to have a whole
separate dependency injection framework specific to the current lexical
scope?"

Not a problem. You can use the 'var' keyword to instruct the dependency
injection framework to bind an object in such a way that it doesn't leak
to an outer scope. You can have as many dependency injection frameworks
as you want. You can register any object using any name in any scope.
The framework will faithfully give you any object you need when you
specify the name you registered. As a bonus, you don't have to download
anything to begin taking advantage of my new framework. You can start
using it immediately. Now you can see why this incredible framework is
about to take the world by storm.
