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
 * Name:		S4Placemark.h
 * Module:		GeoLocation
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
//#ifdef __IPHONE_3_0
//#import <CoreLocation/CLErrorDomain.h>
//#endif
//#import <CoreLocation/CLError.h>
//#import <CoreLocation/CLLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import "S4GeoLocation.h"


// =================================== Defines =========================================

#define kS4LOCATION_DISTANCE_UNKNOWN				FLT_MAX


// ================================== Typedefs =========================================



// ================================== Globals =========================================



// ============================= Forward Declarations =================================



// ================================== Protocols ========================================



// ================================= S4Placemark Class =================================

@interface S4Placemark : S4GeoLocation <NSCoding, MKAnnotation, MKReverseGeocoderDelegate>
{
@private
	// holds the name or title associated with this location
	NSString									*m_titleStr;

	// A dictionary containing keys and values from an Address Book record.
	// For a list of strings that you can use for the keys of this dictionary,
	// see the “Address Property” constants in ABPerson Reference. All of the
	// keys in should be at the top level of the dictionary. 
	NSDictionary								*m_addressDictionary;

	// Used internally
	MKReverseGeocoder							*m_mkReverseGeoCoder;

	// This CLLocation represents the Placemark's geo-coordinates
	CLLocation									*m_clLocation;

	// Provides a member var to applications that support user "favorites"
	BOOL										m_bIsFavorite;

	// If m_bIsLocal equals YES, then the MKAnnotation method subtitle returns a street
	//  address;  otherwise, subtitle returns a "City, State" formatted string
	BOOL										m_bIsLocal;
}

// **** Properties ****

// The keys in this dictionary are those defined by the Address Book framework and 
// used to access address information for a person. For a list of the strings that
// might be in this dictionary, see the “Address Property” constants in ABPerson Reference.
@property (nonatomic, readonly) NSDictionary	*addressDictionary;

// This CLLocation represents the Placemark's geo-coordinates
@property (nonatomic, readonly) CLLocation		*clLocation;

// The state associated with the placemark.  If the placemark location was Apple’s
// headquarters, the value for this property would be the string “CA” or “California”.
@property (nonatomic, readonly) NSString		*administrativeArea;

// The name of the country associated with the placemark. If the placemark location
// was Apple’s headquarters, the value for this property would be the string “United States”.
@property (nonatomic, readonly) NSString		*country;

// The abbreviated country name. This string is the standard abbreviation used to refer
// to the country. For example, if the placemark location was Apple’s headquarters,
// the value for this property would be the string “US”.
@property (nonatomic, readonly) NSString		*countryCode;

// The city associated with the placemark. If the placemark location was Apple’s
// headquarters, the value for this property would be the string “Cupertino”.
@property (nonatomic, readonly) NSString		*locality;

// The postal code associated with the placemark. If the placemark location was
// Apple’s headquarters, the value for this property would be the string “95014”.
@property (nonatomic, readonly) NSString		*postalCode;

// Additional administrative area information for the placemark. Subadministrative
// areas typically correspond to counties or other regions that are then organized
// into a larger administrative area or state. For example, if the placemark location
// was Apple’s headquarters, the value for this property would be the string
// “Santa Clara”, which is the county in California that contains the city of Cupertino.
@property (nonatomic, readonly) NSString		*subAdministrativeArea;

// Additional city-level information for the placemark. This property contains additional
// information, such as the name of the neighborhood or landmark associated with the
// placemark. It might also refer to a common name that is associated with the location.
@property (nonatomic, readonly) NSString		*subLocality;

// Additional street-level information for the placemark. Subthroughfares provide
// information such as the street number for the location. For example,if the
// placemark location was Apple’s headquarters (1 Infinite Loop), the value for this
// property would be the string “1”.
@property (nonatomic, readonly) NSString		*subThoroughfare;

// The street address associated with the placemark. The street address contains the
// street name. For example, if the placemark location was Apple’s headquarters, the
// value for this property would be the string “Infinite Loop”.
@property (nonatomic, readonly) NSString		*thoroughfare;






// **** Instance Methods ****

//	initialziation methods
- (id)initWithCoordinate: (CLLocationCoordinate2D)coordinate
				andTitle: (NSString *)title
				 isLocal: (BOOL)bIsLocal;

- (id)initWithAddressDictionary: (NSDictionary *)addressDictionary
				needsConversion: (BOOL)bConvertDict
					   andTitle: (NSString *)title
						isLocal: (BOOL)bIsLocal;

- (id)initWithCoordinate: (CLLocationCoordinate2D)coordinate
	   addressDictionary: (NSDictionary *)addressDictionary
		 needsConversion: (BOOL)bConvertDict
				andTitle: (NSString *)title
				 isLocal: (BOOL)bIsLocal;

// OVERRIDE this method if you wish to convert "your" NSDictionary's
// key/value pairs into a dictionary containing keys and values
// conforming to Apple Address Book record constants
- (NSDictionary *)convertDictionary: (NSDictionary *)addressDictionary;

- (NSString *)streetNumber;
- (NSString *)street;
- (NSString *)city;
- (NSString *)county;
- (NSString *)state;
- (NSString *)zipCode;

// favorites
- (BOOL)favorite;
- (void)setFavorite: (BOOL)bIsFavorite;

// compute distances
- (double)distanceInMiles: (S4Location *)otherLocation;
- (double)distanceInKilometers: (S4Location *)otherLocation;

// latitude
- (CLLocationDegrees)latitude;
- (NSString *)latitudeAsString;

// longitude
- (CLLocationDegrees)longitude;
- (NSString *)longitudeAsString;


// **** MKAnnotation Protocol implementation ****

//		MKAnnotation has an implicit property:
//		@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (CLLocationCoordinate2D)coordinate;


//		MKAnnotation protocol methods
- (NSString *)title;
- (NSString *)subtitle;


// **** MKReverseGeocoder delegate methods ****

- (void)reverseGeocoder: (MKReverseGeocoder *)geocoder didFindPlacemark: (MKPlacemark *)placemark;
- (void)reverseGeocoder: (MKReverseGeocoder *)geocoder didFailWithError: (NSError *)error;


// **** NSCoding protocol methods ****

- (void)encodeWithCoder: (NSCoder *)encoder;
- (id)initWithCoder: (NSCoder *)decoder;

@end
