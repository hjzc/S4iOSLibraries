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
 * Name:		XmlToDictParser.m
 * Module:		Test
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <CoreLocation/CLLocation.h>
#import "XmlToDictParser.h"
#import "AppDelegate_Shared.h"
#import "S4NetUtilities.h"
#import "S4FileUtilities.h"
#import "S4CommonDefines.h"
#import "S4CoreLocationManager.h"


// ================================== Defines ==========================================

#define WAIT_FOR_CORE_LOCATION_AVAIL			4


// ================================== Typedefs ==========================================




// ================================== Globals ==========================================

// This is the base URL string for Yahoo Local Services - passing in a location.  Use stringWithFormat in this format:
//  kYahooLocationService, kYahooDevApiKey, kCoffeeQueryStr, kCategoryInt, User Prefs address, User Prefs search radius
static NSString							*kYahooLocationService		= @"http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=%@&query=%@&category=%d&location=%@&results=20&sort=distance&radius=%@&output=xml";

// This is the base URL string for Yahoo Local Services - passing in a latitude and longitude.  Use stringWithFormat in this format:
//  kYahooCoordinateService, kYahooDevApiKey, kCoffeeQueryStr, kCategoryInt, Latitude, Longitude, User Prefs search radius
static NSString							*kYahooCoordinateService	= @"http://local.yahooapis.com/LocalSearchService/V3/localSearch?appid=%@&query=%@&category=%d&latitude=%f&longitude=%f&results=20&sort=distance&radius=%@&output=xml";

// This is the Yahoo App Developer API key to pass to te local.yahooapis.com service
static NSString							*kYahooDevApiKey		= @"qTT0aj3V34Ey8j1hI8rgejuMg7fe18V_RhNtmIY5YWf4tlhW9tAUohDuRLaCCjEl.LoN";

// This is the query string passed to the service to look up coffee shops
static NSString							*kCoffeeQueryStr		= @"coffee";

// This is the category code for "coffee houses"
static int								kCategoryInt			= 96926169;

// Element names for the Yahoo local service coffee vendor XML feed
static NSString							*kResult_Element		= @"Result";

static NSString							*kTestAddressStr		= @"619 Market Street, San Francisco, CA 94105";
static NSString							*kSearchRadius			= @"40";


// =========================== Begin Class XmlToDictParser () ===========================

//@interface XmlToDictParser ()

//@end



// ================================== Begin Class XmlToDictParser ==================================

@implementation XmlToDictParser


//============================================================================
//	XmlToDictParser :: init
//============================================================================
- init
{
	if (self = [super init])
	{
	}
	return (self);
}


//============================================================================
//	XmlToDictParser :: dealloc
//============================================================================
- (void)dealloc
{
	[super dealloc];
}


//============================================================================
//	XmlToDictParser :: start
//============================================================================
- (BOOL)start
{
	S4CoreLocationManager				*corelocMgr;
//	int									i;
	CLLocation							*curCLLocation;
	CLLocationDegrees					latitude;
	CLLocationDegrees					longitude;
	NSString							*urlStr = nil;
	NSString							*pathStr = nil;
	BOOL								bResult = NO;

	// see if CoreLocation is enabled and getting data
	corelocMgr = [S4CoreLocationManager getInstance];
	if ([corelocMgr locationServicesAvailable])
	{
		// get the current CL value
		curCLLocation = [corelocMgr lastLocation];
		if (nil != curCLLocation)
		{
			latitude = curCLLocation.coordinate.latitude;
			longitude = curCLLocation.coordinate.longitude; 
			urlStr = [[NSString alloc] initWithFormat: kYahooCoordinateService, kYahooDevApiKey, kCoffeeQueryStr, kCategoryInt, latitude, longitude, kSearchRadius];
		}
	}

	// if CoreLocation is not working or taking too long, use a hardcoded location instead
	if (nil == urlStr)
	{
		urlStr = [[NSString alloc] initWithFormat: kYahooLocationService, kYahooDevApiKey, kCoffeeQueryStr, kCategoryInt, kTestAddressStr, kSearchRadius];
	}

	bResult = [self startParsingFromUrlPath: urlStr rootElementName: kResult_Element withObject: nil];
	if (NO == bResult)
	{
		pathStr = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: LOCAL_XML_FILE];
		bResult = [self startParsingFromFilePath: pathStr rootElementName: kResult_Element withObject: nil];
	}
	return (bResult);
}

@end
