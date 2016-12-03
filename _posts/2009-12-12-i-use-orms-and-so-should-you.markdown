---
layout: post
status: publish
published: true
title: I use ORMs (and so should you)
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 81
date: '2009-12-12 02:13:32 -0800'
date_gmt: '2009-12-12 10:13:32 -0800'
categories:
- Uncategorized
tags:
- programming
- web development
- database
comments: []
---
{% responsive_image path:
static/img/full/2009/4136613234_dc76ee0d99_o.jpg alt: "the original
database" class: "img-float-left" %} This blog entry is directed mainly
at the body of web developers who have very little formal training but
are trying to improve their own skill sets. As I've matured in my
understanding of object-oriented software design, I've come to grips
with certain realities. Often, I've found myself doing something that
feels 'dirty' or 'hackish'. That's usually because I'm "doing it wrong"
as smarter people say to me when I show them my code or describe my
problem. When that happens I have two courses of action, but the only
one that provides growth and self-improvement is to heed the advice of
my mentors (usually a chorus of developers on IRC saying, "you're doing
it wrong!").

<!--more-->

It's true, I have done it wrong many, many times, but I have learned
from my mistakes and am here to tell you why you should be using
Object-Relational Mappers (ORMs). My recent realization has come after
using a medley of systems to access databases: sqlalchemy, django,
propel, Active Record, Doctrine, and Zend_Db to name a few. This last
one (Zend_Db) is the one that finally drove me to madness with a
complicated sports statistics application. This is no fault of Zend_Db,
it's just not an ORM, and what I need is an ORM. Here's why:

When you're writing object-oriented (OO) software, you're are by
definition working with objects which are instances of classes. Classes
and instances of classes by themselves are great, but its not the
classes themselves that make OO so powerful, its the relationships
between the classes where you can fully realize the power of OO. In my
opinion, the property that most defines OO design is the pursuit of
encapsulation which ensures that all the relationships, operations and
properties of your classes are logically compartmentalized.

Unfortunately, the pursuit of encapsulation and well-designed software
is not perfectly compatible with the way most web applications store
(persist) and retrieve these objects. Most of the time, we use
relational database management systems (RDBMS) such as MySQL,
PostgreSQL, SQLite, etc. The problem is, its hard to preserve an
object's state when all you have to work with is a row in a relational
database. Consider this example controller logic where we want to fetch
a blog entry and related content for display:

~~~ javascript
// Direct DB interface library
entry_result = db.execute("SELECT * FROM `entry` WHERE `entry_id` = %s" % entry_id).first()
entry = new Entry(entry_result)
assets = array()
assets_result = db.execute("SELECT * FROM `asset` WHERE `entry_id` = %s" % entry_id)
for (asset in assets_result) {
  assets.push(new Asset(asset))
}
comments = array()
comments_result = db.execute("SELECT * FROM `comment` WHERE `entry_id` = %s
  LEFT JOIN `author` ON `comment`.`author_id`=`author`.`id`
  " % entry_id)
for (comment in comments_result) {
  comments.push(new Comment(comment))
}
tags = array()
tags_result = db.execute("SELECT * FROM `tags` WHERE `entry_id` = %s" % entry_id)
for (tag in tag_result) {
  tags.push(new Tag(tag))
}
~~~

~~~ javascript
// With an object oriented database abstraction layer
entry = Entry.find(entry_id)
assets = Asset.get_by_entry(entry_id)
comments = Comment.get_by_entry_with_author(entry_id)
tags = Tag.get_by_entry(entry_id)
~~~

~~~ javascript
// With an ORM
entry = Entry.find(entry_id)
entry.assets()
entry.comments()
entry.tags()
~~~

All three of these examples attempt to get data from a database and at
some point convert the data into usable objects. Some of them take a lot
more code than others. All of them require some code because there's no
getting around the need to use some information to actually look up the
entry in question.

Lets take a look at the first example. If you are still writing and
hacking through SQL by hand (some people are still doing this as their
main method of database access), you have not only mixed your model and
controller code (very bad), but you are also stubbornly refusing to
capitalize on all the hard work that entire development communities have
spent years creating and refining. There are still occasional reasons to
write SQL by hand but they are comparitively rare. Please at least use
an object oriented database abstraction layer (think Zend_Db).

But even with that, you're really only slightly better off. For this
application, what we really need is a full-on ORM. With an ORM you write
less code. Less code means less opportunity for bugs, less opportunity
for creating security vunlerabilities and shorter development time, not
to mention you end up with code that looks nice! If you're new to the
idea of an ORM you may wonder why we haven't tried to access assets,
comments or tags in the final example. With an ORM, your system is not
only aware of the relationships between objects, but also the way those
objects and relationships map into your relational database. Hence the
name. There's no need to go fetch all the comments in your controller
because you can access all the comments in your view via the entry
object. When its time to fetch comments for display in your view, you
may call something like entry.get_comments() which would dispatch a new
database query (if you haven't already eager-loaded the comments) and
could return an object which can be iterated upon. There's also
generally no need to write the get_comments method because most ORMs
automatically have such methods available based on nothing other than
the relationships you define.

Keep in mind, these examples are simple for the sake of illustration.
Some systems have extremely complicated relationships which are
difficult to access using old-fashioned database interfaces. This makes
an ORM even more valuable in those circumstances. But it doesn't stop
there. Since we're no longer executing database queries, and instead
operating on related objects, we can try to design models for our
application by setting certain rules within them. We can decide to
eager-load authors when we load comments so we don't lose a lot of
efficiency at the database layer. We can take a page out of django's
book and not even perform database queries by default until the results
are truly needed. That gives us ridiculous flexibility in paginated
views where we only want entries 31-40 for instance (because a limit
query can be dispatched at that time rather than before).

All this is barely scratching the surface of why you need to be using an
ORM. As a side benefit, most ORMs come bundled with other niceties like
database connection pooling, a migration framework, a variety of back
end support, abstraction and fixtures, all of which you need when you're
building web applications, though you might not know it.

In short, you need to be using an ORM.
