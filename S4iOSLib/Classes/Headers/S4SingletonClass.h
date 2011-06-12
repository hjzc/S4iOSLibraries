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
 * Name:		S4SingletonClass.h
 * Module:		Common
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>



// =================================== Defines =========================================

/*	S4SingletonClass defines a MACRO that turns your class into an "Apple-compliant"
	singleton class.  To use, just:
 
	1. Include this header file in your .m class implementation file.

	2. In your "classname".h file, add the following lines and once again replace 
		"classname" with the name of your class:

		+ (classname *)getInstance;

		- (void)oneTimeInit;

	3. Place the SYNTHESIZE_SINGLETON_CLASS(classname) within the implementation
		section of your class replacing "classname" with the name of your class.

	4. Implement the (void)OneTimeInit method and perform your
		instance-specific initialization there (if needed).
 */

#define SYNTHESIZE_SINGLETON_CLASS(classname)						\
																	\
static classname						*g_clsInstance = nil;		\
																	\
																	\
+ (classname *)getInstance											\
{																	\
	@synchronized(self)												\
	{																\
		if (nil == g_clsInstance)									\
		{															\
			[[self alloc] init];									\
		}															\
	}																\
	return (g_clsInstance);											\
}																	\
																	\
																	\
- (id)init															\
{																	\
	if (nil == g_clsInstance)										\
	{																\
		self = [super init];										\
		if (nil != self)											\
		{															\
			[self oneTimeInit];										\
			g_clsInstance = self;									\
		}															\
	}																\
	return (g_clsInstance);											\
}																	\
																	\
																	\
- (id)copyWithZone: (NSZone *)zone									\
{																	\
	return (self);													\
}																	\
																	\
																	\
- (id)retain														\
{																	\
	return (self);													\
}																	\
																	\
																	\
- (unsigned)retainCount												\
{																	\
	return (UINT_MAX);												\
}																	\
																	\
																	\
- (oneway void)release												\
{																	\
}																	\
																	\
																	\
- (id)autorelease													\
{																	\
	return (self);													\
}																	\


// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================


