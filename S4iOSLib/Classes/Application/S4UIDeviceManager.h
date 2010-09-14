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
 * Name:		S4UIDeviceManager.h
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "S4DelgateArray.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// ================================== Globals =========================================



// ============================= Forward Declarations =================================

@class S4UIDeviceManager;


// ================================== Protocols ========================================
// ============================ S4UIDeviceManager Delegate =============================

@protocol S4UIDeviceManagerDelegate <NSObject>

@required
- (void)orientationChangedOnUIDeviceManager: (S4UIDeviceManager *)uiDevManager;

@optional

@end


// =============================== S4UIDeviceManager Class ==============================

@interface S4UIDeviceManager : NSObject
{
@private
	S4DelgateArray								*m_delegateArray;
	BOOL										m_bOrientationNotificationsOn;
	UIDeviceOrientation							m_deviceOrientation;
}

// Properties
@property (nonatomic, readonly) UIDeviceOrientation					orientation;

// Class methods
+ (S4UIDeviceManager *)getInstance;

// Instance methods
- (BOOL)curentDeviceIsiPad;
- (void)startOrientationUpdates;
- (void)stopOrientationUpdates;
- (BOOL)isLandscape;
- (BOOL)isPortrait;
- (BOOL)addDelegate: (id <S4UIDeviceManagerDelegate>)newDelegate;
- (BOOL)removeDelegate: (id <S4UIDeviceManagerDelegate>)removeDelegate;
- (NSString *)orientationAsString;

- (NSString *)deviceUDID;
- (NSString *)platform;
- (NSString *)platformAsString;
- (NSUInteger)cpuFrequency;
- (NSUInteger)busFrequency;
- (NSUInteger)totalMemory;
- (NSUInteger)userMemory;
- (NSNumber *)totalDiskSpace;
- (NSNumber *)freeDiskSpace;
- (NSString *)macaddress;

@end
