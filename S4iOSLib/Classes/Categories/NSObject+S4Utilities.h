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
 *			Erica Sadun
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		NSObject+S4Utilities.h
 * Module:		Categories
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// ========================= Class NSObject (S4Utilities) ==============================

@interface NSObject (S4Utilities)

+ (id)allocInSameZoneAsObject: (id)object;

- (NSArray *)superclasses;

- (const char *)returnTypeForSelector: (SEL)selector;

- (SEL)chooseSelector: (SEL)firstSelector, ...;

- (NSInvocation *)invocationWithSelectorAndArguments: (SEL)selector, ...;
- (BOOL)performSelector: (SEL)selector withReturnValueAndArguments: (void *)result, ...;

- (id)objectByPerformingSelectorWithArguments: (SEL)selector, ...;
- (id)objectByPerformingSelector: (SEL)selector withObject: (id)object1 withObject: (id)object2;
- (id)objectByPerformingSelector: (SEL)selector withObject: (id)object;
- (id)objectByPerformingSelector: (SEL)selector;

- (void)performSelector: (SEL)selector withCPointer: (void *)cPointer afterDelay: (NSTimeInterval)delay;
- (void)performSelector: (SEL)selector withInt: (int)intValue afterDelay: (NSTimeInterval)delay;
- (void)performSelector: (SEL)selector withFloat: (float)floatValue afterDelay: (NSTimeInterval)delay;
- (void)performSelector: (SEL)selector withBool: (BOOL)boolValue afterDelay: (NSTimeInterval)delay;
- (void)performSelector: (SEL)selector afterDelay: (NSTimeInterval)delay;
- (void)performSelector: (SEL)selector withDelayAndArguments: (NSTimeInterval)delay, ...;

- (NSValue *)valueByPerformingSelector: (SEL)selector withObject: (id)object1 withObject: (id)object2;
- (NSValue *)valueByPerformingSelector: (SEL)selector withObject: (id)object;
- (NSValue *)valueByPerformingSelector: (SEL)selector;

- (NSString *)className;

@end
