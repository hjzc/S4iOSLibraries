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
 * All software created by the Initial Developer are Copyright (C) 2008-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Original Author:
 *			Michael Papp, San Francisco, CA, USA
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		S4CacheItem.m
 * Module:		Data
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4CacheItem.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================== Begin Class S4CacheItem () ===============================

@interface S4CacheItem ()

@property (nonatomic, copy, readwrite) NSString					*key;
@property (nonatomic, assign, readwrite) NSDate					*timeStamp;
@property (nonatomic, retain, readwrite) id						contents;

@end



// ============================= Begin Class S4CacheItem ===============================

@implementation S4CacheItem


//============================================================================
//	S4CacheItem :: properties
//============================================================================
// public
@synthesize key = m_keyStr;
@synthesize timeStamp = m_itemTimeStamp;
@synthesize contents = m_itemContents;

// private


//============================================================================
//	S4CacheItem :: initialize
//============================================================================
+ (void)initialize
{
//	if ((NO == g_bInitialized) && ([self class] == [S4CacheItem class]))
//	{
//		g_classOperationQueue = [[NSOperationQueue alloc] init];
//		[g_classOperationQueue setMaxConcurrentOperationCount: NSOperationQueueDefaultMaxConcurrentOperationCount];
//
//		g_bInitialized = YES;
//	}
}


//============================================================================
//	S4CacheItem :: jsonFile
//============================================================================
+ (id)cacheItemWithKey: (NSString *)key forContent: (id)object
{
	return ([[[[self class] alloc] initWithKey: key forContent: object] autorelease]);
}


//============================================================================
//	S4CacheItem :: init
//============================================================================
- (id)init
{
	// throw an exception - should not call init
	return (nil);
}


//============================================================================
//	S4CacheItem :: initWithKey:
//============================================================================
- (id)initWithKey: (NSString *)key forContent: (id)object
{
	self = [super init];
	if (nil != self)
	{
		// protected member vars
		if (STR_NOT_EMPTY(key))
		{
			m_keyStr = [key copy];

			m_itemTimeStamp = [[[NSDate alloc] init] retain];
			
			if (nil != object)
			{
				m_itemContents = [object retain];
			}
			else
			{
				m_itemContents = nil;
			}
		}
		else
		{
			// throw an exception
			self = nil;
		}

	}
	return (self);
}


//============================================================================
//	S4CacheItem :: dealloc
//============================================================================
- (void)dealloc
{
	if (IS_NOT_NULL(m_keyStr))
	{
		[m_keyStr release];
		m_keyStr = nil;
	}

	if (IS_NOT_NULL(m_itemTimeStamp))
	{
		[m_itemTimeStamp release];
		m_itemTimeStamp = nil;
	}

	if IS_NOT_NULL(m_itemContents)
	{
		[m_itemContents release];
		m_itemContents = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4CacheItem :: hash
//============================================================================
- (NSUInteger)hash
{
	return ([self.key hash]);
}


//============================================================================
//	S4CacheItem :: isEqual:
//============================================================================
- (BOOL)isEqual: (id)anObject
{
	BOOL				bResult;

    if ((nil == anObject) || (NO == [anObject isKindOfClass: [self class]]))
	{
        bResult = NO;
	}
	else
	{
		bResult = [self isEqualToS4CacheItem: anObject];
	}
	return (bResult);
}


//============================================================================
//	S4CacheItem :: isEqualToS4CacheItem:
//============================================================================
- (BOOL)isEqualToS4CacheItem: (S4CacheItem *)aCacheItem
{
	BOOL				bResult = NO;

    if (aCacheItem == self)
	{
        bResult = YES;
	}
	else if ((YES == [self.key isEqualToString: aCacheItem.key]) &&
			 (YES == [self.timeStamp isEqualToDate: aCacheItem.timeStamp]))
	{
		bResult = YES;
	}
	return (bResult);
}

@end
