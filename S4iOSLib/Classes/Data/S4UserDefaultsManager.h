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
 * Name:		S4UserDefaultsManager.h
 * Module:		Data
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================

typedef enum
{
	UDTypeArray,
	UDTypeUIColor,
	UDTypeData,
	UDTypeDate,
	UDTypeDictionary,
	UDTypeNumber,
	UDTypeString
} UserDefaultType;


// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// =========================== Class S4UserDefaultsManager =============================

@interface S4UserDefaultsManager : NSObject
{
@private
	NSMutableDictionary				*m_userDefaultsDictionary;
	BOOL							m_bHasRegistered;
}

// class methods
+ (S4UserDefaultsManager *)getInstance;

// instance methods
// this method MUST be called before using this class
- (BOOL)registerDefaults;

// registration methods
- (void)addUserDefaultBool: (BOOL)bValue forKey: (NSString *)key;
- (void)addUserDefaultDouble: (double)dValue forKey: (NSString *)key;
- (void)addUserDefaultFloat: (float)value forKey: (NSString *)key;
- (void)addUserDefaultInteger: (NSInteger)iValue forKey: (NSString *)key;
- (void)addUserDefaultObject: (id)object ofType: (UserDefaultType)type forKey: (NSString *)key;

/**************************************************************************************/
// NOTES:
//  NSUserDefaults only supports the following native types:
//		NSArray
//		NSData
//		NSDate
//		NSDictionary
//		NSNumber
//		NSString
/**************************************************************************************/

// getters and setters
- (NSMutableArray *)arrayForKey: (NSString *)key;
- (void)setArray: (NSArray *)value forKey: (NSString *)key;

- (BOOL)boolForKey: (NSString *)key;
- (void)setBool: (BOOL)bValue forKey: (NSString *)key;

- (UIColor *)colorForKey: (NSString *)key;
- (void)setColor: (UIColor *)cValue forKey: (NSString *)key;

- (NSMutableData *)dataForKey: (NSString *)key;
- (void)setData: (NSData *)value forKey: (NSString *)key;

- (NSDate *)dateForKey: (NSString *)key;
- (void)setDate: (NSDate *)value forKey: (NSString *)key;

- (NSMutableDictionary *)dictionaryForKey: (NSString *)key;
- (void)setDictionary: (NSDictionary *)value forKey: (NSString *)key;

- (double)doubleForKey: (NSString *)key;
- (void)setDouble: (double)dValue forKey: (NSString *)key;

- (float)floatForKey: (NSString *)key;
- (void)setFloat: (float)fValue forKey: (NSString *)key;

// convenience method
- (UIImage *)imageForKey: (NSString *)key;

- (NSInteger)integerForKey: (NSString *)key;
- (void)setInteger: (NSInteger)iValue forKey: (NSString *)key;

- (NSNumber *)numberForKey: (NSString *)key;
- (void)setNumber: (NSNumber *)value forKey: (NSString *)key;

- (NSMutableString *)stringForKey: (NSString *)key;
- (void)setString: (NSString *)value forKey: (NSString *)key;

@end
