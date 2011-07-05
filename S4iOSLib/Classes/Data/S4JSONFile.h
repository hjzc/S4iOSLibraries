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
 * Name:		S4JSONFile.h
 * Module:		Data
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import "S4CommonDefines.h"
#import "S4JSONCommon.h"


// =================================== Defines =========================================

#define DEFAULT_JSON_TIMEOUT			(NSTimeInterval)300.0


// ================================== Typedefs =========================================



// =================================== Globals =========================================

S4_EXTERN_CONSTANT_NSSTR				S4JSONFileErrorDomain;
S4_EXTERN_CONSTANT_NSSTR				kDefaultJSONFileHostStr;


// ============================= Forward Declarations ==================================

@class S4JSONFile;


// ================================== Protocols ========================================

@protocol S4JSONFileDelegate <NSObject>

@required
// Called by the parser when parsing has begun.
- (void)jsonFileDidBeginParsingData: (S4JSONFile *)file;

// Called by the retriever in the case of an error.
- (void)jsonFile: (S4JSONFile *)file didFailWithError: (NSError *)error;

// Called by the retriever when all the JSON has been parsed.
- (void)jsonFile: (S4JSONFile *)file didEndParsingJSON: (id)jsonObject ofType: (S4JSONClassType)type;

@end


// ================================ Class S4JSONFile ===================================

@interface S4JSONFile : NSObject
{
@protected
	id													m_rootJSONObject;
	NSError												*m_lastError;
	id <S4JSONFileDelegate>								m_delegate;
    NSString											*m_reachableHostStr;
	NSOperationQueue									*m_operationQueue;
    NSAutoreleasePool									*m_parsingAutoreleasePool;
    BOOL												m_bDoneParsing;
}

// Properties
@property (nonatomic, retain) NSString						*reachableHostStr;
@property (nonatomic, retain) NSOperationQueue				*operationQueue;
@property (nonatomic, readonly) id							document;
@property (nonatomic, readonly) NSError						*lastError;

// Class methods
+ (id)jsonFile;

// Instance methods
- (id)initWithParserOptions: (S4JSONParserOptions)parserOptions;

- (S4JSONParserError)parse: (NSData *)data error: (NSError **)error;

- (S4JSONParserError)parseCompleted;

- (BOOL)requestJSONfromURLStr: (NSString *)urlStr
				  forDelegate: (id <S4JSONFileDelegate>)delegate
					  timeout: (NSTimeInterval)requestTimeout
				  useWebCache: (BOOL)bUseCache;

- (BOOL)parseJSONfromFilePath: (NSString *)pathStr forDelegate: (id <S4JSONFileDelegate>)delegate;

- (void)cancel;

// protected method (of sorts)
- (NSError *)errorforCode: (S4JSONParserError)code description: (NSString *)descStr reason: (NSString *)failStr;

@end
