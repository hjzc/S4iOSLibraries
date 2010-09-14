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
 * Name:		S4HttpConnection.h
 * Module:		Network
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================

typedef enum
{
	kCacheNoData			= 1,
	kWriteToFile			= 2,
	kCacheAllData			= 4
}	RequestedAction;


// ================================== Globals =========================================



// ============================= Forward Declarations =================================

@class S4HttpConnection;


// ================================== Protocols ========================================
// ============================ S4HttpConnection Delegate =============================

@protocol S4HttpConnectionDelegate <NSObject>

@required
- (BOOL)httpConnection: (S4HttpConnection *)connection receivedData: (NSData *)data;
- (void)httpConnection: (S4HttpConnection *)connection failedWithError: (NSError *)error;
- (void)httpConnection: (S4HttpConnection *)connection completedWithData: (NSMutableData *)data;

@optional
- (BOOL)httpConnection: (S4HttpConnection *)connection receivedResponse: (NSURLResponse *)response;
- (NSURLRequest *)httpConnection: (S4HttpConnection *)connection receivedRedirectdirectRequest: (NSURLRequest *)request forResponse: (NSURLResponse *)redirectResponse;

@end



// ============================== S4HttpConnection Class ==============================

@interface S4HttpConnection : NSObject
{
@private
	NSURLConnection								*m_nsURLConnection;
	NSMutableData								*m_receivedData;
	id <S4HttpConnectionDelegate>				m_delegate;
	NSOutputStream								*m_fileOutputStream;
	RequestedAction								m_requestedAction;
	NSString									*m_filePathAndNameStr;
}


- (BOOL)openConnectionForRequest: (NSURLRequest *)request delegate: (id <S4HttpConnectionDelegate>)delegate;
- (BOOL)openNonCachingConnectionForRequest: (NSURLRequest *)request delegate: (id <S4HttpConnectionDelegate>)delegate;
- (BOOL)openConnectionForRequest: (NSURLRequest *)request
						delegate: (id <S4HttpConnectionDelegate>)delegate
			   writeToFileAtPath: (NSString *)path
						withName: (NSString *)fileName;
- (void)cancelConnection;

// NSURLConnection delegate methods
- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error;
- (NSURLRequest *)connection: (NSURLConnection *)connection willSendRequest: (NSURLRequest *)request redirectResponse: (NSURLResponse *)redirectResponse;
- (void)connection: (NSURLConnection *)connection didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;
- (NSCachedURLResponse *)connection: (NSURLConnection *)connection willCacheResponse: (NSCachedURLResponse *)cachedResponse;

@end
