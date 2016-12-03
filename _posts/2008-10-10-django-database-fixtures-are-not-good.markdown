---
layout: post
status: publish
published: true
title: django database fixtures are <del>not</del> good
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 57
date: '2008-10-10 05:46:28 -0700'
date_gmt: '2008-10-10 13:46:28 -0700'
categories:
- Uncategorized
tags:
- programming
- python
- django
comments:
- id: 3
  author: ''
  author_email: ''
  author_url: ''
  date: '2008-10-10 18:28:47 -0700'
  date_gmt: ''
  content: "You can just include certain applications by passing them to the dumpdata
    command.\r\n./manage.py dumpdata blog \r\nWill only dump your blog tables."
- id: 4
  author: ''
  author_email: ''
  author_url: ''
  date: '2008-10-10 18:29:52 -0700'
  date_gmt: ''
  content: "Hi there,\r\n\r\nI use initial_data.yaml files a lot, so you might be
    interested that Django looks only in the fixtures/ directories inside the
    directories of each of your INSTALLED_APPS (see your project's settings.py). Furthermore
    you are able to specify an optional FIXTURE_DIRS list in your settings.py where
    Django should also look for fixture files. (http://docs.djangoproject.com/en/dev/ref/settings/#fixture-dirs)\r\n\r\ndumpdata
    takes a list of app names, that enables you to only dump the models inside those.\r\n\r\nCheers,\r\njezdez\r\n"
- id: 5
  author: stevecrozz
  author_email: ''
  author_url: ''
  date: '2008-10-13 05:58:25 -0700'
  date_gmt: ''
  content: I'll definitely use that one
- id: 526
  author: pragmar
  author_email: ben@pragmar.com
  author_url: http://www.pragmar.com
  date: '2010-06-07 12:17:58 -0700'
  date_gmt: '2010-06-07 19:17:58 -0700'
  content: Fixtures can definitely be a chore when models are in flux. You'd think
    flush could add missing table columns since it is destroying the data anyways,
    but for whatever reason it will not modify an existing table. Generally I've found
    the easiest way to use a fixture during early development is to run a script that
    drops the database tables, syncdb, then loaddata (in that order). Once development
    is mature and models aren't changing, loading from fixtures is a lot less of a
    headache.
- id: 1083
  author: Gene
  author_email: gene@picante.co.nz
  author_url: http://blog.picante.co.nz
  date: '2010-07-22 15:49:03 -0700'
  date_gmt: '2010-07-22 22:49:03 -0700'
  content: "Hi,\r\n\r\nConsider South for prototyping.   It is extremely easy on the
    developer to change the schema in models.py (which you do anyway), then create
    a migration (a one liner), and migrate (another on liner.)\r\n\r\n  $  vi models.py
    #  add remove fields, tables, change types, etc.\r\n  $  manage.py startmigration
    myproj --auto  #  creates a migration file\r\n  $  manage.py migrate myproj  #
    \ runs\r\n\r\nYou can even prototype with a distributed team.  Just check the
    migrations in.\r\n\r\nWhen you run tests, your migrations are run to bring your
    db up to the current migration revision on the test DB.  Then it loads fixtures,
    if that's how you add in test data. \r\n\r\nWhen the rate of db schema changes
    slows down, you can refactor your migrations in a number of ways.  But, you should
    continue to use South.  \r\n\r\n(Note, I don't have anything to do with South.
    \ I just think it's required equipment in a Django DB application.)"
---
{% responsive_image path: static/img/full/2008/django-logo.jpg alt:
"Django logo" class: "img-float-left" %} I've been working on a project
using django, and I've got some great things to say about it. I also
have some nasty things to say. I'm currently prototyping, which means
the databases I work with get destroyed and recreated regularly. I
normally have a set of test data that should always be present in the
system. Database fixtures to the rescue!

The [django
documentation](http://docs.djangoproject.com/en/dev/howto/initial-data/)
has a nice section on database fixtures and how to deal with them
properly. You can even give your fixtures a special name (initial_data),
and the syncdb command will automatically load your initial fixtures for
you. The first thing that really struck me about these fixtures is the
fact that you have to reference your model for every database row. Why
not divide the fixtures into sections so you only have to type it out
once? The fixtures could really benefit from that type of context.

The second thing I noticed, after typing out all my fixtures in YAML
format, is that django claims to support YAML format, but doesn't
actually check for an initial_data.yml (or initial_data.yaml) file.
That's a big disappointment. Now am I supposed to translate that file
back into xml or json? It picks up files with those names perfectly
fine.

<!--more-->

You might think I should use django's dumpdata command, but you might be
surprised to know that while dumpdata allows you to specifically
*exclude* certain models, it doesn't allow you to *only include* certain
models. My project has nearly 100 database tables and dozens of models.
Am I supposed to --exclude each of them?

I've spent the last hour and a half trying to get django to bend to my
will. Needless to say, I am less than impressed. It would be nice if I
could easily force the system to check for yaml files, but to a django
novice like myself, the framework appears to suffer from black box
syndrome with its weird system of magical callbacks. Does anyone know
what's going on here?

**UPDATE 2008-10-12:** I've got some helpful feedback from here and had
a fresh look at the documentation. Looks like I glossed over the part
where it said next to yaml: "This serializer is only available if PyYAML
is installed". So a quick "apt-get install python-yaml" did the trick
for me (ubuntu package) after renaming my .yml file to .yaml. If you
can't find a binary for your OS, you can always get the <a>PyYAML
source</a>. Initial database fixtures are now working smoothly for me in
my format of choice.
