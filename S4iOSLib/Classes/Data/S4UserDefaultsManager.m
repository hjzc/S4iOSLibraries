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
 * Name:		S4UserDefaultsManager.m
 * Module:		Data
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4UserDefaultsManager.h"
#import "S4SingletonClass.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================

#define DFLT_DICT_SIZE					(NSUInteger)8


// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ================= Begin Class S4UserDefaultsManager (PrivateImpl) ===================

@interface S4UserDefaultsManager (PrivateImpl)

- (id)getUserDefaultsObjectForKey: (NSString *)key;
- (void)setUserDefaultsObject: (id)value forKey: (NSString *)key;
- (id)getEncodedObjectForKey: (NSString *)key;
- (void)setObjectToEncode: (id)object forKey: (NSString *)key;
- (void)oneTimeInit;

@end




@implementation S4UserDefaultsManager (PrivateImpl)

//============================================================================
//	S4UserDefaultsManager (PrivateImpl) :: getUserDefaultsObjectForKey:
//============================================================================
- (id)getUserDefaultsObjectForKey: (NSString *)key
{
	id						idResult = nil;

	if (YES == m_bHasRegistered)
	{
		if (STR_NOT_EMPTY(key))
		{
			idResult = [[NSUserDefaults standardUserDefaults] objectForKey: key];
		}
		else
		{
			@throw [NSException exceptionWithName: NSInvalidArgumentException
										   reason: @"S4UserDefaultsManager invalid key passed to getter method"
										 userInfo: nil];
		}
	}
	else
	{
		@throw [NSException exceptionWithName: NSInternalInconsistencyException
									   reason: @"S4UserDefaultsManager registerDefaults has not been called"
									 userInfo: nil];
	}
	return (idResult);
}


//============================================================================
//	S4UserDefaultsManager (PrivateImpl) :: setUserDefaultsObject:
//============================================================================
- (void)setUserDefaultsObject: (id)object forKey: (NSString *)key
{
	id						value;

	// check to see if registerDefaults has been called first
	if (YES == m_bHasRegistered)
	{
		if (STR_NOT_EMPTY(key))
		{
			if (IS_NULL(object))
			{
				value = [NSNull null];
			}
			else
			{
				value = object;
			}
			[[NSUserDefaults standardUserDefaults] setObject: value forKey: key];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		else		// bad key
		{
			@throw [NSException exceptionWithName: NSInvalidArgumentException
										   reason: @"S4UserDefaultsManager invalid key passed to setter method"
										 userInfo: nil];
		}
	}
	else		// no call to registerDefaults; throw an exception
	{
		@throw [NSException exceptionWithName: NSInternalInconsistencyException
									   reason: @"S4UserDefaultsManager registerDefaults has not been called"
									 userInfo: nil];
	}
}


//============================================================================
//	S4UserDefaultsManager (PrivateImpl) :: getEncodedObjectForKey:
//============================================================================
- (id)getEncodedObjectForKey: (NSString *)key
{
	NSData					*data;
	id						idResult = nil;

	// check to see if registerDefaults has been called first
	if (YES == m_bHasRegistered)
	{
		if (STR_NOT_EMPTY(key))
		{
			data = [self dataForKey: key];
			if (IS_NOT_NULL(data))
			{
				idResult = [NSKeyedUnarchiver unarchiveObjectWithData: data];
			}
			else
			{
				idResult = [NSNull null];
			}
		}
		else		// bad key
		{
			@throw [NSException exceptionWithName: NSInvalidArgumentException
										   reason: @"S4UserDefaultsManager invalid key passed to getter method"
										 userInfo: nil];
		}
	}
	else		// no call to registerDefaults; throw an exception
	{
		@throw [NSException exceptionWithName: NSInternalInconsistencyException
									   reason: @"S4UserDefaultsManager registerDefaults has not been called"
									 userInfo: nil];
	}	
	return (idResult);
}


//============================================================================
//	S4UserDefaultsManager (PrivateImpl) :: setObjectToEncode:
//============================================================================
- (void)setObjectToEncode: (id)object forKey: (NSString *)key
{
	NSData				*data;

	// check to see if registerDefaults has been called first
	if (YES == m_bHasRegistered)
	{
		if (STR_NOT_EMPTY(key))
		{
			if (IS_NULL(object))
			{
				data = (NSData *)[NSNull null];
			}
			else
			{
				data = [NSKeyedArchiver archivedDataWithRootObject: object];
			}
			[self setUserDefaultsObject: data forKey: key];
		}
		else		// bad key
		{
			@throw [NSException exceptionWithName: NSInvalidArgumentException
										   reason: @"S4UserDefaultsManager invalid key passed to setter method"
										 userInfo: nil];
		}
	}
	else		// no call to registerDefaults; throw an exception
	{
		@throw [NSException exceptionWithName: NSInternalInconsistencyException
									   reason: @"S4UserDefaultsManager registerDefaults has not been called"
									 userInfo: nil];
	}	
}


//============================================================================
//	S4UserDefaultsManager (PrivateImpl) :: oneTimeInit
//============================================================================
- (void)oneTimeInit
{
	m_userDefaultsDictionary = [NSMutableDictionary dictionaryWithCapacity: DFLT_DICT_SIZE];
	m_bHasRegistered = NO;
}

@end




// =================== Begin Class S4UserDefaultsManager =====================

@implementation S4UserDefaultsManager


///////////////////////////////////// START SINGLETON METHODS /////////////////////////////////////


SYNTHESIZE_SINGLETON_CLASS(S4UserDefaultsManager)


///////////////////////////////////// INSTANCE METHODS /////////////////////////////////////

//============================================================================
//	S4UserDefaultsManager :: registerDefaults
//============================================================================
- (BOOL)registerDefaults
{
	BOOL						bNeedToRegister;
	int							count;
	NSEnumerator				*keys;
	NSString					*curKey;
	id							curValue;

	// check if this is the first time we are running
	bNeedToRegister = NO;
	count = 0;
	keys = [m_userDefaultsDictionary keyEnumerator];
	curKey = [keys nextObject];
	while (STR_NOT_EMPTY(curKey))
	{
		count++;
		curValue = [[NSUserDefaults standardUserDefaults] objectForKey: curKey];
		if (nil == curValue)
		{
			bNeedToRegister = YES;
			break;
		}
		curKey = [keys nextObject];
	}

	// check to make sure client has set at least one user default value in dictionary
	if (0 < count)
	{
		if (YES == bNeedToRegister)
		{
			[[NSUserDefaults standardUserDefaults] registerDefaults: m_userDefaultsDictionary];
			m_bHasRegistered = [[NSUserDefaults standardUserDefaults] synchronize];
		}
		else
		{
			m_bHasRegistered = YES;
		}		
	}
	else
	{
		@throw [NSException exceptionWithName: NSInternalInconsistencyException
									   reason: @"S4UserDefaultsManager registerDefaults called with no user defaults set first"
									 userInfo: nil];
	}

	return (m_bHasRegistered);
}


//============================================================================
//	S4UserDefaultsManager :: addUserDefaultBool:
//============================================================================
- (void)addUserDefaultBool: (BOOL)bValue forKey: (NSString *)key
{
	NSNumber					*valueNumber;

	if (STR_NOT_EMPTY(key))
	{
		valueNumber = [NSNumber numberWithBool: bValue];
		[m_userDefaultsDictionary setObject: valueNumber forKey: key];
	}
}


//============================================================================
//	S4UserDefaultsManager :: addUserDefaultDouble:
//============================================================================
- (void)addUserDefaultDouble: (double)dValue forKey: (NSString *)key
{
	NSNumber					*valueNumber;

	if (STR_NOT_EMPTY(key))
	{
		valueNumber = [NSNumber numberWithDouble: dValue];
		[m_userDefaultsDictionary setObject: valueNumber forKey: key];
	}
}


//============================================================================
//	S4UserDefaultsManager :: addUserDefaultFloat:
//============================================================================
- (void)addUserDefaultFloat: (float)value forKey: (NSString *)key
{
	NSNumber					*valueNumber;

	if (STR_NOT_EMPTY(key))
	{
		valueNumber = [NSNumber numberWithFloat: value];
		[m_userDefaultsDictionary setObject: valueNumber forKey: key];
	}
}


//============================================================================
//	S4UserDefaultsManager :: addUserDefaultInteger:
//============================================================================
- (void)addUserDefaultInteger: (NSInteger)iValue forKey: (NSString *)key
{
	NSNumber					*valueNumber;

	if (STR_NOT_EMPTY(key))
	{
		valueNumber = [NSNumber numberWithInteger: iValue];
		[m_userDefaultsDictionary setObject: valueNumber forKey: key];
	}
}


//============================================================================
//	S4UserDefaultsManager :: addUserDefaultObject:
//============================================================================
- (void)addUserDefaultObject: (id)object ofType: (UserDefaultType)type forKey: (NSString *)key
{
	id							value = nil;

	// check for a valid key
	if (STR_NOT_EMPTY(key))
	{
		if (IS_NULL(object))
		{
			value = [NSNull null];
		}
		else
		{
			if (UDTypeUIColor == type)
			{
				value = [NSKeyedArchiver archivedDataWithRootObject: object];
			}
			else if ((UDTypeArray == type) ||
					 (UDTypeData == type) ||
					 (UDTypeDate == type) ||
					 (UDTypeDictionary == type) ||
					 (UDTypeNumber == type) ||
					 (UDTypeString == type))
			{
				value = object;
			}
			else
			{
				@throw [NSException exceptionWithName: NSInvalidArgumentException
											   reason: @"S4UserDefaultsManager unknown UDType passed to addUserDefaultObject method"
											 userInfo: nil];
			}
		}

		// now set the key and value in our user defaults dictionary
		if (nil != value)
		{
			[m_userDefaultsDictionary setObject: value forKey: key];
		}
	}
	else		// bad key
	{
		@throw [NSException exceptionWithName: NSInvalidArgumentException
									   reason: @"S4UserDefaultsManager invalid key passed to addUserDefaultObject method"
									 userInfo: nil];
	}
}


//============================================================================
//	S4UserDefaultsManager :: arrayForKey:
//============================================================================
- (NSMutableArray *)arrayForKey: (NSString *)key
{
	return ((NSMutableArray *)[[self getUserDefaultsObjectForKey: key] mutableCopy]);
}


//============================================================================
//	S4UserDefaultsManager :: setArray:
//============================================================================
- (void)setArray: (NSArray *)value forKey: (NSString *)key
{
	[self setUserDefaultsObject: value forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: boolForKey:
//============================================================================
- (BOOL)boolForKey: (NSString *)key
{
	NSNumber					*valueNumber;

	valueNumber = (NSNumber *)[self getUserDefaultsObjectForKey: key];
	return ([valueNumber boolValue]);
}


//============================================================================
//	S4UserDefaultsManager :: setBool:
//============================================================================
- (void)setBool: (BOOL)bValue forKey: (NSString *)key
{
	NSNumber					*valueNumber;

	valueNumber = [NSNumber numberWithBool: bValue];
	[self setUserDefaultsObject: valueNumber forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: colorForKey:
//============================================================================
- (UIColor *)colorForKey: (NSString *)key
{
	return ((UIColor *)[self getEncodedObjectForKey: key]);	
}


//============================================================================
//	S4UserDefaultsManager :: setColor:
//============================================================================
- (void)setColor: (UIColor *)cValue forKey: (NSString *)key
{
	[self setObjectToEncode: cValue forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: dataForKey:
//============================================================================
- (NSMutableData *)dataForKey: (NSString *)key
{
	return ((NSMutableData *)[[self getUserDefaultsObjectForKey: key] mutableCopy]);
}


//============================================================================
//	S4UserDefaultsManager :: setData:
//============================================================================
- (void)setData: (NSData *)value forKey: (NSString *)key
{
	[self setUserDefaultsObject: value forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: dateForKey:
//============================================================================
- (NSDate *)dateForKey: (NSString *)key
{
	return ((NSDate *)[self getUserDefaultsObjectForKey: key]);
}


//============================================================================
//	S4UserDefaultsManager :: setDate:
//============================================================================
- (void)setDate: (NSDate *)value forKey: (NSString *)key
{
	[self setUserDefaultsObject: value forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: dictionaryForKey:
//============================================================================
- (NSMutableDictionary *)dictionaryForKey: (NSString *)key
{
	return ((NSMutableDictionary *)[[self getUserDefaultsObjectForKey: key] mutableCopy]);
}


//============================================================================
//	S4UserDefaultsManager :: setDictionary:
//============================================================================
- (void)setDictionary: (NSDictionary *)value forKey: (NSString *)key
{
	[self setUserDefaultsObject: value forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: doubleForKey:
//============================================================================
- (double)doubleForKey: (NSString *)key
{
	NSNumber					*valueNumber;

	valueNumber = (NSNumber *)[self getUserDefaultsObjectForKey: key];
	return ([valueNumber doubleValue]);
}


//============================================================================
//	S4UserDefaultsManager :: setDouble:
//============================================================================
- (void)setDouble: (double)dValue forKey: (NSString *)key
{
	NSNumber					*valueNumber;

	valueNumber = [NSNumber numberWithDouble: dValue];
	[self setUserDefaultsObject: valueNumber forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: floatForKey:
//============================================================================
- (float)floatForKey: (NSString *)key
{
	NSNumber					*valueNumber;

	valueNumber = (NSNumber *)[self getUserDefaultsObjectForKey: key];
	return ([valueNumber floatValue]);
}


//============================================================================
//	S4UserDefaultsManager :: setFloat:
//============================================================================
- (void)setFloat: (float)fValue forKey: (NSString *)key
{
	NSNumber					*valueNumber;

	valueNumber = [NSNumber numberWithFloat: fValue];
	[self setUserDefaultsObject: valueNumber forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: imageForKey:
//============================================================================
- (UIImage *)imageForKey: (NSString *)key
{
	NSData						*data;
    UIImage						*imageResult = nil;

	data = [self dataForKey: key];
    if (IS_NOT_NULL(data))
	{
		imageResult = [UIImage imageWithData: data];
	}
	return (imageResult);
}


//============================================================================
//	S4UserDefaultsManager :: integerForKey:
//============================================================================
- (NSInteger)integerForKey: (NSString *)key
{
	NSNumber					*valueNumber;

	valueNumber = (NSNumber *)[self getUserDefaultsObjectForKey: key];
	return ([valueNumber integerValue]);
}


//============================================================================
//	S4UserDefaultsManager :: setInteger:
//============================================================================
- (void)setInteger: (NSInteger)iValue forKey: (NSString *)key
{
	NSNumber					*valueNumber;

	valueNumber = [NSNumber numberWithInteger: iValue];
	[self setUserDefaultsObject: valueNumber forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: numberForKey:
//============================================================================
- (NSNumber *)numberForKey: (NSString *)key
{
	return ((NSNumber *)[self getUserDefaultsObjectForKey: key]);
}


//============================================================================
//	S4UserDefaultsManager :: setNumber:
//============================================================================
- (void)setNumber: (NSNumber *)value forKey: (NSString *)key
{
	[self setUserDefaultsObject: value forKey: key];
}


//============================================================================
//	S4UserDefaultsManager :: stringForKey:
//============================================================================
- (NSMutableString *)stringForKey: (NSString *)key
{
	return ((NSMutableString *)[[self getUserDefaultsObjectForKey: key] mutableCopy]);
}


//============================================================================
//	S4UserDefaultsManager :: setString:
//============================================================================
- (void)setString: (NSString *)value forKey: (NSString *)key
{
	[self setUserDefaultsObject: value forKey: key];
}

@end
