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
 * Name:		S4ScreenUtils.h
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "S4DelgateArray.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================

typedef enum
{
	kHighestResolution		= 0,
	kMediumResolution		= 2,
	kLowestResolution		= 4
}	ScreenResolution;


// =================================== Globals =========================================



// ============================= Forward Declarations ==================================

@class S4ScreenUtils;


// ================================== Protocols ========================================
// ============================== S4VideoOut Delegate ==================================

@protocol S4VideoOutDelegate <NSObject>

@required
- (void)screensConnected: (NSArray *)screens toWindow: (UIWindow *)window;
- (void)screensDisconnected: (NSArray *)screens fromWindow: (UIWindow *)window;

@optional
- (void)updateDisplayLink: (CADisplayLink *)displayLink forWindow: (UIWindow *)window;

@end


// ============================= Class S4ScreenUtils ===================================

@interface S4ScreenUtils : NSObject
{

}

+ (UIImage *)glCaptureScreenForHeight: (NSInteger)scrnHeight forWidth: (NSInteger)scrnWidth inCameraRoll: (BOOL)bAddToPhotos;

+ (UIImage *)glCaptureView: (UIView *)view;

+ (UIImage *)uikitScreenshotToCameraRoll: (BOOL)bAddToPhotos;

@end
