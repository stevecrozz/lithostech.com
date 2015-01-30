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
<p><a href="http:&#47;&#47;www.flickr.com&#47;photos&#47;oxtopus&#47;143202024"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2008&#47;08&#47;4136613234_dc76ee0d99_o-217x290.jpg" alt="Stack of Floppies" width="217" height="290" class="alignleft size-medium wp-image-549" &#47;><&#47;a>I recently got a new VPS from <a href="http:&#47;&#47;vpslink.com">vpslink.com<&#47;a>. Their service is great because I can choose from a list of operating systems. I, of course, chose "Hardy Heron", Ubuntu 8.04. This service is totally unmanaged other than DNS and billing so I have to manage everything myself, including backup.<&#47;p></p>
<p>I haven't found anything out there that I've fallen in love with as far as backup is concerned, so I started with a shell script that covered the basics. I needed a rotating incremental backup script with full backups performed once a week. I wanted all the backups to live in a top level path like &#47;backup and I wanted the whole backup process to be owned and operated by a backup user. My distribution came with a backup user, it just needed to be configured.<&#47;p><br />
<a id="more"></a><a id="more-42"></a></p>
<p>So I created a home directory for the user at &#47;home&#47;backup and set its ownership and also created a &#47;backup folder and set its ownership.<&#47;p></p>
<pre>
sudo mkdir &#47;home&#47;backup<br />
sudo chown backup:backup &#47;home&#47;backup<br />
sudo mkdir &#47;backup<br />
sudo chown backup:backup &#47;backup<br />
<&#47;pre></p>
<p>The backup user will be using tar to backup my system, including files that even the backup user shouldn't be able to directly modify. So I modified my sudoers file to allow the backup user to use tar without providing a password (so it can be done automatically).<&#47;p></p>
<pre>
sudo visudo -f &#47;etc&#47;sudoers<br />
...<br />
backup ALL = NOPASSWD: &#47;bin&#47;tar<br />
<&#47;pre></p>
<p>Giving a user access to use tar as root is a major security risk which we'll deal with later by not allowing the backup user to login at all. For now, it'll be easiest if we can login as backup, so lets modify the existing backup user to allow a login, then we'll become that user and write the backup script.<&#47;p></p>
<pre>
sudo usermod  -s &#47;bin&#47;bash -d &#47;home&#47;backup -p <somepassword> backup<br />
su backup<br />
mkdir &#47;backup&#47;filesystem<br />
mkdir ~&#47;scripts<br />
vi ~&#47;scripts&#47;filesystembackup.sh<br />
<&#47;pre></p>
<p>The backup script I'm going to use is loosely based on someone else's script. To start with, let's set some relevant variables and the she-bang line.<&#47;p></p>
<pre>
#!&#47;bin&#47;bash<br />
DIRECTORIES="&#47;home &#47;etc &#47;var&#47;www &#47;var&#47;log &#47;usr&#47;share&#47;php"<br />
BACKUPDIR=&#47;backup&#47;filesystem<br />
CREATE="&#47;usr&#47;bin&#47;sudo &#47;bin&#47;tar --create --absolute-names --preserve --same-owner"<br />
EXTRACT="&#47;usr&#47;bin&#47;sudo &#47;bin&#47;tar --bzip2 --extract --same-owner --preserve --absolute-names --file"<br />
DOW=`&#47;bin&#47;date +%a`<br />
DOM=`&#47;bin&#47;date +%d`<br />
DM=`&#47;bin&#47;date +%d%b`<br />
LATESTBACKUP=$(date -r &#47;backup&#47;filesystem&#47;weekly&#47;$(ls -1rt &#47;backup&#47;filesystem&#47;weekly&#47;|tail -1))<br />
<&#47;pre></p>
<p>I want to backup all the home directories, the whole &#47;etc folder, all the webroot folders in &#47;var&#47;www, my php libraries, and probably some more stuff that I'll think of later. The $CREATE and $EXTRACT variables are tar commands to absolute path names, and preserve everything about the files that we're going to back up. I only set the $EXTRACT variable so I'll have the command I need in case of an emergency. This way I won't have to dig through the man pages like I've been doing when time is critical. A couple friendly developers helped me with the last line which gets the date of the most recent weekly backup.<&#47;p></p>
<p>Now before I start backing up files, there's one more thing that I want in the backup. That is, the most recent list of my installed official ubuntu packages. The home directory for backup seems like a good place for it since all the home directories are going to get backed up anyway.<&#47;p></p>
<pre>
&#47;usr&#47;bin&#47;dpkg --get-selections > &#47;home&#47;backup&#47;dpkg-list<br />
<&#47;pre></p>
<p>One thing to note, is that when the backup runs, it'll be running tar as root, so the files it creates won't be owned by the backup user, but by root. I don't like that, so we'll run the output of tar through a pipe to bzip2 which we won't run as sudo, so bzip2's output won't be owned by root, but by backup.<&#47;p></p>
<pre>
if [ $DOM = "01" ]; then #do the monthly full backup on the first of the month<br />
  $CREATE --file - $DIRECTORIES | &#47;bin&#47;bzip2 --compress > $BACKUPDIR&#47;monthly&#47;$DM.tar.bz2<br />
fi<br />
if [ $DOW = "Sun" ]; then #do the weekly full backup on sundays<br />
  BEGINSTAMP=`date`<br />
  $CREATE --file - $DIRECTORIES | &#47;bin&#47;bzip2 --compress > $BACKUPDIR&#47;weekly&#47;$DM-WEEKLY.tar.bz2<br />
  # Adjust timestamp to right before the backup began<br />
  touch --date "$BEGINTIME" $BACKUPDIR&#47;weekly&#47;$DM-WEEKLY.tar.bz2<br />
else #do the daily incremental backup<br />
  $CREATE --newer "$LATESTBACKUP" --file - $DIRECTORIES | &#47;bin&#47;bzip2 --compress > $BACKUPDIR&#47;daily&#47;$DOW.tar.bz2<br />
fi<br />
<&#47;pre></p>
<p>Take a look at how that works. The script checks for special days like the first of the month and Sunday. On those days it runs a backup into special directories. On every day except sunday, we do an incremental backup with only the changed files since the last weekly backup file was written. Every day, the script checks for the most recently modified weekly backup file and tells tar to only back up files newer than that. The savvy reader might notice that this system leaves a critical window between the time tar begins reading files for the weekly backup, and the time bzip2 writes the compressed file to the disk. That's why we need to record the time before tar begins archiving and apply it to the final bzip2 compressed archive.<&#47;p></p>
<p>Let's set the script's permissions now and schedule it to run in backup's crontab:<&#47;p></p>
<pre>
chmod 770 ~&#47;scripts&#47;filesystembackup.sh<br />
crontab -e<br />
&#47;home&#47;backup&#47;scripts&#47;filesystembackup.sh > &#47;dev&#47;null 2>&1<br />
<&#47;pre></p>
<p>Now we have rotating incremental filesystem backups in our &#47;backup&#47;filesystem path, but they're readable by anyone. Since we have sensitive data here, we'll set a James Bond umask for backup in .bashrc and then logout:<&#47;p></p>
<pre>
vi ~&#47;.bashrc<br />
...<br />
umask 007<br />
exit<br />
<&#47;pre></p>
<p>All that's left is to disable backup from logging in as a security measure:<&#47;p></p>
<pre>
sudo usermod --password '*' --shell &#47;bin&#47;false backup<br />
<&#47;pre></p>
<p>The hard part's all done. The backup files exist, but a hardware or other catastrophic failure could still wipe out your entire system, including its backups. My solution is to synchronize the &#47;backup directory to an off-site machine using rsync. All I need to do is give myself membership to the backup group and I'll be able to sync up a local copy of the backup.<&#47;p></p>
<p>From the remote host:<&#47;p></p>
<pre>
sudo usermod -a -G backup <myusername><br />
<&#47;pre></p>
<p>From my machine at home:<&#47;p></p>
<pre>
mkdir ~&#47;backup<br />
mkdir ~&#47;backup&#47;<site><br />
rsync --archive --verbose <site>:&#47;backup ~&#47;backup&#47;<site><br />
<&#47;pre></p>
<p>I'll schedule that to run every day and I'll consider doing this on more than one machine so I'll have redundant backups.<&#47;p></p>
