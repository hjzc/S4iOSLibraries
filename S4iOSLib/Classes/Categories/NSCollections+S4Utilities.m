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
 * Name:		NSCollections+S4Utilities.m
 * Module:		Categories
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "NSCollections+S4Utilities.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================== Begin NSCollections (PrivateImpl) ========================



// ========================= Begin Class NSArray (S4Utilities) =========================

@implementation NSArray (S4Utilities)

//============================================================================
//	NSArray (S4Utilities) :: isEmpty
//		Helper function
//============================================================================
- (BOOL)isEmpty
{
	return ([self count] == 0);
}

@end



// ====================== Begin Class NSDictionary (S4Utilities) ========================

@implementation NSDictionary (S4Utilities)

//============================================================================
//	NSDictionary (S4Utilities) :: isEmpty
//		Helper function
//============================================================================
- (BOOL)isEmpty
{
	return ([self count] == 0);
}


//============================================================================
//	NSDictionary (S4Utilities) :: containsNonNullValueForKey:
//		Helper function
//============================================================================
- (BOOL)containsNonNullValueForKey: (NSString *)key
{
	BOOL				bResult = NO;

	if (STR_NOT_EMPTY(key))
	{
		bResult = (IS_NOT_NULL([self objectForKey: key]));
	}
	return (bResult);
}


//============================================================================
//	NSDictionary (S4Utilities) :: containsNonNullValueForKey:
//		Helper function
//============================================================================
- (BOOL)containsNonEmptyValueForKey: (NSString *)key
{
	id					object;
	BOOL				bResult = NO;

	if (STR_NOT_EMPTY(key))
	{
		object = [self objectForKey: key];
		if (IS_NOT_NULL(object))
		{
			if (([object respondsToSelector: @selector(count)]) && ([object count] > 0))
			{
				bResult = YES;
			}
			else if (([object respondsToSelector: @selector(length)]) && ([object length] > 0))
			{
				bResult = YES;
			}
			else
			{
				bResult = YES;
			}
		}
	}
	return (bResult);
}

@end
