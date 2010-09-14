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
 * Name:		S4NetworkAccess.m
 * Module:		Network
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>
#import "S4NetworkAccess.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================

static void NetworkAccessChangedCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *data)
{
	NSAutoreleasePool				*localPool;
	S4NetworkAccess					*notificationObject;

	if ((NULL != data) && ([(NSObject *)data isKindOfClass: [S4NetworkAccess class]]))
	{
		localPool = [[NSAutoreleasePool alloc] init];
		notificationObject = (S4NetworkAccess *)data;
		[[NSNotificationCenter defaultCenter] postNotificationName: kS4NetworkChangedNotification object: notificationObject];
		[localPool release];
	}
}


// ======================= Begin Class S4NetworkAccess (PrivateImpl) ===================

@interface S4NetworkAccess (PrivateImpl)

+ (S4NetworkAccess *)networkAccessWithAddress: (const struct sockaddr_in *)hostAddress isLocal: (BOOL)bIsLocal;
- (id)initWithReachabilityRef: (SCNetworkReachabilityRef)scNetReachRef isLocalWiFi: (BOOL)bIsLocalWiFi;
- (S4NetworkReachability)localWiFiStatusForFlags: (SCNetworkReachabilityFlags)flags;
- (S4NetworkReachability)networkStatusForFlags: (SCNetworkReachabilityFlags)flags;

@end




@implementation S4NetworkAccess (PrivateImpl)

//============================================================================
//	S4NetworkAccess (PrivateImpl) :: networkAccessWithAddress:
//		Use to check the reachability of a particular IP address
//============================================================================ 
+ (S4NetworkAccess *)networkAccessWithAddress: (const struct sockaddr_in *)hostAddress isLocal: (BOOL)bIsLocal
{
	SCNetworkReachabilityRef				reachability;
	S4NetworkAccess							*netAccessResult = nil;

	if (NULL != hostAddress)
	{
		reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
		if (NULL != reachability)
		{
			netAccessResult = [[[self alloc] initWithReachabilityRef: reachability isLocalWiFi: bIsLocal] autorelease];
		}
	}
	return (netAccessResult);
}


//============================================================================
//	S4NetworkAccess :: initWithReachabilityRef:
//============================================================================
- (id)initWithReachabilityRef: (SCNetworkReachabilityRef)scNetReachRef isLocalWiFi: (BOOL)bIsLocalWiFi
{
	id					idResult = nil;
	
	self = [super init];
	if (nil != self)
	{
		m_scNetReachabilityRef = scNetReachRef;
		m_bLocalWiFiRef = bIsLocalWiFi;
		m_bNotificationsStarted = NO;

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4NetworkAccess (PrivateImpl) :: localWiFiStatusForFlags:
//============================================================================
- (S4NetworkReachability)localWiFiStatusForFlags: (SCNetworkReachabilityFlags)flags
{
	S4NetworkReachability				reachableResult;

	if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
	{
		reachableResult = NetworkReachableViaWiFi;	
	}
	else
	{
		reachableResult = NetworkNotReachable;
	}
	return (reachableResult);
}


//============================================================================
//	S4NetworkAccess (PrivateImpl) :: networkStatusForFlags:
//============================================================================
- (S4NetworkReachability)networkStatusForFlags: (SCNetworkReachabilityFlags)flags
{
	S4NetworkReachability				reachableResult = NetworkNotReachable;

	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		reachableResult = NetworkNotReachable;
	}
	else
	{
		if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
		{
			reachableResult = NetworkReachableViaWiFi;
		}

		if (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
			((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
		{
			if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
			{
				reachableResult = NetworkReachableViaWiFi;
			}
		}

		if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
		{
			reachableResult = NetworkReachableViaWWAN;
		}
	}
	return (reachableResult);
}

@end




// ========================= Begin Class S4NetworkAccess =====================

@implementation S4NetworkAccess

//============================================================================
//	S4NetworkAccess :: networkAccessWithHostName:
//============================================================================
+ (S4NetworkAccess *)networkAccessWithHostName: (NSString *)hostName
{
	SCNetworkReachabilityRef				reachability;
	S4NetworkAccess							*netAccessResult = nil;

	if (STR_NOT_EMPTY(hostName))
	{
		reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
		if (NULL != reachability)
		{
			netAccessResult= [[[self alloc] initWithReachabilityRef: reachability isLocalWiFi: NO] autorelease];
		}
	}
	return (netAccessResult);
}


//============================================================================
//	S4NetworkAccess :: networkAccessForInternetConnection
//============================================================================
+ (S4NetworkAccess *)networkAccessForInternetConnection
{
	struct sockaddr_in					hostAddress;

	bzero(&hostAddress, sizeof(hostAddress));
	hostAddress.sin_len = sizeof(hostAddress);
	hostAddress.sin_family = AF_INET;
	return ([S4NetworkAccess networkAccessWithAddress: &hostAddress isLocal: NO]);
}


//============================================================================
//	S4NetworkAccess :: networkAccessForLocalWiFi
//============================================================================
+ (S4NetworkAccess *)networkAccessForLocalWiFi
{
	struct sockaddr_in					localWifiAddress;

	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);			// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	return ([S4NetworkAccess networkAccessWithAddress: &localWifiAddress isLocal: YES]);
}


//============================================================================
//	S4NetworkAccess :: dealloc
//============================================================================
- (void)dealloc
{
	[self stopNotifer];

	if (NULL != m_scNetReachabilityRef)
	{
		CFRelease(m_scNetReachabilityRef);
		m_scNetReachabilityRef = NULL;
	}

	[super dealloc];
}


//============================================================================
//	S4NetworkAccess :: startNotifer
//============================================================================
- (BOOL)startNotifer
{
	SCNetworkReachabilityContext			context = {0, self, NULL, NULL, NULL};

	if ((NULL != m_scNetReachabilityRef) && (NO == m_bNotificationsStarted))
	{
		if (SCNetworkReachabilitySetCallback(m_scNetReachabilityRef, NetworkAccessChangedCallback, &context))
		{
			if (SCNetworkReachabilityScheduleWithRunLoop(m_scNetReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
			{
				m_bNotificationsStarted = YES;
			}
		}
	}
	return (m_bNotificationsStarted);
}


//============================================================================
//	S4NetworkAccess :: stopNotifer
//============================================================================
- (void)stopNotifer
{
	if ((NULL != m_scNetReachabilityRef) && (YES == m_bNotificationsStarted))
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(m_scNetReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		m_bNotificationsStarted = NO;
	}
}


//============================================================================
//	S4NetworkAccess :: currentReachabilityStatus
//============================================================================
- (S4NetworkReachability)currentReachabilityStatus
{
	SCNetworkReachabilityFlags			flags;
	S4NetworkReachability				reachableResult = NetworkNotReachable;

	if (NULL != m_scNetReachabilityRef)
	{
		if (SCNetworkReachabilityGetFlags(m_scNetReachabilityRef, &flags))
		{
			if (YES == m_bLocalWiFiRef)
			{
				reachableResult = [self localWiFiStatusForFlags: flags];
			}
			else
			{
				reachableResult = [self networkStatusForFlags: flags];
			}
		}
	}
	return (reachableResult);
}


//============================================================================
//	S4NetworkAccess :: currentReachabilityStatus
//============================================================================
- (BOOL)connectionRequired
{
	SCNetworkReachabilityFlags			flags;
	BOOL								bResult = NO;

	if (NULL != m_scNetReachabilityRef)
	{
		if (SCNetworkReachabilityGetFlags(m_scNetReachabilityRef, &flags))
		{
			bResult = (flags & kSCNetworkReachabilityFlagsConnectionRequired);
		}
	}
	return (bResult);
}

@end
