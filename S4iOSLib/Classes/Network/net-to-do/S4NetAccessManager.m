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
 * Name:		S4NetAccessManager.m
 * Module:		Network
 * Library:		S4 iPhone Libraries
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

#import "S4NetAccessManager.h"
#import "S4SingletonClass.h"
#import "S4CommonDefines.h"
#import "UIDevice-Hardware.h"


// ================================== Defines ==========================================

// ALL S4 LIBS SHOULD DEFINE THIS:
#define LIB_DOMAIN_NAME_STR								@"S4NetAccessManager"


// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================

static void NetworkAccessChangedCallback(SCNetworkReachabilityRef reachabilityRef, SCNetworkReachabilityFlags flags, void *data)
{
	S4NetAccessManager					*netAccessManager;

	if ((NULL != data) && ([(NSObject *)data isKindOfClass: [S4NetAccessManager class]]))
	{
		netAccessManager = (S4NetAccessManager *)data;
		[netAccessManager accessChangedForSCRef: reachabilityRef withFlags: flags];
	}
}


// ======================== Begin Class S4NetAccessManager () ==========================

@interface S4NetAccessManager ()

@property (nonatomic, readwrite) BOOL								wifiCallbacksEnabled;
@property (nonatomic, readwrite) BOOL								inetCallbacksEnabled;

@end



// ================== Begin Class S4NetAccessManager (PrivateImpl) =====================

@interface S4NetAccessManager (PrivateImpl)

- (void)oneTimeInit;
- (void)installSystemConfigCallbacks;
- (void)removeSystemConfigCallbacks;
- (S4NetworkStatus)networkStatusForFlags: (SCNetworkReachabilityFlags)flags;
- (NSString *)flagsToString: (SCNetworkReachabilityFlags)flags;

@end



@implementation S4NetAccessManager (PrivateImpl)

//============================================================================
//	S4NetAccessManager (PrivateImpl) :: oneTimeInit
//============================================================================
- (void)oneTimeInit
{
	struct sockaddr_in					sockaddrWifi;
	struct sockaddr_in					sockaddrInet;

	m_delegateArray = [[S4DelgateArray alloc] initWithCapacity: (NSUInteger)2];

	// first create an SCNetworkReachabilityRef for the WiFi connection
	// NOTE: IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
	bzero(&sockaddrWifi, sizeof(sockaddrWifi));
	sockaddrWifi.sin_len = sizeof(sockaddrWifi);
	sockaddrWifi.sin_family = AF_INET;
	sockaddrWifi.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	m_wifiScReachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&sockaddrWifi);

	// now create an SCNetworkReachabilityRef for the Internet connection
	bzero(&sockaddrInet, sizeof(sockaddrInet));
	sockaddrInet.sin_len = sizeof(sockaddrInet);
	sockaddrInet.sin_family = AF_INET;
	m_inetScReachabilityRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&sockaddrInet);

	// set the callbacks enabled (installed) flags
	self.wifiCallbacksEnabled = NO;
	self.inetCallbacksEnabled = NO;

	// and finally install the System Configuration callbacks for our two SCNetworkReachabilityRef
	[self performSelector: @selector(installSystemConfigCallbacks) withObject: nil afterDelay: 0];
}


//============================================================================
//	S4NetAccessManager (PrivateImpl) :: installSystemConfigCallbacks
//============================================================================
- (void)installSystemConfigCallbacks
{
	SCNetworkReachabilityContext			context = {0, self, NULL, NULL, NULL};

	// install the WiFi callback
	if (NULL != m_wifiScReachabilityRef)
	{
		if (SCNetworkReachabilitySetCallback(m_wifiScReachabilityRef, NetworkAccessChangedCallback, &context))
		{
			if (SCNetworkReachabilityScheduleWithRunLoop(m_wifiScReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
			{
				self.wifiCallbacksEnabled = YES;
			}
		}
	}

	// install the Internet callback
	if (NULL != m_inetScReachabilityRef)
	{
		if (SCNetworkReachabilitySetCallback(m_inetScReachabilityRef, NetworkAccessChangedCallback, &context))
		{
			if (SCNetworkReachabilityScheduleWithRunLoop(m_inetScReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
			{
				self.inetCallbacksEnabled = YES;
			}
		}
	}
}


//============================================================================
//	S4NetAccessManager (PrivateImpl) :: removeSystemConfigCallbacks
//============================================================================
- (void)removeSystemConfigCallbacks
{
	if ((NULL != m_wifiScReachabilityRef) && (YES == self.wifiCallbacksEnabled))
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(m_wifiScReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		self.wifiCallbacksEnabled = NO;
	}
	
	if ((NULL != m_inetScReachabilityRef) && (YES == self.inetCallbacksEnabled))
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(m_inetScReachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
		self.inetCallbacksEnabled = NO;
	}	
}


//============================================================================
//	S4NetAccessManager (PrivateImpl) :: networkStatusForFlags:
//============================================================================
- (S4NetworkStatus)networkStatusForFlags: (SCNetworkReachabilityFlags)flags
{
	S4NetworkStatus						statusResult = NetworkNotReachable;

	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		statusResult = NetworkNotReachable;
	}
	else
	{
		if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
		{
			statusResult = NetworkReachableViaWiFi;
		}

// if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))

		// the connection is on-demand (or on-traffic) if the calling application
		// is using the CFSocketStream or higher APIs
		if (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) ||
			((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
		{
			if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
			{
				statusResult = NetworkReachableViaWiFi;
			}
		}

		// WWAN connections are OK if the calling application is using the CFNetwork APIs
		if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
		{
			statusResult = NetworkReachableViaWWAN;
		}
	}
	return (statusResult);
}


//============================================================================
//	S4NetAccessManager (PrivateImpl) :: flagsToString:
//============================================================================
- (NSString *)flagsToString: (SCNetworkReachabilityFlags)flags
{
	NSMutableString						*strResult;

	strResult = [NSMutableString stringWithString: @"SCNetworkReachability Flags:"];
	if (flags & kSCNetworkReachabilityFlagsIsWWAN)
	{
		[strResult appendString: @"  IsWWAN"];
	}

	if (flags & kSCNetworkReachabilityFlagsReachable)
	{
		[strResult appendString: @" :: Reachable"];
	}

	if (flags & kSCNetworkReachabilityFlagsTransientConnection)
	{
		[strResult appendString: @" :: TransientConnection"];
	}

	if (flags & kSCNetworkReachabilityFlagsConnectionRequired)
	{
		[strResult appendString: @" :: ConnectionRequired"];
	}

	if (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)
	{
		[strResult appendString: @" :: ConnectionOnTraffic"];
	}

	if (flags & kSCNetworkReachabilityFlagsInterventionRequired)
	{
		[strResult appendString: @" :: InterventionRequired"];
	}

	if (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)
	{
		[strResult appendString: @" :: ConnectionOnDemand"];
	}

	if (flags & kSCNetworkReachabilityFlagsIsLocalAddress)
	{
		[strResult appendString: @" :: IsLocalAddress"];
	}

	if (flags & kSCNetworkReachabilityFlagsIsDirect)
	{
		[strResult appendString: @" :: IsDirect"];
	}

	[strResult appendString: @"\n\n"];
	return (strResult);
}

@end



// ========================== Begin Class S4NetAccessManager ===========================

@implementation S4NetAccessManager


//============================================================================
//	S4NetAccessManager synthesize properties
//============================================================================
@synthesize wifiCallbacksEnabled = m_bWiFiCallbacksEnabled;
@synthesize inetCallbacksEnabled = m_bInetCallbacksEnabled;


///////////////////////////////////// START SINGLETON METHODS /////////////////////////////////////


SYNTHESIZE_SINGLETON_CLASS(S4NetAccessManager)


//////////////////////////////////////// INSTANCE METHODS /////////////////////////////////////////


//============================================================================
//	S4NetAccessManager :: currentWiFiStatus
//============================================================================
- (S4NetworkStatus)currentWiFiStatus
{
	SCNetworkReachabilityFlags			flags;
	S4NetworkStatus						statusResult = NetworkNotReachable;

	if (NULL != m_wifiScReachabilityRef)
	{
		if (SCNetworkReachabilityGetFlags(m_wifiScReachabilityRef, &flags))
		{
			if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
			{
				statusResult = NetworkReachableViaWiFi;	
			}
		}
	}
	return (statusResult);
}


//============================================================================
//	S4NetAccessManager :: currentInternetStatus
//============================================================================
- (S4NetworkStatus)currentInternetStatus
{
	SCNetworkReachabilityFlags			flags;
	S4NetworkStatus						statusResult = NetworkNotReachable;

	if (NULL != m_inetScReachabilityRef)
	{
		if (SCNetworkReachabilityGetFlags(m_inetScReachabilityRef, &flags))
		{
			statusResult = [self networkStatusForFlags: flags];
		}
	}
	return (statusResult);
}


//============================================================================
//	S4NetAccessManager :: networkAccessWithHostName:
//============================================================================
- (S4NetworkStatus)networkAccessWithHostName: (NSString *)hostName
{
	SCNetworkReachabilityRef				hostReachabilityRef;
	SCNetworkReachabilityFlags				flags;
	S4NetworkStatus							statusResult = NetworkNotReachable;

	if (STR_NOT_EMPTY(hostName))
	{
		hostReachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
		if (NULL != hostReachabilityRef)
		{
			if (SCNetworkReachabilityGetFlags(hostReachabilityRef, &flags))
			{
				statusResult = [self networkStatusForFlags: flags];
			}
			CFRelease(hostReachabilityRef);
		}
	}
	return (statusResult);
}


//============================================================================
//	S4NetAccessManager :: isWiFiConnectionRequired
//============================================================================
- (BOOL)isWiFiConnectionRequired
{
	SCNetworkReachabilityFlags				flags;
	BOOL									bResult = NO;

	if (NULL != m_wifiScReachabilityRef)
	{
		if (SCNetworkReachabilityGetFlags(m_wifiScReachabilityRef, &flags))
		{
			bResult = (flags & kSCNetworkReachabilityFlagsConnectionRequired);
		}
	}
	return (bResult);
}


//============================================================================
//	S4NetAccessManager :: isInternetConnectionRequired
//============================================================================
- (BOOL)isInternetConnectionRequired
{
	SCNetworkReachabilityFlags				flags;
	BOOL									bResult = NO;

	if (NULL != m_inetScReachabilityRef)
	{
		if (SCNetworkReachabilityGetFlags(m_inetScReachabilityRef, &flags))
		{
			bResult = (flags & kSCNetworkReachabilityFlagsConnectionRequired);
		}
	}
	return (bResult);
}


//============================================================================
//	S4NetAccessManager :: addDelegate
//============================================================================
- (BOOL)addDelegate: (id <S4NetAccessManagerDelegate>)newDelegate
{
	return ([m_delegateArray addDelegate: newDelegate conformsToProtocol: @protocol(S4NetAccessManagerDelegate)]);
}


//============================================================================
//	S4NetAccessManager :: removeDelegate
//============================================================================
- (BOOL)removeDelegate: (id <S4NetAccessManagerDelegate>)removeDelegate
{
	return ([m_delegateArray removeDelegate: removeDelegate conformsToProtocol: @protocol(S4NetAccessManagerDelegate)]);
}


//============================================================================
//	S4NetAccessManager :: accessChangedForSCRef:withFlags:
//============================================================================
- (void)accessChangedForSCRef: (SCNetworkReachabilityRef)reachabilityRef withFlags: (SCNetworkReachabilityFlags)flags
{
	NSArray								*argArray;

	// Inform the delegates of the network change on the main thread
	argArray = [NSArray arrayWithObjects: self, nil];
	[m_delegateArray performDelegateSelectorOnMainThread: @selector(statusChangedForNetAccessManager:)
										   withArguments: argArray];
}

@end
