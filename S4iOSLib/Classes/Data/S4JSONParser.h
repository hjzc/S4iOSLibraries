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
#import "S4CommonDefines.h"
#import "S4JSONCommon.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================

S4_EXTERN_CONSTANT_NSSTR				S4JSONParserErrorDomain;
S4_EXTERN_CONSTANT_NSSTR				S4JSONParserException;
S4_EXTERN_CONSTANT_NSSTR				S4JSONParserValueKey;


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
	void													*m_yajl_handle;
	__weak id <S4JSONParserDelegate>						m_delegate;
	S4JSONParserOptions										m_parserOptions;
	NSError													*m_parserError;
}

@property (nonatomic, assign) __weak											id <S4JSONParserDelegate> delegate;
@property (nonatomic, retain, readonly) NSError									*parserError;
@property (nonatomic, readonly) S4JSONParserOptions								parserOptions;

- (id)initWithParserOptions: (S4JSONParserOptions)parserOptions;
- (S4JSONParserError)parse: (NSData *)data;
- (S4JSONParserError)parseCompleted;

@end
