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
 * Name:		S4JSONSerializer.h
 * Module:		Data
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================

typedef enum
{
	S4JSONSerializerOptionsNone						= 0,
	S4JSONSerializerOptionsBeautify					= 1 << 0,
	S4JSONSerializerOptionsIgnoreUnknownTypes		= 1 << 1,
	S4JSONSerializerOptionsIncludeUnsupportedTypes	= 1 << 2,
} S4JSONSerializerOptions;


// =================================== Globals =========================================

extern NSString *const S4JSONSerializerException;


// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================

@protocol JSONEncoding <NSObject>

@required
- (id)toJSON;

@end


// ============================ Class S4JSONSerializer =================================

@interface S4JSONSerializer : NSObject
{
	void											*m_yajl_gen;
	S4JSONSerializerOptions							m_serializerOptions;
}

- (id)initWithGenOptions: (S4JSONSerializerOptions)genOptions indentString: (NSString *)indentString;

- (void)object: (id)obj;
- (void)null;
- (void)bool: (BOOL)b;
- (void)number: (NSNumber *)number;
- (void)string: (NSString *)s;

- (void)startDictionary;
- (void)endDictionary;

- (void)startArray;
- (void)endArray;

- (void)clear;
- (NSString *)buffer;

@end
