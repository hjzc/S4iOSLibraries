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
 * Name:		S4CircularArray.h
 * Module:		Core
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// ================================== Globals =========================================



// ============================= Forward Declarations =================================



// ================================== Protocols ========================================



// ============================= S4CircularArray Class =================================

@interface S4CircularArray : NSObject
{
@private
	NSMutableArray									*buffer;
	NSUInteger										nextIndex;
}

//	Properties
		/* None */

//	Class methods
+ (id)circularArrayWithCapacity: (NSUInteger)numItems;

//	Instance methods
- (id)initWithCapacity: (NSUInteger)numItems;

- (NSUInteger)count;

- (id)addObject: (id)obj;

- (id)objectAtIndex: (int)i;

- (void)removeObject: (id)key;

- (void)removeObjectAtIndex: (int)i;

- (id)swapObject: (id)anObject atIndex: (NSUInteger)idx;

- (id)findObject: (id)key;

- (int)findIndexOfObject: (id)key;

- (NSArray *)allObjects;

@end
