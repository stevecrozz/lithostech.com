---
layout: post
status: publish
published: true
title: linux filesystem rotating incremental backup
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "I recently got a new VPS from <a href=\"http://vpslink.com\">vpslink.com</a>.
  Their service is great because I can choose from a list of operating systems. I,
  of course, chose \"Hardy Heron\", Ubuntu 8.04. This service is totally unmanaged
  other than DNS and billing so I have to manage everything myself, including backup.
  \r\n\r\nI haven't found anything out there that I've fallen in love with as far
  as backup is concerned, so I started with a shell script that covered the basics.
  I needed a rotating incremental backup script with full backups performed once a
  week. I wanted all the backups to live in a top level path like /backup and I wanted
  the whole backup process to be owned and operated by a backup user. My distribution
  came with a backup user, it just needed to be configured.\r\n"
wordpress_id: 42
date: '2008-08-28 19:07:48 -0700'
date_gmt: '2008-08-29 03:07:48 -0700'
categories:
- Uncategorized
tags:
- linux
- backup
comments: []
---
<p><a href="http://www.flickr.com/photos/oxtopus/143202024"><img src="http://lithostech.com/wp-content/uploads/2008/08/4136613234_dc76ee0d99_o-217x290.jpg" alt="Stack of Floppies" width="217" height="290" class="alignleft size-medium wp-image-549" /></a>I recently got a new VPS from <a href="http://vpslink.com">vpslink.com</a>. Their service is great because I can choose from a list of operating systems. I, of course, chose "Hardy Heron", Ubuntu 8.04. This service is totally unmanaged other than DNS and billing so I have to manage everything myself, including backup.</p></p>
<p>I haven't found anything out there that I've fallen in love with as far as backup is concerned, so I started with a shell script that covered the basics. I needed a rotating incremental backup script with full backups performed once a week. I wanted all the backups to live in a top level path like /backup and I wanted the whole backup process to be owned and operated by a backup user. My distribution came with a backup user, it just needed to be configured.</p><br />
<a id="more"></a><a id="more-42"></a></p>
<p>So I created a home directory for the user at /home/backup and set its ownership and also created a /backup folder and set its ownership.</p></p>
<pre>
sudo mkdir /home/backup<br />
sudo chown backup:backup /home/backup<br />
sudo mkdir /backup<br />
sudo chown backup:backup /backup<br />
</pre></p>
<p>The backup user will be using tar to backup my system, including files that even the backup user shouldn't be able to directly modify. So I modified my sudoers file to allow the backup user to use tar without providing a password (so it can be done automatically).</p></p>
<pre>
sudo visudo -f /etc/sudoers<br />
...<br />
backup ALL = NOPASSWD: /bin/tar<br />
</pre></p>
<p>Giving a user access to use tar as root is a major security risk which we'll deal with later by not allowing the backup user to login at all. For now, it'll be easiest if we can login as backup, so lets modify the existing backup user to allow a login, then we'll become that user and write the backup script.</p></p>
<pre>
sudo usermod  -s /bin/bash -d /home/backup -p <somepassword> backup<br />
su backup<br />
mkdir /backup/filesystem<br />
mkdir ~/scripts<br />
vi ~/scripts/filesystembackup.sh<br />
</pre></p>
<p>The backup script I'm going to use is loosely based on someone else's script. To start with, let's set some relevant variables and the she-bang line.</p></p>
<pre>
#!/bin/bash<br />
DIRECTORIES="/home /etc /var/www /var/log /usr/share/php"<br />
BACKUPDIR=/backup/filesystem<br />
CREATE="/usr/bin/sudo /bin/tar --create --absolute-names --preserve --same-owner"<br />
EXTRACT="/usr/bin/sudo /bin/tar --bzip2 --extract --same-owner --preserve --absolute-names --file"<br />
DOW=`/bin/date +%a`<br />
DOM=`/bin/date +%d`<br />
DM=`/bin/date +%d%b`<br />
LATESTBACKUP=$(date -r /backup/filesystem/weekly/$(ls -1rt /backup/filesystem/weekly/|tail -1))<br />
</pre></p>
<p>I want to backup all the home directories, the whole /etc folder, all the webroot folders in /var/www, my php libraries, and probably some more stuff that I'll think of later. The $CREATE and $EXTRACT variables are tar commands to absolute path names, and preserve everything about the files that we're going to back up. I only set the $EXTRACT variable so I'll have the command I need in case of an emergency. This way I won't have to dig through the man pages like I've been doing when time is critical. A couple friendly developers helped me with the last line which gets the date of the most recent weekly backup.</p></p>
<p>Now before I start backing up files, there's one more thing that I want in the backup. That is, the most recent list of my installed official ubuntu packages. The home directory for backup seems like a good place for it since all the home directories are going to get backed up anyway.</p></p>
<pre>
/usr/bin/dpkg --get-selections > /home/backup/dpkg-list<br />
</pre></p>
<p>One thing to note, is that when the backup runs, it'll be running tar as root, so the files it creates won't be owned by the backup user, but by root. I don't like that, so we'll run the output of tar through a pipe to bzip2 which we won't run as sudo, so bzip2's output won't be owned by root, but by backup.</p></p>
<pre>
if [ $DOM = "01" ]; then #do the monthly full backup on the first of the month<br />
  $CREATE --file - $DIRECTORIES | /bin/bzip2 --compress > $BACKUPDIR/monthly/$DM.tar.bz2<br />
fi<br />
if [ $DOW = "Sun" ]; then #do the weekly full backup on sundays<br />
  BEGINSTAMP=`date`<br />
  $CREATE --file - $DIRECTORIES | /bin/bzip2 --compress > $BACKUPDIR/weekly/$DM-WEEKLY.tar.bz2<br />
  # Adjust timestamp to right before the backup began<br />
  touch --date "$BEGINTIME" $BACKUPDIR/weekly/$DM-WEEKLY.tar.bz2<br />
else #do the daily incremental backup<br />
  $CREATE --newer "$LATESTBACKUP" --file - $DIRECTORIES | /bin/bzip2 --compress > $BACKUPDIR/daily/$DOW.tar.bz2<br />
fi<br />
</pre></p>
<p>Take a look at how that works. The script checks for special days like the first of the month and Sunday. On those days it runs a backup into special directories. On every day except sunday, we do an incremental backup with only the changed files since the last weekly backup file was written. Every day, the script checks for the most recently modified weekly backup file and tells tar to only back up files newer than that. The savvy reader might notice that this system leaves a critical window between the time tar begins reading files for the weekly backup, and the time bzip2 writes the compressed file to the disk. That's why we need to record the time before tar begins archiving and apply it to the final bzip2 compressed archive.</p></p>
<p>Let's set the script's permissions now and schedule it to run in backup's crontab:</p></p>
<pre>
chmod 770 ~/scripts/filesystembackup.sh<br />
crontab -e<br />
/home/backup/scripts/filesystembackup.sh > /dev/null 2>&1<br />
</pre></p>
<p>Now we have rotating incremental filesystem backups in our /backup/filesystem path, but they're readable by anyone. Since we have sensitive data here, we'll set a James Bond umask for backup in .bashrc and then logout:</p></p>
<pre>
vi ~/.bashrc<br />
...<br />
umask 007<br />
exit<br />
</pre></p>
<p>All that's left is to disable backup from logging in as a security measure:</p></p>
<pre>
sudo usermod --password '*' --shell /bin/false backup<br />
</pre></p>
<p>The hard part's all done. The backup files exist, but a hardware or other catastrophic failure could still wipe out your entire system, including its backups. My solution is to synchronize the /backup directory to an off-site machine using rsync. All I need to do is give myself membership to the backup group and I'll be able to sync up a local copy of the backup.</p></p>
<p>From the remote host:</p></p>
<pre>
sudo usermod -a -G backup <myusername><br />
</pre></p>
<p>From my machine at home:</p></p>
<pre>
mkdir ~/backup<br />
mkdir ~/backup/<site><br />
rsync --archive --verbose <site>:/backup ~/backup/<site><br />
</pre></p>
<p>I'll schedule that to run every day and I'll consider doing this on more than one machine so I'll have redundant backups.</p></p>
