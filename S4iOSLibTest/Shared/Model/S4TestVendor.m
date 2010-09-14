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
 * Name:		S4TestVendor.m
 * Module:		Test
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4TestVendor.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================

// these are key values for archiving and unarchiving this class
static NSString							*k_Dict_Key				= @"DICT_STR";
static NSString							*k_Favorite_Key			= @"FAVORITE_BOOL";

static NSString							*kTitle_Element			= @"Title";
static NSString							*kAddress_Element		= @"Address";
static NSString							*kCity_Element			= @"City";
static NSString							*kState_Element			= @"State";
static NSString							*kPhone_Element			= @"Phone";
static NSString							*kLatitude_Element		= @"Latitude";
static NSString							*kLongitude_Element		= @"Longitude";
static NSString							*kAvgRating_Element		= @"AverageRating";
static NSString							*kTotRating_Element		= @"TotalRatings";
static NSString							*kDistance_Element		= @"Distance";
static NSString							*kURL_Element			= @"Url";
static NSString							*kMapURL_Element		= @"MapUrl";
static NSString							*kBizURL_Element		= @"BusinessUrl";


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ======================= Begin Class S4TestVendor (PrivateImpl) ======================

@interface S4TestVendor (PrivateImpl)

- (void)placeHolder1;
- (void)placeHolder2;

@end




@implementation S4TestVendor (PrivateImpl)

//============================================================================
//	S4TestVendor (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}


//============================================================================
//	S4TestVendor (PrivateImpl) :: placeHolder2
//============================================================================
- (void)placeHolder2
{
}

@end




// =========================== Begin Class S4TestVendor ===========================

@implementation S4TestVendor

//============================================================================
//	S4TestVendor :: init
//============================================================================
- (id)init
{
	id			idResult = nil;

	self = [super init];
	if (nil != self)
	{
		m_bIsFavorite = NO;
		m_xmlDictionary = nil;

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4TestVendor :: init
//============================================================================
- (id)initWithDictionary: (NSDictionary *)dict 
{
	id			idResult = nil;
	
	self = [super init];
	if (nil != self)
	{
		m_bIsFavorite = NO;
		m_xmlDictionary = [dict copy];
		
		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4TestVendor :: dealloc
//============================================================================
- (void)dealloc
{
	if (nil != m_xmlDictionary)
	{
		[m_xmlDictionary release];
		m_xmlDictionary = nil;
	}

    [super dealloc];
}


//============================================================================
//	S4TestVendor :: isEquivalent
//============================================================================
- (BOOL)isEquivalent: (S4TestVendor *)otherObject
{
	if ((nil != otherObject) && ([otherObject isKindOfClass: [S4TestVendor class]]))
	{
		if (([[self title] isEqualToString: [otherObject title]]) &&
			([[self address] isEqualToString: [otherObject address]]) &&
			([[self city] isEqualToString: [otherObject city]]) &&
			([[self state] isEqualToString: [otherObject state]]))
		{
			return (YES);
		}
	}
	return (NO);
}


//============================================================================
//	S4TestVendor :: favorite
//============================================================================
- (BOOL)favorite
{
	return (m_bIsFavorite);
}


//============================================================================
//	S4TestVendor :: setFavorite
//============================================================================
- (void)setFavorite: (BOOL)bIsFavorite
{
	m_bIsFavorite = bIsFavorite;
}


//============================================================================
//	S4TestVendor :: latitudeAsDouble
//============================================================================
- (double)latitudeAsDouble
{
	if (STR_NOT_EMPTY([self latitudeStr]))
	{
		return ([[self latitudeStr] doubleValue]);
	}
	return (0.0);
}


//============================================================================
//	S4TestVendor :: longitutdeAsDouble
//============================================================================
- (double)longitutdeAsDouble
{
	if (STR_NOT_EMPTY([self longitudeStr]))
	{
		return ([[self longitudeStr] doubleValue]);
	}
	return (0.0);
}


//============================================================================
//	S4TestVendor :: avgRatingAsDouble
//============================================================================
- (double)avgRatingAsDouble
{
	if (STR_NOT_EMPTY([self avgRating]))
	{
		return ([[self avgRating] doubleValue]);
	}
	return (0.0);
}


//============================================================================
//	S4TestVendor :: totalRatingsAsInt
//============================================================================
- (int)totalRatingsAsInt
{
	if (STR_NOT_EMPTY([self totRatings]))
	{
		return ([[self totRatings] intValue]);
	}
	return (0);
}


//============================================================================
//	S4TestVendor :: distanceAsDouble
//============================================================================
- (double)distanceAsDouble
{
	if (STR_NOT_EMPTY([self distance]))
	{
		return ([[self distance] doubleValue]);
	}
	return (0.0);
}


//============================================================================
//	S4TestVendor :: title
//============================================================================
- (NSString *)title
{
	return ([m_xmlDictionary objectForKey: kTitle_Element]);
}


//============================================================================
//	S4TestVendor :: address
//============================================================================
- (NSString *)address
{
	return ([m_xmlDictionary objectForKey: kAddress_Element]);
}


//============================================================================
//	S4TestVendor :: city
//============================================================================
- (NSString *)city
{
	return ([m_xmlDictionary objectForKey: kCity_Element]);
}


//============================================================================
//	S4TestVendor :: state
//============================================================================
- (NSString *)state
{
	return ([m_xmlDictionary objectForKey: kState_Element]);
}


//============================================================================
//	S4TestVendor :: phone
//============================================================================
- (NSString *)phone
{
	return ([m_xmlDictionary objectForKey: kPhone_Element]);
}


//============================================================================
//	S4TestVendor :: latitudeStr
//============================================================================
- (NSString *)latitudeStr
{
	return ([m_xmlDictionary objectForKey: kLatitude_Element]);
}


//============================================================================
//	S4TestVendor :: longitudeStr
//============================================================================
- (NSString *)longitudeStr
{
	return ([m_xmlDictionary objectForKey: kLongitude_Element]);
}


//============================================================================
//	S4TestVendor :: avgRating
//============================================================================
- (NSString *)avgRating
{
	return ([m_xmlDictionary objectForKey: kAvgRating_Element]);
}


//============================================================================
//	S4TestVendor :: totRatings
//============================================================================
- (NSString *)totRatings
{
	return ([m_xmlDictionary objectForKey: kTotRating_Element]);
}


//============================================================================
//	S4TestVendor :: distance
//============================================================================
- (NSString *)distance
{
	return ([m_xmlDictionary objectForKey: kDistance_Element]);
}


//============================================================================
//	S4TestVendor :: yahooClickUrl
//============================================================================
- (NSString *)yahooClickUrl
{
	return ([m_xmlDictionary objectForKey: kURL_Element]);
}


//============================================================================
//	S4TestVendor :: mapUrl
//============================================================================
- (NSString *)mapUrl
{
	return ([m_xmlDictionary objectForKey: kMapURL_Element]);
}


//============================================================================
//	S4TestVendor :: bizUrl
//============================================================================
- (NSString *)bizUrl
{
	return ([m_xmlDictionary objectForKey: kBizURL_Element]);
}




/*********************************************  NSCoding Protocol Methods *********************************************/

//============================================================================
//	S4TestVendor :: encodeWithCoder
//============================================================================
- (void)encodeWithCoder: (NSCoder *)coder
{
	// encode the base NSObject
//	[super encodeWithCoder: coder];

	// encode the class member vars
	[coder encodeBool: m_bIsFavorite		forKey: k_Favorite_Key];
	[coder encodeObject: m_xmlDictionary	forKey: k_Dict_Key];
}


//============================================================================
//	S4TestVendor :: encodeWithCoder
//============================================================================
- (id)initWithCoder: (NSCoder *)coder
{
	// decode the base NSObject
//	self = [super initWithCoder: coder];
	self = [super init];
	if (nil != self)
	{
		// decode the class member vars
		m_bIsFavorite			= [coder decodeBoolForKey:		k_Favorite_Key];
		m_xmlDictionary			= [[coder decodeObjectForKey:	k_Dict_Key] retain];
	}
	return (self);
}

@end
