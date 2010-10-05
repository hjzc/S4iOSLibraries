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
 * Name:		S4AbstractAppDelegate.h
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "S4NetworkAccess.h"
#import "S4CrashManager.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================

// These are S4-defined values that should be used with the keys below to enable or
// disable the associated functionality at app launch or resume time.  For example, use:
//
// [launchOptionsMutableCopy setObject: kS4EnableOptionValue forKey: kS4EnableCoreLocationMgr];
//
// to enable the S4CoreLocationManager at launch or resume time
#define kS4EnableOptionValue							[NSNumber numberWithBool: YES]
#define kS4DisableOptionValue							[NSNumber numberWithBool: NO]


// ================================== Typedefs =========================================



// =================================== Globals =========================================

// These are S4 internal keys that should be added to the launchOptions dictionary
//  passed to application:didFinishLaunchingWithOptions: delegate method
S4_EXTERN_CONSTANT_NSSTR				kS4EnableCoreLocationMgr;
S4_EXTERN_CONSTANT_NSSTR				kS4EnableOrientationUpdates;


// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// ========================= Class S4AbstractAppDelegate ===============================

@interface S4AbstractAppDelegate : NSObject <S4CrashManagerDelegate>
{
@private
	NSUInteger					m_networkingCount;
	NSOperationQueue			*m_operationQueue;
	NSMutableDictionary			*m_launchOptionsDict;
	BOOL						m_bShowNetworkErrors;
	S4NetworkAccess				*m_networkAccess;
	S4NetworkReachability		m_currentNetworkStatus;
	BOOL						m_bConnectRequired;
	BOOL						m_bIsNetAccessNotifying;
	NSMutableArray				*m_networkObserverArray;
}

// Properties
@property (nonatomic, readonly) NSOperationQueue					*operationsQueue;
@property (nonatomic, readonly) S4NetworkReachability				currentNetworkStatus;
@property (nonatomic, readonly) BOOL								isConnectRequired;

// Class methods
+ (S4AbstractAppDelegate *)sharedAppDelegate;

// Instance methods
// UIApplicationDelegate methods
- (BOOL)application: (UIApplication *)application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions;
- (void)applicationDidBecomeActive: (UIApplication *)application;
- (void)applicationWillResignActive: (UIApplication *)application;
- (void)applicationDidEnterBackground: (UIApplication *)application;
- (void)applicationWillEnterForeground: (UIApplication *)application;
- (void)applicationWillTerminate: (UIApplication *)application;
- (void)applicationDidReceiveMemoryWarning: (UIApplication *)application;
- (void)applicationSignificantTimeChange: (UIApplication *)application;
- (void)application: (UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo;
- (void)application: (UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken: (NSData *)deviceToken;
- (void)application: (UIApplication *)application didFailToRegisterForRemoteNotificationsWithError: (NSError *)error;
- (void)application: (UIApplication *)application didReceiveLocalNotification: (UILocalNotification *)notification;
- (void)applicationProtectedDataWillBecomeUnavailable: (UIApplication *)application;
- (void)applicationProtectedDataDidBecomeAvailable: (UIApplication *)application;

// Network indicator management
- (void)didStartNetworking;
- (void)didStopNetworking;

// Network error alert management - avoid multiple alerts for single error(s)
- (void)showNetworkError: (NSError *)error;
- (void)resetNetworkErrorAlerts;


// the method wrapped by the NSInvocation method passed to
// addNetworkChangedObserver: needs to have the following format:
//
// -(xxxx)yourMethodWithStatus: (S4NetworkReachability)netStatus
//			connectionRequired; (BOOL)isRequired
//					 statusMsg: (NSString *)msg
//		 and_your_parms_follow: ...
//
- (void)addNetworkChangedObserver: (NSInvocation *)observerInvocation;
- (void)removeNetworkChangedObserver: (NSInvocation *)observerInvocation;

// subclasses should override this method to examine exceptions/signals as they occur and decide if they want to retry
// subclasses should call [super crashManager:examineException:failureSoFar:] at the END of their overriding method
- (BOOL)crashManager: (S4CrashManager *)crashManager
	examineException: (NSException *)exception
	   failuresSoFar: (int32_t)totalFailures
			 isFatal: (BOOL)bIsFatal;

// subclasses should override this method to save data and cleanup when exceptions/signals occur as the appl is about to exit
// subclasses should call [super crashManager:applFailedWithCause:] at the END of their overriding method
- (void)crashManager: (S4CrashManager *)crashManager applFailedWithCause: (ApplExitCause)cause;

@end

