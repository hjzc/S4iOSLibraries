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



// ============================== Begin Class S4JSONFile ===============================

@implementation S4JSONFile


//============================================================================
//	S4JSONFile :: properties
//============================================================================
// public
@synthesize reachableHostStr = m_reachableHostStr;
@synthesize operationQueue = m_operationQueue;
@synthesize document = m_rootJSONObject;
@synthesize parserStatus = m_parserStatus;

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
		m_parserStatus = S4JSONParserStatusNone;
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
- (S4JSONParserStatus)parse: (NSData *)data error: (NSError **)error
{
	return (S4JSONParserStatusError);
}


//============================================================================
//	S4JSONFile :: parseCompleted
//============================================================================
- (S4JSONParserStatus)parseCompleted
{
	return (S4JSONParserStatusError);
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

@end
