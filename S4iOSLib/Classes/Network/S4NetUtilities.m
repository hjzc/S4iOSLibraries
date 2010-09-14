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
 * Name:		S4NetUtilities.m
 * Module:		Network
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <CoreFoundation/CoreFoundation.h>
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================

#define DEFAULT_TIMEOUT_INTERVAL		(NSTimeInterval)120.0


// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =========================== Begin Class S4NetUtilities (PrivateImpl) ======================

@interface S4NetUtilities (PrivateImpl)

+ (NSData *)encodedFormFromDictionary: (NSDictionary *)dict;
+ (void)placeHolder;

@end




@implementation S4NetUtilities (PrivateImpl)

//============================================================================
//	S4NetUtilities (PrivateImpl) :: encodedFormFromDictionary:
//============================================================================
+ (NSData *)encodedFormFromDictionary: (NSDictionary *)dict
{
	NSEnumerator					*keys;
	NSString						*curKey;
	NSString						*curValue;
	NSString						*encodedKey;
	NSString						*encodedValue;
	BOOL							bNext;
	NSMutableString					*formStr;
	NSData							*formDataResult = nil;

	if (IS_NOT_NULL(dict))
	{
		keys = [dict keyEnumerator];
		formStr = [NSMutableString stringWithCapacity: 256];

		// loop to get the key-value pairs, properly escaped, in one string
		bNext = NO;
		curKey = [keys nextObject];
		while (IS_NOT_NULL(curKey))
		{
			encodedKey = [S4NetUtilities urlEncodeStr: curKey];

			// now get the value
			curValue = [dict objectForKey: curKey];
			if (IS_NULL(curValue))
			{
				encodedValue = @"";
			}
			else
			{
				encodedValue = [S4NetUtilities urlEncodeStr: [curValue description]];
			}

			if (YES == bNext)
			{
				[formStr appendString: @"&"];
			}
			else
			{
				bNext = YES;
			}
			[formStr appendString: [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue]];
			curKey = [keys nextObject];
		}

		if (STR_NOT_EMPTY(formStr))
		{
			formDataResult = [formStr dataUsingEncoding: NSASCIIStringEncoding];
		}
	}
	return (formDataResult);
}


//============================================================================
//	S4NetUtilities (PrivateImpl) :: placeHolder
//============================================================================
+ (void)placeHolder
{
}

@end




// ============================== Begin Class S4NetUtilities =========================

@implementation S4NetUtilities

//============================================================================
//	S4NetUtilities :: urlEncodeStr:
//============================================================================
+ (NSString *)urlEncodeStr: (NSString *)string
{
	CFStringRef				rawStr;
	CFStringRef				preStr;
	NSString				*encodedStrResult = nil;
	
	if (STR_NOT_EMPTY(string))
	{
		rawStr = (CFStringRef)string;
		preStr = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, rawStr, CFSTR(""), kCFStringEncodingUTF8);
		if (NULL != preStr)
		{
			encodedStrResult = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, preStr, NULL, NULL, kCFStringEncodingUTF8);
			CFRelease(preStr);
		}
	}
	return (encodedStrResult);	
}


//============================================================================
//	S4NetUtilities : createNSUrlForPathStr
//============================================================================
+ (NSURL *)createNSUrlForPathStr: (NSString *)path baseStr: (NSString *)base
{
	CFStringRef				rawPathStr;
	CFStringRef				rawBaseStr;
	CFStringRef				prePathStr;
	CFStringRef				preBaseStr;
	CFStringRef				pathUrlStr;
	CFStringRef				baseUrlStr;
	CFURLRef				baseURL = NULL;
	BOOL					bError = NO;
	NSURL					*nsUrlResult = nil;
	
	if (STR_NOT_EMPTY(base))
	{
		rawBaseStr = (CFStringRef)base;
		preBaseStr = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, rawBaseStr, CFSTR(""), kCFStringEncodingUTF8);
		if (NULL != preBaseStr)
		{
			baseUrlStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, preBaseStr, NULL, NULL, kCFStringEncodingUTF8);
			if (NULL != baseUrlStr)
			{
				baseURL = CFURLCreateWithString(kCFAllocatorDefault, baseUrlStr, NULL);
				CFRelease(baseUrlStr);
			}
			CFRelease(preBaseStr);
		}
		
		if (NULL == baseURL)
		{
			bError = YES;
		}
	}
	
	if ((STR_NOT_EMPTY(path)) && (NO == bError))
	{
		rawPathStr = (CFStringRef)path;
		prePathStr = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, rawPathStr, CFSTR(""), kCFStringEncodingUTF8);
		if (NULL != prePathStr)
		{
			pathUrlStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, prePathStr, NULL, NULL, kCFStringEncodingUTF8);
			if (NULL != pathUrlStr)
			{
				nsUrlResult = (NSURL *)CFURLCreateWithString(kCFAllocatorDefault, pathUrlStr, baseURL);
				CFRelease(pathUrlStr);
			}
			CFRelease(prePathStr);
		}
	}
	return (nsUrlResult);
}


//============================================================================
//	S4NetUtilities :: createRequestForPath:
//============================================================================
+ (NSURLRequest *)createRequestForPath: (NSString *)path
							  useCache: (BOOL)bUseCache
					   timeoutInterval: (NSTimeInterval)timeoutInSec
							  postData: (NSData *)data
							dataIsForm: (BOOL)bIsForm
						 handleCookies: (BOOL)bHandleCookies
{
	NSURL						*nsURL;
	NSURLRequest				*requestResult = nil;
	
	if (STR_NOT_EMPTY(path))
	{
		// create a properly escaped NSURL from the string params
		nsURL = [S4NetUtilities createNSUrlForPathStr: path baseStr: nil];
		if (IS_NOT_NULL(nsURL))
		{
			// create the request
			requestResult = [S4NetUtilities createRequestForURL: nsURL
													   useCache: bUseCache
												timeoutInterval: timeoutInSec
													   postData: data
													 dataIsForm: bIsForm
												  handleCookies: bHandleCookies];
			
			[nsURL release];
		}
	}
	return (requestResult);
}


//============================================================================
//	S4NetUtilities :: createSimpleRequestForURL:
//============================================================================
+ (NSMutableURLRequest *)createSimpleRequestForURL: (NSURL *)url useCache: (BOOL)bUseCache
{
	return ([S4NetUtilities createRequestForURL: url useCache: bUseCache timeoutInterval: 0.0 postData: nil dataIsForm: NO handleCookies: YES]);
}


//============================================================================
//	S4NetUtilities :: createPostRequestForURL:
//============================================================================
+ (NSMutableURLRequest *)createPostRequestForURL: (NSURL *)url
								 timeoutInterval: (NSTimeInterval)timeoutInSec
								  fromDictionary: (NSDictionary *)dict
								   handleCookies: (BOOL)bHandleCookies
{
	NSData					*dataFromDict;

	dataFromDict = [S4NetUtilities encodedFormFromDictionary: dict];
	return ([S4NetUtilities createRequestForURL: url useCache: NO timeoutInterval: timeoutInSec postData: dataFromDict dataIsForm: YES handleCookies: bHandleCookies]);
}


//============================================================================
//	S4NetUtilities :: createRequestForURL:
//============================================================================
+ (NSMutableURLRequest *)createRequestForURL: (NSURL *)url
									useCache: (BOOL)bUseCache
							 timeoutInterval: (NSTimeInterval)timeoutInSec
									postData: (NSData *)data
								  dataIsForm: (BOOL)bIsForm
							   handleCookies: (BOOL)bHandleCookies
{
	NSString						*postLength;
	NSMutableURLRequest				*requestResult = nil;

	if (IS_NOT_NULL(url))
	{
		requestResult = [[NSMutableURLRequest alloc] init];
		if (IS_NOT_NULL(requestResult))
		{
			[requestResult setURL: url];

			if (IS_NOT_NULL(data))
			{
				[requestResult setHTTPMethod: @"POST"];
				postLength = [NSString stringWithFormat: @"%d", [data length]];
				[requestResult setValue: postLength forHTTPHeaderField: @"Content-Length"];
				if (YES == bIsForm)
				{
					[requestResult setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
				}
				[requestResult setHTTPBody: data];
			}
			else
			{
				[requestResult setHTTPMethod: @"GET"];
			}

			if (YES == bUseCache)
			{
				[requestResult setCachePolicy: NSURLRequestUseProtocolCachePolicy];
			}
			else
			{
				[requestResult setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
			}

			if (0 < timeoutInSec)
			{
				[requestResult setTimeoutInterval: timeoutInSec];
			}
			else
			{
				[requestResult setTimeoutInterval: DEFAULT_TIMEOUT_INTERVAL];
			}

			[requestResult setHTTPShouldHandleCookies: bHandleCookies];
			[requestResult setValue: @"gzip" forHTTPHeaderField: @"Accept-Encoding"];
			[requestResult setValue: @"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)" forHTTPHeaderField: @"User-Agent"];
		}
	}
	return (requestResult);
}


//============================================================================
//	S4NetUtilities :: createQueryStringForPath:
//============================================================================
+ (NSString *)createQueryStringForPath: (NSString *)path, ...
{
	NSMutableArray				*queryStrArray;
	va_list						params;
	id							keyObject;
	id							valueObject;
	NSString					*keyStr;
	NSString					*valueStr;
	NSString					*queryArg;
	NSString					*queryStrings = nil;
	NSMutableString				*queryStrResult = nil;

	if (STR_NOT_EMPTY(path))
	{
		// init variable arguments
		va_start(params, path);

		// loop to pull key/value pairs out of the varargs and add to array of strings
		queryStrArray = [NSMutableArray array];
		while (YES)
		{
			keyObject = va_arg(params, id);
			if (IS_NULL(keyObject))
			{
				break;
			}

			valueObject = va_arg(params, id);
			if (IS_NULL(valueObject))
			{
				break;
			}

			keyStr = [keyObject description];
			valueStr = [valueObject description];
			queryArg = [NSString stringWithFormat: @"%@=%@", keyStr, valueStr];
			[queryStrArray addObject: queryArg];
		}

		// reset variable arguments
		va_end(params);

		// if there are two or more query arguments, join them with an "&"
		if ([queryStrArray count] > 0)
		{
			queryStrings = [queryStrArray componentsJoinedByString: @"&"];
			if (STR_NOT_EMPTY(queryStrings))
			{
				queryStrResult = [NSMutableString stringWithCapacity: 256];
				[queryStrResult appendFormat: @"%@%@", path, queryStrings];
			}
		}
	}
	return (queryStrResult);
}


//============================================================================
//	S4NetUtilities : getStringEncoding:forFileAtPath:
//============================================================================
+ (BOOL)getStringEncoding: (NSStringEncoding *)encodingPtr forHttpDocAtPath: (NSString *)path
{
	NSURL					*url;
	NSString				*tmpStr;
	NSError					*error = nil;
	BOOL					bResult = NO;
	
	if (nil != encodingPtr)
	{
		url = [S4NetUtilities createNSUrlForPathStr: path baseStr: nil];
		if (IS_NOT_NULL(url))
		{
			tmpStr = [[NSString stringWithContentsOfURL: url usedEncoding: encodingPtr error: &error] autorelease];
			if ((STR_NOT_EMPTY(tmpStr)) && (IS_NULL(error)))
			{
				bResult = YES;
			}
			[url release];
		}
	}
	return (bResult);
}

@end
