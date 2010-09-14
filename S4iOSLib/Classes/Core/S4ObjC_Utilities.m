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
 * Name:		S4ObjC_Utilities.m
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <CoreFoundation/CoreFoundation.h>
#import "S4ObjC_Utilities.h"
#import "S4CommonDefines.h"
#import <objc/runtime.h>
// #import </usr/include/objc/objc-class.h>


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ======================= Begin Class S4ObjC_Utilities (PrivateImpl) ==================

@interface S4ObjC_Utilities (PrivateImpl)

+ (NSError *)createErrorForDescription: (NSString *)errorStr;

@end




@implementation S4ObjC_Utilities (PrivateImpl)

//============================================================================
//	S4ObjC_Utilities (PrivateImpl) :: createErrorForDescription:
//============================================================================
+ (NSError *)createErrorForDescription: (NSString *)errorStr
{
	NSDictionary			*errDict;
	NSError					*errorResult = nil;

	if (STR_NOT_EMPTY(errorStr))
	{
		errDict = [NSDictionary dictionaryWithObject: errorStr forKey: NSLocalizedDescriptionKey];
		if (IS_NOT_NULL(errDict))
		{
			errorResult = [NSError errorWithDomain: @"NSCocoaErrorDomain" code: -1 userInfo: errDict];
		}
	}
	return (errorResult);
}

@end




// ========================= Begin Class S4ObjC_Utilities ====================

@implementation S4ObjC_Utilities

//============================================================================
//	S4ObjC_Utilities :: initInstanceForClassName:
//============================================================================
+ (id)initInstanceForClassName: (NSString *)className additionalInstanceBytes: (size_t)extraBytes
{
	Class					classRequested;
	id						idTmp;
	id						idResult = nil;

	if (STR_NOT_EMPTY(className))
	{
		classRequested = NSClassFromString(className);
		if (IS_NOT_NULL(classRequested))
		{
			idTmp = class_createInstance(classRequested, extraBytes);
			if (nil != idTmp)
			{
				idResult = [idTmp init];
			}
		}
	}
	return (idResult);
}


//============================================================================
//	S4ObjC_Utilities : instanceForClassName:
//============================================================================
+ (id)instanceForClassName: (NSString *)className additionalInstanceBytes: (size_t)extraBytes
{
	Class					classRequested;
	id						idResult = nil;
	
	if (STR_NOT_EMPTY(className))
	{
		classRequested = NSClassFromString(className);
		if (IS_NOT_NULL(classRequested))
		{
			idResult = class_createInstance(classRequested, extraBytes);
		}
	}
	return (idResult);
}


//============================================================================
//	S4ObjC_Utilities : instanceForClassName:requiresSelector:
//============================================================================
+ (id)instanceForClassName: (NSString *)className additionalInstanceBytes: (size_t)extraBytes requiresSelector: (SEL)aSelector
{
	Class					classRequested;
	id						idResult = nil;
	
	if ((STR_NOT_EMPTY(className)) && (NULL != aSelector))
	{
		classRequested = NSClassFromString(className);
		if (IS_NOT_NULL(classRequested))
		{
			if (YES == [classRequested instancesRespondToSelector: aSelector])
			{
				idResult = class_createInstance(classRequested, extraBytes);
			}
		}
	}
	return (idResult);
}


//============================================================================
//	S4ObjC_Utilities : swizzleSelector:ofClass:withSelector:
//============================================================================
+ (BOOL)swizzleSelector: (SEL)origSelector ofClass: (Class)swizzleClass withSelector: (SEL)newSelector error: (NSError **)error
{
	BOOL					bResult = NO;
#if OBJC_API_VERSION >= 2

	Method					originalMethod;
	Method					replaceMethod;

	if ((nil != origSelector) && (nil != swizzleClass) && (nil != newSelector))
	{
		originalMethod = class_getInstanceMethod(swizzleClass, origSelector);
		replaceMethod = class_getInstanceMethod(swizzleClass, newSelector);
		if ((nil != originalMethod) && (nil != replaceMethod))
		{
			if (class_addMethod(swizzleClass, origSelector, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod)))
			{
				class_replaceMethod(swizzleClass, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
				bResult = YES;
			}
			else
			{
				method_exchangeImplementations(originalMethod, replaceMethod);
				bResult = YES;
			}
		}
	}

	if (NULL != error)
	{
		if (NO == bResult)
		{
			*error = [S4ObjC_Utilities createErrorForDescription: @"S4ObjC_Utilities swizzleSelector: passed invalid arguments"];
		}
		else
		{
			*error = nil;
		}
	}
	
#else

	if (NULL != error)
	{
		*error = [S4ObjC_Utilities createErrorForDescription: @"S4ObjC_Utilities swizzleSelector: not available on Objective-C API < 2"];
	}	

#endif
	return (bResult);	
}

@end
