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
 * Name:		NSString+S4Utilities.m
 * Module:		Categories
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "NSString+S4Utilities.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================== Begin NSNSString (PrivateImpl) ===========================



// ======================== Begin Class NSString (S4Utilities) =========================

@implementation NSString (S4Utilities)

//============================================================================
//	NSString (S4Utilities) :: isEmpty
//		Helper function
//============================================================================
- (BOOL)isEmpty
{
	return ([self length] == 0);
}


//============================================================================
//	NSString (S4Utilities) :: stringByTrimmingWhitespace
//		Helper function
//============================================================================
- (NSString *)stringByTrimmingWhitespace
{
	return [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

@end



// ================== Begin Class NSMutableString (S4Utilities) ========================

@implementation NSMutableString (S4Utilities)

//============================================================================
//	NSDictionary (S4Utilities) :: trimCharactersInSet:
//		Helper function
//============================================================================
- (void)trimCharactersInSet: (NSCharacterSet *)characterSet
{
	NSRange					frontRange;

	// trim front
	frontRange = NSMakeRange(0, 1);
	while ([characterSet characterIsMember: [self characterAtIndex: 0]])
	{
		[self deleteCharactersInRange: frontRange];
	}
	
	// trim back
	while ([characterSet characterIsMember: [self characterAtIndex: ([self length] - 1)]])
	{
		[self deleteCharactersInRange: NSMakeRange(([self length] - 1), 1)];
	}
}


//============================================================================
//	NSDictionary (S4Utilities) :: trimWhitespace:
//		Helper function
//============================================================================
- (void)trimWhitespace
{
	[self trimCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}

@end
