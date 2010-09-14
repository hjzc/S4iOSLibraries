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
 * Name:		S4CCMacProvider.h
 * Module:		Crypto
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#include <CommonCrypto/CommonHMAC.h>
#import <Foundation/Foundation.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// ============================ Class S4CCMacProvider ==================================

@interface S4CCMacProvider : NSObject
{
@private
	CCHmacAlgorithm										m_iAlgorithm;
	NSData												*m_keyData;
	CCHmacContext										m_ccHmacCxt;
}

- (id)initForMD5WithKey: (NSData *)key;
- (id)initForSHA1WithKey: (NSData *)key;
- (id)initForSHA224WithKey: (NSData *)key;
- (id)initForSHA256WithKey: (NSData *)key;
- (id)initForSHA384WithKey: (NSData *)key;

- (void)updateWithBytes: (const void *)bytes length: (NSUInteger)length;
- (void)updateWithData: (NSData *)data;
- (void)updateWithString: (NSString *)string encoding: (NSStringEncoding)encoding;
- (NSData *)digest;
- (NSUInteger)digestLength;

@end
