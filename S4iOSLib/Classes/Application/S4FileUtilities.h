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
 * Name:		S4FileUtilities.h
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// ============================ Class S4FileUtilities ==================================

@interface S4FileUtilities : NSObject
{

}


// commonly used directories
+ (NSString *)tempDirectory;
+ (NSString *)documentsDirectory;
+ (NSString *)cachesDirectory;
+ (NSString *)applSupportDirectory;

// persistant store for NSCoding objects
+ (BOOL)writePersistentKeyedArchiverObject: (id <NSCoding>)object atPath: (NSString *)path;
+ (id <NSCoding>)readPersistentKeyedArchiverObjectAtPath: (NSString *)path;
+ (BOOL)persistentFileExistsAtPath: (NSString *)path;
+ (BOOL)removePersistentFileAtPath: (NSString *)path;

// directory operations
+ (NSString *)uniqueDirectory: (NSString *)parentDirectory create: (BOOL)create;
+ (NSString *)uniqueTemporaryDirectory;
+ (BOOL)createDirectory: (NSString *)directory;
+ (NSArray *)directoryContentsNames: (NSString *)directory;
+ (NSArray *)directoryContentsPaths: (NSString *)directory;
+ (BOOL)isDirectoryAtPath: (NSString *)path;

// file or directory attributes
+ (NSDate *)modificationDate: (NSString *)file;
+ (unsigned long long)size: (NSString *)file;
+ (NSDictionary *)attributesOfItemAtPath: (NSString *)path;

// common file operations
+ (BOOL)fileExists: (NSString *)path;
+ (BOOL)copyDiskItemFromPath: (NSString *)srcPath toPath: (NSString *)dstPath;
+ (BOOL)moveDiskItemFromPath: (NSString *)srcPath toPath: (NSString *)dstPath;
+ (NSString *)cleanupFileName: (NSString *)name;
+ (void)deleteDiskItemAtPath: (NSString *)itemPath;
+ (void)writeData: (NSData *)data toFileAtPath: (NSString *)file;
+ (NSData *)readDataFromFileAtPath: (NSString *)file;
+ (BOOL)copyBundleFile: (NSString *)bundleFile toDocfile: (NSString *)docFile shouldOverwrite: (BOOL)bOverwrite;

// PList file operations
+ (void)writeObject: (id)object toPropListFile: (NSString *)file;
+ (id)readObjectFromPropListFile: (NSString *)file;
+ (NSDictionary *)readPlistFromBundleFile: (NSString *)fileName;
+ (CFPropertyListRef)readPlistFromCFURL: (CFURLRef)fileURL;
+ (BOOL)writePlist: (CFPropertyListRef)propertyList toCFURL: (CFURLRef)fileURL;

// search methods
+ (NSString *)pathForFileNamed: (NSString *)filename onPath: (NSString *)path;
+ (NSString *)pathForFileNamed: (NSString *)filename;
+ (NSString *)pathForBundleFileNamed: (NSString *)filename;
+ (NSArray *)pathsForFilesWithExtension: (NSString *)fileExtension onPath: (NSString *)path;
+ (NSArray *)pathsForFilesWithExtension: (NSString *)fileExtension;
+ (NSArray *)pathsForBundleFilesWithExtension: (NSString *)fileExtension;

// get the text encoding of a file (for text-based files)
//	NSStringEncoding types are:
//
//					NSASCIIStringEncoding
//					NSNEXTSTEPStringEncoding
//					NSJapaneseEUCStringEncoding
//					NSUTF8StringEncoding
//					NSISOLatin1StringEncoding
//					NSSymbolStringEncoding
//					NSNonLossyASCIIStringEncoding
//					NSShiftJISStringEncoding
//					NSISOLatin2StringEncoding
//					NSUnicodeStringEncoding
//					NSWindowsCP1251StringEncoding
//					NSWindowsCP1252StringEncoding
//					NSWindowsCP1253StringEncoding
//					NSWindowsCP1254StringEncoding
//					NSWindowsCP1250StringEncoding
//					NSISO2022JPStringEncoding
//					NSMacOSRomanStringEncoding
//					NSUTF16StringEncoding
//					NSUTF16BigEndianStringEncoding
//					NSUTF16LittleEndianStringEncoding
//					NSUTF32StringEncoding
//					NSUTF32BigEndianStringEncoding
//					NSUTF32LittleEndianStringEncoding
//
+ (BOOL)getStringEncoding: (NSStringEncoding *)encodingPtr forFileAtPath: (NSString *)path;

@end
