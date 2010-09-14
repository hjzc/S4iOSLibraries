/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the S4 iOS Libraries.
 *
 * The Initial Developer of the Original Code is
 * Michael Papp dba SeaStones Software Company.
 * All software created by the Initial Developer are Copyright (C) 2008-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Original Author:
 *			Michael Papp, San Francisco, CA, USA
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		AppDelegate_Shared.m
 * Module:		S4iPhoneTest
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "AppDelegate_Shared.h"
#import "RootViewController.h"
#import "S4FileUtilities.h"
#import "S4UserDefaultsManager.h"
#import "NSObject+S4Utilities.h"
#import "S4CommonDefines.h"
#import "S4CrashManager.h"
#import "S4CCMacProvider.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================= Begin Class AppDelegate_Shared ============================

@implementation AppDelegate_Shared

@synthesize window;
@synthesize navigationController;


//============================================================================
//	AppDelegate_Shared :: applicationDidFinishLaunching:
//============================================================================
- (BOOL)application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	NSMutableDictionary			*localLaunchOptions = nil;
	S4UserDefaultsManager		*userDfltsMgr;
	BOOL						bTest;
	BOOL						bResult;

	if (IS_NOT_NULL(launchOptions))
	{
		localLaunchOptions = [launchOptions mutableCopyWithZone: NULL];
	}
	else
	{
		localLaunchOptions = [NSMutableDictionary dictionaryWithCapacity: (NSUInteger)2];
	}

	if (IS_NOT_NULL(localLaunchOptions))
	{
		[localLaunchOptions setObject: kS4EnableOptionValue forKey: kS4EnableCoreLocationMgr];
		[localLaunchOptions setObject: kS4EnableOptionValue forKey: kS4EnableOrientationUpdates];
		bResult = [super application: application didFinishLaunchingWithOptions: localLaunchOptions];
	}
	else
	{
		bResult = [super application: application didFinishLaunchingWithOptions: launchOptions];
	}

	// first launch - copy files from bundle to documents directory
	bTest = [S4FileUtilities copyBundleFile: LOCAL_XML_FILE toDocfile: LOCAL_XML_FILE shouldOverwrite: NO];
	if (YES == bTest)
	{
		NSLog(@"S4FileUtilities:copyBundleFile Test:  passed\n");
	}
	else
	{
		NSLog(@"S4FileUtilities:copyBundleFile Test:  FAILED\n");
	}
	
	// test user defaults
	userDfltsMgr = [S4UserDefaultsManager getInstance];
	[userDfltsMgr addUserDefaultBool: YES forKey: @"booleanTest"];
	[userDfltsMgr addUserDefaultObject: @"This is a test" ofType: UDTypeString forKey: @"stringTest"];
	bTest = [userDfltsMgr registerDefaults];
	if (YES == bTest)
	{
		NSLog(@"S4UserDefaultsManager:registerDefaults Test:  passed\n");
	}
	else
	{
		NSLog(@"S4UserDefaultsManager:registerDefaults Test:  FAILED\n");
	}

	bTest = [userDfltsMgr boolForKey: @"booleanTest"];
	NSString *strTest = [userDfltsMgr stringForKey: @"stringTest"];
	if (bTest)
	{
		[userDfltsMgr setBool: NO forKey: @"booleanTest"];
		if (STR_NOT_EMPTY(strTest))
		{
			NSLog(@"UserDefaultsTest:  %@\n", strTest);
			[userDfltsMgr setString: @"This is not a test" forKey: @"stringTest"];
		}
	}
	else
	{
		[userDfltsMgr setBool: YES forKey: @"booleanTest"];
		if (STR_NOT_EMPTY(strTest))
		{
			NSLog(@"UserDefaultsTest:  %@\n", strTest);
			[userDfltsMgr setString: @"This is a test" forKey: @"stringTest"];
		}
	}

	// test Category functionality
	NSArray *testArray = [self superclasses];
	if (nil != testArray)
	{
		NSLog(@"NSObject+S4Utilities Test:  %@\n", testArray);
//		[testArray release];
	}

	// test Corelocation callbacks
	bTest = [[S4CoreLocationManager getInstance] addDelegate: self];
	if (YES == bTest)
	{
		NSLog(@"S4CoreLocationManager:addDelegate Test:  passed\n");
	}
	else
	{
		NSLog(@"S4CoreLocationManager:addDelegate Test:  FAILED\n");
	}

	// test crypto code
	S4CCMacProvider* mac = [[S4CCMacProvider alloc] initForSHA1WithKey: [@"Secret" dataUsingEncoding: NSASCIIStringEncoding]];
	[mac updateWithString: @"Hello, world!" encoding: NSASCIIStringEncoding];
	NSData* digest = [mac digest];
	NSLog(@"Testing S4CCMacProvider -> Digest = %@", digest);

	// Configure and show the window
	[window addSubview: [navigationController view]];
	[window makeKeyAndVisible];

	// install crash reporting
	bTest = [[S4CrashManager getInstance] installCrashReportingForDelegate: self shouldSaveLog: YES];
	if (YES == bTest)
	{
		NSLog(@"S4CrashManager:installCrashReportingForDelegate Test:  passed\n");
	}
	else
	{
		NSLog(@"S4CrashManager:installCrashReportingForDelegate Test:  FAILED\n");
	}
	NSLog(@"Contents of previous crashLog:\n\n%@", [[S4CrashManager getInstance] getCrashLog]);
	[[S4CrashManager getInstance] deleteCrashLog];

	return (bResult);
}


//============================================================================
//	AppDelegate_Shared :: applicationDidBecomeActive:
//============================================================================
- (void)applicationDidBecomeActive: (UIApplication *)application
{
	// start up the CoreLocation observer
	[[S4CoreLocationManager getInstance] startUpdatesWithAccuracy: kHighAccuracy];
}	


//============================================================================
//	AppDelegate_Shared :: applicationDidEnterBackground:
//============================================================================
- (void)applicationDidEnterBackground: (UIApplication *)application
{
	[[S4CoreLocationManager getInstance] stopUpdates];		// Stop updating geo-location
}


//============================================================================
//	AppDelegate_Shared :: applicationWillResignActive:
//============================================================================
- (void)applicationWillResignActive: (UIApplication *)application
{
	[[NSUserDefaults standardUserDefaults] synchronize];	// Save preferences
}


//============================================================================
//	AppDelegate_Shared :: applicationWillEnterForeground:
//============================================================================
- (void)applicationWillEnterForeground: (UIApplication *)application
{
	// start up the CoreLocation observer
	[[S4CoreLocationManager getInstance] startUpdatesWithAccuracy: kHighAccuracy];
}


//============================================================================
//	AppDelegate_Shared :: applicationWillTerminate:
//============================================================================
- (void)applicationWillTerminate: (UIApplication *)application
{
	[super applicationWillTerminate: application];
}


//============================================================================
//	AppDelegate_Shared :: dealloc
//============================================================================
- (void)dealloc
{
	[navigationController release];
	[window release];
	[super dealloc];
}


//============================================================================
//	AppDelegate_Shared :: coreLocManager:newLocationUpdate:
//============================================================================
- (void)coreLocManager: (S4CoreLocationManager *)clManager newLocationUpdate: (CLLocation *)newLocation
{
	NSLog(@"S4CorlocationManager:newLocationUpdate: %@\n\n", [newLocation description]);
}


//============================================================================
//	AppDelegate_Shared :: coreLocManager:newError:
//============================================================================
- (void)coreLocManager: (S4CoreLocationManager *)clManager newError: (NSString *)errorString
{
	NSLog(@"S4CorlocationManager:newError: %@\n\n", errorString);
}


//============================================================================
//	AppDelegate_Shared :: crashManager:examineException:failureSoFar:
//============================================================================
- (BOOL)crashManager: (S4CrashManager *)crashManager
	examineException: (NSException *)exception
	   failuresSoFar: (int32_t)totalFailures
			 isFatal: (BOOL)bIsFatal
{
	NSLog(@"AppDelegate_Shared crashManager:examineException: called with exception %@ and failures = %d", exception, totalFailures);
	if (YES == bIsFatal)
	{
		NSLog(@"It is fatal\n\n");
	}
	else
	{
		NSLog(@"It is non-fatal\n\n");
	}
	if (5 == totalFailures)
	{
		return NO;
	}
	return YES;
}


//============================================================================
//	AppDelegate_Shared :: crashManager:applFailedWithCause:
//============================================================================
- (void)crashManager: (S4CrashManager *)crashManager applFailedWithCause: (ApplExitCause)cause
{
	NSLog(@"AppDelegate_Shared crashManager:applFailedWithCause: called\n\n\n");
}

@end
