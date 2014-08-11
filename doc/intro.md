
# Learning to Build Object Oriented Frameworks #

<img style="float: left;" src="img/jigsaw.png">
[Object oriented frameworks](http://en.wikipedia.org/wiki/Software_framework)
are a mainstay of modern software development. Whether you develop in Java, C#,
Objective-C, Python, Ruby or Javascript, chances are you're basing your
development on some sort of application development framework.

Yet, few of us are familiar with *building* application frameworks to fulfill
business needs in our organizations. This series of posts illustrates object
oriented framework development around a simple (but not trivial) application
domain.

## What's a framework anyway? ##

At is essence, a framework is a foundation for developing a particular type of
application.

A framework captures the expertise needed to solve a particular class of
problems. In doing so it provides pre-written code that you can add to in
order to build a concrete application.

This concept is beautifully illustrated by Apple's OSX documentation in
the following allegory:

<img src="https://developer.apple.com/library/mac/referencelibrary/GettingStarted/RoadMapOSX/books/IntegrateYourCodewiththeFrameworks/Art/house_framework.png" width="50%" height="50%">

Unlike an application, a framework is not directly executable. This is so
because, for its given application domain, a framework captures what doesn't
change and deliberately leaves out what *can* change. You, the application
developer leveraging the framework, must provide the bits that change for the
framework to become an executable application.

As a consequence of this, developing with framework exhibits a property dubbed
*[inversion of control](http://martinfowler.com/bliki/InversionOfControl.html)*
where it is the framework that calls your code, not the other way around.

## What a framework is *not* ##

As follows from the above, a framework is *not* a library. When you use a
library your code decides when and how to call it. In a framework setup, the
framework is in control; you supply it with your code for it to execute at a
time of its choosing.

As it's often the case in software development, the term *framework* is
somewhat overloaded and is used at times with too narrow a scope. Among web
developers, in particular, "framework" has become synonymous with "web
application development framework" or "model-view-controller framework".
While these development tools are indeed frameworks, the notion of 
framework as the foundation for a class of applications is much more general.


## Too abstract! Show me an example ##

Sure.


