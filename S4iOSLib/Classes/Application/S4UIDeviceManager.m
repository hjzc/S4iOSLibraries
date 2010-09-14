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
 * Name:		S4UIDeviceManager.m
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4UIDeviceManager.h"
#import "S4SingletonClass.h"
#import "S4CommonDefines.h"
#import "UIDevice-Hardware.h"


// ================================== Defines ==========================================

// ALL S4 LIBS SHOULD DEFINE THIS:
#define LIB_DOMAIN_NAME_STR								@"S4UIDeviceManager"


// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================= Begin Class S4UIDeviceManager () ==========================

@interface S4UIDeviceManager ()

@property (nonatomic, readwrite) UIDeviceOrientation				orientation;

@end



// =================== Begin Class S4UIDeviceManager (PrivateImpl) =====================

@interface S4UIDeviceManager (PrivateImpl)

- (void)oneTimeInit;
- (void)orientationChanged: (NSNotification *)notification;

@end



@implementation S4UIDeviceManager (PrivateImpl)

//============================================================================
//	S4UIDeviceManager (PrivateImpl) :: oneTimeInit
//============================================================================
- (void)oneTimeInit
{
		m_delegateArray = [[S4DelgateArray alloc] initWithCapacity: (NSUInteger)2];
		m_bOrientationNotificationsOn = NO;
		self.orientation = [UIDevice currentDevice].orientation;
}


//============================================================================
//	S4UIDeviceManager (PrivateImpl) :: orientationChanged:
//============================================================================
- (void)orientationChanged: (NSNotification *)notification
{
	NSArray								*argArray;

	// before calling delegate, set the orientation property/instance var
	self.orientation = [UIDevice currentDevice].orientation;

	// Send the update to our delegate on the main thread
	argArray = [NSArray arrayWithObjects: self, nil];
	[m_delegateArray performDelegateSelectorOnMainThread: @selector(orientationChangedOnUIDeviceManager:)
												withArguments: argArray];
}

@end



// ====================== Begin Class S4UIDeviceManager ======================

@implementation S4UIDeviceManager


//============================================================================
//	S4UIDeviceManager synthesize properties
//============================================================================
@synthesize orientation = m_deviceOrientation;


///////////////////////////////////// START SINGLETON METHODS /////////////////////////////////////


SYNTHESIZE_SINGLETON_CLASS(S4UIDeviceManager)


//////////////////////////////////////// INSTANCE METHODS /////////////////////////////////////////


//============================================================================
//	S4UIDeviceManager :: curentDeviceIsiPad
//============================================================================
- (BOOL)curentDeviceIsiPad
{
	if ([[UIDevice currentDevice] respondsToSelector: @selector(userInterfaceIdiom)] &&
		[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		return (YES);
	}
	return (NO);
}


//============================================================================
//	S4UIDeviceManager :: startOrientationUpdates
//============================================================================
- (void)startOrientationUpdates
{
	if (NO == m_bOrientationNotificationsOn)
	{
		m_bOrientationNotificationsOn = YES;
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(orientationChanged:)
													 name: UIDeviceOrientationDidChangeNotification
												   object: nil];
	}
}


//============================================================================
//	S4UIDeviceManager :: stopOrientationUpdates
//============================================================================
- (void)stopOrientationUpdates
{
	if (YES == m_bOrientationNotificationsOn)
	{
		[[NSNotificationCenter defaultCenter] removeObserver: self];
		[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
		m_bOrientationNotificationsOn = NO;
	}
}


//============================================================================
//	S4UIDeviceManager :: isLandscape
//============================================================================
- (BOOL)isLandscape
{
	return (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation));
}


//============================================================================
//	S4UIDeviceManager :: isPortrait
//============================================================================
- (BOOL)isPortrait
{
	return (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation));
}


//============================================================================
//	S4UIDeviceManager :: addDelegate
//============================================================================
- (BOOL)addDelegate: (id <S4UIDeviceManagerDelegate>)newDelegate
{
	return ([m_delegateArray addDelegate: newDelegate conformsToProtocol: @protocol(S4UIDeviceManagerDelegate)]);
}


//============================================================================
//	S4UIDeviceManager :: removeDelegate
//============================================================================
- (BOOL)removeDelegate: (id <S4UIDeviceManagerDelegate>)removeDelegate
{
	return ([m_delegateArray removeDelegate: removeDelegate conformsToProtocol: @protocol(S4UIDeviceManagerDelegate)]);
}


//============================================================================
//	S4UIDeviceManager :: orientationAsString
//============================================================================
- (NSString *)orientationAsString
{
	NSString			*strResult = nil;

	switch ([[UIDevice currentDevice] orientation])
	{
		case UIDeviceOrientationUnknown:
		{
			strResult = [NSString stringWithString: @"Unknown"];
			break;
		}

		case UIDeviceOrientationPortrait:
		{
			strResult = [NSString stringWithString: @"Portrait"];
			break;
		}

		case UIDeviceOrientationPortraitUpsideDown:
		{
			strResult = [NSString stringWithString: @"Portrait Upside Down"];
			break;
		}

		case UIDeviceOrientationLandscapeLeft:
		{
			strResult = [NSString stringWithString: @"Landscape Left"];
			break;
		}

		case UIDeviceOrientationLandscapeRight:
		{
			strResult = [NSString stringWithString: @"Landscape Right"];
			break;
		}

		case UIDeviceOrientationFaceUp:
		{
			strResult = [NSString stringWithString: @"Face Up"];
			break;
		}

		case UIDeviceOrientationFaceDown:
		{
			strResult = [NSString stringWithString: @"Face Down"];
			break;
		}

		default:
		{
			strResult = [NSString stringWithString: @"Unknown"];
			break;
		}
	}
	return (strResult);
}


//============================================================================
//	S4UIDeviceManager :: deviceUDID
//============================================================================
- (NSString *)deviceUDID
{
	return ([[UIDevice currentDevice] uniqueIdentifier]);
}



//============================================================================
//	S4UIDeviceManager :: platform
//============================================================================
- (NSString *)platform
{
	return ([[UIDevice currentDevice] platform]);
}


//============================================================================
//	S4UIDeviceManager :: platformAsString
//============================================================================
- (NSString *)platformAsString
{
	return ([[UIDevice currentDevice] platformString]);
}


//============================================================================
//	S4UIDeviceManager :: cpuFrequency
//============================================================================
- (NSUInteger)cpuFrequency
{
	return ([[UIDevice currentDevice] cpuFrequency]);
}


//============================================================================
//	S4UIDeviceManager :: busFrequency
//============================================================================
- (NSUInteger)busFrequency
{
	return ([[UIDevice currentDevice] busFrequency]);	
}


//============================================================================
//	S4UIDeviceManager :: totalMemory
//============================================================================
- (NSUInteger)totalMemory
{
	return ([[UIDevice currentDevice] totalMemory]);
}


//============================================================================
//	S4UIDeviceManager :: userMemory
//============================================================================
- (NSUInteger)userMemory
{
	return ([[UIDevice currentDevice] userMemory]);	
}


//============================================================================
//	S4UIDeviceManager :: totalDiskSpace
//============================================================================
- (NSNumber *)totalDiskSpace
{
	return ([[UIDevice currentDevice] totalDiskSpace]);
}


//============================================================================
//	S4UIDeviceManager :: freeDiskSpace
//============================================================================
- (NSNumber *)freeDiskSpace
{
	return ([[UIDevice currentDevice] freeDiskSpace]);	
}


//============================================================================
//	S4UIDeviceManager :: macaddress
//============================================================================
- (NSString *)macaddress
{
	return ([[UIDevice currentDevice] macaddress]);	
}

@end
