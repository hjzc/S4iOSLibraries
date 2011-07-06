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
 * Name:		S4YajlJSONFile.m
 * Module:		Data
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4YajlJSONFile.h"
#import "S4NetUtilities.h"
#import "S4FileUtilities.h"
#import "S4NetworkAccess.h"
#import "S4OperationsHandler.h"


// =================================== Defines =========================================

#define MAX_READ_BYTES							(NSUInteger)32768
#define MAX_READ_BUFFER_SZ						sizeof(uint8_t) * MAX_READ_BYTES					


// ================================== Typedefs =========================================



// =================================== Globals =========================================

NSInteger										S4JSONFileStackCapacity = 20;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ==================== Begin Class S4YajlJSONFile (PrivateImpl) =======================

@interface S4YajlJSONFile (PrivateImpl)

- (BOOL)setUpParse;
- (void)cleanUpParse;
- (void)downloadAndParseForUrl: (NSString *)urlStr;
- (void)readAndParseAtFilePath: (NSString *)filePathStr;
- (BOOL)parseData: (NSData *)data;
- (BOOL)startParsingPath: (NSString *)pathStr
			withDelegate: (id <S4JSONFileDelegate>)delegate
			 forSelector: (SEL)parsingSelector;
- (void)parseStarted;
- (void)parseError: (NSError *)error;
- (void)parseEnded;
- (void)popJsonStack;
- (void)popJsonKeyStack;

@end



@implementation S4YajlJSONFile (PrivateImpl)

//============================================================================
//	S4YajlJSONFile (PrivateImpl) :: setUpParse
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
//	S4YajlJSONFile (PrivateImpl) :: cleanUpParse
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
//	S4YajlJSONFile (PrivateImpl) :: downloadAndParseForUrl:
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
											handleCookies: YES];
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
					if ([m_S4HttpConnection openNonCachingConnectionForRequest: request delegate: self])
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
//	S4YajlJSONFile (PrivateImpl) :: readAndParseAtFilePath:
//============================================================================
- (void)readAndParseAtFilePath: (NSString *)filePathStr
{
	NSInputStream						*inputStream;
	uint8_t								*readBufferPtr;
	NSInteger							bytesRead;
	NSData								*jsonData;

	if (YES == [self setUpParse])
	{
		// read the JSON data from the file
		inputStream = [NSInputStream inputStreamWithFileAtPath: filePathStr];
		if (IS_NOT_NULL(inputStream))
		{
			readBufferPtr = malloc(MAX_READ_BUFFER_SZ);
			if (NULL != readBufferPtr)
			{
				// tell the UI that parsing has begun (show a spinner, etc.)
				[self performSelectorOnMainThread: @selector(parseStarted) withObject: nil waitUntilDone: NO];
				
				// read from stream
				[inputStream open];
				while ((YES == [inputStream hasBytesAvailable]) && (NO == m_bDoneParsing))
				{
					bytesRead = [inputStream read: readBufferPtr maxLength: MAX_READ_BYTES];
					if (bytesRead > 0)
					{
						jsonData = [[NSData alloc] initWithBytesNoCopy: (void *)readBufferPtr
																length: (NSUInteger)bytesRead
														  freeWhenDone: NO];
						if (IS_NOT_NULL(jsonData))
						{
							// Process the block of data
							[self parseData: jsonData];
							[jsonData autorelease];
						}
						else
						{
							
						}
					}
				}

				// close the stream
				[inputStream close];

				// pass the parsed JSON back to the delegate
				[self performSelectorOnMainThread: @selector(parseEnded) withObject: nil waitUntilDone: NO];

				// free the buffer
				free(readBufferPtr);
			}
		}
	}
	// Release resources used only in this thread
	m_bDoneParsing = YES;
	[self cleanUpParse];
}


//============================================================================
//	S4YajlJSONFile (PrivateImpl) :: parseData:
//============================================================================
- (BOOL)parseData: (NSData *)data
{
	S4JSONParserError					parseError;
	NSError								*localError;
	BOOL								bResult = NO;

	parseError = [m_parser parse: data];
	if (S4JSONParserNoError == parseError)
	{
		bResult = YES;
	}
	else
	{
		localError = [self errorforCode: parseError description: nil reason: nil];
		if (IS_NOT_NULL(localError))
		{
			[self performSelectorOnMainThread: @selector(parseError:) withObject: localError waitUntilDone: NO];
		}
	}
	return (bResult);
}


//============================================================================
//	S4YajlJSONFile (PrivateImpl) :: startParsingPath:
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
//	S4YajlJSONFile (PrivateImpl) :: popJsonStack
//============================================================================
- (void)popJsonStack
{
	[m_stack removeLastObject];
	m_array = nil;
	m_dict = nil;
	m_curClassType = kInvalidJSONClass;

	id value = nil;
	if ([m_stack count] > 0)
	{
		value = [m_stack objectAtIndex: ([m_stack count] - 1)];
	}

	if ([value isKindOfClass: [NSArray class]])
	{    
		m_array = (NSMutableArray *)value;
		m_curClassType = kNSArrayJSONClass;
	}
	else if ([value isKindOfClass: [NSDictionary class]])
	{    
		m_dict = (NSMutableDictionary *)value;
		m_curClassType = kNSDictionaryJSONClass;
	}
}


//============================================================================
//	S4YajlJSONFile (PrivateImpl) :: popJsonKeyStack
//============================================================================
- (void)popJsonKeyStack
{
	m_key = nil;
	[m_keyStack removeLastObject];
	if ([m_keyStack count] > 0) 
	{
		m_key = [m_keyStack objectAtIndex: ([m_keyStack count] - 1)];
	}
}



/********************************************* Methods performed on the Main Thread  *********************************************/

//============================================================================
//	S4YajlJSONFile (PrivateImpl) :: parseStarted
//============================================================================
- (void)parseStarted
{
	[m_delegate jsonFileDidBeginParsingData: self];
}


//============================================================================
//	S4YajlJSONFile (PrivateImpl) :: parseError:
//============================================================================
- (void)parseError: (NSError *)error
{
	[m_delegate jsonFile: self didFailWithError: error];
	[self cancel];
}


//============================================================================
//	S4YajlJSONFile (PrivateImpl) :: parseEnded
//		This is called explicitly by the read file parser code
//		and implicitly by the S4HttpConnection's completion
//		delegate method
//============================================================================
- (void)parseEnded
{
	S4JSONParserError						parseError;
	S4JSONClassType							jsonObjectType;
	NSError									*error = nil;

	parseError = [m_parser parseCompleted];
	if ((S4JSONParserNoError == parseError) && (IS_NOT_NULL(m_rootJSONObject)))
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
	else	// could not create a JSON parser
	{
		error = [self errorforCode: S4JSONParserParsingError description: nil reason: nil];
	}

	if (IS_NOT_NULL(error))
	{
		[self parseError: error];
	}
}

@end




// ============================ Begin Class S4YajlJSONFile =============================

@implementation S4YajlJSONFile


//============================================================================
//	S4YajlJSONFile :: properties
//============================================================================
// public

// private



//============================================================================
//	S4YajlJSONFile :: jsonFile
//============================================================================
+ (id)jsonFile
{
	return ([[[[self class] alloc] init] autorelease]);
}


//============================================================================
//	S4YajlJSONFile :: init
//============================================================================
- (id)init
{
	return ([self initWithParserOptions: S4JSONParserOptionsAllowComments]);
}


//============================================================================
//	S4YajlJSONFile :: initWithParserOptions:
//============================================================================
- (id)initWithParserOptions: (S4JSONParserOptions)parserOptions
{
	self = [super initWithParserOptions: parserOptions];
	if (nil != self)
	{
		// private member vars
		m_parser = [[S4JSONParser alloc] initWithParserOptions: parserOptions];
		m_parser.delegate = self;
		m_dict = nil;
		m_array = nil;
		m_key = nil;
		m_stack = [[NSMutableArray alloc] initWithCapacity: S4JSONFileStackCapacity];
		m_keyStack = [[NSMutableArray alloc] initWithCapacity: S4JSONFileStackCapacity];  
		m_curClassType = kInvalidJSONClass;
		m_S4HttpConnection = nil;
		m_requestTimeout = 0.0;
		m_bUseCache = NO;
	}
	return (self);
}


//============================================================================
//	S4YajlJSONFile :: dealloc
//============================================================================
- (void)dealloc
{
	if (IS_NOT_NULL(m_stack))
	{
		[m_stack release];
		m_stack = nil;
	}

	if (IS_NOT_NULL(m_keyStack))
	{
		[m_keyStack release];
		m_keyStack = nil;
	}

	if (IS_NOT_NULL(m_parser))
	{
		m_parser.delegate = nil;
		[m_parser release];
		m_parser = nil;
	}

	if (IS_NOT_NULL(m_S4HttpConnection))
	{
		[m_S4HttpConnection release];
		m_S4HttpConnection = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4YajlJSONFile :: parse:
//============================================================================
- (S4JSONParserError)parse: (NSData *)data error: (NSError **)error
{
	S4JSONParserError					parseError;
	NSError								*localError;

	parseError = [m_parser parse: data];
	localError = [self errorforCode: parseError description: nil reason: nil];
	if (nil != error)
	{
		*error = localError;
	}
	return (parseError);
}


//============================================================================
//	S4YajlJSONFile :: parseCompleted
//============================================================================
- (S4JSONParserError)parseCompleted
{
	S4JSONParserError				parseError;

	parseError = [m_parser parseCompleted];
	(void)[self errorforCode: parseError description: nil reason: nil];
	return (parseError);
}


//============================================================================
//	S4YajlJSONFile :: requestJSONfromURLStr:
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
//	S4YajlJSONFile :: parseJSONfromFilePath:
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
//	S4YajlJSONFile :: cancel
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



// ====================================== S4JSONParser delegate methods ==========================================

//============================================================================
//	S4YajlJSONFile :: parser:didAdd:
//============================================================================
- (void)parser: (S4JSONParser *)parser didAdd: (id)value
{
	switch(m_curClassType)
	{
		case kUnknownJSONClass:
		case kInvalidJSONClass:
		{
			break;
		}

		case kNSArrayJSONClass:
		{
			[m_array addObject: value];
			break;
		}

		case kNSDictionaryJSONClass:
		{
			NSParameterAssert(m_key);
			[m_dict setObject: value forKey: m_key];
			[self popJsonKeyStack];
			break;
		} 

		default:
			break;
	} 
}


//============================================================================
//	S4YajlJSONFile :: parser:didMapKey:
//============================================================================
- (void)parser: (S4JSONParser *)parser didMapKey: (NSString *)key
{
	m_key = key;
	[m_keyStack addObject: m_key];
}


//============================================================================
//	S4YajlJSONFile :: parserDidStartDictionary:
//============================================================================
- (void)parserDidStartDictionary: (S4JSONParser *)parser
{
	NSMutableDictionary				*dict;

	dict = [[NSMutableDictionary alloc] initWithCapacity: S4JSONFileStackCapacity];
	if (IS_NULL(m_rootJSONObject))
	{
		m_rootJSONObject = [dict retain];
	}
	[m_stack addObject: dict];
	[dict release];
	m_dict = dict;
	m_curClassType = kNSDictionaryJSONClass;  
}


//============================================================================
//	S4YajlJSONFile :: parserDidEndDictionary:
//============================================================================
- (void)parserDidEndDictionary: (S4JSONParser *)parser
{
	id value = [[m_stack objectAtIndex: ([m_stack count] - 1)] retain];
	[self popJsonStack];
	[self parser: parser didAdd: value];
	[value release];
}


//============================================================================
//	S4YajlJSONFile :: parserDidStartArray:
//============================================================================
- (void)parserDidStartArray: (S4JSONParser *)parser
{
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity: S4JSONFileStackCapacity];
	if (IS_NULL(m_rootJSONObject))
	{
		m_rootJSONObject = [array retain];
	}
	[m_stack addObject: array];
	[array release];
	m_array = array;
	m_curClassType = kNSArrayJSONClass;
}


//============================================================================
//	S4YajlJSONFile :: parserDidEndArray:
//============================================================================
- (void)parserDidEndArray: (S4JSONParser *)parser
{
	id value = [[m_stack objectAtIndex: ([m_stack count] - 1)] retain];
	[self popJsonStack];  
	[self parser: parser didAdd: value];
	[value release];
}



// ================================== S4HttpConnection delegate methods ==========================================

//============================================================================
//	S4YajlJSONFile :: httpConnection:receivedData:
//============================================================================
- (BOOL)httpConnection: (S4HttpConnection *)connection receivedData: (NSData *)data
{
	return ([self parseData: data]);
}


//============================================================================
//	S4YajlJSONFile :: httpConnection:failedWithError:
//============================================================================
- (void)httpConnection: (S4HttpConnection *)connection failedWithError: (NSError *)error
{
	[self performSelectorOnMainThread: @selector(parseError:) withObject: error waitUntilDone: NO];
}


//============================================================================
//	S4YajlJSONFile :: httpConnection:completedWithData:
//============================================================================
- (void)httpConnection: (S4HttpConnection *)connection completedWithData: (NSMutableData *)data
{
	[self performSelectorOnMainThread: @selector(parseEnded) withObject: nil waitUntilDone: NO];
}

@end
