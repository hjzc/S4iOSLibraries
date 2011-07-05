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
 * Name:		S4SbJSONFile.m
 * Module:		Data
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4SbJSONFile.h"
#import "SBJsonParser.h"
#import "S4NetUtilities.h"
#import "S4FileUtilities.h"
#import "S4NetworkAccess.h"
#import "S4OperationsHandler.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ===================== Begin Class S4SbJSONFile (PrivateImpl) ========================

@interface S4SbJSONFile (PrivateImpl)

- (BOOL)setUpParse;
- (void)cleanUpParse;
- (void)downloadAndParseForUrl: (NSString *)urlStr;
- (void)readAndParseAtFilePath: (NSString *)filePathStr;
- (BOOL)startParsingPath: (NSString *)pathStr
			withDelegate: (id <S4JSONFileDelegate>)delegate
			 forSelector: (SEL)parsingSelector;
- (NSError *)errorWithDescription: (NSString *)descStr andFailReason: (NSString *)failStr;
- (void)parseStarted;
- (void)parseError: (NSError *)error;
- (void)parseEnded: (NSData *)data;

@end



@implementation S4SbJSONFile (PrivateImpl)

//============================================================================
//	S4SbJSONFile (PrivateImpl) :: setUpParse
//============================================================================
- (BOOL)setUpParse
{
	BOOL					bResult = NO;

	// create an autorelease pool to deal with temporary alloations
	m_parsingAutoreleasePool = [[NSAutoreleasePool alloc] init];
	if (IS_NOT_NULL(m_parsingAutoreleasePool))
    {
		// set the parser executing flag
		m_bDoneParsing = NO;
        bResult = YES;
    }
	return (bResult);
}


//============================================================================
//	S4SbJSONFile (PrivateImpl) :: cleanUpParse
//============================================================================
- (void)cleanUpParse
{	
	if IS_NOT_NULL(m_parsingAutoreleasePool)
	{
		[m_parsingAutoreleasePool release];
		m_parsingAutoreleasePool = nil;
	}	
}


//============================================================================
//	S4SbJSONFile (PrivateImpl) :: downloadAndParseForUrl:
//============================================================================
- (void)downloadAndParseForUrl: (NSString *)urlStr
{
	NSURL								*url;
	NSMutableURLRequest					*request;
	
	if (YES == [self setUpParse])
	{
		// create a properly escaped NSURL from the string params
		url = [S4NetUtilities createNSUrlForPathStr: urlStr baseStr: nil];
		if (IS_NOT_NULL(url))
		{
			// create the request
			request = [S4NetUtilities createRequestForURL: url
												 useCache: m_bUseCache
										  timeoutInterval: m_requestTimeout
												 postData: nil
											   dataIsForm: NO
											handleCookies: NO];
			if (IS_NOT_NULL(request))
			{
				[request setValue: @"application/json; charset=utf-8" forHTTPHeaderField: @"Content-Type"];
				[request setValue: @"application/json" forHTTPHeaderField: @"Accept"];
				[request setValue: @"utf-8" forHTTPHeaderField: @"Accept-Charset"];
				[request setHTTPMethod: @"GET"];
				
				m_S4HttpConnection = [[S4HttpConnection alloc] init];
				if (IS_NOT_NULL(m_S4HttpConnection))
				{
					// open the HTTP connection
					if ([m_S4HttpConnection openConnectionForRequest: request delegate: self])
					{
						// tell the UI that the operation has begun (put up a network spinner, etc.)
						[self performSelectorOnMainThread: @selector(parseStarted) withObject: nil waitUntilDone: NO];
                        
						// loop on the runLoop until the m_bdoneParsing flag is set
						do
						{
							[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate distantFuture]];
						}
						while (NO == m_bDoneParsing);
					}
					[self cancel];		// release the S4HttpConnection
				}
				[request release];
			}
			[url release];
		}
	}
	// Release resources used only in this thread
	[self cleanUpParse];
}


//============================================================================
//	S4SbJSONFile (PrivateImpl) :: readAndParseAtFilePath:
//============================================================================
- (void)readAndParseAtFilePath: (NSString *)filePathStr
{
	NSData								*jsonData;
	NSError								*error = nil;

	if (YES == [self setUpParse])
	{
		// tell the UI that parsing has begun (show a spinner, etc.)
		[self performSelectorOnMainThread: @selector(parseStarted) withObject: nil waitUntilDone: NO];

		// read the JSON data from the file
		jsonData = [NSData dataWithContentsOfFile: filePathStr options: NSDataReadingUncached error: &error];
		if ((nil == error) && (IS_NOT_NULL(jsonData)))
		{
			// pass the parsed JSON back to the delegate
			[self performSelectorOnMainThread: @selector(parseEnded) withObject: jsonData waitUntilDone: NO];
		}
	}
	// Release resources used only in this thread
	m_bDoneParsing = YES;
	[self cleanUpParse];
}


//============================================================================
//	S4SbJSONFile (PrivateImpl) :: startParsingPath:
//============================================================================
- (BOOL)startParsingPath: (NSString *)pathStr
			withDelegate: (id <S4JSONFileDelegate>)delegate
			 forSelector: (SEL)parsingSelector
{
	S4OperationsHandler					*s4OpsHandler;
	NSMutableArray						*argArray;
	BOOL								bResult = NO;
    
	// retain the delegate
	m_delegate = [delegate retain];

	// create an S4OperationsHandler instance to spin a new thread for the parse operation
	s4OpsHandler = [S4OperationsHandler handlerWithOperationQueue: self.operationQueue];
	if IS_NOT_NULL(s4OpsHandler)
	{
		argArray = [NSMutableArray arrayWithCapacity: (NSUInteger)2];
		if IS_NOT_NULL(argArray)
		{
			// put the pathStr argument on the called methods parameter list
			[argArray addObject: pathStr];
			
			// create an NSInvocation for the parsing operation on put it on the global NSOperationQueue
			bResult = [s4OpsHandler addSelectorToQueue: parsingSelector
											  onTarget: self
										 withArguments: argArray];
		}
	}
	return (bResult);
}


//============================================================================
//	S4SbJSONFile (PrivateImpl) :: errorWithLocalDescription:
//============================================================================
- (NSError *)errorWithDescription: (NSString *)descStr andFailReason: (NSString *)failStr
{
	NSError									*error = nil;
	NSMutableDictionary						*userDict = nil;
	NSString								*localizedDescription;
	NSString								*localizedFailureReason;

	userDict = [NSMutableDictionary dictionaryWithCapacity: 2];
	if (nil != userDict)
	{
		if (STR_NOT_EMPTY(descStr))
		{
			localizedDescription = descStr;
		}
		else
		{
			localizedDescription = @"Generic JSON error";
		}
		[userDict setObject: localizedDescription forKey: NSLocalizedDescriptionKey];

		if (STR_NOT_EMPTY(failStr))
		{
			localizedFailureReason = failStr;
		}
		else
		{
			localizedFailureReason = @"Generic JSON error";
		}
		[userDict setObject: localizedFailureReason forKey: NSLocalizedFailureReasonErrorKey];
	}

	// create the NSError
	error = [NSError errorWithDomain: S4JSONFileErrorDomain code: JSONFileParseError userInfo: userDict];

	return (error);
}



/********************************************* Methods performed on the Main Thread  *********************************************/

//============================================================================
//	S4SbJSONFile (PrivateImpl) :: parseStarted
//============================================================================
- (void)parseStarted
{
	[m_delegate jsonFileDidBeginParsingData: self];
}


//============================================================================
//	S4SbJSONFile (PrivateImpl) :: parseError:
//============================================================================
- (void)parseError: (NSError *)error
{
	[m_delegate jsonFile: self didFailWithError: error];
	[self cancel];
}


//============================================================================
//	S4SbJSONFile (PrivateImpl) :: parseEnded
//		This is called explicitly by the read file parser code
//		and implicitly by the S4HttpConnection's completion
//		delegate method
//============================================================================
- (void)parseEnded: (NSData *)data
{
	S4JSONClassType							jsonObjectType;
	NSError									*error = nil;

	if (S4JSONParserStatusOK == [self parse: data error: &error])
	{
		if (YES == [m_rootJSONObject isKindOfClass: [NSDictionary class]])
		{
			jsonObjectType = kNSDictionaryJSONClass;
		}
		else if (YES == [m_rootJSONObject isKindOfClass: [NSArray class]])
		{
			jsonObjectType = kNSArrayJSONClass;
		}
		else if (YES == [m_rootJSONObject isKindOfClass: [NSString class]])
		{
			jsonObjectType = kNSStringJSONClass;
		}
		else if (YES == [m_rootJSONObject isKindOfClass: [NSNumber class]])
		{
			jsonObjectType = kNSNumberJSONClass;
		}
		else
		{
			jsonObjectType = kUnknownJSONClass;
		}			

		// call the delegate with the JSON from the server parsed into an NSObject class
		[m_delegate jsonFile: self didEndParsingJSON: m_rootJSONObject ofType: jsonObjectType];
	}
}

@end




// ============================= Begin Class S4SbJSONFile ==============================

@implementation S4SbJSONFile


//============================================================================
//	S4SbJSONFile :: properties
//============================================================================
// public

// private



//============================================================================
//	S4SbJSONFile :: jsonFile
//============================================================================
+ (id)jsonFile
{
	return ([[[[self class] alloc] init] autorelease]);
}


//============================================================================
//	S4SbJSONFile :: init
//============================================================================
- (id)init
{
  return ([self initWithParserOptions: S4JSONParserOptionsAllowComments]);
}


//============================================================================
//	S4SbJSONFile :: initWithParserOptions:
//============================================================================
- (id)initWithParserOptions: (S4JSONParserOptions)parserOptions
{
	self = [super initWithParserOptions: parserOptions];
	if (nil != self)
	{
		// private member vars
		m_S4HttpConnection = nil;
		m_requestTimeout = 0.0;
		m_bUseCache = NO;
	}
	return (self);
}


//============================================================================
//	S4SbJSONFile :: dealloc
//============================================================================
- (void)dealloc
{
	if (IS_NOT_NULL(m_S4HttpConnection))
	{
		[m_S4HttpConnection release];
		m_S4HttpConnection = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4SbJSONFile :: parse:
//============================================================================
- (S4JSONParserStatus)parse: (NSData *)data error: (NSError **)error
{
	SBJsonParser						*jsonParser;
	id									idResult;
	NSError								*localError = nil;

	if (IS_NOT_NULL(data))
	{
		jsonParser = [[SBJsonParser alloc] init];
		if IS_NOT_NULL(jsonParser)
		{
			idResult = [jsonParser objectWithData: data];
			if (IS_NOT_NULL(idResult))
			{
				m_rootJSONObject = [idResult retain];
				m_parserStatus = S4JSONParserStatusOK;
			}
			else
			{
				localError = [self errorWithDescription: @"Parser error" andFailReason: jsonParser.error];
				m_parserStatus = S4JSONParserStatusBadData;
			}
			[jsonParser release];
		}
		else
		{
			localError = [self errorWithDescription: @"Allocation error" andFailReason: @"could not allocate parser"];
			m_parserStatus = S4JSONParserStatusError;
		}
	}
	else
	{
		localError = [self errorWithDescription: @"Bad data" andFailReason: @"data to parse is NIL"];
		m_parserStatus = S4JSONParserStatusError;
	}

	if (nil != error)
	{
		*error = localError;
	}
	return (m_parserStatus);
}


//============================================================================
//	S4SbJSONFile :: parseCompleted
//============================================================================
- (S4JSONParserStatus)parseCompleted
{
	return (m_parserStatus);
}


//============================================================================
//	S4SbJSONFile :: requestJSONfromURLStr:
//============================================================================
- (BOOL)requestJSONfromURLStr: (NSString *)urlStr
				  forDelegate: (id <S4JSONFileDelegate>)delegate
					  timeout: (NSTimeInterval)requestTimeout
				  useWebCache: (BOOL)bUseCache
{
	S4NetworkAccess						*networkAccess;
	BOOL								bResult = NO;

	if ((STR_NOT_EMPTY(urlStr)) && (IS_NOT_NULL(delegate)) && (YES == [delegate conformsToProtocol: @protocol(S4JSONFileDelegate)]))
	{
		networkAccess = [S4NetworkAccess networkAccessWithHostName: self.reachableHostStr];
		if ((IS_NOT_NULL(networkAccess)) && (NetworkNotReachable != [networkAccess currentReachabilityStatus]))
		{
			// start the parse
			m_requestTimeout = requestTimeout;
			m_bUseCache = bUseCache;
			bResult = [self startParsingPath: urlStr
								withDelegate: delegate
								 forSelector: @selector(downloadAndParseForUrl:)];
		}
	}
	return (bResult);
}


//============================================================================
//	S4SbJSONFile :: parseJSONfromFilePath:
//============================================================================
- (BOOL)parseJSONfromFilePath: (NSString *)pathStr forDelegate: (id <S4JSONFileDelegate>)delegate;
{
	BOOL								bResult = NO;
	
	if ((STR_NOT_EMPTY(pathStr)) && (IS_NOT_NULL(delegate)) && (YES == [delegate conformsToProtocol: @protocol(S4JSONFileDelegate)]))
	{
		if (YES == [S4FileUtilities fileExists: pathStr])
		{
			// start the parse
			bResult = [self startParsingPath: pathStr
								withDelegate: delegate
								 forSelector: @selector(readAndParseAtFilePath:)];
		}
	}
	return (bResult);
}


//============================================================================
//	S4SbJSONFile :: cancel
//============================================================================
- (void)cancel
{
	// dump the connection
	if (IS_NOT_NULL(m_S4HttpConnection))
	{
		[m_S4HttpConnection cancelConnection];
		[m_S4HttpConnection autorelease];
		m_S4HttpConnection = nil;
	}
	// Set the condition which ends the run loop for downloading or while condition for files
	m_bDoneParsing = YES; 	
}



// ================================== S4HttpConnection delegate methods ==========================================

//============================================================================
//	S4SbJSONFile :: httpConnection:receivedData:
//============================================================================
- (BOOL)httpConnection: (S4HttpConnection *)connection receivedData: (NSData *)data
{
	return (YES);
}


//============================================================================
//	S4SbJSONFile :: httpConnection:failedWithError:
//============================================================================
- (void)httpConnection: (S4HttpConnection *)connection failedWithError: (NSError *)error
{
	[self performSelectorOnMainThread: @selector(parseError:) withObject: error waitUntilDone: NO];
}


//============================================================================
//	S4SbJSONFile :: httpConnection:completedWithData:
//============================================================================
- (void)httpConnection: (S4HttpConnection *)connection completedWithData: (NSMutableData *)data
{
	[self performSelectorOnMainThread: @selector(parseEnded) withObject: data waitUntilDone: NO];
}

@end
