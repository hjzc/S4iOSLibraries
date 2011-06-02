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
 * Name:		S4HttpInvokeOperation.m
 * Module:		Network
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4HttpInvokeOperation.h"
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ==================== Begin Class S4HttpInvokeOperation (PrivateImpl) ================

@interface S4HttpInvokeOperation (PrivateImpl)

- (void)dropConnection;
- (void)doCancel;
- (void)invokeDataCallback: (NSData *)returnData;
- (void)invokeErrorCallback: (NSError *)returnError;

@end




@implementation S4HttpInvokeOperation (PrivateImpl)

//============================================================================
//	S4HttpInvokeOperation (PrivateImpl) :: dropConnection
//============================================================================
- (void)dropConnection
{
	if (nil != m_S4HttpConnection)
	{
		[m_S4HttpConnection cancelConnection];
		[m_S4HttpConnection autorelease];
		m_S4HttpConnection = nil;
	}
}


//============================================================================
//	S4HttpInvokeOperation (PrivateImpl) :: doCancel
//============================================================================
- (void)doCancel
{
	// KVO compliance
	[self willChangeValueForKey: @"isFinished"];
	[self willChangeValueForKey: @"isExecuting"];
	
	// dump the connection
	[self dropConnection];

	// update internal values
	m_bFinished = YES;
	m_bExecuting = NO;

	// KVO compliance
	[self didChangeValueForKey: @"isExecuting"];
	[self didChangeValueForKey: @"isFinished"];

	// it is OK if we are released now
	[self release];
}

	
//============================================================================
//	S4HttpInvokeOperation (PrivateImpl) :: invokeDataCallback:
//============================================================================
- (void)invokeDataCallback: (NSData *)returnData
{
	NSData					*localData;

	localData = returnData;

	[m_DataInvocation setArgument: &localData atIndex: 2];
	[m_DataInvocation invoke];
}


//============================================================================
//	S4HttpInvokeOperation (PrivateImpl) :: invokeErrorCallback:
//============================================================================
- (void)invokeErrorCallback: (NSError *)returnError
{
	NSError				*localErrorObject;
	
	localErrorObject = returnError;

	[m_ErrInvocation setArgument: &localErrorObject atIndex: 2];
	[m_ErrInvocation invoke];
}

@end




// ====================== Begin Class S4HttpInvokeOperation ==================

@implementation S4HttpInvokeOperation


//============================================================================
//	S4HttpInvokeOperation :: init
//============================================================================
- (id)init
{
	id					idResult = nil;

	self = [super init];
	if (nil != self)
	{
		m_UrlRequest = nil;
		m_S4HttpConnection = nil;
		m_DataInvocation = nil;
		m_ErrInvocation = nil;
		m_bStarted = NO;
		m_bCancelled = NO;
		m_bExecuting = NO;
		m_bFinished = NO;
		m_bReady = NO;

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4HttpInvokeOperation :: prepareForRequest:
//============================================================================
- (BOOL)prepareForRequest: (NSURLRequest *)request dataInvocation: (NSInvocation *)dataInvoke errInvocation: (NSInvocation *)errInvoke
{
	BOOL				bResult = NO;

	if ((NO == m_bStarted) && (IS_NOT_NULL(request)) && (IS_NOT_NULL(dataInvoke)) && (IS_NOT_NULL(errInvoke)))
	{
		m_UrlRequest = [request retain];

		m_DataInvocation = [dataInvoke retain];
		[m_DataInvocation retainArguments];

		m_ErrInvocation = [errInvoke retain];
		[m_ErrInvocation retainArguments];

		// keep ourselves alive while our request is running
		[self retain];

		// we are ready, set the flags
		m_bReady = YES;
		bResult = YES;
	}
	return (bResult);
}


//============================================================================
//	S4HttpInvokeOperation :: dealloc
//============================================================================
- (void)dealloc
{
	[self dropConnection];
	NS_SAFE_RELEASE(m_UrlRequest)
	NS_SAFE_RELEASE(m_DataInvocation)
	NS_SAFE_RELEASE(m_ErrInvocation)

	[super dealloc];
}




// ================================== NSOperation subclassed methods ==========================================

//============================================================================
//	S4HttpInvokeOperation :: start
//============================================================================
- (void)start
{
	if (YES == [NSThread isMainThread])
	{
		if (NO == [self isCancelled])
		{
			if (NO == m_bStarted)
			{
				if (YES == m_bReady)
				{
					m_bStarted = YES;
					m_S4HttpConnection = [[S4HttpConnection alloc] init];
					if (nil != m_S4HttpConnection)
					{
						if ([m_S4HttpConnection openConnectionForRequest: m_UrlRequest delegate: self])
						{
							// KVO compliance
							[self willChangeValueForKey: @"isExecuting"];
							m_bExecuting = YES;
							[self didChangeValueForKey: @"isExecuting"];
						}

						// release the request now
						[m_UrlRequest release];
						m_UrlRequest = nil;				
					}
				}
				else
				{
					@throw [NSException exceptionWithName: NSInvalidArgumentException
												   reason: @"S4HttpInvokeOperation started without calling prepareForRequest"
												 userInfo: nil];
				}
			}
			else
			{
				@throw [NSException exceptionWithName: NSInvalidArgumentException
											   reason: @"[S4HttpInvokeOperation start] has already been performed"
											 userInfo: nil];
			}
		}
	}
	else	// iOS 4 bug fix
	{
		[self performSelectorOnMainThread: @selector(start) withObject: nil waitUntilDone: NO];
	}
}


//============================================================================
//	S4HttpInvokeOperation :: main
//============================================================================
- (void)main
{
}


//============================================================================
//	S4HttpInvokeOperation :: cancel
//============================================================================
- (void)cancel
{
	[super cancel];
	[self willChangeValueForKey: @"isCancelled"];
	m_bCancelled = YES;
	[self didChangeValueForKey: @"isCancelled"];
}


//============================================================================
//	S4HttpInvokeOperation :: isCancelled
//============================================================================
- (BOOL)isCancelled
{
	return (m_bCancelled);
}


//============================================================================
//	S4HttpInvokeOperation :: isConcurrent
//============================================================================
- (BOOL)isConcurrent
{
	return (YES);
}


//============================================================================
//	S4HttpInvokeOperation :: isExecuting
//============================================================================
- (BOOL)isExecuting
{
	return (m_bExecuting);
}


//============================================================================
//	S4HttpInvokeOperation :: isFinshed
//============================================================================
- (BOOL)isFinished
{
	return (m_bFinished);
}


//============================================================================
//	S4HttpInvokeOperation :: isReady
//============================================================================
- (BOOL)isReady
{
	if ([super isReady])
	{
		return (m_bReady);
	}
	return (NO);
}




// ================================== S4HttpConnection delegate methods ==========================================

//============================================================================
//	S4HttpInvokeOperation :: httpConnection:receivedData:
//============================================================================
- (BOOL)httpConnection: (S4HttpConnection *)connection receivedData: (NSData *)data
{
	BOOL				bResult;

	// check to see if we are cancelled
	if (NO == [self isCancelled])
	{
		bResult = YES;
	}
	else
	{
		// canceled for some reason; update our state and cancel the connection
		[self doCancel];

		// this tells the S4HttpConnection to cancel its underlying NSURLConnection
		bResult = NO;
	}
	return (bResult);
}


//============================================================================
//	S4HttpInvokeOperation :: httpConnection:failedWithError:
//============================================================================
- (void)httpConnection: (S4HttpConnection *)connection failedWithError: (NSError *)error
{
	[self performSelectorOnMainThread: @selector(invokeErrorCallback:) withObject: error waitUntilDone: NO];
	[self doCancel];
}


//============================================================================
//	S4HttpInvokeOperation :: httpConnection:completedWithData:
//============================================================================
- (void)httpConnection: (S4HttpConnection *)connection completedWithData: (NSMutableData *)data
{
	[self performSelectorOnMainThread: @selector(invokeDataCallback:) withObject: data waitUntilDone: NO];
	[self doCancel];
}

@end
