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
 * Name:		S4RegEx.m
 * Module:		Data
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4RegEx.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================

S4_INTERN_CONSTANT_NSSTR			kS4PredicateFormatStr = @"SELF MATCHES %@";
S4_INTERN_CONSTANT_NSSTR			kS4EmailRegexPattern =	@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
															@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
															@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
															@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
															@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
															@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
															@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ======================== Begin Class S4RegEx (PrivateImpl) ==========================

@interface S4RegEx (PrivateImpl)


@end


// =============================== Begin Class S4RegEx =================================

@implementation S4RegEx

//============================================================================
//	S4RegEx :: regexWithPattern:
//============================================================================
+ (id)regexWithPattern: (NSString *)patternString
{
	S4RegEx					*classInstance;

	classInstance = [[[self alloc] init] autorelease];
	if (IS_NOT_NULL(classInstance))
	{
		if (NO == [classInstance setPatternString: patternString])
		{
			[classInstance release];
			classInstance = nil;
		}
	}
	return (classInstance);
}


//============================================================================
//	S4RegEx :: isValidEmailAddress:
//============================================================================
+ (BOOL)isValidEmailAddress: (NSString *)emailAddressStr
{
	S4RegEx					*classInstance;
	BOOL					bResult = NO;

	classInstance = [S4RegEx regexWithPattern: kS4EmailRegexPattern];
	if (IS_NOT_NULL(classInstance))
	{
		bResult = [classInstance stringMatches: emailAddressStr];
		[classInstance release];
	}
	return (bResult);
}


//============================================================================
//	S4RegEx :: init
//============================================================================
- (id)init
{
	id					idResult = nil;

	self = [super init];
	if (nil != self)
	{
		m_regExPredicate = nil;

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4RegEx :: dealloc
//============================================================================
- (void)dealloc
{
	if (IS_NOT_NULL(m_regExPredicate))
	{
		[m_regExPredicate release];
		m_regExPredicate = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4RegEx :: setPatternString:
//============================================================================
- (BOOL)setPatternString: (NSString *)patternString
{
	BOOL					bResult = NO;

	if (((IS_NULL(m_regExPredicate))) && (STR_NOT_EMPTY(patternString)) && ([patternString canBeConvertedToEncoding: NSUTF8StringEncoding]))
	{
		m_regExPredicate = [[NSPredicate predicateWithFormat: kS4PredicateFormatStr, patternString] retain];
		bResult = YES;
	}
	return (bResult);
}


//============================================================================
//	S4RegEx :: stringMatches:
//============================================================================
- (BOOL)stringMatches: (NSString *)string
{
	BOOL					bResult = NO;

	if ((STR_NOT_EMPTY(string)) && (IS_NOT_NULL(m_regExPredicate)))
	{
		bResult = [m_regExPredicate evaluateWithObject: string];
	}
	return (bResult);
}

@end