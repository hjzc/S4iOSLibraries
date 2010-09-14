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
 * Name:		S4NetworkAccess.h
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>


// =================================== Defines =========================================

#define kS4NetworkChangedNotification					@"S4NetworkChangedNotification"


// ================================== Typedefs =========================================

/*
 * An enumeration that defines the return values of the network state of the device.
 */
typedef enum
{
	NetworkNotReachable = 0,
	NetworkReachableViaWiFi,
	NetworkReachableViaWWAN
} S4NetworkReachability;


// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// ============================ Class S4NetworkAccess ==================================

@interface S4NetworkAccess : NSObject
{
@private
	SCNetworkReachabilityRef		m_scNetReachabilityRef;
	BOOL							m_bLocalWiFiRef;
	BOOL							m_bNotificationsStarted;
}

// Use to check the reachability of a particular host name. 
+ (S4NetworkAccess *)networkAccessWithHostName: (NSString *)hostName;

// Use to see if the default route is available
//  Should be used by applications that do not connect to a particular host
+ (S4NetworkAccess *)networkAccessForInternetConnection;

// Use to see if a local wifi connection is available
+ (S4NetworkAccess *)networkAccessForLocalWiFi;

//Start listening for reachability notifications on the current run loop
- (BOOL)startNotifer;
- (void)stopNotifer;

- (S4NetworkReachability)currentReachabilityStatus;
- (BOOL)connectionRequired;

@end


