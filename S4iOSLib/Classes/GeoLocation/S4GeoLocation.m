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
 * Name:		S4GeoLocation.m
 * Module:		GeoLocation
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "S4GeoLocation.h"
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================

#define MIN_LAT_SPAN						0.0045f
#define MIN_LON_SPAN						0.0035f


// ================================== Typedefs ==========================================



// ================================== Globals ==========================================

static NSString			*kGoogleGeoCoderFormatUrl = @"http://maps.google.com/maps/geo?q=%@&output=csv";


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =========================== Begin Class S4GeoLocation ===============================

@implementation S4GeoLocation

//============================================================================
//	S4GeoLocation :: doubleToString:
//============================================================================
+ (NSString *)doubleToString: (double)value
{
	NSNumber					*number;
	
	number = [NSNumber numberWithDouble: value];
	if (IS_NOT_NULL(number))
	{
		return ([number stringValue]);
	}
	return (nil);
}


//============================================================================
//	S4GeoLocation :: stringToDouble:
//============================================================================
+ (double)stringToDouble: (NSString *)string
{
	if (STR_NOT_EMPTY(string))
	{
		return ([string doubleValue]);
	}
	return (0.0);
}


//============================================================================
//	S4GeoLocation :: calculateRegionForAnnotationArray:
//============================================================================
+ (MKCoordinateRegion)calculateRegionForAnnotationArray: (NSArray *)annotationArray
{
	CLLocationCoordinate2D				curCoordinate;
	CLLocationCoordinate2D				maxCoord = {-90.0f, -180.0f};
	CLLocationCoordinate2D				minCoord = {90.0f, 180.0f};
	MKCoordinateRegion					mkRegionResult;
	
	if (IS_NOT_NULL(annotationArray) && ([annotationArray count] > 0))
	{
		// perform calculation on all coordinates in NSArray to derive the MKRegion we need
		for (id <MKAnnotation> curAnnotation in annotationArray)
		{
			curCoordinate = curAnnotation.coordinate;
			
			// figure out map region parameters
			if (curCoordinate.longitude > maxCoord.longitude)
			{
				maxCoord.longitude = curCoordinate.longitude;
			}
			
			if (curCoordinate.latitude > maxCoord.latitude)
			{
				maxCoord.latitude = curCoordinate.latitude;
			}
			
			if (curCoordinate.longitude < minCoord.longitude)
			{
				minCoord.longitude = curCoordinate.longitude;
			}
			
			if (curCoordinate.latitude < minCoord.latitude)
			{
				minCoord.latitude = curCoordinate.latitude;
			}
		}
		
		// set the center coordinate
		mkRegionResult.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.0;
		mkRegionResult.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.0;
		
		// set the span
		if (MIN_LAT_SPAN > (maxCoord.latitude - minCoord.latitude))
		{
			mkRegionResult.span.latitudeDelta = MIN_LAT_SPAN;
		}
		else
		{
			mkRegionResult.span.latitudeDelta = maxCoord.latitude - minCoord.latitude;
		}
		
		if (MIN_LON_SPAN > (maxCoord.longitude - minCoord.longitude))
		{
			mkRegionResult.span.longitudeDelta = MIN_LON_SPAN;
		}
		else
		{
			mkRegionResult.span.longitudeDelta = maxCoord.longitude - minCoord.longitude;
		}
	}
	else
	{
		mkRegionResult.center.latitude = 0.0;
		mkRegionResult.center.longitude = 0.0;
		mkRegionResult.span.latitudeDelta = MIN_LAT_SPAN;
		mkRegionResult.span.longitudeDelta = MIN_LON_SPAN;
	}
	return (mkRegionResult);
}


//============================================================================
//	S4GeoLocation :: init
//============================================================================
- (id)init
{
	id			idResult = nil;

	self = [super init];
	if (nil != self)
	{		
		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4GeoLocation :: dealloc
//============================================================================
- (void)dealloc
{	
    [super dealloc];
}


//============================================================================
//	S4GeoLocation :: geocodeFromGoogleForAddress:
//============================================================================
- (CLLocation *)geocodeFromGoogleForAddress: (NSString *)address
{
	NSString					*urlStr;
	NSURL						*url;
	NSStringEncoding			strEncoding;
	NSError						*error;
	NSString					*locationStr;
	NSArray						*resultItems;
	CLLocationDegrees			latitude;
	CLLocationDegrees			longitude;
	CLLocation					*locResult = nil;

	if (STR_NOT_EMPTY(address))
	{
		urlStr = [NSString stringWithFormat: kGoogleGeoCoderFormatUrl, address];

		// create a properly escaped NSURL from the string params
		url = [S4NetUtilities createNSUrlForPathStr: urlStr baseStr: nil];
		if (IS_NOT_NULL(url))
		{
			locationStr = [NSString stringWithContentsOfURL: url usedEncoding: &strEncoding error: &error];
			if STR_NOT_EMPTY(locationStr)
			{
				resultItems = [locationStr componentsSeparatedByString: @","];
				if (([resultItems count] >= 4) && ([[resultItems objectAtIndex: 0] isEqualToString: @"200"]))
				{
					latitude = [[resultItems objectAtIndex: 2] doubleValue];
					longitude = [[resultItems objectAtIndex: 3] doubleValue];
					locResult = [[[CLLocation alloc] initWithLatitude: latitude longitude: longitude] autorelease];
				}
			}
		}
	}
	return (locResult);
}



/*********************************************  NSCoding Protocol Methods *********************************************/

//============================================================================
//	S4GeoLocation :: encodeWithCoder
//============================================================================
- (void)encodeWithCoder: (NSCoder *)coder
{
	// encode the superclass, unless it is NSObject
	[super encodeWithCoder: coder];

	// encode the class member vars
	//  -- none to encode --
}


//============================================================================
//	S4GeoLocation :: encodeWithCoder
//============================================================================
- (id)initWithCoder: (NSCoder *)coder
{
	id			idResult = nil;

	// decode the superclass, unless it is NSObject
	self = [super initWithCoder: coder];
	if (nil != self)
	{		
		idResult = self;
	}
	return (idResult);
}

@end
