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
 * Name:		S4ObjC_Utilities.h
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// ================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// =========================== Class S4ObjC_Utilities ==================================

@interface S4ObjC_Utilities : NSObject
{

}

// get an instance of a class given the Class name, and then send it an 'init' message
+ (id)initInstanceForClassName: (NSString *)classNameStr additionalInstanceBytes: (size_t)extraBytes;

// get an instance of a class given the Class name
+ (id)instanceForClassName: (NSString *)className additionalInstanceBytes: (size_t)extraBytes;

// get an instance of a class given the Class name, but only if instances respond to given selector
+ (id)instanceForClassName: (NSString *)className additionalInstanceBytes: (size_t)extraBytes requiresSelector: (SEL)aSelector;

// Swaps one method's selector for another's in the given class
+ (BOOL)swizzleSelector: (SEL)origSelector ofClass: (Class)swizzleClass withSelector: (SEL)newSelector error: (NSError **)error;

@end
