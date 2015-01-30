---
layout: post
status: publish
published: true
title: all about backup
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "Backup seems like a very simple concept. The idea is to make an extra copy
  of important data so in the event of a failure or disaster, that data can be promptly
  recovered. But anyone who&#39;s been through the data recovery process knows that
  its just not that simple.\r\n\r\n"
wordpress_id: 13
date: '2006-06-03 20:31:47 -0700'
date_gmt: '2006-06-04 04:31:47 -0700'
categories:
- Uncategorized
tags:
- backup
comments: []
---
<p>Backup seems like a very simple concept. The idea is to make an extra copy of important data so in the event of a failure or disaster, that data can be promptly recovered. But anyone who&#39;s been through the data recovery process knows that its just not that simple.<&#47;p></p>
<p>There are a staggaring array of different choices to make when designing a backup solution. The decisions you make will be determined by the type of data and amount you need to back up, your reliability and downtime tolerances, and your budget. A good backup solution can be as simple as a USB thumb drive to hold backup accounting records or as complex as the most advanced disk to disk to disk solutions for backing up legacy database systems.<&#47;p><a id="more"></a><a id="more-13"></a></p>
<p><strong>Choosing Hardware<&#47;strong></p>
<p>The hardware you choose will probably be your most important investment in a backup solution. The hardware you choose should last many years, so you should consider your options carefully.<&#47;p></p>
<p><em>Nothing<&#47;em></p>
<p>The first and most popular backup solution is to not backup at all. Many people have lost valuable data more than once and continue to operate with no backup solution. If you are doing this you are simply begging to lose your data.<&#47;p><br />
<em>RAID<&#47;em></p>
<p>The second most popular backup choice is RAID (Redundant Array of Independant Disks). Very simply, RAID uses two or more hard disk drives inside your computer rather than just one. The disks operate as a single unit. The result is that a disk can fail completely and be replaced many times without any down time at all. RAID cannot be considred a viable backup solution because any errors on one disk end up on the other disks (possibly ruining your data) and it does not protect you from catastrophes like fire and theft.<&#47;p><br />
<em>Tape backup<&#47;em></p>
<p>Tape backup solutions are also very popular. Tapes can hold vast amounts of data for their small size and price to storage capacity ratio. But here at lithostech, we rarely recommend tape backup as a solution. The magnetic tape media normally doesn&#39;t last more than a few years of reading and writing, and we&#39;ve simply never had a good experience restoring from tape backup. We even had one occasion where a drive motor actually spun the tape right off the reel during a nightly backup. Take our advice and avoid tape backup like the plague.<&#47;p><br />
<em>Disk backup<&#47;em></p>
<p>Normally we recommend disk backup hardware just like the drives you need to back up from. A simple disk backup solution could be a portable USB or firewire drive. Some manufacturers have made optical disk drives with swappable disks designed specifically for backups. For medium sized businesses with very important data, often times we recommend a SAN (Storage Area Network). A SAN is a machine physically connected to the company network. The sole purpose of a SAN is to provide lots of data storage. It can be used as a centralized backup center even for data located on many machines accross the network. But unless the SAN is located in a remote office, it is still subject to the same disasters that threaten the rest of your network. This is why a complete backup solution always includes a portable disk (to be taken off site every night). Specialized software can backup your data from your computer&#39;s hard drives to a SAN and then to a portable hard drive. This is known as disk-disk-disk backup.<&#47;p><br />
<em>Remote backup<&#47;em></p>
<p>Alternatively you can let someone else handle your backup needs. You can subscribe to an online backup service and (for a subscription fee) upload your data securely over the internet to a remote backup site. With this solution running, you never have to worry about taking a copy of your data off site every day because it already is off site. But many times this solution is not feasible because internet connections are extremely slow in comparison to any modern local backup device. If you have a moderate amount of data to backup or a slow internet connection this will probably not work for you.<&#47;p></p>
<p><strong>Caveats<&#47;strong></p>
<p>Choose a backup solution with room for expansion, don&#39;t limit yourself. Too many people end up with more data than their system can handle and end up having to use multiple disks which complicate things. Or worse yet they may just not realize that their backup solution is no longer backing up all their data. Pay attention to the difference between &#39;compressed&#39; storage space and actual storage space. Backup hardware vendors will tend to inflate their storage capacities by using a &#39;compressed&#39; storage value. Vendors typically use a compression ratio between 2:1 and 3:1 so their capacities can be overstated by a factor of 3 or sometimes more. This number is basically meaningless and should not be compared accross brands. If a company claims their storage solution can hold &#39;up to&#39; a certain amount be sure to ask whether that is compressed or uncompressed. Many times the data you want to back up is already compressed and cannot be compressed much further.<&#47;p><br />
<strong>Software<&#47;strong></p>
<p>There are many vendors selling their own brand of backup software. Most of them offer a free 30 day trial version to allow you to determine what is right for you. If you need a very basic backup solution, its possible that your operating system can provide the backup functionality you need with built in software (ie NTBACKUP for Windows).<&#47;p></p>
<p>One problem you will probably run into while setting up your backup solution are files currently in use. Normally, when a file is in use, it cannot be accessed by another application or user. This means that if your important files are open while the backup procedure runs, those files will not be backed up. This can turn out to be very frustrating because a forgetful or careless employee may leave important files open on his or her workstation every single night when the backup is running. If this is a problem, your company can force users to log off at night or after a period of inactivity.<&#47;p></p>
<p>But if employees need 24&#47;7 access to files, then important data may still escape the backup procedure. Thankfully, the latest versions of most Operating Systems can handle this by forcing the system to copy what its using to memory and stopping the disk use of that file. Then the system takes a snapshot of the data. That way when the backup program runs it can grab a copy of the snapshot if a particular file is still in use. Windows Server 2003 uses the Volume Shadow Copy Service for this, Linux distrobutions can use LVM2, and other operating systems and software packages have various names for the same concept.<&#47;p></p>
<p>Unfortunately most software systems are not VSS aware, so when Microsoft&#39;s VSS sends its commands to a running process they are not understood. If you use legacy software, this service may not work for you. The other option (for non VSS aware Windows software) is to use St. Bernard software Open File Manager. Most common backup suites offer Open File Manager as an add-in and it goes by several different names.<&#47;p></p>
<p>If you need to backup an exchange server, an SQL database, or an ORACLE database, you should look into the offerings from different backup software vendors. If you need to do disk-disk-disk make sure your software can support that before you make your decision.<&#47;p></p>
<p>Keep in mind that even though you may have a great backup that has all your important data, it may take you several hours to properly restore that data. Most backup systems backup only files, folders, and databases. This means that when your hardware fails, you need to replace your failed hardware, then reinstall and setup your operating systems, then reinstall all the critical software, and then copy your data to its new location. All this can take an awfully long time. Some businesses have been able to bypass most of this work by using their backup system to back up the entire system from the ground up. A full system restore can be in the range of an hour or less because the process is mostly automated and takes care of Operating Systems, software, settings, and data all at once. This form of backup, sometimes referred to as Bare Metal Backup, uses up more resources and requires special software, but the ease of recovery makes it an important option for those of us working with mission critical data.<&#47;p></p>
<p>All in all, backup can be a very confusing subject. Make sure you try your software before you buy it. Don&#39;t spend any money until you know what you need. Be very careful about buying used equipment, many times old computer equipment is unloaded for next to nothing when its no longer supported, and the last thing your company needs is the headache of trying to make unsupported or out of date equipment work in a production environment.<&#47;p></p>
<p>If you&#39;re having trouble making the right decision, then call a technology consultant. A few hundred dollars spent in researching a customized solution can mean massive savings later on down the road.<&#47;p></p>
