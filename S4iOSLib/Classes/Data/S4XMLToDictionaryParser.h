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
 * Name:		S4XMLToDictionaryParser.h
 * Module:		Data
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "S4HttpConnection.h"
#import <libxml/tree.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================

@class S4XMLToDictionaryParser;


// ================================== Protocols ========================================

@protocol S4XmlDictParserDelegate <NSObject>

@required
// Called by the parser when parsing has begun.
- (void)parserDidBeginParsingData: (S4XMLToDictionaryParser *)parser;

// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData: (S4XMLToDictionaryParser *)parser;

// Called by the parser in the case of an error.
- (void)parser: (S4XMLToDictionaryParser *)parser didFailWithError: (NSError *)error;

// Called by the parser when one or more objects have been parsed. This method may be called multiple times.
- (void)parser: (S4XMLToDictionaryParser *)parser addParsedDictionary: (NSDictionary *)parsedDictionary;

@end


// ========================= Class S4XMLToDictionaryParser =============================

@interface S4XMLToDictionaryParser : NSObject <S4HttpConnectionDelegate>
{
@private
    id <S4XmlDictParserDelegate>						m_delegate;
	NSMutableData										*m_charDataBuffer;
	BOOL												m_bInElement;
    BOOL												m_bElementHasChars;
	NSString											*m_rootElementNameStr;
	NSMutableDictionary									*m_curXmlDictionary;
	NSString											*m_reachableHostStr;
	NSAutoreleasePool									*m_parsingAutoreleasePool;
	xmlParserCtxtPtr									m_libXmlParserContext;
	BOOL												m_bDoneParsing;
	S4HttpConnection									*m_S4HttpConnection;
}

// Properties
@property (nonatomic, retain) NSString					*reachableHostStr;

// Class methods
+ (id)parser;

// Instance methods
- (BOOL)startParsingFromUrlPath: (NSString *)pathStr rootElementName: (NSString *)rootElementStr withDelegate: (id <S4XmlDictParserDelegate>)delegate;
- (BOOL)startParsingFromFilePath: (NSString *)pathStr rootElementName: (NSString *)rootElementStr withDelegate: (id <S4XmlDictParserDelegate>)delegate;
- (void)cancelParse;

@end
