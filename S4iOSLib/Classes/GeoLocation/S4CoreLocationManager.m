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
 * Name:		S4CoreLocationManager.m
 * Module:		GeoLocation
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4CoreLocationManager.h"
#import "S4SingletonClass.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ======================= Begin Class S4CoreLocationManager () ========================

@interface S4CoreLocationManager ()

@property (nonatomic, copy) CLLocation								*m_lastLocation;
@property (nonatomic, retain) NSDate								*m_clMgrStartTime;

@end



// ================= Begin Class S4CoreLocationManager (PrivateImpl) ===================

@interface S4CoreLocationManager (PrivateImpl)

- (void)oneTimeInit;
- (BOOL)isValidLocation: (CLLocation *)newLocation withRespectToOldLocation: (CLLocation *)oldLocation;
- (BOOL)isValidLocation: (CLLocation *)location;

@end



@implementation S4CoreLocationManager (PrivateImpl)

//============================================================================
//	S4CoreLocationManager (PrivateImpl) :: oneTimeInit
//============================================================================
- (void)oneTimeInit
{
	// set up the CoreLocationManager member var and set self as delegate
	m_CLLocationManager = [[CLLocationManager alloc] init];
	if (nil != m_CLLocationManager)
	{
		m_CLLocationManager.delegate = self;
		m_delegateArray = [[S4DelgateArray alloc] initWithCapacity: (NSUInteger)2];
		m_bIsRunning = NO;
		self.m_lastLocation = nil;
		self.shouldDisplayHeadingCalDialog = NO;
		self.m_clMgrStartTime = [NSDate date];
	}		
}


//============================================================================
//	S4CoreLocationManager (PrivateImpl) :: isValidLocation:withRespectToOldLocation
//============================================================================
- (BOOL)isValidLocation: (CLLocation *)newLocation withRespectToOldLocation: (CLLocation *)oldLocation
{
	NSTimeInterval				secondsSinceLastPoint;
	NSTimeInterval				secondsSinceManagerStarted;
	BOOL						bResult = NO;
	
	// Filter out nil locations
	if ((IS_NOT_NULL(newLocation)) && (IS_NOT_NULL(oldLocation)))
	{
		// Negative accuracy means an invalid or unavailable measurement
		if (newLocation.horizontalAccuracy >= 0)
		{
			// Filter out points that are out of order
			secondsSinceLastPoint = [newLocation.timestamp timeIntervalSinceDate: oldLocation.timestamp];
			if (secondsSinceLastPoint >= 0)
			{
				// Filter out points created before the manager was initialized
				secondsSinceManagerStarted = [newLocation.timestamp timeIntervalSinceDate: self.m_clMgrStartTime];
				if (secondsSinceManagerStarted >= 0)
				{
					// The newLocation is good to use
					bResult = YES;
				}
			}			
		}
	}
	return (bResult);
}


//============================================================================
//	S4CoreLocationManager (PrivateImpl) :: isValidLocation
//============================================================================
- (BOOL)isValidLocation: (CLLocation *)location
{
	NSTimeInterval				secondsSinceManagerStarted;
	BOOL						bResult = NO;
	
	// Filter out nil locations
	if (IS_NOT_NULL(location))
	{
		// Negative accuracy means an invalid or unavailable measurement
		if (location.horizontalAccuracy >= 0)
		{
			// Filter out points created before the manager was initialized
			secondsSinceManagerStarted = [location.timestamp timeIntervalSinceDate: self.m_clMgrStartTime];
			if (secondsSinceManagerStarted >= 0)
			{
				// The newLocation is good to use
				bResult = YES;
			}
		}
	}
	return (bResult);
}

@end



// ==================== Begin Class S4CoreLocationManager ====================

@implementation S4CoreLocationManager


//============================================================================
//	S4CoreLocationManager synthesize properties
//============================================================================
@synthesize m_lastLocation;
@synthesize m_clMgrStartTime;
@synthesize shouldDisplayHeadingCalDialog = m_bDisplayHeadingCalDialog;


///////////////////////////////////// START SINGLETON METHODS /////////////////////////////////////


SYNTHESIZE_SINGLETON_CLASS(S4CoreLocationManager)


//////////////////////////////////////// INSTANCE METHODS /////////////////////////////////////////


//============================================================================
//	S4CoreLocationManager :: startUpdatesWithAccuracy
//============================================================================
- (void)startUpdatesWithAccuracy: (LocationAccuracy)newAccuracy
{
	if (NO == m_bIsRunning)
	{
		m_bIsRunning = YES;
		[self setAccuracy: newAccuracy];
		[m_CLLocationManager startUpdatingLocation];			// start up the CLLocationManager
	}
}


//============================================================================
//	S4CoreLocationManager :: stopUpdates
//============================================================================
- (void)stopUpdates
{
	if (YES == m_bIsRunning)
	{
		m_bIsRunning = NO;
		[m_CLLocationManager stopUpdatingLocation];
	}
}


//============================================================================
//	S4CoreLocationManager :: setAccuracy
//============================================================================
- (void)setAccuracy: (LocationAccuracy)newAccuracy
{
	if (kHighestAccuracy == newAccuracy)
	{
		m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
		m_CLLocationManager.distanceFilter = kCLDistanceFilterNone;
	}
	else if (kHighAccuracy == newAccuracy)
	{
		m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
		m_CLLocationManager.distanceFilter = 10;
	}
	else if (kMediumAccuracy == newAccuracy)
	{
		m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
		m_CLLocationManager.distanceFilter = 100;
	}
	else if (kLowAccuracy == newAccuracy)
	{
		m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
		m_CLLocationManager.distanceFilter = 1000;
	}
	else if (kLowestAccuracy == newAccuracy)
	{
		m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
		m_CLLocationManager.distanceFilter = 3000;
	}
	else if (kDefaultAccuracy == newAccuracy)
	{
		m_CLLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
		m_CLLocationManager.distanceFilter = kCLDistanceFilterNone;
	}
}


//============================================================================
//	S4CoreLocationManager :: locationServicesAvailable
//============================================================================
- (BOOL)locationServicesAvailable
{
	return (m_CLLocationManager.locationServicesEnabled);
}


//============================================================================
//	S4CoreLocationManager :: addDelegate
//============================================================================
- (BOOL)addDelegate: (id <S4CoreLocationMgrDelegate>)newDelegate
{
	return ([m_delegateArray addDelegate: newDelegate conformsToProtocol: @protocol(S4CoreLocationMgrDelegate)]);
}


//============================================================================
//	S4CoreLocationManager :: removeDelegate
//============================================================================
- (BOOL)removeDelegate: (id <S4CoreLocationMgrDelegate>)removeDelegate
{
	return ([m_delegateArray removeDelegate: removeDelegate conformsToProtocol: @protocol(S4CoreLocationMgrDelegate)]);
}


//============================================================================
//	S4CoreLocationManager :: lastLocation
//============================================================================
- (CLLocation *)lastLocation
{
	return (self.m_lastLocation);
}


//============================================================================
//	S4CoreLocationManager :: resetLastLocation
//============================================================================
- (void)resetLastLocation
{
	self.m_clMgrStartTime = [NSDate date];
	self.m_lastLocation = nil;
}



/******************************************  CLLocationManager Delegate Methods ******************************************/

//============================================================================
//	S4CoreLocationManager :: didUpdateToLocation
//============================================================================
- (void)locationManager: (CLLocationManager *)manager didUpdateToLocation: (CLLocation *)newLocation fromLocation: (CLLocation *)oldLocation
{
	NSArray						*argArray;

	// if we have not yet had a valid CLLocation update, see if this one is good
	if (nil == self.m_lastLocation)
	{
		if (YES == [self isValidLocation: newLocation])
		{
			self.m_lastLocation = newLocation;

			// Send the update to our delegate on the main thread
			argArray = [NSArray arrayWithObjects: self, newLocation, nil];
			[m_delegateArray performDelegateSelectorOnMainThread: @selector(coreLocManager:newLocationUpdate:)
												   withArguments: argArray];			
		}		
	}
	else if (YES == [self isValidLocation: newLocation withRespectToOldLocation: self.m_lastLocation])
	{
		self.m_lastLocation = newLocation;
		// Send the update to our delegate on the main thread
		argArray = [NSArray arrayWithObjects: self, newLocation, nil];
		[m_delegateArray performDelegateSelectorOnMainThread: @selector(coreLocManager:newLocationUpdate:)
											   withArguments: argArray];
	}
}


//============================================================================
//	S4CoreLocationManager :: didFailWithError
//============================================================================
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
	NSMutableString						*errorString;
	NSArray								*argArray;

	errorString = [[[NSMutableString alloc] init] autorelease];
	if ([error domain] == kCLErrorDomain)
	{
		switch ([error code])
		{
			case kCLErrorDenied:
				[errorString appendFormat: @"%@\n", @"User is blocking Location Services"];
				[self stopUpdates];
				break;
			case kCLErrorLocationUnknown:
				[errorString appendFormat: @"%@\n", @"Unable to determine location"];
				break;
			default:
				[errorString appendFormat: @"%@ %d\n", @"Generic Location Error:", [error code]];
				break;
		}
	}
	else
	{
		[errorString appendFormat: @"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat: @"Description: \"%@\"\n", [error localizedDescription]];
	}

	// Send the update to our delegate on the main thread
	argArray = [NSArray arrayWithObjects: self, errorString, nil];
	[m_delegateArray performDelegateSelectorOnMainThread: @selector(coreLocManager:newError:)
										   withArguments: argArray];
}


//============================================================================
//	S4CoreLocationManager :: didUpdateHeading
//============================================================================
- (void)locationManager: (CLLocationManager *)manager didUpdateHeading: (CLHeading *)newHeading
{
	NSArray								*argArray;

	// Send the update to our delegate on the main thread
	argArray = [NSArray arrayWithObjects: self, newHeading, nil];
	[m_delegateArray performDelegateSelectorOnMainThread: @selector(coreLocManager:newHeadingUpdate:)
										   withArguments: argArray];	
}


//============================================================================
//	S4CoreLocationManager :: locationManagerShouldDisplayHeadingCalibration
//============================================================================
- (BOOL)locationManagerShouldDisplayHeadingCalibration: (CLLocationManager *)manager
{
	return (self.shouldDisplayHeadingCalDialog);
}

@end
