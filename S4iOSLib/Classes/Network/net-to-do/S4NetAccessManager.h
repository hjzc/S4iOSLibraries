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
 * The Original Code is the S4 iPhone Libraries.
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
 * Name:		S4NetAccessManager.h
 * Module:		Network
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "S4DelgateArray.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================

/*
 * An enumeration that defines the return values of the network state of the device.
 */
typedef enum
{
	NetworkNotReachable = 0,
	NetworkReachableViaWiFi,
	NetworkReachableViaWWAN
} S4NetworkStatus;


// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================

@class S4NetAccessManager;


// ================================== Protocols ========================================
// =========================== S4NetAccessManager Delegate =============================

@protocol S4NetAccessManagerDelegate <NSObject>

@required
- (void)statusChangedForNetAccessManager: (S4NetAccessManager *)netAccessManager;

@optional

@end


// =============================== S4NetAccessManager Class ==============================

@interface S4NetAccessManager : NSObject
{
@private
	S4DelgateArray								*m_delegateArray;
	SCNetworkReachabilityRef					m_wifiScReachabilityRef;
	SCNetworkReachabilityRef					m_inetScReachabilityRef;
	BOOL										m_bWiFiCallbacksEnabled;
	BOOL										m_bInetCallbacksEnabled;
}

// Properties
@property (nonatomic, readonly) BOOL								wifiCallbacksEnabled;
@property (nonatomic, readonly) BOOL								inetCallbacksEnabled;

// Class methods
+ (S4NetAccessManager *)getInstance;

// Instance methods
- (S4NetworkStatus)currentWiFiStatus;
- (S4NetworkStatus)currentInternetStatus;
- (S4NetworkStatus)networkAccessWithHostName: (NSString *)hostName;
- (BOOL)isWiFiConnectionRequired;
- (BOOL)isInternetConnectionRequired;
- (BOOL)addDelegate: (id <S4NetAccessManagerDelegate>)newDelegate;
- (BOOL)removeDelegate: (id <S4NetAccessManagerDelegate>)removeDelegate;
- (void)accessChangedForSCRef: (SCNetworkReachabilityRef)reachabilityRef withFlags: (SCNetworkReachabilityFlags)flags;

@end
