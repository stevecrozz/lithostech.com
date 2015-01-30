---
layout: post
status: publish
published: true
title: Get SSH Protocol Links Working in Ubuntu+Chrome+Unity
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
wordpress_id: 631
wordpress_url: http://lithostech.com/?p=631
date: '2014-04-01 23:26:07 -0700'
date_gmt: '2014-04-02 06:26:07 -0700'
categories:
- Uncategorized
tags:
- ubuntu
- ssh
- chrome
- unity
comments: []
---
This has been plaguing me for years and I finally figured it out. Thanks
to eleperte who created
[ssh-xdg-open](https://github.com/epleterte/ssh-xdg-open), I was finally
able to see what to do. Ssh-xdg-open didn't work for me, but there was
enough information available for me to figure out the missing pieces.

Forget about gconftool and you don't need ssh-xdg-open. If all you
want is working ssh://protocol links, then just use xdg-mime to set the
default application for handling ssh protocol links and create an
application handler with the same name as that application.

~~~ bash
xdg-mime default ssh.desktop x-scheme-handler/ssh
cat << EOF > ~/.local/share/applications/ssh.desktop
[Desktop Entry]
Version=1.0
Name=SSH Launcher
Exec=bash -c '(URL="%U" HOST="\${URL:6}"; ssh \$HOST); bash'
Terminal=true
Type=Application
Icon=utilities-terminal
EOF
~~~

All this does is launch bash, parse the host from the URL and executes
ssh. When ssh exits, it executes bash again so the window stays open. I
wrote it this way because you can't count on everything to work all the
time and if you don't keep the window open, the error messages will
vanish into the ether and your sanity with them.
