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
 * Name:		S4Placemark.m
 * Module:		GeoLocation
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <AddressBook/AddressBook.h>
#import "S4Placemark.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================

// these are Address Book keys found in the MKPlacemark dictionary, not defined in Apple
// headers;  the "kFormattedAddressLines" constant returns an NSArray of formatted strings
static NSString							*kSubAdministrativeArea		= @"SubAdministrativeArea";
static NSString							*kSubThoroughfare			= @"SubThoroughfare";
static NSString							*kSubLocality				= @"SubLocality";
static NSString							*kFormattedAddressLines		= @"FormattedAddressLines";

// these are key values for archiving and unarchiving this class
static NSString							*kCodingKey_1				= @"CODING_KEY_1";
static NSString							*kCodingKey_2				= @"CODING_KEY_2";
static NSString							*kCodingKey_3				= @"CODING_KEY_3";
static NSString							*kCodingKey_4				= @"CODING_KEY_4";
static NSString							*kCodingKey_5				= @"CODING_KEY_5";
static NSString							*kCodingKey_6				= @"CODING_KEY_6";
static NSString							*kCodingKey_7				= @"CODING_KEY_7";
static NSString							*kCodingKey_8				= @"CODING_KEY_8";
static NSString							*kCodingKey_9				= @"CODING_KEY_9";
static NSString							*kCodingKey_10				= @"CODING_KEY_10";
static NSString							*kCodingKey_11				= @"CODING_KEY_11";
static NSString							*kCodingKey_12				= @"CODING_KEY_12";
static NSString							*kCodingKey_14				= @"CODING_KEY_14";
static NSString							*kCodingKey_15				= @"CODING_KEY_15";
static NSString							*kCodingKey_16				= @"CODING_KEY_16";
static NSString							*kCodingKey_17				= @"CODING_KEY_17";
static NSString							*kCodingKey_18				= @"CODING_KEY_18";
static NSString							*kCodingKey_19				= @"CODING_KEY_19";
static NSString							*kCodingKey_20				= @"CODING_KEY_20";

// DEFAULT "BAD VALUE" RETURN STRINGS
static NSString							*kNoNameResultStr			= @"No name information provided";
static NSString							*kNoAddressResultStr		= @"No street information provided";
static NSString							*kNoCityResultStr			= @"No city provided";
static NSString							*kNoStateResultStr			= @"No state provided";
static NSString							*kNoCountyResultStr			= @"No county provided";
static NSString							*kNoStreetNumberResultStr	= @"No street number provided";
static NSString							*kNoCountryResultStr		= @"No country provided";
static NSString							*kNoZipCodeResultStr		= @"No zipcode provided";
static NSString							*kNoCountryCodeResultStr	= @"No country code provided";
static NSString							*kNoLandmarkResultStr		= @"No landmark data provided";

// FORMATTING STRINGS
static NSString							*kCityStateFormatStr		= @"%@, %@";
static NSString							*kAddressLineFormatStr		= @"%@ %@";

// const values for determining distance ("the earth is round")
const double							GREAT_CIRCLE_RADIUS_KILOMETERS = 6371.797;
const double							GREAT_CIRCLE_RADIUS_MILES = 3438.461;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =========================== Begin Class S4Placemark () ==============================

@interface S4Placemark ()

@property (nonatomic, copy) NSString						*m_titleStr;
@property (nonatomic, retain) MKReverseGeocoder				*m_mkReverseGeoCoder;

@end



// ===================== Begin Class S4Placemark (PrivateImpl) =========================

@interface S4Placemark (PrivateImpl)

- (double)distanceToLocation: (S4Placemark *)otherPlacemark useKilometers: (BOOL)bInKm;
- (NSString *)getStringAttributeForKey: (NSString *)key defaultValue: (NSString *)defaultStr;
- (void)setAddressDictionary: (NSDictionary *)newDictionary;

- (void)setCLLocationWithLatitude: (CLLocationDegrees)newLatitude longitude: (CLLocationDegrees)newLongitude;

@end



@implementation S4Placemark (PrivateImpl)

//============================================================================
//	S4Placemark (PrivateImpl) :: distanceToLocation:
//============================================================================
- (double)distanceToLocation: (S4Placemark *)otherPlacemark useKilometers: (BOOL)bInKm
{
	double					lat1;
    double					lng1;
    double					lat2;
    double					lng2;
	double					diff;
	double					distance;
	
	if (otherPlacemark == nil)
	{
		return kS4LOCATION_DISTANCE_UNKNOWN;
	}

	lat1 = (self.latitude / 180) * M_PI;
	lng1 = (self.longitude / 180) * M_PI;
	lat2 = (otherPlacemark.latitude / 180) * M_PI;
	lng2 = (otherPlacemark.longitude / 180) * M_PI;

	diff = lng1 - lng2;

	if (diff < 0)
	{
		diff = -diff;
	}

	if (diff > M_PI)
	{
		diff = 2 * M_PI;
	}

	distance = acos(sin(lat2) * sin(lat1) + cos(lat2) * cos(lat1) * cos(diff));

	if (YES == bInKm)
	{
		distance *= GREAT_CIRCLE_RADIUS_KILOMETERS;
	}
	else
	{
		distance *= GREAT_CIRCLE_RADIUS_MILES;
	}
	return (distance);
}


//============================================================================
//	S4Placemark (PrivateImpl) :: getStringAttributeForKey:
//============================================================================
- (NSString *)getStringAttributeForKey: (NSString *)key defaultValue: (NSString *)defaultStr
{
	NSString			*tmpStr;
	NSString			*valueResult;
	
	valueResult = defaultStr;
	if (IS_NOT_NULL(m_addressDictionary) && (STR_NOT_EMPTY(key)))
	{
		tmpStr = [m_addressDictionary objectForKey: key];
		if (STR_NOT_EMPTY(tmpStr))
		{
			valueResult = tmpStr;
		}
	}
	return (valueResult);
}


//============================================================================
//	S4Placemark (PrivateImpl) :: setAddressDictionary:
//============================================================================
- (void)setAddressDictionary: (NSDictionary *)newDictionary
{
	if IS_NOT_NULL(m_addressDictionary)
	{
		[m_addressDictionary release];
		m_addressDictionary = nil;
	}

	if IS_NOT_NULL(newDictionary)
	{
		m_addressDictionary = [newDictionary copy];
	}
}


//============================================================================
//	S4Placemark (PrivateImpl) :: setCLLocation:
//============================================================================
- (void)setCLLocationWithLatitude: (CLLocationDegrees)newLatitude longitude: (CLLocationDegrees)newLongitude
{
	if IS_NOT_NULL(m_clLocation)
	{
		[m_clLocation release];
		m_clLocation = nil;
	}

	m_clLocation = [[[CLLocation alloc] initWithLatitude: newLatitude longitude: newLongitude] retain];
}

@end



// ========================= Begin Class S4Placemark ==========================

@implementation S4Placemark

//============================================================================
//	S4Placemark :: properties
//============================================================================
// private member vars
@synthesize m_titleStr;
@synthesize addressDictionary = m_addressDictionary;
@synthesize m_mkReverseGeoCoder;
@synthesize clLocation = m_clLocation;


//============================================================================
//	S4Placemark :: init
//============================================================================
- (id)init
{
	id			idResult = nil;
	
	self = [super init];
	if (nil != self)
	{
		// private instance member vars
		m_titleStr = nil;
		m_addressDictionary = nil;
		m_mkReverseGeoCoder = nil;
		m_clLocation = nil;
		m_bIsFavorite = NO;
		m_bIsLocal = NO;

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4Placemark :: initWithCoordinate:
//============================================================================
- (id)initWithCoordinate: (CLLocationCoordinate2D)coordinate
				andTitle: (NSString *)title
				 isLocal: (BOOL)bIsLocal
{
	id			idResult = nil;
	
	self = [super init];
	if (nil != self)
	{
		// private instance member vars
		self.m_titleStr = title;
		m_addressDictionary = nil;
		m_mkReverseGeoCoder = nil;
		[self setCLLocationWithLatitude: coordinate.latitude longitude: coordinate.longitude];
		m_bIsFavorite = NO;
		m_bIsLocal = bIsLocal;

		idResult = self;
	}
	return (idResult);	
}


//============================================================================
//	S4Placemark :: initWithAddressDictionary:
//============================================================================
- (id)initWithAddressDictionary: (NSDictionary *)addressDictionary
				needsConversion: (BOOL)bConvertDict
					   andTitle: (NSString *)title
						isLocal: (BOOL)bIsLocal
{
	NSDictionary				*convertedDictionary;
	id							idResult = nil;
	
	self = [super init];
	if (nil != self)
	{
		// private instance member vars
		self.m_titleStr = title;

		if (YES == bConvertDict)
		{
			convertedDictionary = [self convertDictionary: addressDictionary];
			[self setAddressDictionary: convertDictionary];
		}
		else
		{
			[self setAddressDictionary: addressDictionary];
		}

		m_mkReverseGeoCoder = nil;
		[self setCLLocationWithLatitude: 0.0 longitude: 0.0];
		m_bIsFavorite = NO;
		m_bIsLocal = bIsLocal;

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4Placemark :: initWithCoordinate:addressDictionary:
//============================================================================
- (id)initWithCoordinate: (CLLocationCoordinate2D)coordinate
	   addressDictionary: (NSDictionary *)addressDictionary
		 needsConversion: (BOOL)bConvertDict
				andTitle: (NSString *)title
				 isLocal: (BOOL)bIsLocal
{
	id			idResult = nil;
	
	self = [super init];
	if (nil != self)
	{
		// private instance member vars
		self.m_titleStr = title;

		if (YES == bConvertDict)
		{
			convertedDictionary = [self convertDictionary: addressDictionary];
			[self setAddressDictionary: convertDictionary];
		}
		else
		{
			[self setAddressDictionary: addressDictionary];
		}

		m_mkReverseGeoCoder = nil;
		[self setCLLocationWithLatitude: coordinate.latitude longitude: coordinate.longitude];
		m_bIsFavorite = NO;
		m_bIsLocal = bIsLocal;

		idResult = self;
	}
	return (idResult);	
}


//============================================================================
//	S4Placemark :: dealloc
//============================================================================
- (void)dealloc
{
	self.m_titleStr = nil;

	[self setAddressDictionary: nil];

	if (nil != m_mkReverseGeoCoder)
	{
		if ([m_mkReverseGeoCoder isQuerying])
		{
			[m_mkReverseGeoCoder cancel];
			m_mkReverseGeoCoder.delegate = nil;
		}
		[m_mkReverseGeoCoder release];
		m_mkReverseGeoCoder = nil;
	}

	if IS_NOT_NULL(m_clLocation)
	{
		[m_clLocation release];
		m_clLocation = nil;
	}
	
//	if (nil != self.m_longitudeStr)
//	{
//		[self.m_longitudeStr release];
//		self.m_longitudeStr = nil;
//	}

    [super dealloc];
}












//============================================================================
//	S4Placemark :: convertDictionary:
//		OVERRIDE this method if you want to convert "your" NSDictionary into
//		a dictionary containing keys and values from an Address Book record
//============================================================================
- (NSDictionary *)convertDictionary: (NSDictionary *)addressDictionary
{
/*
 // Property keys
 extern const ABPropertyID kABPersonFirstNameProperty;          // First name - kABStringPropertyType
 extern const ABPropertyID kABPersonLastNameProperty;           // Last name - kABStringPropertyType
 extern const ABPropertyID kABPersonMiddleNameProperty;         // Middle name - kABStringPropertyType
 extern const ABPropertyID kABPersonPrefixProperty;             // Prefix ("Sir" "Duke" "General") - kABStringPropertyType
 extern const ABPropertyID kABPersonSuffixProperty;             // Suffix ("Jr." "Sr." "III") - kABStringPropertyType
 extern const ABPropertyID kABPersonNicknameProperty;           // Nickname - kABStringPropertyType
 extern const ABPropertyID kABPersonFirstNamePhoneticProperty;  // First name Phonetic - kABStringPropertyType
 extern const ABPropertyID kABPersonLastNamePhoneticProperty;   // Last name Phonetic - kABStringPropertyType
 extern const ABPropertyID kABPersonMiddleNamePhoneticProperty; // Middle name Phonetic - kABStringPropertyType
 extern const ABPropertyID kABPersonOrganizationProperty;       // Company name - kABStringPropertyType
 extern const ABPropertyID kABPersonJobTitleProperty;           // Job Title - kABStringPropertyType
 extern const ABPropertyID kABPersonDepartmentProperty;         // Department name - kABStringPropertyType
 extern const ABPropertyID kABPersonEmailProperty;              // Email(s) - kABMultiStringPropertyType
 extern const ABPropertyID kABPersonBirthdayProperty;           // Birthday associated with this person - kABDateTimePropertyType
 extern const ABPropertyID kABPersonNoteProperty;               // Note - kABStringPropertyType
 extern const ABPropertyID kABPersonCreationDateProperty;       // Creation Date (when first saved)
 extern const ABPropertyID kABPersonModificationDateProperty;   // Last saved date
 
 // Addresses
 extern const ABPropertyID kABPersonAddressProperty;            // Street address - kABMultiDictionaryPropertyType
 extern const CFStringRef kABPersonAddressStreetKey;
 extern const CFStringRef kABPersonAddressCityKey;
 extern const CFStringRef kABPersonAddressStateKey;
 extern const CFStringRef kABPersonAddressZIPKey;
 extern const CFStringRef kABPersonAddressCountryKey;
 extern const CFStringRef kABPersonAddressCountryCodeKey;
 
*/

	return (nil);
}


- (NSMutableDictionary *)getAddressDictionary
{
	if ([self isKindOfClass: [S4Placemark class]])
	{
		return (m_addressDictionary);
	}
	return (nil);
}





//============================================================================
//	S4Placemark :: streetNumber
//============================================================================
- (NSString *)streetNumber
{
	return ([self getStringAttributeForKey: kSubThoroughfare
							  defaultValue: kNoStreetNumberResultStr]);
}


//============================================================================
//	S4Placemark :: street
//============================================================================
- (NSString *)street
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressStreetKey
							  defaultValue: kNoAddressResultStr]);
}


//============================================================================
//	S4Placemark :: city
//============================================================================
- (NSString *)city
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressCityKey
							  defaultValue: kNoCityResultStr]);
}


//============================================================================
//	S4Placemark :: county
//============================================================================
- (NSString *)county
{
	return ([self getStringAttributeForKey: kSubAdministrativeArea
							  defaultValue: kNoCountyResultStr]);
}


//============================================================================
//	S4Placemark :: state
//============================================================================
- (NSString *)state
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressStateKey
							  defaultValue: kNoStateResultStr]);
}


//============================================================================
//	S4Placemark :: zipCode
//============================================================================
- (NSString *)zipCode
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressZIPKey
							  defaultValue: kNoZipCodeResultStr]);
}










//============================================================================
//	S4Placemark :: favorite
//============================================================================
- (BOOL)favorite
{
	return (m_bIsFavorite);
}


//============================================================================
//	S4Placemark :: setFavorite
//============================================================================
- (void)setFavorite: (BOOL)bIsFavorite
{
	m_bIsFavorite = bIsFavorite;
}


//============================================================================
//	S4Placemark :: distanceInMiles:
//============================================================================
- (double)distanceInMiles: (S4Placemark *)otherPlacemark
{
	return ([self distanceToLocation: otherPlacemark useKilometers: NO]);
}


//============================================================================
//	S4Placemark :: distanceInMiles:
//============================================================================
- (double)distanceInKilometers: (S4Placemark *)otherPlacemark
{
	return ([self distanceToLocation: otherPlacemark useKilometers: YES]);
}


//============================================================================
//	S4Placemark :: latitude
//============================================================================
- (CLLocationDegrees)latitude
{
	return (self.clLocation.coordinate.latitude);
}


//============================================================================
//	S4Placemark :: latitudeAsString
//============================================================================
- (NSString *)latitudeAsString
{
	return ([S4GeoLocation doubleToString: self.clLocation.coordinate.latitude]);
}


//============================================================================
//	S4Placemark :: longitude
//============================================================================
- (CLLocationDegrees)longitude
{
	return (self.clLocation.coordinate.longitude);
}


//============================================================================
//	S4Placemark :: longitudeAsString
//============================================================================
- (NSString *)longitudeAsString
{
	return ([S4GeoLocation doubleToString: self.clLocation.coordinate.longitude]);
}



/*******************************************  MKPlacemark Property Support ********************************************/

//============================================================================
//	S4Placemark :: administrativeArea
//============================================================================
- (NSString *)administrativeArea
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressStateKey
							  defaultValue: kNoStateResultStr]);
}


//============================================================================
//	S4Placemark :: country
//============================================================================
- (NSString *)country
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressCountryKey
							  defaultValue: kNoCountryResultStr]);
}


//============================================================================
//	S4Placemark :: countryCode
//============================================================================
- (NSString *)countryCode
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressCountryCodeKey
							  defaultValue: kNoCountryCodeResultStr]);
}


//============================================================================
//	S4Placemark :: locality
//============================================================================
- (NSString *)locality
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressCityKey
							  defaultValue: kNoCityResultStr]);
}


//============================================================================
//	S4Placemark :: postalCode
//============================================================================
- (NSString *)postalCode
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressZIPKey
							  defaultValue: kNoZipCodeResultStr]);
}


//============================================================================
//	S4Placemark :: subAdministrativeArea
//============================================================================
- (NSString *)subAdministrativeArea
{
	return ([self getStringAttributeForKey: kSubAdministrativeArea
							  defaultValue: kNoCountyResultStr]);
}


//============================================================================
//	S4Placemark :: subLocality
//============================================================================
- (NSString *)subLocality
{
	return ([self getStringAttributeForKey: kSubLocality
							  defaultValue: kNoLandmarkResultStr]);
}


//============================================================================
//	S4Placemark :: subThoroughfare
//============================================================================
- (NSString *)subThoroughfare
{
	return ([self getStringAttributeForKey: kSubThoroughfare
							  defaultValue: kNoStreetNumberResultStr]);
}


//============================================================================
//	S4Placemark :: thoroughfare
//============================================================================
- (NSString *)thoroughfare
{
	return ([self getStringAttributeForKey: (NSString *)kABPersonAddressStreetKey
							  defaultValue: kNoAddressResultStr]);
}



/******************************************  MKAnnotation Protocol Methods *******************************************/

//============================================================================
//	S4Placemark :: coordinate
//============================================================================
- (CLLocationCoordinate2D)coordinate
{
	return (self.clLocation.coordinate);
}


//============================================================================
//	S4Placemark :: title
//============================================================================
- (NSString *)title
{
	return (m_titleStr);
}


//============================================================================
//	S4Placemark :: subtitle
//============================================================================
- (NSString *)subtitle
{
	if (YES == m_bIsLocal)
	{
		return ([NSString stringWithFormat: kAddressLineFormatStr, [self streetNumber], [self street]]);
	}
	return ([NSString stringWithFormat: kCityStateFormatStr, [self city], [self state]]);
}




/************************************  MKReverseGeocoderDelegate Protocol Methods ************************************/

//============================================================================
//	S4Placemark :: reverseGeocoder:didFindPlacemark:
//============================================================================
- (void)reverseGeocoder: (MKReverseGeocoder *)geocoder didFindPlacemark: (MKPlacemark *)placemark
{
/*
 NSDictionary			*addressDict;
 
 
 addressDict = placemark.addressDictionary;
 self.searchBar.text = [NSString stringWithFormat: kAddressFieldFormatStr,
 [addressDict objectForKey: (NSString *)kABPersonAddressCityKey],
 [addressDict objectForKey: (NSString *)kABPersonAddressStateKey],
 [addressDict objectForKey: (NSString *)kABPersonAddressZIPKey]];
 */
	[self.m_mkReverseGeoCoder cancel];

	if (IS_NOT_NULL(placemark))
	{
		if (STR_NOT_EMPTY(placemark.thoroughfare))
		{
			self.m_addressStr_1 = placemark.thoroughfare;
		}
		
		if (STR_NOT_EMPTY(placemark.subThoroughfare))
		{
			self.m_addressStr_2 = placemark.subThoroughfare;
		}
		
		if (STR_NOT_EMPTY(placemark.subLocality))
		{
			self.m_neighborhoodStr = placemark.subLocality;
		}
		
		if (STR_NOT_EMPTY(placemark.locality))
		{
			self.m_cityStr = placemark.locality;
		}
		
		if (STR_NOT_EMPTY(placemark.subAdministrativeArea))
		{
			self.m_countyStr = placemark.subAdministrativeArea;
		}
		
		if (STR_NOT_EMPTY(placemark.administrativeArea))
		{
			self.m_stateStr = placemark.administrativeArea;
		}
		
		if (STR_NOT_EMPTY(placemark.postalCode))
		{
			self.m_postalCodeStr = placemark.postalCode;
		}
		
		if (STR_NOT_EMPTY(placemark.country))
		{
			self.m_countryStr = placemark.country;
		}
		
		if (STR_NOT_EMPTY(placemark.countryCode))
		{
			self.m_countryCodeStr = placemark.countryCode;
		}
		
		if (IS_NOT_NULL(placemark.addressDictionary))
		{
			self.m_addressDictionary = placemark.addressDictionary;
		}
	}
}

//============================================================================
//	S4Placemark :: reverseGeocoder:didFailWithError:
//============================================================================
- (void)reverseGeocoder: (MKReverseGeocoder *)geocoder didFailWithError: (NSError *)error
{
	[self.m_mkReverseGeoCoder cancel];
//	[self performSelectorOnMainThread: @selector(receivedCoreLocationError:) withObject: kUnableToFindLocation waitUntilDone: NO];
}



/*********************************************  NSCoding Protocol Methods *********************************************/

//============================================================================
//	S4Placemark :: encodeWithCoder
//============================================================================
- (void)encodeWithCoder: (NSCoder *)encoder
{
	// encode the superclass, unless it is NSObject
	[super encodeWithCoder: encoder];
	
	// encode the class member vars
	[encoder encodeObject:	self.m_titleStr		forKey:	kCodingKey_1];
	[encoder encodeObject:	m_addressDictionary	forKey:	kCodingKey_2];
	[encoder encodeObject:	m_clLocation		forKey:	kCodingKey_3];
	[encoder encodeBool:	m_bIsFavorite		forKey:	kCodingKey_4];
	[encoder encodeBool:	m_bIsLocal			forKey:	kCodingKey_5];

/*
	[encoder encodeInt32:	(int32_t)intv		forKey:	(NSString *)key];
	[encoder encodeInt:		(int)intv			forKey:	(NSString *)key];
*/
/*
	[encoder encodeObject: self.m_neighborhoodStr forKey:		kCodingKey_14];
	[encoder encodeObject: self.m_cityStr forKey:				kCodingKey_19];
	[encoder encodeObject: self.m_countyStr forKey:			kCodingKey_6];
	[encoder encodeObject: self.m_stateStr forKey:			kCodingKey_7];
	[encoder encodeObject: self.m_postalCodeStr forKey:		kCodingKey_8];
	[encoder encodeObject: self.m_countryStr forKey:			kCodingKey_9];
	[encoder encodeObject: self.m_countryCodeStr forKey:		kCodingKey_10];
	[encoder encodeObject: self.m_phoneStr forKey:			kCodingKey_11];
	[encoder encodeObject: self.m_addressDictionary forKey:	kCodingKey_12];
	[encoder encodeObject: self.m_latitudeStr forKey:			kCodingKey_15];
	[encoder encodeObject: self.m_longitudeStr forKey:		kCodingKey_16];
	[encoder encodeDouble: m_cl2DCoordinate.latitude forKey:	kCodingKey_17];
	[encoder encodeDouble: m_cl2DCoordinate.longitude forKey:	kCodingKey_18];
*/
	
}


//============================================================================
//	S4Placemark :: initWithCoder
//============================================================================
- (id)initWithCoder: (NSCoder *)decoder
{
	id			idResult = nil;

	// decode the superclass, unless it is NSObject
	self = [super initWithCoder: decoder];
	if (nil != self)
	{
		// decode the class member vars
		self.m_titleStr			= [[decoder	decodeObjectForKey:	kCodingKey_1] retain];
		m_addressDictionary		= [[decoder	decodeObjectForKey:	kCodingKey_2] retain];
		m_clLocation			= [[decoder	decodeObjectForKey:	kCodingKey_3] retain];
		m_bIsFavorite			= [decoder	decodeBoolForKey:	kCodingKey_4];
		m_bIsLocal				= [decoder	decodeBoolForKey:	kCodingKey_5];

		m_mkReverseGeoCoder = nil;
/*
		(int32_t)				= [decoder decodeInt32ForKey:	(NSString *)key]:
		(int)					= [decoder decodeIntForKey:		(NSString *)key]:
*/
/*
		self.m_neighborhoodStr		= [[decoder decodeObjectForKey: kCodingKey_4] retain];
		self.m_cityStr				= [[decoder decodeObjectForKey: kCodingKey_5] retain];
		self.m_countyStr			= [[decoder decodeObjectForKey: kCodingKey_6] retain];
		self.m_stateStr				= [[decoder decodeObjectForKey: kCodingKey_7] retain];
		self.m_postalCodeStr		= [[decoder decodeObjectForKey: kCodingKey_8] retain];
		self.m_countryStr			= [[decoder decodeObjectForKey: kCodingKey_9] retain];
		self.m_countryCodeStr		= [[decoder decodeObjectForKey: kCodingKey_10] retain];
		self.m_phoneStr				= [[decoder decodeObjectForKey: kCodingKey_11] retain];
		self.m_addressDictionary	= [[decoder decodeObjectForKey: kCodingKey_12] retain];
		
		self.m_latitudeStr			= [[decoder decodeObjectForKey: kCodingKey_15] retain];
		self.m_longitudeStr			= [[decoder decodeObjectForKey: kCodingKey_16] retain];
		m_cl2DCoordinate.latitude	= [decoder decodeDoubleForKey:  kCodingKey_17];
		m_cl2DCoordinate.longitude	= [decoder decodeDoubleForKey:  kCodingKey_18];
*/
		idResult = self;
	}
	return (idResult);
}

@end
