---
layout: post
status: publish
published: true
title: working with linux filesystem permissions and acl
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 70
date: '2009-02-14 02:19:11 -0800'
date_gmt: '2009-02-14 10:19:11 -0800'
categories:
- Uncategorized
tags:
- linux
- acl
- permissions
- filesystem
comments: []
---
Now that we have our fancy new VPS and are allowed to create multiple
user accounts, I've run into a problem with basic linux permissions that
you really only find when you have multiple users working in the same
space. In my case, we need multiple users to have access to all of our
online property web roots. I started by using chown to force the entire
web root under the ownership of www-data:www-data and adding everyone
who needed access to the secondary www-data group. This works fine until
people start making changes. Each new file they write becomes owned by
only them and their primary group.

<!--more-->
For example, stevecrozz creates a new file in the web root and it ends
up looking like this:

~~~ bash
-rw-r--r--  1 stevecrozz stevecrozz    0 2009-02-14 01:50 stuff
~~~

Of course this means that no one else will be able to make changes to
that file. After a little digging in the man pages I found the
set-group-id flag which forces new files to be owned by the group of the
containing folder. That gets me much closer, but not quite there.

~~~ bash
$ rm -Rf test
$ mkdir test
$ sudo chown www-data:www-data test
$ sudo chmod 2775 test
$ touch test/somefile
$ ls -lAh test
total 0
-rw-r--r-- 1 stevecrozz www-data 0 2009-02-14 02:07 somefile
~~~

The group ownership of the parent folder is preserved, but the file
still isn't writeable by another member of the group. This is where I
ran into the limits of basic unix-style permissions. Luckily, as I
found, there's a more complete acl-style setup ready to go. In ubuntu,
you can install the tools to make it work with (oddly enough) "apt-get
install acl".

Your filesystem needs to be mounted with acl support, so edit your
/etc/fstab and find the line for the filesystem you want to alter. and
add acl in there. I changed the line:

~~~ bash
/dev/sda1       /           ext3    defaults,errors=remount-ro,noatime    0 1
~~~

to:

~~~ bash
/dev/sda1       /           ext3    defaults,acl,errors=remount-ro,noatime    0 1
~~~

Remount it with "sudo mount -o remount,acl /" instead of rebooting.

Now you're ready to go with much more powerful access control. Now you
can go crazy. In this example I'll make all the directories in my web
root world readable and group writeable including every new file and
directory.

~~~ bash
$ cd /var/www
$ sudo find -type d -exec chmod 0775 {} \;
$ sudo find -type f -exec chmod 0664 {} \;
$ sudo setfacl -R -m d:u::rwx,d:g::rwx,d:o:--- .
$ ls -lAh
total 40K
drwxrwsr-x+  9 www-data www-data 4.0K 2009-02-14 01:28 blitz.fresnobeehive.com
drwxrwsr-x+ 11 www-data www-data 4.0K 2009-02-14 01:20 data.fresnobeehive.com
drwxrwsr-x+  3 www-data www-data 4.0K 2009-02-14 01:42 fblinks.com
drwxrwsr-x+ 13 www-data www-data 4.0K 2009-02-14 01:14 fresnobeehive.com
drwxrwsr-x+  3 www-data www-data 4.0K 2009-02-14 00:47 newsroom.fresnobeehive.com
$ getfacl fresnobeehive.com
# file: fresnobeehive.com
# owner: www-data
# group: www-data
user::rwx
group::rwx
other::r-x
default:user::rwx
default:group::rwx
default:other::r-x
$
$ touch fresnobeehive.com/somefile
$ mkdir fresnobeehive.com/somedir
$ ls -lAh fresnobeehive.com
...
drwxrwsr-x+ 2 stevecrozz www-data 4.0K 2009-02-14 02:32 somedir
-rw-rw-r--  1 stevecrozz www-data    0 2009-02-14 02:31 somefile
...
~~~

You can see that new files created are owned by the www-data group and
have the group write flag set. New folders are added in the same way
plus they have the access control flags of the parent. If anyone needs
access to write to the web root, I just add that person to the www-data
group. Those  pluses on the end of the permission strings mean that
we've got acls set which we can examine with getfacl, and also that I am
awesome.
