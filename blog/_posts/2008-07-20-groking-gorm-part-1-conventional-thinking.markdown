---
title: "Grokking GORM - Part 1: Conventional thinking"
layout: post
tags:
- grails
- groovy
- java
---
For any developer that's ever touched JDBC (and it's safe to assume that's *most* Java devs, right?), [GORM](http://grails.org/gorm) is one of the many Grails features that addresses a clear and prominent pain point in the Java space.  Put simply, GORM is *humane* ORM.  It means leaving the low-level database-related plumbing to the framework and instead investing your time in the business tier.  After all, your app needs to solve a *business* problem, right?  And it's a pretty safe bet that your business analysts didn't spend time listing out any requirements about managing DB connections, result sets, sessions, or DAO code.  Nope.  They're focused on a much higher level, and we should be too.

If you're fortunate enough to be developing a greenfield application, you can just follow the Grails conventions and come close to forgetting that there's a database under the covers at all.  GORM dynamically equips you with all the persistence methods you need to manage your domain, and yet you still have the ability to drop down to that lower level should the need arise.  

NFJS is in RTP this weekend, and in ["Advanced Domain Models in Grails"](http://www.nofluffjuststuff.com/speaker_topic_view.jsp?topicId=609 "Advanced Domain Models in Grails: Enterprise Integration Made Easy"), I'll be looking first at the functionality that GORM provides out-of-the-box and then exploring how you can mold GORM to take advantage of its benefits in a variety of environments.  We'll start by looking at a sample app that colors within the lines of the Grails conventions, and you can download and try out that app [now](http://jasonrudolph.com/downloads/presentations/Advanced_Domain_Models_in_Grails-Example_Code.zip).  (Be sure to have a look at the included README files for all the details.)  

Inside the app you'll find working examples of various relationship types (including many-to-many, which people occasionally struggle with at first), constraints, and the always-cool dynamic finders.  Check out the test cases in `test/integration`. Among other things, the test cases illustrate exactly how the entities relate to one another.  (Want  to know which side of a many-to-many relationship can perform a cascading `save` operation?  Check out the tests.)  To run the tests, just execute `grails test-app` from the command line.  

Of course, there's just no substitute for hands-on experimentation. To interact with the domain models yourself, simply navigate into the project directory and run `grails console` to get an interactive shell where you can
experiment with the domain objects first-hand. Or better yet, write additional tests of your own!  If you get adventurous (and I hope you do), try out some of the [many other possibilities available in GORM](http://grails.org/Dynamic+Methods+Reference#DynamicMethodsReference-DomainClasses "Grails - Dynamic Methods Reference").

Be sure to watch for Part 2, where we begin our venture into the land of non-conformity. Stay tuned.
