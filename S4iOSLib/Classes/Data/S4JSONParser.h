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
 * Name:		S4JSONParser.h
 * Module:		Data
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#include "yajl_parse.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================

typedef enum
{
	S4JSONParserErrorCodeAllocError			= 1,
	S4JSONParserErrorCodeDoubleOverflow		= 2,
	S4JSONParserErrorCodeIntegerOverflow	= 3
} S4JSONParserErrorCode;


typedef enum
{
	S4JSONParserOptionsNone				= 0,
	S4JSONParserOptionsAllowComments	= 1 << 0,
	S4JSONParserOptionsCheckUTF8		= 1 << 1,
	S4JSONParserOptionsStrictPrecision	= 1 << 2,
} S4JSONParserOptions;


typedef enum
{
	S4JSONParserStatusNone		= 0,
	S4JSONParserStatusOK		= 1,
	S4JSONParserStatusBadData	= 2,
	S4JSONParserStatusError		= 3
} S4JSONParserStatus;


// =================================== Globals =========================================

extern NSString *const S4JSONParserErrorDomain;
extern NSString *const S4JSONParserException;
extern NSString *const S4JSONParserValueKey;


// ============================= Forward Declarations ==================================

@class S4JSONParser;


// ================================== Protocols ========================================

@protocol S4JSONParserDelegate <NSObject>

@optional
- (void)parserDidStartDictionary: (S4JSONParser *)parser;
- (void)parserDidEndDictionary: (S4JSONParser *)parser;
- (void)parserDidStartArray: (S4JSONParser *)parser;
- (void)parserDidEndArray: (S4JSONParser *)parser;
- (void)parser: (S4JSONParser *)parser didMapKey: (NSString *)key;
- (void)parser: (S4JSONParser *)parser didAdd: (id)value;

@end


// ============================== Class S4JSONParser ====================================

@interface S4JSONParser : NSObject
{
	yajl_handle											handle_;
	__weak id <S4JSONParserDelegate>					delegate_;
	S4JSONParserOptions									parserOptions_;
	NSError												*parserError_;
}

@property (nonatomic, assign) __weak											id <S4JSONParserDelegate> delegate;
@property (nonatomic, retain, readonly) NSError									*parserError;
@property (nonatomic, readonly) S4JSONParserOptions								parserOptions;

- (id)initWithParserOptions: (S4JSONParserOptions)parserOptions;
- (S4JSONParserStatus)parse: (NSData *)data;
- (S4JSONParserStatus)parseCompleted;

@end
