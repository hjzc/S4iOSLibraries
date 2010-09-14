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
 * Name:		S4CCMacProvider.m
 * Module:		Crypto
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4CCMacProvider.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ==================== Begin Class S4CCMacProvider (PrivateImpl) ======================

@interface S4CCMacProvider (PrivateImpl)

- (id)initWithAlgorithm: (CCHmacAlgorithm)algorithm usingKey: (NSData *)key;

@end



@implementation S4CCMacProvider (PrivateImpl)

//============================================================================
//	S4CCMacProvider (PrivateImpl) :: initWithAlgorithm:usingKey:
//============================================================================
- (id)initWithAlgorithm: (CCHmacAlgorithm)algorithm usingKey: (NSData *)key
{
	id					idResult = nil;

	if ((self = [super init]) != nil)
	{
		m_iAlgorithm = algorithm;
		m_keyData = [key retain];
		CCHmacInit(&m_ccHmacCxt, m_iAlgorithm, [key bytes], [key length]);

		idResult = self;
	}
	return (idResult);
}

@end




// ====================== Begin Class S4CCMacProvider ========================

@implementation S4CCMacProvider

//============================================================================
//	S4CCMacProvider :: init
//============================================================================
- (id)initForMD5WithKey: (NSData *)key
{
	return ([self initWithAlgorithm: kCCHmacAlgMD5 usingKey: key]);
}


//============================================================================
//	S4CCMacProvider :: init
//============================================================================
- (id)initForSHA1WithKey: (NSData *)key
{
	return ([self initWithAlgorithm: kCCHmacAlgSHA1 usingKey: key]);
}


//============================================================================
//	S4CCMacProvider :: init
//============================================================================
- (id)initForSHA224WithKey: (NSData *)key
{
	return ([self initWithAlgorithm: kCCHmacAlgSHA224 usingKey: key]);
}


//============================================================================
//	S4CCMacProvider :: init
//============================================================================
- (id)initForSHA256WithKey: (NSData *)key
{
	return ([self initWithAlgorithm: kCCHmacAlgSHA256 usingKey: key]);
}


//============================================================================
//	S4CCMacProvider :: init
//============================================================================
- (id)initForSHA384WithKey: (NSData *)key
{
	return ([self initWithAlgorithm: kCCHmacAlgSHA384 usingKey: key]);
}


//============================================================================
//	S4CCMacProvider :: dealloc
//============================================================================
- (void)dealloc
{
	[m_keyData release];
	
	[super dealloc];
}


//============================================================================
//	S4CCMacProvider :: updateWithBytes:length:
//============================================================================
- (void)updateWithBytes: (const void *)bytes length: (NSUInteger)length
{
	CCHmacUpdate(&m_ccHmacCxt, bytes, length);
}


//============================================================================
//	S4CCMacProvider :: updateWithData:
//============================================================================
- (void)updateWithData: (NSData *)data
{
	[self updateWithBytes: [data bytes] length: [data length]];
}


//============================================================================
//	S4CCMacProvider :: updateWithString:encoding:
//============================================================================
- (void)updateWithString: (NSString *)string encoding: (NSStringEncoding)encoding
{
	[self updateWithData: [string dataUsingEncoding: encoding]];
}


//============================================================================
//	S4CCMacProvider :: digest
//============================================================================
- (NSData *)digest
{
	unsigned char				digest_bytes[512];
	unsigned int				digest_length = 0;

	CCHmacFinal(&m_ccHmacCxt, digest_bytes);

	switch (m_iAlgorithm)
	{
		case kCCHmacAlgMD5:
		{
			digest_length = CC_MD5_DIGEST_LENGTH;
			break;
		}

		case kCCHmacAlgSHA1:
		{
			digest_length = CC_SHA1_DIGEST_LENGTH;
			break;
		}

      case kCCHmacAlgSHA224:
         digest_length = CC_SHA224_DIGEST_LENGTH;
         break;
      case kCCHmacAlgSHA256:
         digest_length = CC_SHA256_DIGEST_LENGTH;
         break;
      case kCCHmacAlgSHA384:
         digest_length = CC_SHA384_DIGEST_LENGTH;
         break;
      case kCCHmacAlgSHA512:
         digest_length = CC_SHA512_DIGEST_LENGTH;
         break;
   }
   return [NSData dataWithBytes: digest_bytes length: digest_length];
}


//============================================================================
//	S4CCMacProvider :: digestLength
//============================================================================
- (NSUInteger)digestLength
{
   NSUInteger				digest_length = 0;

   switch (m_iAlgorithm)
	{
      case kCCHmacAlgMD5:
         digest_length = CC_MD5_DIGEST_LENGTH;
         break;
      case kCCHmacAlgSHA1:
         digest_length = CC_SHA1_DIGEST_LENGTH;
         break;
      case kCCHmacAlgSHA224:
         digest_length = CC_SHA224_DIGEST_LENGTH;
         break;
      case kCCHmacAlgSHA256:
         digest_length = CC_SHA256_DIGEST_LENGTH;
         break;
      case kCCHmacAlgSHA384:
         digest_length = CC_SHA384_DIGEST_LENGTH;
         break;
      case kCCHmacAlgSHA512:
         digest_length = CC_SHA512_DIGEST_LENGTH;
         break;
   }
   return digest_length;
}

@end
