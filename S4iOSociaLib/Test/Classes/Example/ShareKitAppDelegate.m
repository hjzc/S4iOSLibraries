//
//  ShareKitAppDelegate.m
//  ShareKit
//
//  Created by Nathan Weiner on 6/4/10.
//  Copyright Idea Shower, LLC 2010. All rights reserved.
//

#import "ShareKitAppDelegate.h"
#import "RootViewController.h"

#import "SHK.h"
#import "SHKReadItLater.h"
#import "SHKFacebook.h"



S4_INTERN_CONSTANT_NSSTR									SHKMyAppName = @"My App Name";
S4_INTERN_CONSTANT_NSSTR									SHKMyAppURL = @"http://example.com";

// Posterous
S4_INTERN_CONSTANT_NSSTR									SHKPosterousAPIKey = @"";

// Delicious
S4_INTERN_CONSTANT_NSSTR									SHKDeliciousConsumerKey = @"";
S4_INTERN_CONSTANT_NSSTR									SHKDeliciousSecretKey = @"";

// Read It Later
S4_INTERN_CONSTANT_NSSTR									SHKReadItLaterKey = @"";

// Evernote
S4_INTERN_CONSTANT_NSSTR									SHKEvernoteUserStoreURL = @"";
S4_INTERN_CONSTANT_NSSTR									SHKEvernoteSecretKey = @"";
S4_INTERN_CONSTANT_NSSTR									SHKEvernoteConsumerKey = @"";
S4_INTERN_CONSTANT_NSSTR									SHKEvernoteNetStoreURLBase = @"";

// Bit.ly
S4_INTERN_CONSTANT_NSSTR									SHKBitLyLogin = @"";
S4_INTERN_CONSTANT_NSSTR									SHKBitLyKey = @"";

// Flickr
S4_INTERN_CONSTANT_NSSTR									SHKFlickrConsumerKey = @"";
S4_INTERN_CONSTANT_NSSTR									SHKFlickrSecretKey = @"";
S4_INTERN_CONSTANT_NSSTR									SHKFlickrCallbackUrl = @"";

// Facebook
S4_INTERN_CONSTANT_NSSTR									SHKFacebookAppId = @"";

// Twitter
S4_INTERN_CONSTANT_NSSTR									SHKTwitterConsumerKey = @"";
S4_INTERN_CONSTANT_NSSTR									SHKTwitterSecret = @"";
// You need to set this if using OAuth, see note above (xAuth users can skip it)
S4_INTERN_CONSTANT_NSSTR									SHKTwitterCallbackUrl = @"";
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
S4_INTERN_CONSTANT_NSSTR									SHKTwitterUsername = @"";



@implementation ShareKitAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
	
	navigationController.topViewController.title = SHKLocalizedString(@"Examples");
	[navigationController setToolbarHidden:NO];
	
	[self performSelector:@selector(testOffline) withObject:nil afterDelay:0.5];
	
	return YES;
}

- (void)testOffline
{	
	[SHK flushOfflineQueue];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	// Save data if appropriate
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	SHKFacebook *facebookSharer = [[[SHKFacebook alloc] init] autorelease];
	return [[facebookSharer facebook] handleOpenURL:url];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

