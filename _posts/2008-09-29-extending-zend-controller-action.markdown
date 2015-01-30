---
layout: post
status: publish
published: true
title: extending Zend_Controller_Action
author:
  display_name: stevecrozz
  login: stevecrozz
  email: stevecrozz@gmail.com
  url: http://lithostech.com
author_login: stevecrozz
author_email: stevecrozz@gmail.com
author_url: http://lithostech.com
excerpt: "Once you understand all the basic concepts of writing programs, the practice
  of software development can sometimes devolve into a simple exercise in pattern
  recognition. If you catch yourself writing the same code more than once or twice,
  you're probably doing something wrong. Here's an example that will apply particularly
  to those of us who use the Zend Framework. \r\n\r\n"
wordpress_id: 54
date: '2008-09-29 01:14:22 -0700'
date_gmt: '2008-09-29 09:14:22 -0700'
categories:
- Uncategorized
tags:
- programming
- php
- zend framework
comments:
- id: 17
  author: ''
  author_email: ''
  author_url: ''
  date: '2008-12-18 13:38:07 -0800'
  date_gmt: ''
  content: "This is good for a simple set of stuff, but I'd like to point out that
    for things such as auth checking it would be a better idea to use a controller
    plugin and check the stuff in preDispatch. Generally, action helpers and&#47;or
    controller plugins are more suitable for this as well, as they are more easily
    reusable than base controllers.\r\n\r\nJust some considerations to keep in mind!
    =)"
---
<p><a href="http:&#47;&#47;www.flickr.com&#47;photos&#47;calevans&#47;1716641542"><img src="http:&#47;&#47;lithostech.com&#47;wp-content&#47;uploads&#47;2008&#47;09&#47;4136613234_dc76ee0d99_o-207x290.jpg" alt="Zend Framework" width="207" height="290" class="alignleft size-medium wp-image-533" &#47;><&#47;a>Once you understand all the basic concepts of writing programs, the practice of software development can sometimes devolve into a simple exercise in pattern recognition. If you catch yourself writing the same code more than once or twice, you're probably doing something wrong. Here's an example that will apply particularly to those of us who use the Zend Framework.<&#47;p></p>
<p>Typically, in a web application following MVC design principles, there are patterns that emerge from your actions. Patterns like access control, detecting special requests and responding appropriately, preparing pagination controls, etc. The Zend Framework and other frameworks provide abstract classes to handle the basics, but they're meant to be extended to suit your own application.<&#47;p><a id="more"></a><a id="more-54"></a></p>
<p>Make sure you have your own .&#47;library folder within your application that's on your php include path and create a directory structure for your extended action class beginning with a namespace of your choice. I'm using Crozz. Here's a skeleton that I've paced in .&#47;library&#47;Crozz&#47;Controller&#47;Action.php:<&#47;p></p>
<pre>
abstract class Crozz_Controller_Action extends Zend_Controller_Action<br />
{<br />
&#47;**<br />
* Overrides the default constructer so we can call our own domain logic<br />
*<br />
* @param Zend_Controller_Request_Abstract $request<br />
* @param Zend_Controller_Response_Abstract $response<br />
* @param array $invokeArgs<br />
*&#47;<br />
public function __construct(Zend_Controller_Request_Abstract $request, Zend_Controller_Response_Abstract $response, array $invokeArgs = array())<br />
{<br />
parent::__construct($request, $response, $invokeArgs);<br />
}<br />
}<br />
<&#47;pre></p>
<p>Now you can place domain logic in the new constructor and it will be processed for each of your application's action classes as long as they extend the new class which is Crozz_Controller_Action in my case. You can still use the same init() callback to register action specific functionality, but all the common logic should go into the new application-wide constructor above.<&#47;p></p>
<p>I'll add some useful logic now as an example:<&#47;p></p>
<pre>
$this->_flashMessenger = $this->_helper->getHelper('FlashMessenger');<br />
$this->_actionName = $this->_request->getActionName();<br />
$this->view->user = Zend_Auth::getInstance()->getIdentity();</p>
<p>&#47;**<br />
* Fire up the view<br />
*&#47;<br />
$this->initView();</p>
<p>&#47;**<br />
* Some *very* basic access control, this is pretty much all I need for this app at the moment<br />
*&#47;<br />
if (in_array($this->_actionName, array('edit', 'new', 'create', 'destroy', 'update'))) {<br />
if (!$this->view->user) {<br />
$this->_helper->redirector->setGotoSimple('unauthorized', 'error');<br />
}<br />
}</p>
<p>&#47;**<br />
* Detect javascript calls and disable the layout engine and<br />
* view renderer accordingly<br />
*&#47;<br />
if ($this->_request->isXmlHttpRequest()) {<br />
$this->_helper->layout->disableLayout();<br />
$this->_helper->viewRenderer->setNoRender();<br />
}<br />
<&#47;pre></p>
<p>This is just a start obviously, but it already starts taking a load off your actions. This should enable you to do only what is necessary in your actions and no more. In the first 3 lines, I've created three new properties that I find very useful, even more so when they're available by default. The simple access control is probably inadequate for most applications where users can have multiple roles and content ownership, but it suits me fine. The last bit is especially useful because I always turn off the view renderer and the layout engine for asynchronous requests. It should be noted that isXmlHttpRequest() works by examining a header that isn't always sent, check the <a href="http:&#47;&#47;framework.zend.com&#47;manual&#47;en&#47;">documentation<&#47;a> for more information.<&#47;p></p>
<p>Experiment on your own by adding more properties and even additional custom functions. Add a getter for a custom pagination control, define your own complex access control, add an autoloader for form classes. You can get very specific here too. Try adding an initShow() method that fires only when the action name is show and tell it to grab a Zend_Row object from the model class with the requested id and assign it to $this->row. Following this pattern, a conventional application might never need to even access the models directly, that could be handled in the abstract class.<&#47;p></p>
<p>Why follow someone else's convention when you can create your own (shameless ruby on rails stab)!<&#47;p></p>
