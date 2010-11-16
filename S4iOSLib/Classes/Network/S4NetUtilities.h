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
 * Name:		S4NetUtilities.h
 * Module:		Network
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <stdarg.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// ================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// ============================ Class S4NetUtilities ===================================

@interface S4NetUtilities : NSObject
{

}

// Common URL and Request methods
+ (NSString *)urlEncodeStr: (NSString *)string;

+ (NSURL *)createNSUrlForPathStr: (NSString *)path baseStr: (NSString *)base;

+ (NSURLRequest *)createRequestForPath: (NSString *)path
							  useCache: (BOOL)bUseCache
					   timeoutInterval: (NSTimeInterval)timeoutInSec
							  postData: (NSData *)data
							dataIsForm: (BOOL)bIsForm
						 handleCookies: (BOOL)bHandleCookies;

+ (NSMutableURLRequest *)createSimpleRequestForURL: (NSURL *)url useCache: (BOOL)bUseCache;

+ (NSMutableURLRequest *)createPostRequestForURL: (NSURL *)url
								 timeoutInterval: (NSTimeInterval)timeoutInSec
								  fromDictionary: (NSDictionary *)dict
								   handleCookies: (BOOL)bHandleCookies;

+ (NSMutableURLRequest *)createRequestForURL: (NSURL *)url
									useCache: (BOOL)bUseCache
							 timeoutInterval: (NSTimeInterval)timeoutInSec
									postData: (NSData *)data
								  dataIsForm: (BOOL)bIsForm
							   handleCookies: (BOOL)bHandleCookies;

+ (NSMutableURLRequest *)addBasicAuthToURLRequest: (NSURLRequest *)urlRequest
									  forUserName: (NSString *)username
									  andPassword: (NSString *)password;

+ (NSURLCredential *)createNSURLCredentialForUser: (NSString *)username withPassword: (NSString *)password;

+ (NSString *)createQueryStringForPath: (NSString *)path, ...;

// get the text encoding of a file (for text-based files)
//	NSStringEncoding types are:
//
//					NSASCIIStringEncoding
//					NSNEXTSTEPStringEncoding
//					NSJapaneseEUCStringEncoding
//					NSUTF8StringEncoding
//					NSISOLatin1StringEncoding
//					NSSymbolStringEncoding
//					NSNonLossyASCIIStringEncoding
//					NSShiftJISStringEncoding
//					NSISOLatin2StringEncoding
//					NSUnicodeStringEncoding
//					NSWindowsCP1251StringEncoding
//					NSWindowsCP1252StringEncoding
//					NSWindowsCP1253StringEncoding
//					NSWindowsCP1254StringEncoding
//					NSWindowsCP1250StringEncoding
//					NSISO2022JPStringEncoding
//					NSMacOSRomanStringEncoding
//					NSUTF16StringEncoding
//					NSUTF16BigEndianStringEncoding
//					NSUTF16LittleEndianStringEncoding
//					NSUTF32StringEncoding
//					NSUTF32BigEndianStringEncoding
//					NSUTF32LittleEndianStringEncoding
//
+ (BOOL)getStringEncoding: (NSStringEncoding *)encodingPtr forHttpDocAtPath: (NSString *)path;

@end
