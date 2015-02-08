---
layout: post
status: publish
published: true
title: building a drop-down form for an html input
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: When working on a newspaper website, it's common practice to receive design
  requirements from some unknown authority. An email will just end up in your inbox
  with a note such as, "Our yahoo contract requires the word 'search' to be capitalized
  in the phrase 'Web Search powered by Yahoo! SEARCH' which must appear in the search
  bar with the name Yahoo! in bold red font. Things like this have become so common
  that my first instinct is always along the lines of "how can I get out of that",
  or "is there a loophole?".
wordpress_id: 63
date: '2008-12-13 21:22:11 -0800'
date_gmt: '2008-12-14 05:22:11 -0800'
categories:
- Uncategorized
tags:
- html
comments: []
---
<a href="http://lithostech.com/wp-content/uploads/2008/12/Screenshot-fresnobee.com-Home-Mozilla-Firefox-1.png"><img src="http://lithostech.com/wp-content/uploads/2008/12/Screenshot-fresnobee.com-Home-Mozilla-Firefox-1.png" alt="screenshot of fresnobee.com, drop down search interface" title="screenshot of fresnobee.com, drop down search interface" width="299" height="195" class="alignright size-full wp-image-213" /></a>When working on a newspaper website, it's common practice to receive design requirements from some unknown authority. An email will just end up in your inbox with a note such as, "Our yahoo contract requires the word 'search' to be capitalized in the phrase 'Web Search powered by Yahoo! SEARCH' which must appear in the search bar with the name Yahoo! in bold red font. Things like this have become so common that my first instinct is always along the lines of "how can I get out of that", or "is there a loophole?". There are so many requirements that they leave pages looking like a cluttered mess, just like every newspaper web site out there.<a id="more"></a><a id="more-63"></a>
That's when we have to get creative and try to find elements that we're actually allowed to touch, and arrange them so the pages still look as clean as possible. A perfect example is this drop-down search selection tool. We have three main types of search on fresnobee.com. I won't get into why we have to have three different search types in this post, but I will say that the reasons are not good ones.
Users on our site have to be able to select which search tool they're going to use before they hit the search button. In the past we've used a regular XHTML select element which renders into a regular drop-down select menu in the search bar. A user would click the drop down to select the search type, then enter search terms and finally click the search button (or hit the ENTER key). This is exactly what's done at one of our affiliate papers, the <a href="http://www.bellinghamherald.com/">Bellingham Herlad</a>. That approach takes up precious space in the search bar which could otherwise be left clean and blank in my opinion, or filled with more junk in someone else's opinion. Another similarly bad approach can be found at the <a href="http://www.miamiherald.com/">Miami Herald</a>. Either way it's a waste of space because a user doesn't need to select a search option if that user is not using the search function.
I found another approach which is much better at the <a href="http://www.sacbee.com/">Sacramento Bee</a>. The search options are hidden until the search input element receives focus. But when the search input is unfocused, the options don't go away. You have to click the close button that pops up to make that happen. That feels needlessly complex to me, so I wrote what I think is the cleanest possible approach using the jQuery library and some CSS magic. It was harder than I first thought because you can't just use the input element's onblur event handler because the order of event handling won't allow you to select a search option. When you focus the input element, the search options are instructed to appear, and you try to select one of the options, the input element's onblur event fires before the search option focus event has a chance to fire. The result (at least in the browsers I tried) is that the option is never selected.
<pre>
$(document).ready(function() { // Wait for the DOM to load
  // search text input receives focus
  $('#search_input').focus(function() {
    $('#search_options').show(); // display the search options
    $().bind('click', catchClicks); // register some event handlers so we can determine when to close the search options
    $().bind('keyup', catchKeyPresses);
  });
  function catchClicks(e)
  {
    // did user click somewhere outside the search bar?
    if (!$(e.target).parents('#searchBar').is('#searchBar')) {
      closeSearchOptions();
    }
  }
  function catchKeyPresses(e)
  {
    // ESC
    if (e.keyCode == 27) {
      closeSearchOptions();
    }
    // TAB
    if (e.keyCode == 9) {
      closeSearchOptions();
      $('#searchBar input[type=submit]').focus();
    }
  }
  function closeSearchOptions()
  {
    // Remove the event handlers we set when the search options opened
    $().unbind('click', catchClicks);
    $().unbind('keyup', catchKeyPresses);
    $('#search_options').hide();
  }
  // turn off autocompleting in a way that doesn't break validation
  $('#search_input').attr('autocomplete', 'off');
  // reselect the text input when search options are selected
  $('#search_options input').focus(function() {
    $('#search_input').focus();
  });
  $('#searchBar form').submit(function(){
    // catch searches and direct them to the right places
    // this part is boring, so I left it out for this post
  });
});
</pre>
The basic idea is very straightforward for the focus event, but it gets more complex for the "blur" event. Basically, the script registers very generic event handlers for any key press and any mouse click when the input is focused. If the key press is TAB or ESC, then we close the options menu. If the click is on an XHTML element that does not have an ancestor that is the search bar, then we close the options menu. When we close the options menu, we unbind the event handlers. Lastly, some browsers like to offer help to people using the search by displaying an autocomplete dropdown menu below the search input. This causes a conflict with our new search bar so we have to turn it off. In HTML 4, there was an attribute "autocomplete" that could be used to turn off this functionality, but its not valid XHTML markup, so I cheated and set it after the DOM loads.
