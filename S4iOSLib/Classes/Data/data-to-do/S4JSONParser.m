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
 * Name:		S4JSONParser.m
 * Module:		Data
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <UIKit/UIKit.h>
#import "S4JSONParser.h"
#import "S4NetUtilities.h"
#import "S4FileUtilities.h"
#import "S4NetworkAccess.h"
#import "S4CommonDefines.h"
#import "S4OverlayViewController.h"
#import "S4OperationsHandler.h"
#import "JSON.h"


// =================================== Defines =========================================

#define DEFAULT_STRING_SZ						32
#define GENERIC_REACHABILITY_URL				@"www.yahoo.com"
#define DEFAULT_DICTIONARY_SZ					(NSUInteger)16

#define MAX_READ_BYTES							(NSUInteger)32768
#define MAX_READ_BUFFER_SZ						sizeof(uint8_t) * MAX_READ_BYTES

// ALL S4 LIBS SHOULD DEFINE THIS:
#define LIB_DOMAIN_NAME_STR						@"S4JSONParser"


// ================================== Typedefs =========================================



// =================================== Globals =========================================

static NSString									*kGenericErrorStr = @"JSON Parse failed";


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ============================ Begin Class S4JSONParser () ==============================

@interface S4JSONParser ()

@property (nonatomic, retain) NSString								*m_reachableHostStr;

@end



// ======================= Begin Class S4JSONParser (PrivateImpl) ========================

@interface S4JSONParser (PrivateImpl)

- (void)downloadAndParseWithObject: (id)object forUrl: (NSString *)urlStr;
- (void)readFileAndParseWithObject: (id)object forFilePath: (NSString *)filePathStr;
- (BOOL)startParsingPath: (NSString *)pathStr withObject: (id)object forSelector: (SEL)parsingSelector;
- (void)downloadStarted;
- (void)downloadEnded;
- (void)parsedNewDictionary: (NSDictionary *)newDictionary;
- (void)parseError: (NSError *)error;
- (void)parseEnded;

@end



@implementation S4JSONParser (PrivateImpl)

//============================================================================
//	S4JSONParser (PrivateImpl) :: downloadAndParseWithObject:
//============================================================================
- (void)downloadAndParseWithObject: (id)object forUrl: (NSString *)urlStr
{
	NSAutoreleasePool				*parsingAutoreleasePool;
	BOOL							bFailed = YES;
	NSURL							*url;
	NSStringEncoding				strEncoding;
	NSError							*error = nil;
	NSString						*rawString;
	SBJSON							*jsonParser;
	id								idResult;

	// create an autorelease pool to deal with temporary alloations
	parsingAutoreleasePool = [[NSAutoreleasePool alloc] init];

	// clear out the system internet cache
	[[NSURLCache sharedURLCache] removeAllCachedResponses];

	// create a properly escaped NSURL from the string params
	url = [S4NetUtilities createNSUrlForPathStr: urlStr baseStr: nil];
	if (IS_NOT_NULL(url))
	{
		// tell the UI to show the network spinner going
		[self performSelectorOnMainThread: @selector(downloadStarted) withObject: nil waitUntilDone: NO];

		rawString = [NSString stringWithContentsOfURL: url usedEncoding: &strEncoding error: &error];
		if ((nil == error) && (STR_NOT_EMPTY(rawString)))
		{
			jsonParser = [[SBJSON alloc] init];
			if IS_NOT_NULL(jsonParser)
			{
				idResult = [jsonParser objectWithString: rawString error: &error];
				[jsonParser release];
				if ((nil == error) && (IS_NOT_NULL(idResult)))
				{
					if ([idResult isKindOfClass: [NSArray class]])
					{
						[self performSelectorOnMainThread: @selector(parsedNewArray:) withObject: (NSArray *)idResult waitUntilDone: NO];
					}
					else if ([idResult isKindOfClass: [NSDictionary class]])
					{
						[self performSelectorOnMainThread: @selector(parsedNewDictionary:) withObject: (NSDictionary *)idResult waitUntilDone: NO];
					}
					bFailed = NO;
				}
			}
		}
		[url release];

		// tell the UI to hide the network spinner
		[self performSelectorOnMainThread: @selector(downloadEnded) withObject: nil waitUntilDone: NO];
	}

	if (YES == bFailed)
	{
		[self performSelectorOnMainThread: @selector(parseError:) withObject: error waitUntilDone: NO];
	}

	// Release resources used only in this thread
	[parsingAutoreleasePool release];
	parsingAutoreleasePool = nil;
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: readFileAndParseWithObject:
//============================================================================
- (void)readFileAndParseWithObject: (id)object forFilePath: (NSString *)filePathStr
{
	NSAutoreleasePool				*parsingAutoreleasePool;
	BOOL							bFailed = YES;
	NSStringEncoding				strEncoding;
	NSError							*error = nil;
	NSString						*rawString;
	SBJSON							*jsonParser;
	id								idResult;

	
	// create an autorelease pool to deal with temporary alloations
	parsingAutoreleasePool = [[NSAutoreleasePool alloc] init];

	// tell the UI to show the network spinner going
	[self performSelectorOnMainThread: @selector(downloadStarted) withObject: nil waitUntilDone: NO];

	rawString = [NSString stringWithContentsOfFile: filePathStr usedEncoding: &strEncoding error: &error];
	if ((nil == error) && (STR_NOT_EMPTY(rawString)))
	{
		jsonParser = [[SBJSON alloc] init];
		if IS_NOT_NULL(jsonParser)
		{
			idResult = [jsonParser objectWithString: rawString error: &error];
			[jsonParser release];
			if ((nil == error) && (IS_NOT_NULL(idResult)))
			{
				if ([idResult isKindOfClass: [NSArray class]])
				{
					[self performSelectorOnMainThread: @selector(parsedNewArray:) withObject: (NSArray *)idResult waitUntilDone: NO];
				}
				else if ([idResult isKindOfClass: [NSDictionary class]])
				{
					[self performSelectorOnMainThread: @selector(parsedNewDictionary:) withObject: (NSDictionary *)idResult waitUntilDone: NO];
				}
				bFailed = NO;
			}
		}

		// tell the UI to hide the network spinner
		[self performSelectorOnMainThread: @selector(downloadEnded) withObject: nil waitUntilDone: NO];
	}
	
	if (YES == bFailed)
	{
		[self performSelectorOnMainThread: @selector(parseError:) withObject: error waitUntilDone: NO];
	}
	
	// Release resources used only in this thread
	[parsingAutoreleasePool release];
	parsingAutoreleasePool = nil;


				// pass the completed NSMutableArray of coffee vendors back to the delegate
				[self performSelectorOnMainThread: @selector(parseEnded) withObject: nil waitUntilDone: NO];
}


//============================================================================
//	S4JSONParser :: startParsingPath:
//============================================================================
- (BOOL)startParsingPath: (NSString *)pathStr withObject: (id)object forSelector: (SEL)parsingSelector
{
	id									localObject;
	S4OperationsHandler					*s4OpsHandler;
	NSMutableArray						*argArray;
	BOOL								bResult = NO;

	// set the local var for the object
	if (nil == object)
	{
		localObject = [NSNull null];
	}
	else
	{
		localObject = object;
	}

	// create an S4OperationsHandler instance to spin a new thread for the parse operation
	s4OpsHandler = [S4OperationsHandler handlerWithOperationQueue: nil];
	if IS_NOT_NULL(s4OpsHandler)
	{
		argArray = [NSMutableArray arrayWithCapacity: (NSUInteger)2];
		if IS_NOT_NULL(argArray)
		{
			[argArray addObject: localObject];
			[argArray addObject: pathStr];

			bResult = [s4OpsHandler addSelectorToQueue: parsingSelector
											  onTarget: self
										 withArguments: argArray];
		}
	}
	return (bResult);
}




/********************************************* Methods performed on the Main Thread  *********************************************/

//============================================================================
//	S4JSONParser (PrivateImpl) :: downloadStarted
//============================================================================
- (void)downloadStarted
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[[S4OverlayViewController getInstance] show];
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: downloadEnded
//============================================================================
- (void)downloadEnded
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	// hide the "Loading..." spinner window
	[[S4OverlayViewController getInstance] hide];
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: parsedNewDictionary:
//============================================================================
- (void)parsedNewDictionary: (NSDictionary *)newDictionary
{
	if ((IS_NOT_NULL(self.delegate)) && ([self.delegate respondsToSelector: @selector(parser:addParsedDictionary:)]))
	{
		[self.delegate parser: self addParsedDictionary: newDictionary];
	}
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: parseError:
//============================================================================
- (void)parseError: (NSError *)error
{
	NSError							*retError;
	NSDictionary					*userInfoDict;

	retError = error;
	if (nil == retError)
	{
		userInfoDict = [NSDictionary dictionaryWithObject: kGenericErrorStr forKey: NSLocalizedDescriptionKey];
		if (IS_NOT_NULL(userInfoDict))
		{
			retError = [NSError errorWithDomain: LIB_DOMAIN_NAME_STR code: (NSInteger)1 userInfo: userInfoDict];
		}
	}
	
	if ((IS_NOT_NULL(self.delegate)) &&
		([self.delegate respondsToSelector: @selector(parser:didFailWithError:)]) &&
		(IS_NOT_NULL(retError)))
	{
		[self.delegate parser: self didFailWithError: retError];
	}
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: parseEnded
//		This is called explicitly by the read file parser code
//		and implicitly by the S4HttpConnection's completion
//		delegate method
//============================================================================
- (void)parseEnded
{

	if ((IS_NOT_NULL(self.delegate)) && ([self.delegate respondsToSelector:@selector(parserDidEndParsingData:)]))
	{
		[self.delegate parserDidEndParsingData: self];
	}
}

@end




// ========================= Begin Class S4JSONParser ========================

@implementation S4JSONParser


//============================================================================
//	S4JSONParser :: properties
//============================================================================
// public
@synthesize delegate = m_delegate;

// private
@synthesize m_reachableHostStr;


//============================================================================
//	S4JSONParser :: parser
//============================================================================
+ (id)parser
{
	return ([[[[self class] alloc] init] autorelease]);
}


//============================================================================
//	S4JSONParser :: init
//============================================================================
- (id)init
{
	if (self = [super init])
	{
		// public member vars
		self.delegate = nil;
		
		// private member vars
		self.m_reachableHostStr = GENERIC_REACHABILITY_URL;
	}
	return (self);
}


//============================================================================
//	S4JSONParser :: dealloc
//============================================================================
- (void)dealloc
{
	self.delegate = nil;

	[super dealloc];
}


//============================================================================
//	S4JSONParser :: startParsingFromUrlPath:
//============================================================================
- (BOOL)startParsingFromUrlPath: (NSString *)pathStr withObject: (id)object
{
	S4NetworkAccess						*networkAccess;
	BOOL								bResult = NO;

	if STR_NOT_EMPTY(pathStr)
	{
		networkAccess = [S4NetworkAccess networkAccessWithHostName: self.m_reachableHostStr];
		if ((IS_NOT_NULL(networkAccess)) && (NetworkNotReachable != [networkAccess currentReachabilityStatus]))
		{
			// start the parse
			bResult = [self startParsingPath: pathStr
								  withObject: object
								 forSelector: @selector(downloadAndParseWithObject:forUrl:)];
		}
	}
	return (bResult);
}


//============================================================================
//	S4JSONParser :: startParsingFromFilePath:
//============================================================================
- (BOOL)startParsingFromFilePath: (NSString *)pathStr withObject: (id)object
{
	BOOL								bResult = NO;
	
	if STR_NOT_EMPTY(pathStr)
	{
		if (YES == [S4FileUtilities fileExists: pathStr])
		{
			// start the parse
			bResult = [self startParsingPath: pathStr
								  withObject: object
								 forSelector: @selector(readFileAndParseWithObject:forFilePath:)];
		}
	}
	return (bResult);
}


//============================================================================
//	S4JSONParser :: setReachabilityHostName:
//============================================================================
- (void)setReachabilityHostName: (NSString *)hostName
{
	if (STR_NOT_EMPTY(hostName))
	{
		self.m_reachableHostStr = hostName;
	}
}

@end
