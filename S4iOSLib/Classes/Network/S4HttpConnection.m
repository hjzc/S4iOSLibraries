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
 * Name:		S4HttpConnection.m
 * Module:		Network
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <CoreFoundation/CoreFoundation.h>
#import "S4HttpConnection.h"
#import "S4FileUtilities.h"
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================

#define DFLT_DATA_BUFFER_SZ					(NSUInteger)2048
#define MAX_BUFFER_SZ						(NSUInteger)(NSUIntegerMax - 4)
#define MAX_AUTH_ATTEMPTS					(NSInteger)5


// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ==================== Begin Class S4HttpConnection (PrivateImpl) =====================

@interface S4HttpConnection (PrivateImpl)

- (void)cancelConnectionForError: (NSError *)error;
- (void)handleResponseForContentLength: (long long)contentLength;
- (void)handleReceivedData: (NSData *)data;

@end




@implementation S4HttpConnection (PrivateImpl)

//============================================================================
//	S4HttpConnection (PrivateImpl) :: cancelConnectionForError:
//============================================================================
- (void)cancelConnectionForError: (NSError *)error
{
	[m_delegate httpConnection: self failedWithError: error];
	[self cancelConnection];
	
}


//============================================================================
//	S4HttpConnection (PrivateImpl) :: handleResponseForContentLength:
//============================================================================
- (void)handleResponseForContentLength: (long long)contentLength
{
	NSError							*error;

	// Set up the data buffer if CacheAllData is the requested action
	if (kCacheAllData == m_requestedAction)
	{
		if (IS_NOT_NULL(m_receivedData))			// release any previously allocated NSData buffer
		{
			[m_receivedData release];
			m_receivedData = nil;
		}

		// make sure the size does not overflow the dataWithCapacity maximum
		if (NSURLResponseUnknownLength == contentLength)
		{
			m_receivedData = [[NSMutableData dataWithCapacity: DFLT_DATA_BUFFER_SZ] retain];		// allocate and retain
		}
		else if (MAX_BUFFER_SZ > contentLength)
		{
			m_receivedData = [[NSMutableData dataWithCapacity: (NSUInteger)contentLength] retain];		// allocate and retain
		}

		// if contentLength > MAX_BUFFER_SZ || the m_receivedData could not be instantiated, inform user of error and cancel connection
		if (IS_NULL(m_receivedData))
		{
			error = [NSError errorWithDomain: NSURLErrorDomain code: NSURLErrorCannotLoadFromNetwork userInfo: nil];
			[self cancelConnectionForError: error];
		}
	}
}


//============================================================================
//	S4HttpConnection (PrivateImpl) :: handleReceivedData:
//============================================================================
- (void)handleReceivedData: (NSData *)data
{
	NSInteger						dataLength;
	const uint8_t					*dataBufferPtr;
	NSInteger						totalBytesWritten;
	NSInteger						curBytesWritten;
	NSError							*error;

	if (kCacheAllData == m_requestedAction)					// append the data received if requested action
	{
		[m_receivedData appendData: data];
	}
	else if (kWriteToFile == m_requestedAction)				// else if writing to a file...
	{
		// if this is the first pass on receiving data, create the stream and open it
		if (IS_NULL(m_fileOutputStream))
		{
			m_fileOutputStream = [[NSOutputStream alloc] initToFileAtPath: m_filePathAndNameStr append: NO];
			if (IS_NOT_NULL(m_fileOutputStream))
			{
				[m_fileOutputStream open];
			}
			else
			{
				error = [NSError errorWithDomain: NSURLErrorDomain code: NSURLErrorCannotOpenFile userInfo: nil];
				[self cancelConnectionForError: error];
			}
		}

		if (IS_NOT_NULL(m_fileOutputStream))
		{
			dataLength = [data length];
			if (0 < dataLength)
			{
				dataBufferPtr = (const uint8_t *)[data bytes];
				totalBytesWritten = 0;

				// write out the bytes till the data buffer is exhausted
				do
				{
					curBytesWritten = [m_fileOutputStream write: &dataBufferPtr[totalBytesWritten] maxLength: (dataLength - totalBytesWritten)];

					assert(curBytesWritten != 0);

					if (-1 == curBytesWritten)					// file write error, cancel the connection
					{
						error = [NSError errorWithDomain: NSURLErrorDomain code: NSURLErrorCannotWriteToFile userInfo: nil];
						[self cancelConnectionForError: error];
						break;
					}
					else
					{
						totalBytesWritten += curBytesWritten;
					}
				} while (totalBytesWritten < dataLength);
			}
		}
	}
}

@end



// ====================== Begin Class S4HttpConnection =======================

@implementation S4HttpConnection

//============================================================================
//	S4HttpConnection :: init
//============================================================================
- (id)init
{
	id					idResult = nil;

	self = [super init];
	if (nil != self)
	{
		m_nsURLConnection = nil;
		m_receivedData = nil;
		m_delegate = nil;
		m_fileOutputStream = nil;
		m_requestedAction = kCacheAllData;
		m_filePathAndNameStr = nil;

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4HttpConnection :: dealloc
//============================================================================
- (void)dealloc
{
	if (IS_NOT_NULL(m_nsURLConnection))
	{
		[m_nsURLConnection release];
		m_nsURLConnection = nil;
	}

	if (IS_NOT_NULL(m_receivedData))
	{
		[m_receivedData release];
		m_receivedData = nil;
	}

	if (IS_NOT_NULL(m_delegate))
	{
		[m_delegate release];
		m_delegate = nil;
	}

	if (IS_NOT_NULL(m_fileOutputStream))
	{
		[m_fileOutputStream release];
		m_fileOutputStream = nil;
	}

	if (IS_NOT_NULL(m_filePathAndNameStr))
	{
		[m_filePathAndNameStr release];
		m_filePathAndNameStr = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4HttpConnection :: openConnectionForRequest
//============================================================================
- (BOOL)openConnectionForRequest: (NSURLRequest *)request delegate: (id <S4HttpConnectionDelegate>)delegate
{
	BOOL							bResult = NO;

	if ((IS_NULL(m_nsURLConnection)) && (IS_NOT_NULL(request)) &&
		(IS_NOT_NULL(delegate)) && ([delegate conformsToProtocol: @protocol(S4HttpConnectionDelegate)]))
	{
		m_delegate = [delegate retain];

		// create the connection with the request and start loading the data
		m_nsURLConnection = [[NSURLConnection alloc] initWithRequest: request delegate: self];
		if (nil != m_nsURLConnection)
		{
			bResult = YES;
		}
	}
	return (bResult);
}


//============================================================================
//	S4HttpConnection :: openNonCachingConnectionForRequest
//============================================================================
- (BOOL)openNonCachingConnectionForRequest: (NSURLRequest *)request delegate: (id <S4HttpConnectionDelegate>)delegate
{
	m_requestedAction = kCacheNoData;
	return ([self openConnectionForRequest: request delegate: delegate]);
}


//============================================================================
//	S4HttpConnection :: openConnectionForPathStr
//============================================================================
- (BOOL)openConnectionForRequest: (NSURLRequest *)request
						delegate: (id <S4HttpConnectionDelegate>)delegate
			   writeToFileAtPath: (NSString *)path
						withName: (NSString *)fileName
{
	BOOL							bResult = NO;

	if ((STR_NOT_EMPTY(path)) && (STR_NOT_EMPTY(fileName)))
	{
		if (YES == [S4FileUtilities createDirectory: path])
		{
			m_filePathAndNameStr = [[path stringByAppendingPathComponent: fileName] retain];
			if (IS_NOT_NULL(m_filePathAndNameStr))
			{
				m_requestedAction = kWriteToFile;
				bResult = [self openConnectionForRequest: request delegate: delegate];
			}
		}
	}
	return (bResult);
}


//============================================================================
//	S4HttpConnection :: cancelConnection
//============================================================================
- (void)cancelConnection
{
	if (IS_NOT_NULL(m_nsURLConnection))
	{
		[m_nsURLConnection cancel];
	}

	if (IS_NOT_NULL(m_fileOutputStream))
	{
		[m_fileOutputStream close];
		[m_fileOutputStream release];
		m_fileOutputStream = nil;
	}
}




// ================================== NSURLConnection delegate methods ==========================================

//============================================================================
//	S4HttpConnection :: didReceiveResponse
//
// this method is called when the server has determined that it
// has enough information to create the NSURLResponse
// it can be called multiple times, for example in the case of a
// redirect, so each time we reset the data.
// m_receivedData is declared as a method instance elsewhere
//============================================================================
- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response
{
	NSHTTPURLResponse				*httpResponse;
	NSInteger						iStatusCode;
	NSMutableDictionary				*userDict;
	NSString						*localizedFailureReason;
	NSString						*localizedDescription;
	NSError							*error;

	httpResponse = (NSHTTPURLResponse *)response;
	iStatusCode = [httpResponse statusCode];
	if ((199 < iStatusCode) && (400 > iStatusCode))						// connection OK
	{
		// init the data buffer (if used) and set the suggested filename
		[self handleResponseForContentLength: [httpResponse expectedContentLength]];

		// inform the delegate of a response if it supports this optional protocol method
		if ([m_delegate respondsToSelector: @selector(httpConnection:receivedResponse:)])
		{
			if (NO == [m_delegate httpConnection: self receivedResponse: response])
			{
				// a NO response from the delegate means cancel further callbacks
				[self cancelConnection];
			}			
		}
	}
	else																// connection failed
	{
		// create an NSError object to inform the delegate that the connection failed
		//  NOTE: if we get here, the NSURLConnection will NOT call our error delegate!
		userDict = [NSMutableDictionary dictionaryWithCapacity: 10];
		if (nil != userDict)
		{
			[userDict setDictionary: [httpResponse allHeaderFields]];
			localizedDescription = [NSHTTPURLResponse localizedStringForStatusCode: iStatusCode];
			[userDict setObject: localizedDescription forKey: NSLocalizedDescriptionKey];
			localizedFailureReason = [NSString stringWithFormat: @"Status code returned: %d", iStatusCode];
			[userDict setObject: localizedFailureReason forKey: NSLocalizedFailureReasonErrorKey];
		}

		// create the NSError
		error = [NSError errorWithDomain: NSURLErrorDomain code: NSURLErrorBadServerResponse userInfo: userDict];			

		// inform the delegate and cancel the connection
		[self cancelConnectionForError: error];
	}
}


//============================================================================
//	S4HttpConnection :: didReceiveData
//
// append the new data to the receivedData
// receivedData is declared as a method instance elsewhere
//============================================================================
- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data
{
	// do the requested action with the data
	[self handleReceivedData: data];

	// notify the delegate
	if (NO == [m_delegate httpConnection: self receivedData: data])
	{
		// a NO response from the delegate means cancel further callbacks
		[self cancelConnection];
	}
}


//============================================================================
//	S4HttpConnection :: didFailWithError
//============================================================================
- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error
{
	// inform the delegate and cancel the connection
	[self cancelConnectionForError: error];
}


//============================================================================
//	S4HttpConnection :: connectionDidFinishLoading
//============================================================================
- (void)connectionDidFinishLoading: (NSURLConnection *)connection
{
	// inform the delegate
	[m_delegate httpConnection: self completedWithData: m_receivedData];

	// cancel the connection if our delegate did not
	[self cancelConnection];
}


//============================================================================
//	S4HttpConnection :: willSendRequest
//	Handles redirect requests
//============================================================================
- (NSURLRequest *)connection: (NSURLConnection *)connection willSendRequest: (NSURLRequest *)request redirectResponse: (NSURLResponse *)redirectResponse
{
	NSURLRequest			*newRequest;

	newRequest = request;
	if (nil != redirectResponse)
	{
		// inform the delegate of a redirect if it supports this optional protocol method
		if ((nil != m_delegate) && ([m_delegate respondsToSelector: @selector(httpConnection:receivedRedirectRequest:forResponse:)]))
		{
			newRequest = [m_delegate httpConnection: self receivedRedirectRequest: request forResponse: redirectResponse];
		}
	}
	return (newRequest);
	
}


//============================================================================
//	S4HttpConnection :: didSendBodyData
//	Provides delegate with progress information for uploads
//============================================================================
- (void)connection: (NSURLConnection *)connection didSendBodyData: (NSInteger)bytesWritten
												totalBytesWritten: (NSInteger)totalBytesWritten
										totalBytesExpectedToWrite: (NSInteger)totalBytesExpectedToWrite
{
	// inform the delegate of a redirect if it supports this optional protocol method
	if ((nil != m_delegate) && ([m_delegate respondsToSelector: @selector(httpConnection:totalBytesWritten:totalBytesToWrite:)]))
	{
		[m_delegate httpConnection: self totalBytesWritten: totalBytesWritten totalBytesToWrite: totalBytesExpectedToWrite];
	}	
}


//============================================================================
//	S4HttpConnection :: canAuthenticateAgainstProtectionSpace
//	Asks if the delegate can handle specific types of authentication
//============================================================================
- (BOOL)connection: (NSURLConnection *)connection canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace
{
	NSString				*authenticationMethod;
	BOOL					bResult = NO;

	// ask the delegate if it supports this authentication method (via an optional protocol method)
	if ((nil != m_delegate) && ([m_delegate respondsToSelector: @selector(httpConnection:supportsProtectionSpace:)]))
	{
		bResult = [m_delegate httpConnection: self supportsProtectionSpace: protectionSpace];
	}
	else		// default behavior mimics the System rules that apply if the delegate method was not implemented
	{
		authenticationMethod = [protectionSpace authenticationMethod];
		if (STR_NOT_EMPTY(authenticationMethod))
		{
			if (([authenticationMethod isEqualToString: NSURLAuthenticationMethodDefault]) ||
				([authenticationMethod isEqualToString: NSURLAuthenticationMethodHTTPBasic]) ||
				([authenticationMethod isEqualToString: NSURLAuthenticationMethodHTTPDigest]) ||
				([authenticationMethod isEqualToString: NSURLAuthenticationMethodHTMLForm]) ||
				([authenticationMethod isEqualToString: NSURLAuthenticationMethodNegotiate]))
			{
				bResult = YES;
			}
			else if (([authenticationMethod isEqualToString: NSURLAuthenticationMethodClientCertificate]) ||
					 ([authenticationMethod isEqualToString: NSURLAuthenticationMethodServerTrust]))
			{
				bResult = NO;
			}
		}
	}
	return (bResult);
}


//============================================================================
//	S4HttpConnection :: didReceiveAuthenticationChallenge
//	Handles HTTPS authentication challenges
//============================================================================
- (void)connection: (NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSURLCredential				*credential = nil;

	if (IS_NOT_NULL(challenge))
	{
		// if authentication has failed less than MAX_AUTH_ATTEMPTS times
		if ([challenge previousFailureCount] < MAX_AUTH_ATTEMPTS)
		{
			// inform the delegate of a authentication challenge if it supports this optional protocol method
			if ((nil != m_delegate) && ([m_delegate respondsToSelector: @selector(httpConnection:respondToAuthChallenge:)]))
			{
				credential = [m_delegate httpConnection: self respondToAuthChallenge: challenge];
			}

			if (IS_NOT_NULL(credential))
			{
				[[challenge sender] useCredential: credential forAuthenticationChallenge: challenge];
			}
			else
			{
				[[challenge sender] continueWithoutCredentialForAuthenticationChallenge: challenge];
			}			
		}
		else
		{
			[[challenge sender] cancelAuthenticationChallenge: challenge];
		}
	}
}


//============================================================================
//	S4HttpConnection :: didCancelAuthenticationChallenge
//	The -connection:didCancelAuthenticationChallenge: isn't meaningful in the
//	context of an NSURLConnection, so we just don't implement that method
//============================================================================
//- (void)connection: (NSURLConnection *)connection didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
//{
//}


//============================================================================
//	S4HttpConnection :: willCacheResponse
//	Handles caching notification if user wants custom approach
//============================================================================
- (NSCachedURLResponse *)connection: (NSURLConnection *)connection willCacheResponse: (NSCachedURLResponse *)cachedResponse
{
	NSCachedURLResponse				*newCachedResponse;

	newCachedResponse = cachedResponse;
/*
	if ([[[[cachedResponse response] URL] scheme] isEqual:@"https"])
	{
		newCachedResponse = nil;
	}
	else
	{		
		NSDictionary *newUserInfo;

		newUserInfo = [NSDictionary dictionaryWithObject: [NSCalendarDate date] forKey: @"Cached Date"];

		newCachedResponse = [[[NSCachedURLResponse alloc] initWithResponse: [cachedResponse response]
																	  data:[cachedResponse data]
																  userInfo:newUserInfo
															 storagePolicy:[cachedResponse storagePolicy]] autorelease];
	}
*/
	return (newCachedResponse);
}


@end
