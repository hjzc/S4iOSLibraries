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
 * Name:		S4OperationsHandler.m
 * Module:		Core
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4OperationsHandler.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================

#define MAX_CONCURRENT_OPERATIONS						(NSInteger)NSOperationQueueDefaultMaxConcurrentOperationCount

// ALL S4 LIBS SHOULD DEFINE THIS:
#define LIB_DOMAIN_NAME_STR								@"S4OperationsHandler"


// ================================== Typedefs =========================================



// =================================== Globals =========================================

// static class variables
// the NSOperationsQueue for all S4OperationsHandler instances (if requested)
static NSOperationQueue					*g_classOperationQueue;
static BOOL								g_bInitialized = NO;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ======================== Begin Class S4OperationsHandler () =========================

@interface S4OperationsHandler ()

@property (nonatomic, retain) NSOperationQueue				*m_instanceOperationQueue;

@end



// =================== Begin Class S4OperationsHandler (PrivateImpl) ===================

@interface S4OperationsHandler (PrivateImpl)

- (void)cancelAllOperations;
- (void)setMaxConcurrentOperationCount: (NSInteger)count;
- (void)setSuspended: (BOOL)suspend;
- (void)waitUntilAllOperationsAreFinished;

@end



@implementation S4OperationsHandler (PrivateImpl)

//============================================================================
//	S4OperationsHandler (PrivateImpl) :: cancelAllOperations
//============================================================================
- (void)cancelAllOperations
{
	[g_classOperationQueue cancelAllOperations];
}


//============================================================================
//	S4OperationsHandler (PrivateImpl) :: setMaxConcurrentOperationCount:
//============================================================================
- (void)setMaxConcurrentOperationCount: (NSInteger)count
{
	[g_classOperationQueue setMaxConcurrentOperationCount: count];
}


//============================================================================
//	S4OperationsHandler (PrivateImpl) :: setMaxConcurrentOperationCount:
//============================================================================
- (void)setSuspended: (BOOL)suspend
{
	[g_classOperationQueue setSuspended: suspend];
}


//============================================================================
//	S4OperationsHandler (PrivateImpl) :: waitUntilAllOperationsAreFinished
//============================================================================
- (void)waitUntilAllOperationsAreFinished
{
	[g_classOperationQueue waitUntilAllOperationsAreFinished];
}

@end




// ===================== Begin Class S4OperationsHandler =====================

@implementation S4OperationsHandler


//============================================================================
//	S4OperationsHandler :: properties
//============================================================================
// private
@synthesize m_instanceOperationQueue;


//============================================================================
//	S4OperationsHandler :: initialize
//============================================================================
+ (void)initialize
{
	if ((NO == g_bInitialized) && ([self class] == [S4OperationsHandler class]))
	{
		g_classOperationQueue = [[NSOperationQueue alloc] init];
		[g_classOperationQueue setMaxConcurrentOperationCount: MAX_CONCURRENT_OPERATIONS];

		g_bInitialized = YES;
	}
}


//============================================================================
//	S4OperationsHandler :: handlerWithOperationQueue:
//============================================================================
+ (id)handlerWithOperationQueue: (NSOperationQueue *)queue
{
	return [[[[self class] alloc] initWithOperationQueue: queue] autorelease];
}


//============================================================================
//	S4OperationsHandler :: init
//============================================================================
- (id)init
{
	self = [super init];
	if (nil != self)
	{
		self.m_instanceOperationQueue = g_classOperationQueue;
	}
	return (self);
}


//============================================================================
//	S4OperationsHandler :: initWithOperationQueue
//============================================================================
- (id)initWithOperationQueue: (NSOperationQueue *)queue
{
	self = [super init];
	if (nil != self)
	{
		if IS_NOT_NULL(queue)
		{
			self.m_instanceOperationQueue = queue;
		}
		else
		{
			m_instanceOperationQueue = g_classOperationQueue;
		}
	}
	return (self);
}


//============================================================================
//	S4OperationsHandler :: dealloc
//============================================================================
- (void)dealloc
{
	// if our instance member var has not been set to the class operation
	//  queue, call release on it
	if (NO == [g_classOperationQueue isEqual: self.m_instanceOperationQueue])
	{
		self.m_instanceOperationQueue = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4OperationsHandler :: addSelectorToQueue:
//============================================================================
- (BOOL)addSelectorToQueue: (SEL)selector
				  onTarget: (id)target
			 withArguments: (NSArray *)argArray
{
	NSInvocation						*invocation;
	NSUInteger							numArgs;
	NSUInteger							index;
	NSUInteger							argIndex;
	id									localObject;
	NSInvocationOperation				*invokeOperation;
	BOOL								bResult = NO;

	if (IS_NOT_NULL(target) && (NULL != selector))
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

					for (index = 0; index < numArgs; index++)
					{
						// When the argument value is an object, pass a pointer to the variable
						//  (or memory) from which the object should be copied:
						localObject = [argArray objectAtIndex: index];
						[invocation setArgument: &localObject atIndex: argIndex];
						argIndex++;
					}
				}
			}

			// now wrap the NSInvocation in an NSOperation subclass
			invokeOperation = [[NSInvocationOperation alloc] initWithInvocation: invocation];
			if (IS_NOT_NULL(invokeOperation))
			{
				[self.m_instanceOperationQueue addOperation: invokeOperation];
				[invokeOperation release];
				bResult = YES;
			}
		}
	}
	return (bResult);
}


//============================================================================
//	S4OperationsHandler :: operations
//============================================================================
- (NSArray *)operations
{
	return ([self.m_instanceOperationQueue operations]);
}


//============================================================================
//	S4OperationsHandler :: isSuspended
//============================================================================
- (BOOL)isSuspended
{
	return ([self.m_instanceOperationQueue isSuspended]);
}

@end
