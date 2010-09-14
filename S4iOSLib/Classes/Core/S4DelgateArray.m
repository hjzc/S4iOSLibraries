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
 * Name:		S4DelgateArray.m
 * Module:		Core
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4DelgateArray.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================

#define MIN_INITIAL_ARRAY_CAPACITY				(NSUInteger)5


// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================== Begin Class S4DelgateArray () ============================

@interface S4DelgateArray ()

@end



// =========================== Begin Class S4DelgateArray ==============================

@implementation S4DelgateArray


//============================================================================
//	S4DelgateArray synthesize properties
//============================================================================



//============================================================================
//	S4DelgateArray :: arrayWithCapacity:
//============================================================================
+ (id)arrayWithCapacity: (NSUInteger)numItems
{
	return [[[[self class] alloc] initWithCapacity: numItems] autorelease];
}


//============================================================================
//	S4DelgateArray :: init
//============================================================================
- (id)init
{
	return ([self initWithCapacity: MIN_INITIAL_ARRAY_CAPACITY]);
}


//============================================================================
//	S4DelgateArray :: initWithCapacity:
//============================================================================
- (id)initWithCapacity: (NSUInteger)numItems
{
	id			idResult = nil;

	self = [super init];
	if (nil != self)
	{
		// private member vars
		m_privateNSMutableArray = [[NSMutableArray alloc] initWithCapacity: numItems];

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4DelgateArray :: dealloc
//============================================================================
- (void)dealloc
{
	if (IS_NOT_NULL(m_privateNSMutableArray))
	{
		[m_privateNSMutableArray release];
		m_privateNSMutableArray = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4DelgateArray :: addDelegate:conformsToProtocol
//============================================================================
- (BOOL)addDelegate: (id)newDelegate conformsToProtocol: (Protocol *)aProtocol
{
	BOOL				bResult = NO;
	
	if ((IS_NOT_NULL(newDelegate)) && (NULL != aProtocol) && ([newDelegate conformsToProtocol: aProtocol]))
	{
		@synchronized(self)
		{
			[m_privateNSMutableArray addObject: newDelegate];
		}
		bResult = YES;
	}
	return (bResult);
}


//============================================================================
//	S4DelgateArray :: removeDelegate:conformsToProtocol
//============================================================================
- (BOOL)removeDelegate: (id)removeDelegate conformsToProtocol: (Protocol *)aProtocol
{
	NSUInteger				idxToBeRemoved;
	BOOL					bResult = NO;
	
	if ((IS_NOT_NULL(removeDelegate)) && (NULL != aProtocol) && ([removeDelegate conformsToProtocol: aProtocol]))
	{
		@synchronized(self)
		{
			// try to find the object in question either via object address (IndenticalTo) or hash value (isEqual)
			idxToBeRemoved = [m_privateNSMutableArray indexOfObjectIdenticalTo: removeDelegate];
			if (NSNotFound == idxToBeRemoved)
			{
				idxToBeRemoved = [m_privateNSMutableArray indexOfObject: removeDelegate];
			}
			
			// if we found one, remove it
			if (NSNotFound != idxToBeRemoved)
			{
				[m_privateNSMutableArray removeObjectAtIndex: idxToBeRemoved];
				bResult = YES;
			}
		}
	}
	return (bResult);
}


//============================================================================
//	S4DelgateArray :: addSelectorToQueue:
//============================================================================
- (BOOL)performDelegateSelectorOnMainThread: (SEL)selector withArguments: (NSArray *)argArray
{
	NSInvocation						*invocation;
	NSUInteger							numArgs;
	NSUInteger							i;
	NSUInteger							argIndex;
	id									localObject;
	BOOL								bResult = NO;

	if (NULL != selector)
	{
		for (id target in m_privateNSMutableArray)
		{
			if ((IS_NOT_NULL(target)) && ([target respondsToSelector: selector]))
			{
				// create an NSInvocation for the target/selector tuple
				invocation = [NSInvocation invocationWithMethodSignature: [target methodSignatureForSelector: selector]];
				if (IS_NOT_NULL(invocation))
				{
					// make sure everything is retained by the Invocation object
					[invocation retainArguments];

					// the target and selector MUST be set
					[invocation setSelector: selector];
					[invocation setTarget: target];

					// now add the arguments from the NSArray, if any
					if (IS_NOT_NULL(argArray))
					{
						numArgs = [argArray count];
						if (numArgs > 0)
						{
							// Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively;
							//  you should set these values directly with the setTarget: and setSelector: methods.
							//  Use indices 2 and greater for the arguments normally passed in a message.			
							argIndex = 2;

							for (i = 0; i < numArgs; i++)
							{
								// When the argument value is an object, pass a pointer to the variable
								//  (or memory) from which the object should be copied:
								localObject = [argArray objectAtIndex: i];
								[invocation setArgument: &localObject atIndex: argIndex];
								argIndex++;
							}
						}
					}

					// now wrap the NSInvocation in an NSOperation subclass
					[invocation performSelectorOnMainThread: @selector(invokeWithTarget:) withObject: target waitUntilDone: [NSThread isMainThread]];
					bResult = YES;
				}
			}
		}
	}
	return (bResult);
}

@end
