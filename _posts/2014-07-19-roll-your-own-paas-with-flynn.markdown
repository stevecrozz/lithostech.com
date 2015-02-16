---
layout: post
status: publish
published: true
title: Roll Your Own PaaS With Flynn
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 644
wordpress_url: http://lithostech.com/?p=644
date: '2014-07-19 21:50:41 -0700'
date_gmt: '2014-07-20 04:50:41 -0700'
categories:
- Uncategorized
tags:
- flynn
- docker
- PaaS
- cloud
- etcd
comments:
- id: 109978
  author: Roger Telegan
  author_email: roger.telegan@sikkasoftware.com
  author_url: http://SikkaSoft.Com
  date: '2014-07-21 11:18:11 -0700'
  date_gmt: '2014-07-21 18:18:11 -0700'
  content: Excellent write up, nice instructions to get me on track to exploring Flynn.
---
As a developer, I've long struggled with the problem of how to deploy
the applications I create. In an ideal world, I could spend all of my
energy doing what I do best (building applications), and none of my
energy dealing with operations concerns. That sounds like a good reason
to have an operations team. But an operations team has the same problem
because ideally, the operations team could spend all their time handling
operations concerns, and none of their time worrying about how
applications were created.

Deploying an application is largely an exercise in defining (or
discovering) the relationship between an application and its
environment. This can be a tricky and error-prone job because there is
so much variety in applications, environments and the people who create
them. If everyone involved could agree on an interface contract, we'd
all save a lot of time and energy.

This is what PaaS has tried to do. Solutions like
[EngineYard](https://www.engineyard.com/),
[Heroku](https://www.heroku.com/), [Google App
Engine](https://developers.google.com/appengine/), and
[OpenShift](https://www.openshift.com/) have sprung up to varying
degrees of success. Of these, Heroku has had the largest impact on the
way we think about software service deployment and what PaaS can do. You
can find an entire ecosystem of software packages on GitHub designed to
make your applications adhere to the tenets of [The Twelve-Factor
App](http://12factor.net/). And that's a good thing because we're
starting to see what life could be like in a world where apps fit neatly
into PaaS-shaped boxes.

<!--more-->

I was planning to write a lot about why I'm such a big fan of PaaS, and
why Flynn makes sense, but I can't do a better job than
[Jeff Lindsay already did](http://progrium.com/blog/2014/02/06/the-start-of-the-age-of-flynn/).
In case you haven't heard of it, Flynn is a collection of services that
essentially comprise a free and open-source PaaS. The project is
crowd-funded and written almost entirely in Go. After playing with Flynn
off and on for a few months, I was hooked on the idea, and I had to talk
with Jonathan Rudenberg to hear more about what his plans are for the
future of this project.

Flynn, when viewed as a whole system, is a Heroku-like PaaS that you run
and manage yourself. But it's more flexible than Heroku because it's
free and open-source. Another nice benefit is you can run services that
bind to arbitrary TCP ports like data stores or mail servers. Eventually
it will also be available as a paid service. Jonathan didn't get too
much more specific on the paid service idea, but did mention you'd be
able to bring your own hardware and let the service manage Flynn for
you.

Flynn is not a production-ready system at the moment, but that hasn't
stopped me from playing with it.
[flynn-demo](https://github.com/flynn/flynn-demo) is a project that uses
[Vagrant](http://www.vagrantup.com/) to launch a local demo of Flynn.
Following along with the Vagrantfile, I was able to create a
[RightScale ServerTemplate](http://my.rightscale.com/library/server_templates/Flynn-Node/lineage/50044)
to deploy flynn nodes. If you have a RightScale account, you can import
this ServerTemplate and try it out for yourself.

Bootstrapping a Flynn node is a pretty simple process thanks to
flynn-bootstrap which does most of the work. flynn-bootstrap uses
[Docker](https://www.docker.com/) download and run images for each
component of the system. Although you do have to provide a compatible
Docker environment and pass some configuration to end up with a working
system, and that's worth a little explanation.

If you aim to try this out right now, you'll need to install Docker
v0.10.0. Flynn requires Docker to support hairpin NAT configuration,
which is [broken](https://github.com/dotcloud/docker/pull/6810) in more
recent Docker releases. So we're stuck with Docker v0.10.0 for now.
Here's the boot script I used to install Flynn's dependencies on a plain
Ubuntu 12.04 EC2 instance and bootstrap Flynn:

~~~ bash
#!/bin/sh
apt-get install -y --force-yes apt-transport-https apparmor
sudo groupadd docker
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y lxc-docker-0.10.0
# Fix for https://github.com/flynn/flynn/issues/13
echo 3600 > /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_close_wait
docker pull flynn/host
docker pull flynn/discoverd
docker pull flynn/etcd
echo "Configuring flynn with host ip: $HOST_IP_ADDRESS"
docker run -d -v=/var/run/docker.sock:/var/run/docker.sock -p=1113:1113 flynn/host -external $HOST_IP_ADDRESS -force
docker pull flynn/postgres
docker pull flynn/controller
docker pull flynn/gitreceive
docker pull flynn/strowger
docker pull flynn/shelf
docker pull flynn/slugrunner
docker pull flynn/slugbuilder
docker run -e CONTROLLER_DOMAIN="$CONTROLLER_DOMAIN" -e=DISCOVERD=$HOST_IP_ADDRESS:1111 flynn/bootstrap
~~~

The Flynn stack is divided into two logical layers. The first layer
(layer-0 or "the grid") is designed to link a cluster of nodes to an
abstract set of containerized processes. Flynn provides its own service
discovery system called discoverd which is currently backed by etcd, and
all services managed by Flynn are registered with discoverd. Flynn-host
is the outermost grid component and acts as the glue between flynn and
all the containerized processes managed by flynn. When flynn-host
starts, it registers itself with discoverd and awaits instructions to do
things like start and stop docker containers. You just need to provide
it with an IP address that can be used to reach it and the IP addresses
of other nodes if you're building a multi-node system.

> flynn-host is the Flynn host service. An instance of it
> runs on every host in the Flynn cluster. It is responsible for running
> jobs (in Linux containers) and reporting back to schedulers and the
> leader.

Flynn's second layer (layer-1) takes care of higher level concerns. The
controller provides an API to manage Flynn itself and application
deployments, strowger handles TCP routing and gitreceive is an SSH
server that receives git pushes and funnels them through the
[buildpack](https://devcenter.heroku.com/articles/buildpacks)-based
build process and on to flynn-host for deployment.

From the outside, you can manage Flynn using the controller API. You can
do it on your own, or you can use
[flynn-cli](https://github.com/flynn/flynn-cli) which is what I'm using.
But in order to actually reach the controller, you must give the
controller a hostname. Strowger routes HTTP/HTTPS traffic by hostname so
that multiple web services can share the same TCP port and the
controller is just one of those services.

Lets see what happens when you actually run these bootstrap steps:

~~~ bash
Pulling repository flynn/host
Pulling repository flynn/discoverd
Pulling repository flynn/etcd
Configuring flynn with host ip: 10.225.143.38
26d55886b9713306c6e02baaf3e81812e38987a3940becbc395bf7251a7ba482
Pulling repository flynn/postgres
Pulling repository flynn/controller
Pulling repository flynn/gitreceive
Pulling repository flynn/strowger
Pulling repository flynn/shelf
Pulling repository flynn/slugrunner
Pulling repository flynn/slugbuilder
Unable to find image 'flynn/bootstrap' locally
Pulling repository flynn/bootstrap
01:38:04.728829 run-app postgres
01:38:06.855957 gen-random controller-key
01:38:06.859304 gen-random controller-key bb1fbd27bdc88fc897f286ed3646d522
01:38:06.859440 wait postgres-wait
01:38:22.556066 run-app controller
01:38:24.084380 wait controller-wait
01:38:25.118462 add-app controller-inception
01:38:25.197556 add-app postgres-app
01:38:25.219009 scale-app scheduler-scale
01:38:25.227535 run-app scheduler
01:38:25.834894 deploy-app shelf
01:38:26.675131 deploy-app strowger
01:38:26.720940 gen-ssh-key gitreceive-key
01:38:31.364098 deploy-app gitreceive
01:38:31.423730 gen-tls-cert controller-cert
01:38:36.533851 gen-tls-cert controller-cert pin: Hey8twCAAZtTJBc8QO7zyOhh+EOMRU6MHdAv5Sb32og=
01:38:36.534140 wait strowger-wait
01:38:36.544377 add-route gitreceive-route
01:38:36.599113 add-route controller-route
01:38:36.609110 log log-complete
01:38:36.611568 log log-complete Flynn bootstrapping complete. Install flynn-cli and paste the line below into a new terminal window:
flynn server-add -g localhost:2201 -p Hey8twCAAZtTJBc8QO7zyOhh+EOMRU6MHdAv5Sb32og= default https://flynn.lithostech.com:8081 bb1fbd27bdc88fc897f286ed3646d522
~~~

Pay close attention to the very last line because it contains all the
connection parameters needed to talk to the flynn controller on this
server. Actually not quite because there's a bug in this output. It
should actually read:

~~~ bash
flynn server-add -g flynn.lithostech.com:2222 -p Hey8twCAAZtTJBc8QO7zyOhh+EOMRU6MHdAv5Sb32og= default https://flynn.lithostech.com bb1fbd27bdc88fc897f286ed3646d522
~~~

But that's ok because as long as you stay on the rails, it all works
great from here. The full Flynn stack is running on a single server and
waiting for you to connect and deploy some apps. Here's a quick
walkthrough:

Start by adding your public SSH key so gitreceive can authenticate
you:

~~~ bash
$ flynn key-add
Key 15:2d:8e:5a:32:ba:88:74:f1:ad:9d:19:ea:10:1e:45 added
~~~

You'll need an app to deploy. Flynn has an example app you can use:

~~~ bash
$ git clone https://github.com/flynn/nodejs-flynn-example
Cloning into 'nodejs-flynn-example'...
remote: Reusing existing pack: 18, done.
remote: Total 18 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (18/18), done.
Checking connectivity... done.
~~~

From your app's git repository, run 'flynn create example' which creates
an app named 'example' on the remote flynn server automatically and adds
the remote server as a git remote named 'flynn.'

~~~ bash
$ flynn create example
Created example
~~~

Now you're ready to deploy. Just push to the remote named 'flynn' and
flynn will deploy your app.

~~~ bash
$ git push flynn master
The authenticity of host '[flynn.lithostech.com]:2222 ([54.188.176.86]:2222)' can't be established.
ECDSA key fingerprint is 9c:7a:48:42:cc:1c:d5:e7:ed:d4:47:79:b2:15:df:4d.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[flynn.lithostech.com]:2222,[54.188.176.86]:2222' (ECDSA) to the list of known hosts.
Counting objects: 18, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (17/17), done.
Writing objects: 100% (18/18), 1.84 KiB | 0 bytes/s, done.
Total 18 (delta 6), reused 0 (delta 0)
-----> Building example...
-----> Node.js app detected
-----> Requested node range: 0.10.x
-----> Resolved node version: 0.10.29
-----> Downloading and installing node
-----> Writing a custom .npmrc to circumvent npm bugs
-----> Installing dependencies
       npm WARN package.json node-example@0.0.1 No description
       npm WARN package.json node-example@0.0.1 No repository field.
       npm WARN package.json node-example@0.0.1 No README data
-----> Cleaning up node-gyp and npm artifacts
-----> Building runtime environment
-----> Discovering process types
       Procfile declares types -> web
-----> Compiled slug size is 5.2M
-----> Creating release...
=====> Application deployed
To ssh://git@flynn.lithostech.com:2222/example.git
 * [new branch]      master -> master
~~~

By default, there are no processes actually running your app, so you'll
need to add some web workers to run the web service. Just as in Heroku
and
[Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html),
you define your workers in a Procfile. The one for this example app
defines only one worker named 'web.' Scale it up to three workers using
flynn scale.

~~~ bash
$ flynn scale web=3
~~~

Now your app is running, but you still can't reach it until you tell
Flynn which hostname should be routed to your application. Add an HTTP
route for your new app and you should be able to hit it with curl.
Obviously, you'll need to make a corresponding DNS entry as well:

~~~ bash
$ flynn route-add-http example.lithostech.com
http/ae2ae90b2946e116bb8c6b4b52933e22
$ curl example.lithostech.com
Hello from Flynn on port 55008
$ curl example.lithostech.com
Hello from Flynn on port 55009
$ curl example.lithostech.com
Hello from Flynn on port 55007
~~~

You can see that Flynn has set up three web workers inside three Docker
containers and exposed them on sequential TCP ports on the host server.
Strowger routes incoming HTTP requests to the workers at random, but
having looked at the code, it looks like other routing methods could be
added without too much trouble.

Keep in mind, this is a young project with lofty goals, so there are
some rough edges. But I'm impressed with what I've seen so far. The
Flynn team, and especially Jonathan, has been more than helpful in
helping me understand this system. I can't wait to see how this shapes
up.
