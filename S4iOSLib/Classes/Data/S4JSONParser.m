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

#import "S4JSONParser.h"
#include "yajl_parse.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================

S4_INTERN_CONSTANT_NSSTR						S4JSONParserErrorDomain = @"S4JSONParserErrorDomain";
S4_INTERN_CONSTANT_NSSTR						S4JSONParserException = @"S4JSONParserException";
S4_INTERN_CONSTANT_NSSTR						S4JSONParserValueKey = @"S4JSONParserValueKey";


// ============================= Forward Declarations ==================================

// yajl callback functions
int yajl_null(void *ctx);
int yajl_boolean(void *ctx, int boolVal);
int ParseDouble(void *ctx, const char *buf, const char *numberVal, unsigned int numberLen);
int yajl_number(void *ctx, const char *numberVal, size_t numberLen);
int yajl_string(void *ctx, const unsigned char *stringVal, size_t stringLen);
int yajl_map_key(void *ctx, const unsigned char *stringVal, size_t stringLen);
int yajl_start_map(void *ctx);
int yajl_end_map(void *ctx);
int yajl_start_array(void *ctx);
int yajl_end_array(void *ctx);


// S4JSONParser private methods
@interface S4JSONParser (PrivateImpl)

- (void)_add: (id)value;
- (void)_mapKey: (NSString *)key;
- (void)_startDictionary;
- (void)_endDictionary;
- (void)_startArray;
- (void)_endArray;
- (NSError *)_errorForStatus: (NSInteger)code message: (NSString *)message value: (NSString *)value;
- (void)_cancelWithErrorForStatus: (NSInteger)code message: (NSString *)message value: (NSString *)value;

@end


// ================================== Inlines ==========================================

int yajl_null(void *ctx)
{
	[(id)ctx _add: [NSNull null]];
	return 1;
}


int yajl_boolean(void *ctx, int boolVal)
{
	NSNumber *number = [[NSNumber alloc] initWithBool: (BOOL)boolVal];
	[(id)ctx _add: number];
	[number release];
	return 1;
}

// Instead of using yajl_integer and yajl_double we use yajl_number and parse
// as double (or long long); This is to be more compliant since Javascript numbers are represented
// as double precision floating point, though JSON spec doesn't define a max value 
// and is up to the parser?

//int yajl_integer(void *ctx, long integerVal) {
//  [(id)ctx _add:[NSNumber numberWithLong:integerVal]];
//  return 1;
//}
//
//int yajl_double(void *ctx, double doubleVal) {
//  [(id)ctx _add:[NSNumber numberWithDouble:doubleVal]];
//  return 1;
//}

int ParseDouble(void *ctx, const char *buf, const char *numberVal, unsigned int numberLen)
{
	double d = strtod((char *)buf, NULL);
	if ((d == HUGE_VAL || d == -HUGE_VAL) && errno == ERANGE)
	{
		NSString *s = [[NSString alloc] initWithBytes:numberVal length:numberLen encoding:NSUTF8StringEncoding];
		[(id)ctx _cancelWithErrorForStatus: S4JSONParserDoubleOverflowError message: [NSString stringWithFormat:@"double overflow on '%@'", s] value: s];
		[s release];
		return 0;
	}
	NSNumber *number = [[NSNumber alloc] initWithDouble: d];
	[(id)ctx _add: number];
	[number release];
	return 1;
}


int yajl_number(void *ctx, const char *numberVal, size_t numberLen)
{
	char buf[numberLen+1];
	memcpy(buf, numberVal, numberLen);
	buf[numberLen] = 0;
	
	if (memchr(numberVal, '.', numberLen) || memchr(numberVal, 'e', numberLen) || memchr(numberVal, 'E', numberLen))
	{
		return ParseDouble(ctx, buf, numberVal, numberLen);
	}
	else
	{
		long long i = strtoll((const char *) buf, NULL, 10);
		if ((i == LLONG_MIN || i == LLONG_MAX) && errno == ERANGE)
		{
			if (([(id)ctx parserOptions] & S4JSONParserOptionsStrictPrecision) == S4JSONParserOptionsStrictPrecision)
			{
				NSString *s = [[NSString alloc] initWithBytes: numberVal length: numberLen encoding: NSUTF8StringEncoding];
				[(id)ctx _cancelWithErrorForStatus: S4JSONParserIntegerOverflowError message: [NSString stringWithFormat: @"integer overflow on '%@'", s] value: s];
				[s release];
				return 0;
			}
			else
			{
				// If we integer overflow lets try double precision for HUGE_VAL > double > LLONG_MAX 
				return ParseDouble(ctx, buf, numberVal, numberLen);
			}
		}
		NSNumber *number = [[NSNumber alloc] initWithLongLong: i];
		[(id)ctx _add: number];
		[number release];
	}
	
	return 1;
}


int yajl_string(void *ctx, const unsigned char *stringVal, size_t stringLen)
{
	NSString *s = [[NSString alloc] initWithBytes: stringVal length: stringLen encoding: NSUTF8StringEncoding];
	[(id)ctx _add: s];
	[s release];
	return 1;
}


int yajl_map_key(void *ctx, const unsigned char *stringVal, size_t stringLen)
{
	NSString *s = [[NSString alloc] initWithBytes: stringVal length: stringLen encoding: NSUTF8StringEncoding];
	[(id)ctx _mapKey: s];
	[s release];
	return 1;
}


int yajl_start_map(void *ctx)
{
	[(id)ctx _startDictionary];
	return 1;
}


int yajl_end_map(void *ctx)
{
	[(id)ctx _endDictionary];
	return 1;
}


int yajl_start_array(void *ctx)
{
	[(id)ctx _startArray];
	return 1;
}


int yajl_end_array(void *ctx)
{
	[(id)ctx _endArray];
	return 1;
}


static yajl_callbacks callbacks =
{
	yajl_null,
	yajl_boolean,
	NULL,					// yajl_integer (using yajl_number)
	NULL,					// yajl_double (using yajl_number)
	yajl_number,
	yajl_string,
	yajl_start_map,
	yajl_map_key,
	yajl_end_map,
	yajl_start_array,
	yajl_end_array
};



// ============================ Begin Class S4JSONParser () ==============================

@interface S4JSONParser ()

@property (nonatomic, retain, readwrite) NSError *parserError;

@end



// ======================= Begin Class S4JSONParser (PrivateImpl) ========================

@implementation S4JSONParser (PrivateImpl)

//============================================================================
//	S4JSONParser (PrivateImpl) :: _add:
//============================================================================
- (void)_add: (id)value
{
	[m_delegate parser: self didAdd: value];
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: _mapKey:
//============================================================================
- (void)_mapKey: (NSString *)key
{
	[m_delegate parser: self didMapKey: key];
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: _startDictionary
//============================================================================
- (void)_startDictionary
{
	[m_delegate parserDidStartDictionary: self];
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: _endDictionary
//============================================================================
- (void)_endDictionary
{
	[m_delegate parserDidEndDictionary: self];
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: _startArray
//============================================================================
- (void)_startArray
{ 
	[m_delegate parserDidStartArray: self];
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: _endArray
//============================================================================
- (void)_endArray
{
	[m_delegate parserDidEndArray:self];
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: _errorForStatus:
//============================================================================
- (NSError *)_errorForStatus: (NSInteger)code message: (NSString *)message value: (NSString *)value
{
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
	if (nil != value)
	{
		[userInfo setObject: value forKey: S4JSONParserValueKey];
	}
	return [NSError errorWithDomain: S4JSONParserErrorDomain code: code userInfo: userInfo];
}


//============================================================================
//	S4JSONParser (PrivateImpl) :: _cancelWithErrorForStatus:
//============================================================================
- (void)_cancelWithErrorForStatus: (NSInteger)code message: (NSString *)message value: (NSString *)value
{
	self.parserError = [self _errorForStatus:code message:message value:value];
}

@end




// ========================= Begin Class S4JSONParser ========================

@implementation S4JSONParser


//============================================================================
//	S4JSONParser :: properties
//============================================================================
@synthesize parserError = m_parserError;
@synthesize delegate = m_delegate;
@synthesize parserOptions = m_parserOptions;


//============================================================================
//	S4JSONParser :: init
//============================================================================
- (id)init
{
	return [self initWithParserOptions: S4JSONParserOptionsNone];
}


//============================================================================
//	S4JSONParser :: initWithParserOptions:
//============================================================================
- (id)initWithParserOptions: (S4JSONParserOptions)parserOptions
{
	self = [super init];
	if (nil != self)
	{
		m_parserOptions = parserOptions;   
	}
	return self;
}


//============================================================================
//	S4JSONParser :: dealloc
//============================================================================
- (void)dealloc
{
	if (NULL != m_yajl_handle)
	{
		yajl_free((yajl_handle)m_yajl_handle);
		m_yajl_handle = NULL;
	}

	if (IS_NOT_NULL(m_parserError))
	{
		[m_parserError release];
		m_parserError = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4JSONParser :: parse:
//============================================================================
- (S4JSONParserError)parse: (NSData *)data
{
	S4JSONParserError			parseError = S4JSONParserAllocationError;

	if (NULL == m_yajl_handle)
	{
		m_yajl_handle = (void *)yajl_alloc(&callbacks, NULL, self);
		if (NULL == m_yajl_handle)
		{
			self.parserError = [self _errorForStatus: S4JSONParserAllocationError message: @"Unable to allocate YAJL handle" value: nil];
		}
		else
		{
			if (m_parserOptions & S4JSONParserOptionsAllowComments)
			{
				yajl_config((yajl_handle)m_yajl_handle, yajl_allow_comments, 1); // turn comment support on
			}
			else
			{
				yajl_config((yajl_handle)m_yajl_handle, yajl_allow_comments, 0); // turn comment support off
			}
			
			if (m_parserOptions & S4JSONParserOptionsCheckUTF8)
			{
				yajl_config((yajl_handle)m_yajl_handle, yajl_dont_validate_strings, 0); // enable utf8 checking
			}
			else
			{
				yajl_config((yajl_handle)m_yajl_handle, yajl_dont_validate_strings, 1); // disable utf8 checking
			}
		}
	}
	
	if (NULL != m_yajl_handle)
	{
		yajl_status status = yajl_parse((yajl_handle)m_yajl_handle, [data bytes], [data length]);
		if (status == yajl_status_client_canceled)
		{
			// We cancelled because we encountered an error here in the client;
			// and parserError should be already set
			parseError = S4JSONParserCanceledError;
		}
		else if (status == yajl_status_error)
		{
			unsigned char *errorMessage = yajl_get_error((yajl_handle)m_yajl_handle, 1, [data bytes], [data length]);
			NSString *errorString = [NSString stringWithUTF8String: (char *)errorMessage];
			self.parserError = [self _errorForStatus: status message: errorString value: nil];
			yajl_free_error((yajl_handle)m_yajl_handle, errorMessage);
			parseError = S4JSONParserParsingError;
		}
		else if (status == yajl_status_ok)
		{
			parseError = S4JSONParserNoError;
		}
		else
		{
			self.parserError = [self _errorForStatus: status message: [NSString stringWithFormat: @"Unexpected status %d", status] value: nil];
			parseError = S4JSONParserUnknownError;
		}
	}
	return (parseError);
}


//============================================================================
//	S4JSONParser :: parseCompleted
//============================================================================
- (S4JSONParserError)parseCompleted
{
	yajl_status					status;
	S4JSONParserError			parseError = S4JSONParserAllocationError;

	if (NULL != m_yajl_handle)
	{
		status = yajl_complete_parse((yajl_handle)m_yajl_handle);
		if (yajl_status_error == status)
		{
			self.parserError = [self _errorForStatus: status message: [NSString stringWithFormat: @"Parse error with status %d", status] value: nil];
			parseError = S4JSONParserParsingError;
		}
		else if (yajl_status_ok == status)
		{
			parseError = S4JSONParserNoError;
		}
		else
		{
			self.parserError = [self _errorForStatus: status message: [NSString stringWithFormat: @"Unexpected status %d", status] value: nil];
			parseError = S4JSONParserUnknownError;
		}
	}
	return (parseError);
}

@end
