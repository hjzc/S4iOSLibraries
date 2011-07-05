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
 * Name:		S4JSONSerializer.m
 * Module:		Data
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4JSONSerializer.h"
#import "S4CryptoUtils.h"
#include "yajl_gen.h"
// #include "Base64Transcoder.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================

NSString *const S4JSONSerializerException = @"S4JSONSerializerException";


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================= Begin Class S4JSONSerializer ==============================

@implementation S4JSONSerializer

//============================================================================
//	S4JSONSerializer :: init
//============================================================================
- (id)init
{
	return [self initWithGenOptions: S4JSONSerializerOptionsNone indentString: @""];
}


//============================================================================
//	S4JSONSerializer :: initWithGenOptions:
//============================================================================
- (id)initWithGenOptions: (S4JSONSerializerOptions)genOptions indentString: (NSString *)indentString
{
	self = [super init];
	if (nil != self)
	{
		m_serializerOptions = genOptions;
		m_yajl_gen = (void *)yajl_gen_alloc(NULL);
		if (NULL != m_yajl_gen)
		{
			if (genOptions & S4JSONSerializerOptionsBeautify)
			{
				yajl_gen_config((yajl_gen)m_yajl_gen, yajl_gen_beautify, 1);
			}
			yajl_gen_config((yajl_gen)m_yajl_gen, yajl_gen_indent_string, [indentString UTF8String]);
		}
	}
	return self;
}


//============================================================================
//	S4JSONSerializer :: dealloc
//============================================================================
- (void)dealloc
{ 
	if (m_yajl_gen != NULL)
	{
		yajl_gen_free((yajl_gen)m_yajl_gen);
	}

	[super dealloc];
}


//============================================================================
//	S4JSONSerializer :: object:
//============================================================================
- (void)object: (id)obj
{  
	if ([obj conformsToProtocol: @protocol(JSONEncoding)])
	{
		return [self object: [obj toJSON]];
	}
	else if ([obj isKindOfClass:[NSArray class]])
	{
		[self startArray];
		for(id element in obj)
			[self object:element];
		[self endArray];
	}
	else if ([obj isKindOfClass:[NSDictionary class]])
	{
		[self startDictionary];
		for(id key in obj)
		{
			[self object:key];
			[self object:[obj objectForKey:key]];
		}
		[self endDictionary];
	}
	else if ([obj isKindOfClass:[NSNumber class]])
	{
		if ('c' != *[obj objCType])
		{
			[self number:obj];
		}
		else
		{
			[self bool:[obj boolValue]];
		}
	}
	else if ([obj isKindOfClass:[NSString class]])
	{
		[self string:obj];
	}
	else if ([obj isKindOfClass:[NSNull class]])
	{
		[self null];
	}
	else
	{
		BOOL unknownType = NO;
		if (m_serializerOptions & S4JSONSerializerOptionsIncludeUnsupportedTypes)
		{
			// Begin with support for non-JSON representable (PList) types
			if ([obj isKindOfClass:[NSDate class]])
			{
				[self number:[NSNumber numberWithLongLong:round([obj timeIntervalSince1970] * 1000)]];
			}
			else if ([obj isKindOfClass:[NSData class]])
			{
				[self string: [S4CryptoUtils stringByBase64EncodingData: obj]];
			}
			else if ([obj isKindOfClass:[NSURL class]])
			{
				[self string:[obj absoluteString]];
			}
			else
			{
				unknownType = YES;
			}
		}
		else
		{
			unknownType = YES;
		}
    
		// If we didn't handle special PList types
		if (unknownType)
		{
			if (!(m_serializerOptions & S4JSONSerializerOptionsIgnoreUnknownTypes))
			{
				[NSException raise: S4JSONSerializerException format: @"Unknown object type: %@ (%@)", [obj class], obj];
			}
			else
			{
				[self null]; // Use null value for unknown type if we are ignoring
			}
		}
	}
}


//============================================================================
//	S4JSONSerializer :: null
//============================================================================
- (void)null
{
	yajl_gen_null((yajl_gen)m_yajl_gen);
}


//============================================================================
//	S4JSONSerializer :: bool:
//============================================================================
- (void)bool: (BOOL)b
{
	yajl_gen_bool((yajl_gen)m_yajl_gen, b);
}


//============================================================================
//	S4JSONSerializer :: number:
//============================================================================
- (void)number: (NSNumber *)number
{
	NSString *s = [number stringValue];
	unsigned int length = [s lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	const char *c = [s UTF8String];
	yajl_gen_number((yajl_gen)m_yajl_gen, c, length);
}


//============================================================================
//	S4JSONSerializer :: string:
//============================================================================
- (void)string: (NSString *)s
{
	unsigned int length = [s lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	const unsigned char *c = (const unsigned char *)[s UTF8String]; 
	yajl_gen_string((yajl_gen)m_yajl_gen, c, length);
}


//============================================================================
//	S4JSONSerializer :: startDictionary
//============================================================================
- (void)startDictionary
{
	yajl_gen_map_open((yajl_gen)m_yajl_gen);
}


//============================================================================
//	S4JSONSerializer :: endDictionary
//============================================================================
- (void)endDictionary
{
	yajl_gen_map_close((yajl_gen)m_yajl_gen);
}


//============================================================================
//	S4JSONSerializer :: startArray
//============================================================================
- (void)startArray
{
	yajl_gen_array_open((yajl_gen)m_yajl_gen);
}


//============================================================================
//	S4JSONSerializer :: endArray
//============================================================================
- (void)endArray
{
	yajl_gen_array_close((yajl_gen)m_yajl_gen);
}


//============================================================================
//	S4JSONSerializer :: clear
//============================================================================
- (void)clear
{
	yajl_gen_clear((yajl_gen)m_yajl_gen);
}


//============================================================================
//	S4JSONSerializer :: buffer
//============================================================================
- (NSString *)buffer
{
	const unsigned char *buf;  
	size_t len;
	yajl_gen_get_buf((yajl_gen)m_yajl_gen, &buf, &len); 
	NSString *s = [NSString stringWithUTF8String:(const char*)buf]; 
	return s;
} 

@end




