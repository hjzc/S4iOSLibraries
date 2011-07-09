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
 * Name:		S4ImageFetcher.m
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4ImageFetcher.h"
#import "S4HttpInvokeOperation.h"
#import "S4NetUtilities.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================

// ALL S4 LIBS SHOULD DEFINE THIS:
S4_INTERN_CONSTANT_NSSTR						S4ImageFetcherErrorDomain = @"S4ImageFetcherErrorDomain";

// static class variables
// the NSOperationsQueue for all S4ImageFetcher instances (if none is provided)
static NSOperationQueue							*g_classOperationQueue;
static BOOL										g_bInitialized = NO;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ===================== Begin Class S4ImageFetcher (PrivateImpl) ======================

@interface S4ImageFetcher (PrivateImpl)

- (void)asyncDataResponse: (id)data;
- (void)asyncErrorResponse: (id)error;

@end




@implementation S4ImageFetcher (PrivateImpl)

//============================================================================
//	S4ImageFetcher (PrivateImpl) :: asyncDataResponse:
//============================================================================
- (void)asyncDataResponse: (id)data
{
	UIImage									*image;
	NSMutableDictionary						*userDict;
	S4ImageFetcherError						errorCode = S4ImageFetcherNoError;
	NSString								*localizedDescription;
	NSString								*localizedFailureReason;
	NSError									*error;

	if (IS_NOT_NULL(data))
	{
		image = [UIImage imageWithData: data];
		if (IS_NOT_NULL(image))
		{
			[m_delegate imageFetcher: self loadedImage: image context: m_userObject];
		}
		else
		{
			localizedDescription = @"Invalid image";
			localizedFailureReason = @"The data sent by the server could not be used for an image";
			errorCode = S4ImageFetcherInvalidImageError;
		}
	}
	else
	{
		localizedDescription = @"Invalid data";
		localizedFailureReason = @"The server responded with invalid data";
		errorCode = S4ImageFetcherInvalidDataError;
	}

	if (S4ImageFetcherNoError != errorCode)
	{
		// create an NSDictionary to hold values for the NSError
		userDict = [NSMutableDictionary dictionaryWithCapacity: 2];
		if (IS_NOT_NULL(userDict))
		{
			// set the keys in the error dictionary
			[userDict setObject: localizedDescription forKey: NSLocalizedDescriptionKey];
			[userDict setObject: localizedFailureReason forKey: NSLocalizedFailureReasonErrorKey];
		}

		// create the NSError
		error = [NSError errorWithDomain: S4ImageFetcherErrorDomain code: (NSInteger)errorCode userInfo: userDict];
		[self asyncErrorResponse: error];
	}
}


//============================================================================
//	S4ImageFetcher (PrivateImpl) :: asyncErrorResponse:
//============================================================================
- (void)asyncErrorResponse: (id)error
{
	if (YES == [m_delegate respondsToSelector: @selector(imageFetcher:didFailWithError:)])
	{
		[m_delegate imageFetcher: self didFailWithError: error];
	}
}

@end




// ========================== Begin Class S4ImageFetcher ===============================

@implementation S4ImageFetcher


//============================================================================
//	S4ImageFetcher :: properties
//============================================================================
// public
@synthesize operationQueue = m_operationQueue;
@synthesize imageTag = m_imageTag;

// private


//============================================================================
//	S4ImageFetcher :: initialize
//============================================================================
+ (void)initialize
{
	if ((NO == g_bInitialized) && ([self class] == [S4ImageFetcher class]))
	{
		g_classOperationQueue = [[NSOperationQueue alloc] init];
		[g_classOperationQueue setMaxConcurrentOperationCount: NSOperationQueueDefaultMaxConcurrentOperationCount];

		g_bInitialized = YES;
	}
}


//============================================================================
//	S4ImageFetcher :: jsonFile
//============================================================================
+ (id)fetcherForImageAtURL: (NSString *)urlStr
			  withDelegate: (id <S4ImageFetcherDelegate>)delegate
				   context: (id)userObject
	   usingOperationQueue: (NSOperationQueue *)queue
{
	S4ImageFetcher					*fetcher;

	fetcher = [[[S4ImageFetcher alloc] init] autorelease];
	if (nil != fetcher)
	{
		fetcher.operationQueue = queue;
		if (NO == [fetcher loadImageAtURL: urlStr withDelegate: delegate context: userObject])
		{
			fetcher = nil;
		}
	}
	return (fetcher);
}


//============================================================================
//	S4ImageFetcher :: init
//============================================================================
- (id)init
{
	self = [super init];
	if (nil != self)
	{
		// protected member vars
		m_userObject = nil;
		m_delegate = nil;
		m_imageTag = nil;
		m_operationQueue = nil;
	}
	return (self);
}


//============================================================================
//	S4ImageFetcher :: dealloc
//============================================================================
- (void)dealloc
{
	if (IS_NOT_NULL(m_userObject))
	{
		[m_userObject release];
		m_userObject = nil;
	}

	if IS_NOT_NULL(m_delegate)
	{
		[m_delegate release];
		m_delegate = nil;
	}

	if IS_NOT_NULL(m_imageTag)
	{
		[m_imageTag release];
		m_imageTag = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4ImageFetcher :: loadImageAtURL:
//============================================================================
- (BOOL)loadImageAtURL: (NSString *)urlStr withDelegate: (id <S4ImageFetcherDelegate>)delegate context: (id)userObject
{
	NSURLRequest					*urlRequest;
	S4HttpInvokeOperation			*invokeOperation;
	NSInvocation					*dataInv;
	NSInvocation					*errInv;
	BOOL							bResult = NO;
	
	if ((STR_NOT_EMPTY(urlStr)) && (IS_NOT_NULL(delegate)) && (YES == [delegate conformsToProtocol: @protocol(S4ImageFetcherDelegate)]))
	{
		// retain the objects we need later
		m_userObject = [userObject retain];
		m_delegate = [delegate retain];
		m_imageTag = [urlStr copy];		// imageURL.absoluteString

		// now set up the HTTP download
		urlRequest = [S4NetUtilities createRequestForPath: urlStr
												 useCache: NO
										  timeoutInterval: 0.0
												 postData: nil
											   dataIsForm: NO
											handleCookies: YES];
		// create a properly escaped NSURL from the string params
		if (nil != urlRequest)
		{
			invokeOperation = [[S4HttpInvokeOperation alloc] init];
			if (nil != invokeOperation)
			{
				dataInv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector: @selector(asyncDataResponse:)]];
				[dataInv setSelector: @selector(asyncDataResponse:)];
				[dataInv setTarget: self];
				
				errInv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector: @selector(asyncErrorResponse:)]];
				[errInv setSelector: @selector(asyncErrorResponse:)];
				[errInv setTarget: self];
				
				if ([invokeOperation prepareForRequest: urlRequest dataInvocation: dataInv errInvocation: errInv])
				{
					if (IS_NOT_NULL(m_operationQueue))
					{
						[m_operationQueue addOperation: invokeOperation];
					}
					else
					{
						[g_classOperationQueue addOperation: invokeOperation];
					}

					bResult = YES;
				}
				[invokeOperation release];
			}
			[urlRequest release];
		}
	}
	return (bResult);
}

@end
