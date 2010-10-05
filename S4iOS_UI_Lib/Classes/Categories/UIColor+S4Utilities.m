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
 *			Michael Papp
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		UIColor+S4Utilities.m
 * Module:		Categories
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "UIColor+S4Utilities.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================== Begin Class UIColor (PrivateImpl) ========================

@interface UIColor (PrivateImpl)

- (void)placeHolder;

@end



@implementation UIColor (PrivateImpl)

//============================================================================
//	UIColor (PrivateImpl) :: placeHolder
//============================================================================
- (void)placeHolder
{
}

@end




// ========================== Begin Class UIColor (S4Utilities) =========================

@implementation UIColor (S4Utilities)

//============================================================================
//	UIColor (S4Utilities) :: createRGBValue;
//		Helper function
//============================================================================
+ (CGColorRef)createRGBValue: (CGFloat)red green: (CGFloat)green blue: (CGFloat)blue alpha: (CGFloat)alpha
{
	CGColorSpaceRef			colorSpaceRef;
	CGFloat					components[4] = {red, green, blue, alpha};
	CGColorRef				colorRefResult;
	
	colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	colorRefResult = CGColorCreate(colorSpaceRef, components);
	CGColorSpaceRelease(colorSpaceRef);
	return (colorRefResult);
}


//============================================================================
//	UIColor (S4Utilities) :: colorFromRGBIntegers;
//		Create a new UIColor from standard RGB values (0 to 255)
//============================================================================
+ (UIColor *)colorFromRGBIntegers: (CGFloat)red green: (CGFloat)green blue: (CGFloat)blue alpha: (CGFloat)alpha
{
	CGFloat					redFloat, greenFloat, blueFloat, alphaFloat;
	CGColorRef				colorRef;
	
	redFloat	= red/255;
	greenFloat	= green/255;
	blueFloat	= blue/255;
	alphaFloat	= alpha/1.0;
	
	colorRef = [UIColor createRGBValue: redFloat green: greenFloat blue: blueFloat alpha: alphaFloat];
	return ([UIColor colorWithCGColor: colorRef]);
}

@end
