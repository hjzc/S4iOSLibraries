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
 * All software created by the Initial Developer are Copyright (C) 2008-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Original Author:
 *			Michael Papp, San Francisco, CA, USA
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		S4TestVendor.h
 * Module:		Test
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// =============================== Class S4TestVendor ==================================

@interface S4TestVendor : NSObject <NSCoding>
{
@private
	BOOL					m_bIsFavorite;
	NSDictionary			*m_xmlDictionary;
}

- (id)initWithDictionary: (NSDictionary *)dict;

- (BOOL)isEquivalent: (S4TestVendor *)otherObject;

- (BOOL)favorite;
- (void)setFavorite: (BOOL)bIsFavorite;

- (NSString *)title;
- (NSString *)address;
- (NSString *)city;
- (NSString *)state;
- (NSString *)phone;

- (NSString *)latitudeStr;
- (double)latitudeAsDouble;

- (NSString *)longitudeStr;
- (double)longitutdeAsDouble;

- (NSString *)avgRating;
- (double)avgRatingAsDouble;

- (NSString *)totRatings;
- (int)totalRatingsAsInt;

- (NSString *)distance;
- (double)distanceAsDouble;

- (NSString *)yahooClickUrl;
- (NSString *)mapUrl;
- (NSString *)bizUrl;

// NSCoding protocol methods
- (void)encodeWithCoder: (NSCoder *)encoder;
- (id)initWithCoder: (NSCoder *)decoder;

@end
