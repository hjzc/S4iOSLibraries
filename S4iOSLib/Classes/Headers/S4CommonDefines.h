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
 * Name:		S4CommonDefines.h
 * Module:		Common
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>



// =================================== Defines =========================================

/*	S4DebugLog is almost a drop-in replacement for NSLog.  For example:
		S4DebugLog();
		S4DebugLog(@"here");
		S4DebugLog(@"value: %d", x);

	Unfortunately this doesn't work:		S4DebugLog(aStringVariable); 
	you have to do this instead:			S4DebugLog(@"%@", aStringVariable);

	*** TO SET THE DEBUG FLAG IN BUILDS ***
	If you are using OTHER_CFLAGS then set the value to -DDEBUG=1, if you are instead
	using GCC_PREPROCESSOR_DEFINITIONS then the value needs to be just DEBUG=1
*/
#ifdef DEBUG

#define S4DebugLog(fmt, ...)							NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#else

#define S4DebugLog(...)

#endif

// S4Log always displays output regardless of the DEBUG setting
#define S4Log(fmt, ...)									NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


// macro for performing all NULL tests on objects
#define IS_NOT_NULL(x)									((nil != x) && (![x isEqual: [NSNull null]]))

#define IS_NULL(x)										((nil == x) || ([x isEqual: [NSNull null]]))


// macro for testing NSString's for non-NULL and having content
#define STR_NOT_EMPTY(x)								((nil != x) && (![x isEqual: [NSNull null]]) && ([x length] > 0))


// macro for safely setting an instance var via retain
#define S4_SAFE_RETAIN(mValue, newValue)				\
{														\
	if (mValue != newValue)								\
	{													\
		id oldValue = mValue;							\
		if (IS_NOT_NULL(newValue))						\
		{												\
			mValue = [newValue retain];					\
		}												\
		else											\
		{												\
			mValue = nil;								\
		}												\
		if (IS_NOT_NULL(oldValue))						\
		{												\
			[oldValue release];							\
		}												\
	}													\
}


// macro for safely setting an instance var via copy
#define S4_SAFE_COPY(mValue, newValue)					\
{														\
	if (mValue != newValue)								\
	{													\
		id oldValue = mValue;							\
		if (IS_NOT_NULL(newValue))						\
		{												\
			mValue = [newValue copy];					\
		}												\
		else											\
		{												\
			mValue = nil;								\
		}												\
		if (IS_NOT_NULL(oldValue))						\
		{												\
			[oldValue release];							\
		}												\
	}													\
}


// macro for safe releases on NSObject-based classes
#define	NS_SAFE_RELEASE(object)							\
{														\
	if (IS_NOT_NULL(object))							\
	{													\
		id tmpObject = object;							\
		object = nil;									\
		[tmpObject release];							\
	}													\
}


// macro for safe releases on CoreFoundation 'objects'
#define CF_RELEASE_SAFELY(x)							\
{														\
	if (NULL != x)										\
	{													\
		CFTypeRef cf = x;								\
		x = NULL;										\
		CFRelease(cf);									\
	}													\
}


// macro for safely releasing NSTimers
#define TIMER_RELEASE_SAFELY(timer)						\
{														\
	if (IS_NOT_NULL(timer))								\
	{													\
		[timer invalidate];								\
		timer = nil;									\
	}													\
}


// macro to test if the exact set of bits in the flag are set in the value
#define IS_MASK_SET(value, flag)						(((value) & (flag)) == (flag))


// macros to handle library constants
#define S4_EXTERN_CONSTANT_NSSTR						extern NSString * const
#define S4_INTERN_CONSTANT_NSSTR						NSString * const

#define S4_EXTERN_CONSTANT(ofType)						extern ofType const
#define S4_INTERN_CONSTANT(ofType)						ofType const


// Time definitions
#define S4_MINUTE										60
#define S4_HOUR											(60 * S4_MINUTE)
#define S4_DAY											(24 * S4_HOUR)
#define S4_WEEK											(7 * S4_DAY)
#define S4_MONTH										(30.5 * S4_DAY)
#define S4_YEAR											(365 * S4_DAY)


// ================================== Typedefs =========================================

typedef enum
{
	S4ResultSuccess			= 0,
	S4ResultInvalidParams	= 1,
	S4ResultUnknownError	= 2,
	S4Result_1				= 3,
	S4Result_2				= 4,
	S4Result_3				= 5
} S4ResultCode;


// =================================== Globals =========================================



// ============================= Forward Declarations ==================================
