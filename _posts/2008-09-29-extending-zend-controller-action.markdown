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
    plugin and check the stuff in preDispatch. Generally, action helpers and/or
    controller plugins are more suitable for this as well, as they are more easily
    reusable than base controllers.\r\n\r\nJust some considerations to keep in mind!
    =)"
---
{% picture thumbnail-left 2008/zend-framework-logo.jpg alt="Zend Framework logo" %}

Once you understand all the basic concepts of writing programs, the
practice of software development can sometimes devolve into a simple
exercise in pattern recognition. If you catch yourself writing the same
code more than once or twice, you're probably doing something wrong.
Here's an example that will apply particularly to those of us who use
the Zend Framework.

Typically, in a web application following MVC design principles, there
are patterns that emerge from your actions. Patterns like access
control, detecting special requests and responding appropriately,
preparing pagination controls, etc. The Zend Framework and other
frameworks provide abstract classes to handle the basics, but they're
meant to be extended to suit your own application.

Make sure you have your own ./library folder within your application
that's on your php include path and create a directory structure for
your extended action class beginning with a namespace of your choice.
I'm using Crozz. Here's a skeleton that I've paced in
./library/Crozz/Controller/Action.php:

<!--more-->

~~~ php
abstract class Crozz_Controller_Action extends Zend_Controller_Action
{
    /**
    * Overrides the default constructer so we can call our own domain logic
    *
    * @param Zend_Controller_Request_Abstract $request
    * @param Zend_Controller_Response_Abstract $response
    * @param array $invokeArgs
    */
    public function __construct(Zend_Controller_Request_Abstract $request, Zend_Controller_Response_Abstract $response, array $invokeArgs = array())
    {
        parent::__construct($request, $response, $invokeArgs);
    }
}
~~~

Now you can place domain logic in the new constructor and it will be
processed for each of your application's action classes as long as they
extend the new class which is Crozz_Controller_Action in my case. You
can still use the same init() callback to register action specific
functionality, but all the common logic should go into the new
application-wide constructor above.

I'll add some useful logic now as an example:

~~~ php
$this->_flashMessenger = $this->_helper->getHelper('FlashMessenger');
$this->_actionName = $this->_request->getActionName();
$this->view->user = Zend_Auth::getInstance()->getIdentity();

/**
* Fire up the view
*/
$this->initView();

/**
* Some *very* basic access control, this is pretty much all I need for this app at the moment
*/
if (in_array($this->_actionName, array('edit', 'new', 'create', 'destroy', 'update'))) {
    if (!$this->view->user) {
        $this->_helper->redirector->setGotoSimple('unauthorized', 'error');
    }
}

/**
* Detect javascript calls and disable the layout engine and
* view renderer accordingly
*/
if ($this->_request->isXmlHttpRequest()) {
    $this->_helper->layout->disableLayout();
    $this->_helper->viewRenderer->setNoRender();
}
~~~

This is just a start obviously, but it already starts taking a load off
your actions. This should enable you to do only what is necessary in
your actions and no more. In the first 3 lines, I've created three new
properties that I find very useful, even more so when they're available
by default. The simple access control is probably inadequate for most
applications where users can have multiple roles and content ownership,
but it suits me fine. The last bit is especially useful because I always
turn off the view renderer and the layout engine for asynchronous
requests. It should be noted that isXmlHttpRequest() works by examining
a header that isn't always sent, check the <a
href="http://framework.zend.com/manual/en/">documentation</a> for more
information.

Experiment on your own by adding more properties and even additional
custom functions. Add a getter for a custom pagination control, define
your own complex access control, add an autoloader for form classes. You
can get very specific here too. Try adding an initShow() method that
fires only when the action name is show and tell it to grab a Zend_Row
object from the model class with the requested id and assign it to
$this->row. Following this pattern, a conventional application might
never need to even access the models directly, that could be handled in
the abstract class.

Why follow someone else's convention when you can create your own
(shameless ruby on rails stab)!
