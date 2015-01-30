---
layout: post
status: publish
published: true
title: openwrt wifi radio part 3
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "[flickr-photo:id=3145072499,size=t]Finding a good, cheap sound card should
  have been as easy as ordering the one mentioned on the mighty ohm for $10, but I
  thought I'd save eight bucks and order the cheapest possible one on ebay. When it
  arrived, the right channel was totally non-functional and to say the sound quality
  was poor would be an understatement. It was impressive though, that anyone could
  manufacture and deliver to my door a brand new USB sound card even counting the
  defects for only two dollars. But that's all beside the point.\r\n\r\n"
wordpress_id: 68
date: '2009-02-04 07:44:48 -0800'
date_gmt: '2009-02-04 15:44:48 -0800'
categories:
- Uncategorized
tags:
- linux
- music
- openwrt
- mpd
comments: []
---
<p><a href="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2009&#47;02&#47;4136613234_dc76ee0d99_o.jpg"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2009&#47;02&#47;4136613234_dc76ee0d99_o-290x217.jpg" alt="OpenWRT + LCD" width="290" height="217" class="alignleft size-medium wp-image-502" &#47;><&#47;a>Finding a good, cheap sound card should have been as easy as ordering the one mentioned on the mighty ohm for $10, but I thought I'd save eight bucks and order the cheapest possible one on ebay. When it arrived, the right channel was totally non-functional and to say the sound quality was poor would be an understatement. It was impressive though, that anyone could manufacture and deliver to my door a brand new USB sound card even counting the defects for only two dollars. But that's all beside the point.<&#47;p><a id="more"></a><a id="more-68"></a></p>
<p>My second attempt was to borrow an M-Audio Podcast Factory from my boss. She had an extra one floating around and I thought it would make a great USB sound card since it had built in volume controls and RCA outputs. The sound quality overall was a big improvement over the ebay crap, but I started getting little pops during playback. I got the volume levels tuned to where I could bring that down to a minimum, but it was always noticably there. So I broke down and bought a <a href="http:&#47;&#47;www.newegg.com&#47;Product&#47;Product.aspx?Item=N82E16812186046">new one<&#47;a> for $10 on newegg.com. I got it in today and it works great!<&#47;p></p>
<p>I'm listening to some Ben Folds on this router now and the sound quality has gotten to the point where I can hear the defects in my 128kbps mp3 files, which is excellent because I've already started encoding my new music in FLAC. I also updated my display script a little. It's better, but it tends to cause the audio to skip. I'll put it here anyway for anyone who's watching my progress:<&#47;p></p>
<pre>
echo currentsong \<br />
    | nc 127.0.0.1 6600 \<br />
    | grep -e '^Artist: ' -e '^Album: ' -e '^Title: ' \<br />
    | sed 's&#47;^[A-Za-z:]*: \(.\{1,20\}\).*&#47;\1?n&#47;' > &#47;dev&#47;tts&#47;0<br />
<&#47;pre></p>
<p>This little router doesn't really have any memory to spare so if anyone comes up with some memory saving tips on this bash hack or on openwrt&#47;mpd in general, then drop me a line.<&#47;p></p>
