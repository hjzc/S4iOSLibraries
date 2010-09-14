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
#import <UIKit/UIKit.h>
#import "S4HttpConnection.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================

@class S4JSONParser;


// ================================== Protocols ========================================

@protocol S4JSONParserDelegate <NSObject>

@required
// Called by the parser when the parse is finished and an NSDictionary is the result.
- (void)parser: (S4JSONParser *)parser completedWithDictionary: (NSDictionary *)parsedDictionary;

// Called by the parser when the parse is finished and an NSArray is the result.
- (void)parser: (S4JSONParser *)parser completedWithArray: (NSArray *)parsedArray;

// Called by the parser in the case of an error.
- (void)parser: (S4JSONParser *)parser didFailWithError: (NSError *)error;

@end


// ============================== Class S4JSONParser ====================================

@interface S4JSONParser : NSObject <S4HttpConnectionDelegate>
{
    id <S4JSONParserDelegate>							m_delegate;

@private
	NSString											*m_reachableHostStr;
}

// Properties
@property (nonatomic, retain) id <S4JSONParserDelegate>							delegate;

// Class methods
+ (id)parser;

// Instance methods
- (BOOL)startParsingFromUrlPath: (NSString *)pathStr withObject: (id)object;
- (BOOL)startParsingFromFilePath: (NSString *)pathStr withObject: (id)object;
- (void)setReachabilityHostName: (NSString *)hostName;

@end
