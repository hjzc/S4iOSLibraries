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
 * Name:		S4JSONCommon.h
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
	kInvalidJSONClass		= 0,
	kNSArrayJSONClass		= 1,
	kNSDictionaryJSONClass	= 2,
	kNSStringJSONClass		= 3,
	kNSNumberJSONClass		= 4,
	kUnknownJSONClass		= 5
} S4JSONClassType;


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


typedef enum
{
	S4JSONSerializerOptionsNone						= 0,
	S4JSONSerializerOptionsBeautify					= 1 << 0,
	S4JSONSerializerOptionsIgnoreUnknownTypes		= 1 << 1,
	S4JSONSerializerOptionsIncludeUnsupportedTypes	= 1 << 2,
} S4JSONSerializerOptions;


// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



