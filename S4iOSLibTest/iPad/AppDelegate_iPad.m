//
//  AppDelegate_iPad.m
//  S4iOSLibTest
//
//  Created by Mike Papp on 9/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPad.h"

@implementation AppDelegate_iPad


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	return ([super application: application didFinishLaunchingWithOptions: launchOptions]);
}


- (void)applicationWillResignActive: (UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	[super applicationWillResignActive: application];
}


- (void)applicationDidBecomeActive: (UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
	[super applicationDidBecomeActive: application];
}


/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application
{
	[super applicationWillTerminate: application];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [super applicationDidReceiveMemoryWarning: application];
}


- (void)dealloc
{
	[super dealloc];
}

@end
