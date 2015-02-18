---
layout: post
published: true
title: Goodbye Wordpress, Hello Jekyll
date: '2015-02-17 23:06:05 -0800'
tags:
- wordpress
- jekyll
- cms
- s3
---
As you probably do not recall, this blog was not always running on
Wordpress. In it's first incarnation, it was actually [running Drupal
]({% post_url 2010-03-24-switched-from-drupal-to-wordpress %}). And as
of yesterday, we can add Wordpress to the list of former lithostech.com
platforms. {% picture thumbnail-right 2015/jekyll-homepage.png alt="Jekyll Homepage, Feb 2015" %} This
site is now running on Jekyll, and since it seems to be relatively
unkown compared to wordpress, I thought I'd take the opportunity to
explore this change and explain the move. What follows could be looked
at as a comparison of Wordpress to Jekyll as a blogging platform.

## Theming

Wordpress has served me well. There are plenty of free, prebuilt themes
ready to rock. Sadly, if you're searching for Wordpress themes and you
only consider themes that are mobile-friendly, SEO-friendly, easy to
work on and not full of bloat, you've already elimated the vast majority
of both free and paid themes that are available. If you want something
visually appealing, you're really down to a small handful of available
themes which means your only real option is to use one of those and
extend it, or write your own.

This is a bit daunting, but totally possible, especially starting from
an example. Just read [theme development docs
](http://codex.wordpress.org/Theme_Development) and have a great time.
You can `<?php var_dump($foo); die(); ?>` your way to a complete theme if
you have the time, but unless you're very familiar with this theming
API, it's going to take a while. It's possible to do just about anything
you can imagine, but I found theme authorship to be slow and painful and
more than a little annoying.

Jekyll uses [liquid](http://liquidmarkup.org/) for templating which is
quite powerful and much more compact than plain PHP. After all, Jekyll
is a much simpler tool than Wordpress, and for me that simplicity is a
core strength. Have a look at [this page's layout
](https://github.com/stevecrozz/lithostech.com/blob/master/_layouts/default.html)
to get an idea of how simple it is to write Jekyll themes.

<!--more-->

## Development

Working on Wordpress means writing themes and plugins. You have a few
options for where to do this development. You can develop on your live
server, which sucks, but I think it is what most people do. You can set
up a copy of Wordpress on your laptop including PHP and MySQL and
Apache, trying to minimize the differences between your development and
production environments. You could also set up a staging server as a
copy of your production server and work out the details of shipping code
from there to production. But Wordpress doesn't give you much to help
with the development workflow.

With Jekyll, you can set up a whole development environment with the
built-in web server: `jekyll serve`.  Jekyll automatically watches for
changed files and reloads the server for you. Since the output is just a
bunch of static files, the only possible differences between your
development and any other environment is the web server and its
configuration. I haven't run into a single problem there.

When you develop using Wordpress, there's a bunch of problems that you
have to solve yourself. Where do you keep your source code? How do you
test it? How do you install it? Will there be any weird interactions
with other installed plugins or some remote database state? You may keep
your source code in git, but you could ship it by uploading a zip file
or copying it to your server via FTP. With Jekyll, you keep the entire
platform in source control and you can deploy it anywhere by blindly
copying all the files to a remote location. Any problems should be
clearly visible before you ship.

## Deployment

With Wordpress, this is pretty simple. You just install mysql, php, some
php extensions and a web server (regular LAMP stack stuff). Then
configure the web server, run the web-based wordpress install script and
you're ready to go.

But it's even more simple with Jekyll. Jekyll needs only a filesystem
and a web server with no special configuration beyond what is required
to serve static files. It's so simple that you can deploy Jekyll as I've
done, with [Amazon S3](https://github.com/laurilehmijoki/s3_website).

## Backup

Backing up any system like wordpress is a pain. The Wordpress
application is essentially a bunch of PHP files on disk. These files
live right alongside themes (both enabled and disabled), plugins (both
enabled and disabled), uploaded content, environment-specific
configuration and whatever else someone put in that folder. You probably
have to back up the whole thing because who knows if someone has hacked
the core Wordpress files. You can configure where all these different
files go and you can try to make sure people don't hack Wordpress
itself, but the default configuration throws all these files into one
big, happy directory tree. So it's just like most other PHP apps.
Backing it up perfectly means taking a DB snapshot at the exact moment
that you take a filesystem snapshot. In my experience, this never
happens and everyone is just ok if the filesystem and DB backups are
slightly out of sync.  This is easy enough for any decent sysadmin. But
I've seen a lot of Wordpress sites and the only ones I've found with
adequate backup are the ones I've deployed myself.

For Jekyll, assuming your Jekyll site is in source control, then you
already have a backup, so there's nothing to do unless you want to
backup your backup. I'd encourage that. If you use something like git
then as long as you have the repo cloned in more than one place, I'd
call that a pretty good backup plan.

## Performance

Comparing Wordpress to to Jekyll in a performance test is in some ways
unfair. But since for me, the applications are filling the same
function, I have to do it. Running Jekyll means serving static files.
This means even the most basic installation will be serving up the
entire site from a filesystem cache. Since everything is static, the
entire site can be served up through a CDN with very little effort.

Wordpress can and should be setup with a decent cache, but it's not an
easy task. There's a million caching plugins, each one with its quirks.
I think I had my Wordpress site running fast on a filesystem cache at
one point, but it stopped working after an upgrade and I never figured
out why. In other words, Wordpress can compete with Jekyll if you spend
the effort required to cache everything. But who wants to spend time on
this stuff?

## Dynamic Pages

Here's where Jekyll falls behind. In order to launch this site in a
timely manner, I've given up the search feature. In Wordpress, my
database was my full text search engine. Since I no longer have a
database, I no longer have a search engine.

There are ways around this problem. For instance, I could use a hosted
search solution such as:

- [Google Site Search](https://www.google.com/work/search/products/gss.html)
- [Algolia](https://www.algolia.com/)
- [Amazon CloudSearch](http://aws.amazon.com/cloudsearch/)

Or I could force the browser to do the searching using something like
[lunr.js](http://lunrjs.com/) which seems pretty attractive. This is not
a win for Jekyll, but its something I can work around if I must have
search.

Any other dynamically generated pages cannot work in a static-only site.
For instnace, I switched my comments to [Disqus](https://disqus.com/)
last year because I anticpated wanting to move to Jekyll. I won't
pretend the lack of dynamic pages isn't serious limitation, but there
are a lot of creative solutions out there. In the end, I decided to give
up dynamic pages to gain all of Jekyll's other benefits.

## Authorship

Wordpress makes the job of an author very easy. There's a slick
auto-saving interface with fancy, custom UI for adding tags and
categories as well as for writing posts themselves. The default post
authorship UI control is known as a WYSIWYG (what you see is what you
get) editor. These things resemble typical word processing programs to
some extent and that makes non-techies feel fairly comfortable using
them. The WYSIWYG editor does its best to convert your chicken scratches
into HTML so it can be served to your users. But if you've used one more
than once, you'll understand what I mean when I say what you see is not
always what you get.

The learning curve here is a bit steeper in Jekyll. By default, in
Jekyll, you write your pages and posts in [Markdown](http://daringfireball.net/projects/markdown/syntax).
It takes a little getting used to, but by writing in markdown, you can
have a lot more control over the resulting markup and I think the
results are worth it.  There are a few great live markdown editors out
there. [Dillinger ](http://dillinger.io/) is one.

In Jekyll, all your post metadata, including tags and categoires is part
of a YAML snippet known as [front
matter](http://jekyllrb.com/docs/frontmatter/). If you're used to a GUI,
then this is a step back. But I'm very comfortable editing YAML by hand,
and it is nice having it all in the same document.

## The Winner is Jekyll

Jekyll won me over. I've been planning this move for a while, but didn't
really get started until google sent me a warning about how bad my site
was working on mobile devies. I didn't realize how much I'd grown to
dislike Wordpress until I was faced with the thought of writing a new
Wordpress theme. Instead I switched to Jekyll. And I'm glad I did.
