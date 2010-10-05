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
 * All software created by the Initial Developer are Copyright (C) 2008-2010
 * the Initial Developer. All Rights Reserved.
 *
 * Original Author:
 *			Michael Papp, San Francisco, CA, USA
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		S4AbstractAppDelegate.m
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4AbstractAppDelegate.h"
#import "S4CoreLocationManager.h"
#import "S4UIDeviceManager.h"


// =================================== Defines =========================================

#define MAX_CONCURRENT_OPERATIONS						10
#define DEFAULT_OBSERVER_SZ								(NSUInteger)5

// ALL S4 LIBS SHOULD DEFINE THIS:
#define LIB_DOMAIN_NAME_STR								@"S4AbstractAppDelegate"


// ================================== Typedefs =========================================



// =================================== Globals =========================================

S4_INTERN_CONSTANT_NSSTR			kS4EnableCoreLocationMgr = @"S4ShouldLaunchCoreLocationMgr";
S4_INTERN_CONSTANT_NSSTR			kS4EnableOrientationUpdates = @"S4ShouldEnableOrientationUpdates";


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ======================= Begin Class S4AbstractAppDelegate () ========================

@interface S4AbstractAppDelegate ()

@property (nonatomic, readwrite, assign) NSOperationQueue			*operationsQueue;

@end



// ================== Begin Class S4AbstractAppDelegate (PrivateImpl) ==================

@interface S4AbstractAppDelegate (PrivateImpl)

- (void)displayNetworkActivityIndicator;
- (void)networkAccessChanged: (NSNotification *)notification;
- (void)startServices;
- (void)stopServices;

@end



@implementation S4AbstractAppDelegate (PrivateImpl)

//============================================================================
//	S4AbstractAppDelegate (PrivateImpl) :: displayNetworkActivityIndicator
//============================================================================
- (void)displayNetworkActivityIndicator
{
	if (0 < m_networkingCount)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	else
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}


//============================================================================
//	S4AbstractAppDelegate (PrivateImpl) :: networkAccessChanged:
//============================================================================
- (void)networkAccessChanged: (NSNotification *)notification
{
	S4NetworkAccess						*networkAccess;
	S4NetworkReachability				curNetworkStatus;
	NSString							*statusStr;
	BOOL								bConnectRequired;
	NSUInteger							i;
	NSInvocation						*curObserverInvoke;
	NSInvocationOperation				*invokeOperation;

	networkAccess = (S4NetworkAccess *)[notification object];
	if ((IS_NOT_NULL(networkAccess)) && ([networkAccess isKindOfClass: [S4NetworkAccess class]]))
	{
		curNetworkStatus = [networkAccess currentReachabilityStatus];
		switch (curNetworkStatus)
		{
			case NetworkNotReachable:
			{
				statusStr = @"Access Not Available";
				break;
			}
			case NetworkReachableViaWWAN:
			{
				statusStr = @"Reachable WWAN";
				break;
			}
			case NetworkReachableViaWiFi:
			{
				statusStr = @"Reachable WiFi";
				break;
			}
			default:
			{
				statusStr = @"Network Status Unknown";
				break;
			}
		}

		bConnectRequired = [networkAccess connectionRequired];
		if (YES == bConnectRequired)
		{
			statusStr = [NSString stringWithFormat: @"%@, Connection Required", statusStr];
		}

		// set the instance vars prior to calling the Observers
		m_currentNetworkStatus = curNetworkStatus;
		m_bConnectRequired = bConnectRequired;

		// call notification code
		if ((IS_NOT_NULL(m_networkObserverArray)) && (IS_NOT_NULL(self.operationsQueue)))
		{
			for (i = 0; i < [m_networkObserverArray count]; i++)
			{
				curObserverInvoke = (NSInvocation *)[m_networkObserverArray objectAtIndex: i];

				// set the arguments to the NSInvocation
				[curObserverInvoke setArgument: &curNetworkStatus atIndex: 2];
				[curObserverInvoke setArgument: &bConnectRequired atIndex: 3];
				[curObserverInvoke setArgument: &statusStr        atIndex: 4];

				invokeOperation = [[NSInvocationOperation alloc] initWithInvocation: curObserverInvoke];
				if (IS_NOT_NULL(invokeOperation))
				{
					[self.operationsQueue addOperation: invokeOperation];
					[invokeOperation release];
				}
			}
		}
//		[statusStr release];
	}
}


//============================================================================
//	S4AbstractAppDelegate (PrivateImpl) :: startServices
//============================================================================
- (void)startServices
{
	NSNumber							*boolEnableCLMgr = nil;
	NSNumber							*boolEnableUIDMgr = nil;

	if (IS_NOT_NULL(m_launchOptionsDict))
	{
		// get the value of the kS4EnableCoreLocationMgr key
		boolEnableCLMgr = (NSNumber *)[m_launchOptionsDict objectForKey: kS4EnableCoreLocationMgr];
		if (IS_NOT_NULL(boolEnableCLMgr))
		{
			if (YES == [boolEnableCLMgr boolValue])
			{
				// start up the CoreLocation observer
				[[S4CoreLocationManager getInstance] startUpdatesWithAccuracy: kLowAccuracy];
			}			
		}

		// get the value of the kS4EnableOrientationUpdates key
		boolEnableUIDMgr = (NSNumber *)[m_launchOptionsDict objectForKey: kS4EnableOrientationUpdates];
		if (IS_NOT_NULL(boolEnableUIDMgr))
		{
			if (YES == [boolEnableUIDMgr boolValue])
			{
				// start getting orientation updates
				[[S4UIDeviceManager getInstance] startOrientationUpdates];
			}
		}
	}
}


//============================================================================
//	S4AbstractAppDelegate (PrivateImpl) :: stopServices
//============================================================================
- (void)stopServices
{
	// these are safe; if services have been stopped at some point, these
	//  calls do nothing
	[[S4CoreLocationManager getInstance] stopUpdates];
	[[S4UIDeviceManager getInstance] stopOrientationUpdates];
}

@end




// ========================= Begin Class S4AbstractAppDelegate =========================

@implementation S4AbstractAppDelegate


//============================================================================
//	S4AbstractAppDelegate :: properties
//============================================================================
@synthesize operationsQueue = m_operationQueue;
@synthesize currentNetworkStatus = m_currentNetworkStatus;
@synthesize isConnectRequired = m_bConnectRequired;


//============================================================================
//	S4AbstractAppDelegate :: sharedAppDelegate
//============================================================================
+ (S4AbstractAppDelegate *)sharedAppDelegate
{
    return ((S4AbstractAppDelegate *)[UIApplication sharedApplication].delegate);
}


//============================================================================
//	S4AbstractAppDelegate :: application:didFinishLaunchingWithOptions:
//============================================================================
- (BOOL)application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	// first copy the launchOptions dictionary passed in and keep for persistence
	if (IS_NOT_NULL(launchOptions))
	{
		m_launchOptionsDict = [launchOptions mutableCopyWithZone: NULL];
		[self startServices];
	}		

	// init the network activity stack
	m_networkingCount = 0;

	// init the NSOperationQueue
	self.operationsQueue = [[NSOperationQueue alloc] init];
	[self.operationsQueue setMaxConcurrentOperationCount: MAX_CONCURRENT_OPERATIONS];

	// init the show network error flag
	m_bShowNetworkErrors = YES;

	// observe the kS4NetworkChangedNotification. When that notification is posted, the
	// method "networkAccessChanged" will be called. 
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(networkAccessChanged:)
												 name: kS4NetworkChangedNotification
											   object: nil];

	// now create an S4NetworkAccess instance to send us updates
	m_networkAccess = [S4NetworkAccess networkAccessForInternetConnection];
	if (IS_NOT_NULL(m_networkAccess))
	{
		// init the instance vars
		m_currentNetworkStatus = [m_networkAccess currentReachabilityStatus];
		m_bConnectRequired = [m_networkAccess connectionRequired];

		// and start notifications
		m_bIsNetAccessNotifying = [m_networkAccess startNotifer];
	}
	else
	{
		m_currentNetworkStatus = NetworkNotReachable;
		m_bConnectRequired = YES;
		m_bIsNetAccessNotifying = NO;		
	}

	// create an array to hold network changed observers
	m_networkObserverArray = [NSMutableArray arrayWithCapacity: DEFAULT_OBSERVER_SZ];

	return (YES);
}


//============================================================================
//	S4AbstractAppDelegate :: dealloc:
//============================================================================
- (void)dealloc
{
	if (IS_NOT_NULL(self.operationsQueue))
	{
		[self.operationsQueue release];
		self.operationsQueue = nil;
	}
	
	// NO release - it is autoreleased
	if (IS_NOT_NULL(m_networkAccess))
	{
		if (YES == m_bIsNetAccessNotifying)
		{
			[m_networkAccess stopNotifer];
			m_bIsNetAccessNotifying = NO;
		}
		m_networkAccess = nil;
	}
	
	// NO release - it is autoreleased
	if (IS_NOT_NULL(m_networkObserverArray))
	{
		m_networkObserverArray = nil;
	}
	
	[super dealloc];
}


//============================================================================
//	S4AbstractAppDelegate :: applicationDidBecomeActive:
//============================================================================
- (void)applicationDidBecomeActive: (UIApplication *)application
{
	[self startServices];
}


//============================================================================
//	S4AbstractAppDelegate :: applicationWillResignActive:
//============================================================================
- (void)applicationWillResignActive: (UIApplication *)application
{
	// going into background, stop services
	[self stopServices];
}


//============================================================================
//	S4AbstractAppDelegate :: applicationDidEnterBackground:
//============================================================================
- (void)applicationDidEnterBackground: (UIApplication *)application
{
}


//============================================================================
//	S4AbstractAppDelegate :: applicationWillEnterForeground:
//============================================================================
- (void)applicationWillEnterForeground: (UIApplication *)application
{
}


//============================================================================
//	S4AbstractAppDelegate :: applicationWillTerminate:
//============================================================================
- (void)applicationWillTerminate: (UIApplication *)application
{
	// application terminating, stop services
	[self stopServices];

	// stop the notifications from our S4NetworkAccess instance
	if ((IS_NOT_NULL(m_networkAccess)) && (YES == m_bIsNetAccessNotifying))
	{
//		[m_networkAccess stopNotifer];
		m_bIsNetAccessNotifying = NO;
	}
}


//============================================================================
//	S4AbstractAppDelegate :: applicationDidReceiveMemoryWarning:
//============================================================================
- (void)applicationDidReceiveMemoryWarning: (UIApplication *)application
{
}


//============================================================================
//	S4AbstractAppDelegate :: applicationSignificantTimeChange:
//============================================================================
- (void)applicationSignificantTimeChange: (UIApplication *)application
{
}


//============================================================================
//	S4AbstractAppDelegate :: application:didReceiveRemoteNotification:
//============================================================================
- (void)application: (UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo
{
}


//============================================================================
//	S4AbstractAppDelegate :: application:didRegisterForRemoteNotificationsWithDeviceToken:
//============================================================================
- (void)application: (UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken: (NSData *)deviceToken
{
}


//============================================================================
//	S4AbstractAppDelegate :: application:didFailToRegisterForRemoteNotificationsWithError:
//============================================================================
- (void)application: (UIApplication *)application didFailToRegisterForRemoteNotificationsWithError: (NSError *)error
{
}


//============================================================================
//	S4AbstractAppDelegate :: application:didReceiveLocalNotification:
//============================================================================
- (void)application: (UIApplication *)application didReceiveLocalNotification: (UILocalNotification *)notification
{
}


//============================================================================
//	S4AbstractAppDelegate :: applicationProtectedDataWillBecomeUnavailable:
//============================================================================
- (void)applicationProtectedDataWillBecomeUnavailable: (UIApplication *)application
{
}


//============================================================================
//	S4AbstractAppDelegate :: applicationProtectedDataDidBecomeAvailable:
//============================================================================
- (void)applicationProtectedDataDidBecomeAvailable: (UIApplication *)application
{
}


//============================================================================
//	S4AbstractAppDelegate :: didStartNetworking
//============================================================================
- (void)didStartNetworking
{
	m_networkingCount++;
	[self displayNetworkActivityIndicator];
}


//============================================================================
//	S4AbstractAppDelegate :: didStopNetworking
//============================================================================
- (void)didStopNetworking
{
	if (m_networkingCount > 0)
	{
		m_networkingCount--;
	}
	[self displayNetworkActivityIndicator];
}


//============================================================================
//	S4AbstractAppDelegate :: showNetworkError:
//============================================================================
- (void)showNetworkError: (NSError *)error
{
	UIAlertView				*alert;

	if (YES == m_bShowNetworkErrors)
	{
		if (IS_NOT_NULL(error))
		{
			alert = [[UIAlertView alloc] initWithTitle: @"Network Error"
											   message: [error localizedDescription]
											  delegate: nil
									 cancelButtonTitle: @"Dismiss"
									 otherButtonTitles: nil];
		}
		else
		{
			alert = [[UIAlertView alloc] initWithTitle: @"Network Error" 
											   message: @"Unable to contact host server." 
											  delegate: nil
									 cancelButtonTitle: @"Dismiss" 
									 otherButtonTitles: nil];
		}
		[alert show];
		[alert release];

		// set global show more network errors alerts do not pop up
		m_bShowNetworkErrors = NO;
	}
}


//============================================================================
//	S4AbstractAppDelegate :: resetNetworkErrorAlerts
//============================================================================
- (void)resetNetworkErrorAlerts
{
	m_bShowNetworkErrors = YES;
}


//============================================================================
//	S4AbstractAppDelegate :: addNetworkChangedObserver:
//============================================================================
- (void)addNetworkChangedObserver: (NSInvocation *)observerInvocation
{
	if ((IS_NOT_NULL(observerInvocation)) && (IS_NOT_NULL(m_networkObserverArray)))
	{
		[m_networkObserverArray addObject: observerInvocation];
	}
}


//============================================================================
//	S4AbstractAppDelegate :: removeNetworkChangedObserver:
//============================================================================
- (void)removeNetworkChangedObserver: (NSInvocation *)observerInvocation
{
	if ((IS_NOT_NULL(observerInvocation)) && (IS_NOT_NULL(m_networkObserverArray)))
	{
		[m_networkObserverArray removeObject: observerInvocation];
	}	
}


//============================================================================
//	S4AbstractAppDelegate :: crashManager:examineException:failureSoFar:
//============================================================================
- (BOOL)crashManager: (S4CrashManager *)crashManager
	examineException: (NSException *)exception
	   failuresSoFar: (int32_t)totalFailures
			 isFatal: (BOOL)bIsFatal
{
	if (NO == bIsFatal)
	{
		return (YES);
	}
	return (NO);
}


//============================================================================
//	S4AbstractAppDelegate :: crashManager:applFailedWithCause:
//============================================================================
- (void)crashManager: (S4CrashManager *)crashManager applFailedWithCause: (ApplExitCause)cause
{
	// application terminating, stop services
	[self stopServices];
}

@end
