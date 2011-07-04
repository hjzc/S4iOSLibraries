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
 * Name:		S4CryptoUtils.m
 * Module:		Crypto
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4CryptoUtils.h"
#include "Base64Transcoder.h"
// #import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================




// ========================== Begin Class S4CryptoUtils ================================

@implementation S4CryptoUtils


//============================================================================
//	S4CryptoUtils :: stringByBase64EncodingData
//============================================================================
+ (NSString *)stringByBase64EncodingData: (NSData *)data
{
	size_t						length;
	size_t						maxLength;
	NSMutableData				*converted;
	NSString					*strResult = nil;

	if (nil != data)
	{
		length = (size_t)[data length];
		if (0 < length)
		{
			// find the approximate size of the converted data
			maxLength = EstimateBas64EncodedDataSize(length);

			// create a new data instance to hold the converted data
			converted = [NSMutableData data];
			if (nil != converted)
			{
				[converted setLength: maxLength];

				// do the encoding
				if (Base64EncodeData((const void *)[data bytes], length, (char *)[converted mutableBytes], &maxLength))
				{
					strResult = [[[NSString alloc] initWithData: converted encoding: NSASCIIStringEncoding] autorelease];
				}
			}
		}
	}
	return (strResult);
}

@end
