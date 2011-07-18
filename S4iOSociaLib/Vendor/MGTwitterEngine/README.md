###SPECIAL NOTE ABOUT DARRYLHTHOMAS/MGTWITTERENGINE


This fork is based on [ctshryock/MGTwitterEngine](http://github.com/ctshryock/MGTwitterEngine).  The special note from ctshryock below applies to this fork.

This fork also cherry-picks commits from other forks which may not be included in the ctshryock fork.

This fork aims to make getting started testing with MGTwitterEngine even easier by removing the need to modify the demo app's AppController.m, opting instead to use a dedicated header file for Twitter credentials: TwitterCredentials.h.

Additionally, this fork's AppController allows for the use of a hard-coded Twitter API OAuth token/secret, which can also be specified in TwitterCredentials.h.  This allows developers to begin testing with MGTwitterEngine prior to having recieved [xAuth privileges from Twitter](http://dev.twitter.com/pages/xauth).

Once a developer has registered an application with Twitter, the developer can send an email to [Twitter API support](mailto:api@twitter.com) requesting xAuth privileges.  Before granting xAuth privileges, however, Twitter will most likely request screenshots of the working application.

This presents a bit of a chicken-and-egg problem.  To help alleviate this, Twitter allows the developer to access an OAuth token/secret which can be used for testing.  Changes to the AppController in this fork allow the developer to use this token/secret in lieu of xAuth during the early stages of development.

**NOTE:** Never use your personal OAuth token for a production Twitter client.  This token is for your account only and should only be used to test prior to having xAuth privileges (or implementing [Out-Of-Band/PIN authentication](http://dev.twitter.com/pages/auth_overview#oob)).


###SPECIAL NOTE ABOUT CTSHRYOCK/MGTWITTERENGINE
                                                                                                              
This fork has splintered from the original in that I now manually including [OAuthConsumer](http://github.com/ctshryock/oauthconsumer) and [TouchJSON](http://github.com/schwa/TouchJSON).  The goal here is for new people to be able to clone the project, fill in a minimal amount of info in AppController.m, and get a running application.  [MattGemmell/MGTwitterEngine](https://github.com/mattgemmell/MGTwitterEngine) has a handful of parser options, which causes confusion because which parser to use was left to the developer.  As such, only libxml is available "out of the box", the other options require pulling in outside code.  Furthermore, the xCode project referenced these files, which didn't exist in a fresh clone.  Hence, a fresh clone wouldn't even compile.  This fork is trying to alleviate those pains   

Via the [subtree merge pattern](http://help.github.com/subtree-merge/ "Git Subtree Merge Pattern") I am including for you:
 
* My own fork of [OAuthConsumer](http://github.com/ctshryock/oauthconsumer)
* [TouchJSON](http://github.com/schwa/TouchJSON) for parsing
                                                                      
Because these are handled with the subtree pattern, new clones don't have to go find the missing files.  It should "just compile".  A new developer can input their consumer secret/key and go!




How to use MGTwitterEngine
==========================

MGTwitterEngine is an Objective-C/Cocoa class which makes it easy to add Twitter integration to your own Cocoa apps. It communicates with Twitter via the public Twitter API, which you can read about here:
http://apiwiki.twitter.com/REST+API+Documentation

Using MGTwitterEngine is easy. The basic steps are:


1. Copy all the relevant source files into your own project. You need everything that starts with "MGTwitter", and also the NSString+UUID and NSData+Base64 category files.


2. In whatever class you're going to use MGTwitterEngine from, obviously make sure you #import the MGTwitterEngine.h header file. You should also declare that your class implements the MGTwitterEngineDelegate protocol. The AppController.h header file in the demo project is an example you can use.


3. Implement the MGTwitterEngineDelegate methods, just as the AppController in the demo project does. These are the methods you'll need to implement:

- (void)requestSucceeded:(NSString *)requestIdentifier;
- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error;
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier;
- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)identifier;
- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier;


4. Go ahead and use MGTwitterEngine! Just instantiate the object and set the relevant username and password (as AppController does in the demo project), and then go ahead and call some of the Twitter API methods - you can see a full list of them in the MGTwitterEngine.h header file, which also includes a link to the Twitter API documentation online.


A note about XML parsing
========================

You may wish to use the LibXML parser rather than the NSXMLParser, since LibXML can be faster and has a smaller memory footprint.

In this case, you make need to make the following changes to your project:

1. Set USE_LIBXML to 1, near the top of the MGTwitterEngine.m file.

2. Add libxml2.dylib in Other Frameworks. You'll find the library in:

	/usr/lib/libxml2.dylib
	
3. Add "/usr/include/libxml2" as a Header Search Path in your Project Settings.



A note about using MGTwitterEngine on the iPhone
================================================

MGTwitterEngine can also be used on the iPhone (with the official iPhone SDK). Simply add it to your iPhone application project as usual.

It's recommended that you use the LibXML parser rather than the NSXMLParser on the iPhone. The native parser is faster and has a smaller memory footprint, and every little bit counts on the device. If you configure USE_LIBXML to 1 in MGTwitterEngine.m, you'll need to make a couple of additions to your project.

1. Add libxml2.dylib in Other Frameworks. You'll find the library in:

	/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS2.0.sdk/usr/lib/libxml2.dylib
	
2. Add "$SDKROOT/usr/include/libxml2" as a Header Search Path in your Project Settings.



A note about the data returned from Twitter
===========================================

Each Twitter API method returns an NSString which is a unique identifier for that connection. Those identifiers are passed to all the delegate methods, so you can keep track of what's happening.

Whenever a request is successful, you will receive a call to your implementation of requestSucceeded: so you'll know that everything went OK. For most of the API methods, you will then receive a call to the appropriate method for the type of data you requested (statusesReceived:... or directMessagesReceived:... or userInfoReceived:...). The values sent to these methods are all NSArrays containing an NSDictionary for each status or user or direct message, with sub-dictionaries if necessary (for example, the timeline methods usually return statuses, each of which has a sub-dictionary giving information about the user who posted that status).

Just try calling some of the methods and use NSLog() to see what data you get back; you should find the format very easy to integrate into your applications.

Sometimes, of course, requests will fail - that's just how life is. In the unlikely event that the initial connection for a request can't be made, you will simply get nil back instead of a connection identifier, and then receive no further calls relating to that request. If you get nil back instead of an NSString, the connection has failed entirely. That's a good time to check that the computer is connected to the internet, and so on.

It's far more common however that the connection itself will go ahead just fine, but there will be an error on Twitter's side, either due to technical difficulties, or because there was something wrong with your request (e.g. you entered the wrong username and password, or you tried to get info on a user that doesn't exist, or some such thing). The specific error conditions are mostly documented in the Twitter API documentation online.

In these cases you'll receive a call to requestFailed:withError: which will include an NSError object detailing the error. Twitter usually returns meaningful HTTP error codes (like 404 for 'user not found', etc), and in that case the -domain of the NSError will be "HTTP" and the -code will be the relevant HTTP status code. This makes it really, really easy to know what's happening with your connections.



About twitter.com cookies
=========================

Like most web sites/services, twitter.com sets cookies on your computer when you authenticate with their server. These cookies (stored in NSHTTPCookieStorage) are shared amongst all applications which use NSURLConnection (including Safari and many more).

MGTwitterEngine does not use those cookies, since it does its own direct authentication in the URLs of the requests it makes to the twitter servers. For this reason, as of version 1.0.4 (11th April 2008), it does not attempt to clear any saved cookies for twitter.com when you set a username and password for MGTwitterEngine to use. However, previous versions of MGTwitterEngine did indeed clear twitter's cookies whenever you called the -setUsername:password: method, in order to avoid an old and now fixed possibility of using the wrong credentials for the next request. There are two outcomes from this:

1. MGTwitterEngine no longer clears your twitter.com cookies, so for example you will now no longer have to re-login to Twitter in Safari after using an app which includes MGTwitterEngine. You would usually only have had to re-login with Safari once, but it was still an annoyance if you regularly used Twitter both on the web and with an MGTwitterEngine-using client. This should be fixed now.

2. In the unlikely event that you have any authentication problems when your MGTwitterEngine-using app switches from one Twitter account to another (for example, after switching accounts you still get data back from the old account, at least for the very first new request), you can easily re-enable the old cookie-clearing behaviour. Simply call the method -setClearsCookies: passing YES as the argument, and then call -setUsername:password: again, and all should be well.



About supplying a custom name and other information for your Twitter client
===========================================================================

The client name, url and version information supplied to -setClientName:version:URL:token: is used only for tracking purposes at Twitter; it is not displayed on the website. In order to have a custom name shown for your client when it sends updates to Twitter (e.g. "from MyCoolApp"), you must first contact Twitter and agree on a special identifier which you will send whenever you post an update - this is the 'token' parameter to the previously mentioned method.

You can request such a token using this form at twitter.com:

http://twitter.com/help/request_source

When you receive your token, you can then set that token value using the aforementioned method, and MGTwitterEngine will do the right thing.



That's about it. If you have trouble with the code, or want to make a feature request or report a bug (or even contribute some improvements), you can get in touch with me using the info below. I hope you enjoy using MGTwitterEngine!


Cheers,
-Matt Legend Gemmell


Web:      http://mattgemmell.com
AIM:      MadMcProgrammer
MSN:      mulderuk@hotmail.com
Twitter:  mattgemmell

P.S. If you'd like to hire me for your own Mac OS X (Cocoa) or iPhone / iPod Touch development project, take a look at my consulting site at http://instinctivecode.com :)
