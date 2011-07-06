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
 * Name:		S4JSONFile.m
 * Module:		Data
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4JSONFile.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================

S4_INTERN_CONSTANT_NSSTR						kDefaultJSONFileHostStr = @"www.yahoo.com";

// ALL S4 LIBS SHOULD DEFINE THIS:
S4_INTERN_CONSTANT_NSSTR						S4JSONFileErrorDomain = @"S4JSONFileErrorDomain";


// =================================== Globals =========================================

// static class variables
// the NSOperationsQueue for all S4JSONFile instances (if none is provided)
static NSOperationQueue							*g_classOperationQueue;
static BOOL										g_bInitialized = NO;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =========================== Begin Class S4JSONFile () ===============================

@interface S4JSONFile ()

@property (nonatomic, copy, readwrite) NSError					*lastError;

@end



// ============================== Begin Class S4JSONFile ===============================

@implementation S4JSONFile


//============================================================================
//	S4JSONFile :: properties
//============================================================================
// public
@synthesize reachableHostStr = m_reachableHostStr;
@synthesize operationQueue = m_operationQueue;
@synthesize document = m_rootJSONObject;
@synthesize lastError = m_lastError;

// private


//============================================================================
//	S4JSONFile :: initialize
//============================================================================
+ (void)initialize
{
	if ((NO == g_bInitialized) && ([self class] == [S4JSONFile class]))
	{
		g_classOperationQueue = [[NSOperationQueue alloc] init];
		[g_classOperationQueue setMaxConcurrentOperationCount: NSOperationQueueDefaultMaxConcurrentOperationCount];

		g_bInitialized = YES;
	}
}


//============================================================================
//	S4JSONFile :: jsonFile
//============================================================================
+ (id)jsonFile
{
	return ([[[[self class] alloc] init] autorelease]);
}


//============================================================================
//	S4JSONFile :: init
//============================================================================
- (id)init
{
	return ([self initWithParserOptions: S4JSONParserOptionsAllowComments]);
}


//============================================================================
//	S4JSONFile :: initWithParserOptions:
//============================================================================
- (id)initWithParserOptions: (S4JSONParserOptions)parserOptions
{
	self = [super init];
	if (nil != self)
	{
		// protected member vars
		m_rootJSONObject = nil;
		m_lastError = nil;
		m_delegate = nil;
		m_reachableHostStr = [kDefaultJSONFileHostStr retain];
		m_operationQueue = g_classOperationQueue;
		m_parsingAutoreleasePool = nil;
		m_bDoneParsing = YES;
	}
	return (self);
}


//============================================================================
//	S4JSONFile :: dealloc
//============================================================================
- (void)dealloc
{
	if (IS_NOT_NULL(m_rootJSONObject))
	{
		[m_rootJSONObject release];
		m_rootJSONObject = nil;
	}

	if IS_NOT_NULL(m_delegate)
	{
		[m_delegate release];
		m_delegate = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4JSONFile :: parse:
//============================================================================
- (S4JSONParserError)parse: (NSData *)data error: (NSError **)error
{
	return (S4JSONParserUnimplementedError);
}


//============================================================================
//	S4JSONFile :: parseCompleted
//============================================================================
- (S4JSONParserError)parseCompleted
{
	return (S4JSONParserUnimplementedError);
}


//============================================================================
//	S4JSONFile :: startParsingFromUrlPath:
//============================================================================
- (BOOL)requestJSONfromURLStr: (NSString *)urlStr
				  forDelegate: (id <S4JSONFileDelegate>)delegate
					  timeout: (NSTimeInterval)requestTimeout
				  useWebCache: (BOOL)bUseCache
{
	return (NO);
}


//============================================================================
//	S4JSONFile :: startParsingFromFilePath:
//============================================================================
- (BOOL)parseJSONfromFilePath: (NSString *)pathStr forDelegate: (id <S4JSONFileDelegate>)delegate;
{
	return (NO);
}


//============================================================================
//	S4JSONFile :: cancel
//============================================================================
- (void)cancel
{
}


//============================================================================
//	S4JSONFile :: errorforCode:
//============================================================================
- (NSError *)errorforCode: (S4JSONParserError)code description: (NSString *)descStr reason: (NSString *)failStr
{
	NSMutableDictionary						*userDict = nil;
	NSString								*localizedDescription;
	NSString								*localizedFailureReason;
	NSError									*error;

	if (S4JSONParserNoError == code)				// if no error, set values to nil
	{
		error = nil;
	}
	else											// there was an error
	{
		// create an NSDictionary to hold values for the NSError
		userDict = [NSMutableDictionary dictionaryWithCapacity: 2];
		if (IS_NOT_NULL(userDict))
		{
			if (STR_NOT_EMPTY(descStr))
			{
				localizedDescription = descStr;
			}
			else
			{
				if (S4JSONParserParsingError == code)
				{
					localizedDescription = @"JSON parsing error";
				}
				else if (S4JSONParserInvalidDataError == code)
				{
					localizedDescription = @"JSON data error";
				}
				else if (S4JSONParserAllocationError == code)
				{
					localizedDescription = @"Allocation error";
				}
				else if (S4JSONParserDoubleOverflowError == code)
				{
					localizedDescription = @"Double overflow error";
				}
				else if (S4JSONParserIntegerOverflowError == code)
				{
					localizedDescription = @"Integer overflow error";
				}
				else if (S4JSONParserCanceledError == code)
				{
					localizedDescription = @"Operation canceled error";
				}
				else
				{
					localizedDescription = @"Unknown error";
				}
			}
			

			if (STR_NOT_EMPTY(failStr))
			{
				localizedFailureReason = failStr;
			}
			else
			{
				if (S4JSONParserParsingError == code)
				{
					localizedFailureReason = @"The JSON parser could not parse the data";
				}
				else if (S4JSONParserInvalidDataError == code)
				{
					localizedFailureReason = @"The JSON could not be found or was malformed";
				}
				else if (S4JSONParserAllocationError == code)
				{
					localizedFailureReason = @"The application is out of memory";
				}
				else if (S4JSONParserDoubleOverflowError == code)
				{
					localizedFailureReason = @"A (double) number being evaluated was larger than allowed by the parser";
				}
				else if (S4JSONParserIntegerOverflowError == code)
				{
					localizedFailureReason = @"A (integer) number being evaluated was larger than allowed by the parser";
				}
				else if (S4JSONParserCanceledError == code)
				{
					localizedFailureReason = @"The current parsing operation was canceled due to previous failures";
				}
				else
				{
					localizedFailureReason = @"An unknown error was encountered by the parser";
				}
			}

			// set the keys in the error dictionary
			[userDict setObject: localizedDescription forKey: NSLocalizedDescriptionKey];
			[userDict setObject: localizedFailureReason forKey: NSLocalizedFailureReasonErrorKey];
		}

		// create the NSError
		error = [[NSError alloc] initWithDomain: S4JSONFileErrorDomain code: (NSInteger)code userInfo: userDict];
	}

	// and set the instance var
	self.lastError = error;
	return (error);
}

@end
