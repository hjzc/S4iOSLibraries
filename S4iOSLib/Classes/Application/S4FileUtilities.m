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
 * Name:		S4FileUtilities.m
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4FileUtilities.h"
#import "S4CommonDefines.h"
#import "NSFileManager-Utilities.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================

static NSString							*kTemporaryDirctory = nil;
static NSString							*kDocumentsDirectory = nil;
static NSString							*kCachesDirctory = nil;
static NSString							*kApplSupportDirectory = nil;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ===================== Begin Class S4FileUtilities (PrivateImpl) =====================

@interface S4FileUtilities (PrivateImpl)

+ (NSString *)randomString;
+ (NSFileManager *)getFileManager;

@end




@implementation S4FileUtilities (PrivateImpl)

//============================================================================
//	S4FileUtilities (PrivateImpl) :: randomString
//============================================================================
+ (NSString *)randomString
{
	NSMutableString			*randomStr;

	randomStr = [NSMutableString string];
	for (int i = 0; i < 8; i++)
	{
		[randomStr appendFormat: @"%c", ((rand() % 26) + 'a')];
	}
	return (randomStr);
}


//============================================================================
//	S4FileUtilities (PrivateImpl) :: getFileManager
//============================================================================
+ (NSFileManager *)getFileManager
{
	return ([[[NSFileManager alloc] init] autorelease]);
}

@end




// ======================= Begin Class S4FileUtilities =======================

@implementation S4FileUtilities

//============================================================================
//	S4FileUtilities : tempDirectory
//============================================================================
+ (NSString *)tempDirectory
{
	if (nil == kTemporaryDirctory)
	{
		kTemporaryDirctory = [NSTemporaryDirectory() retain];
	}
	return (kTemporaryDirctory);
}


//============================================================================
//	S4FileUtilities : documentsDirectory
//============================================================================
+ (NSString *)documentsDirectory
{
	NSArray							*pathsArray;

	if (nil == kDocumentsDirectory)
	{
		pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		if ([pathsArray count] > 0)
		{
			kDocumentsDirectory = [[NSString stringWithFormat: @"%@", (NSString *)[pathsArray objectAtIndex: 0]] retain];
		}
	}
	return (kDocumentsDirectory);
}


//============================================================================
//	S4FileUtilities : cachesDirectory
//============================================================================
+ (NSString *)cachesDirectory
{
	NSArray							*pathsArray;

	if (nil == kCachesDirctory)
	{
		pathsArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		if ([pathsArray count] > 0)
		{
			kCachesDirctory = [[NSString stringWithFormat: @"%@", (NSString *)[pathsArray objectAtIndex: 0]] retain];
		}
	}
	return (kCachesDirctory);
}


//============================================================================
//	S4FileUtilities : applSupportDirectory
//============================================================================
+ (NSString *)applSupportDirectory
{
	NSArray							*pathsArray;

	if (nil == kApplSupportDirectory)
	{
		pathsArray = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		if ([pathsArray count] > 0)
		{
			kApplSupportDirectory = [[NSString stringWithFormat: @"%@", (NSString *)[pathsArray objectAtIndex: 0]] retain];
		}
	}
	return (kApplSupportDirectory);
}


//============================================================================
//	S4FileUtilities : writePersistentKeyedArchiverObject
//============================================================================
+ (BOOL)writePersistentKeyedArchiverObject: (id <NSCoding>)object atPath: (NSString *)path
{
	NSString					*archivePath;
	BOOL						bResult = NO;

	if ((nil != object) && (nil != path) && ([path length] > 0))
	{
		archivePath = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: path];
		bResult = [NSKeyedArchiver archiveRootObject: object toFile: archivePath];
	}
	return (bResult);
}


//============================================================================
//	S4FileUtilities : readPersistentKeyedArchiverObjectAtPath
//============================================================================
+ (id <NSCoding>)readPersistentKeyedArchiverObjectAtPath: (NSString *)path
{
	NSString					*archivePath;
	id <NSCoding>				idResult = nil;

	if ((nil != path) && ([path length] > 0))
	{
		archivePath = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: path];
		idResult = [NSKeyedUnarchiver unarchiveObjectWithFile: archivePath];
	}
	return (idResult);
}


//============================================================================
//	S4FileUtilities : persistentFileExistsAtPath
//============================================================================
+ (BOOL)persistentFileExistsAtPath: (NSString *)path
{
	NSString					*archivePath;
	BOOL						bResult = NO;

	if (STR_NOT_EMPTY(path))
	{
		archivePath = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: path];
		bResult = [[S4FileUtilities getFileManager] fileExistsAtPath: archivePath];
	}
	return (bResult);
}


//============================================================================
//	S4FileUtilities : removePersistentFileAtPath
//============================================================================
+ (BOOL)removePersistentFileAtPath: (NSString *)path
{
	NSString					*archivePath;
	BOOL						bResult = NO;

	if ((nil != path) && ([path length] > 0))
	{
		archivePath = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: path];
		bResult = [[S4FileUtilities getFileManager] removeItemAtPath: archivePath error: NULL];
	}
	return (bResult);
}


//============================================================================
//	S4FileUtilities : uniqueDirectory:create:
//============================================================================
+ (NSString *)uniqueDirectory: (NSString *)parentDirectory create: (BOOL)create
{
	NSString* finalDir = nil;

	do
	{
		NSString* random = [self randomString];
		finalDir = [parentDirectory stringByAppendingPathComponent: random];
	}
	while ([[S4FileUtilities getFileManager] fileExistsAtPath: finalDir]);

	if (create)
	{
		[S4FileUtilities createDirectory: finalDir];
	}
	return (finalDir);
}


//============================================================================
//	S4FileUtilities : uniqueTemporaryDirectory
//============================================================================
+ (NSString *)uniqueTemporaryDirectory
{
	return [self uniqueDirectory: [self tempDirectory] create: YES];
}


//============================================================================
//	S4FileUtilities : createDirectory
//============================================================================
+ (BOOL)createDirectory: (NSString *)directory
{
	NSFileManager		*fileManager;
	BOOL				bResult = NO;

	if (STR_NOT_EMPTY(directory))
	{
		fileManager = [S4FileUtilities getFileManager];
		if (NO == [fileManager fileExistsAtPath: directory isDirectory: &bResult])
		{
			bResult = [fileManager createDirectoryAtPath: directory withIntermediateDirectories: YES attributes: nil error: NULL];
		}
	}
	return (bResult);
}


//============================================================================
//	S4FileUtilities : modificationDate
//============================================================================
+ (NSDate *)modificationDate: (NSString *)file
{
	NSDate				*result = nil;

	result = [[[S4FileUtilities getFileManager] attributesOfItemAtPath: file error: NULL] objectForKey: NSFileModificationDate];
	return (result);
}


//============================================================================
//	S4FileUtilities : size
//============================================================================
+ (unsigned long long)size: (NSString *)file
{
	NSNumber					*number;

	number = [[[S4FileUtilities getFileManager] attributesOfItemAtPath: file error: NULL] objectForKey: NSFileSize];
	return ([number unsignedLongLongValue]);
}


//============================================================================
//	S4FileUtilities : attributesOfItemAtPath
//============================================================================
+ (NSDictionary *)attributesOfItemAtPath: (NSString *)path
{
	return ([[S4FileUtilities getFileManager] attributesOfItemAtPath: path error: NULL]);
}


//============================================================================
//	S4FileUtilities : directoryContentsNames
//
//	returns nil on error; empty NSArray if no files, raw filenames otherwise
//============================================================================
+ (NSArray *)directoryContentsNames: (NSString *)directory
{
	return ([[S4FileUtilities getFileManager] contentsOfDirectoryAtPath: directory error: NULL]);
}


//============================================================================
//	S4FileUtilities : directoryContentsPaths
//
//	returns nil on error; empty NSArray if no files, path/filenames otherwise
//============================================================================
+ (NSArray *)directoryContentsPaths: (NSString *)directory
{
	NSArray						*names;
	NSMutableArray				*result = nil;

	if (STR_NOT_EMPTY(directory))
	{
		names = [[S4FileUtilities getFileManager] contentsOfDirectoryAtPath: directory error: NULL];
		if (IS_NOT_NULL(names))
		{
			result = [NSMutableArray array];
			for (NSString *fileName in names)
			{
				[result addObject: [directory stringByAppendingPathComponent: fileName]];
			}
		}
	}
	return (result);
}


//============================================================================
//	S4FileUtilities : fileExists
//============================================================================
+ (BOOL)fileExists: (NSString *)path
{
	if (STR_NOT_EMPTY(path))
	{
		return ([[S4FileUtilities getFileManager] fileExistsAtPath: path]);
	}
	return (NO);
}


//============================================================================
//	S4FileUtilities : copyDiskItemFromPath:toPath:
//============================================================================
+ (BOOL)copyDiskItemFromPath: (NSString *)srcPath toPath: (NSString *)dstPath
{
	if ((STR_NOT_EMPTY(srcPath)) && (STR_NOT_EMPTY(dstPath)))
	{
		return ([[S4FileUtilities getFileManager] copyItemAtPath: srcPath toPath: dstPath error: NULL]);
	}
	return (NO);
}


//============================================================================
//	S4FileUtilities : moveDiskItemFromPath:toPath:
//============================================================================
+ (BOOL)moveDiskItemFromPath: (NSString *)srcPath toPath: (NSString *)dstPath
{	
	if ((STR_NOT_EMPTY(srcPath)) && (STR_NOT_EMPTY(dstPath)))
	{
		return ([[S4FileUtilities getFileManager] moveItemAtPath: srcPath toPath: dstPath error: NULL]);
	}
	return (NO);
}


//============================================================================
//	S4FileUtilities : cleanupFileName
//============================================================================
+ (NSString *)cleanupFileName: (NSString *)name
{
	if (STR_NOT_EMPTY(name))
	{
		return ([[name stringByReplacingOccurrencesOfString: @"/" withString: @"_"] stringByReplacingOccurrencesOfString: @":" withString: @"_"]);
	}
	return (nil);
}


//============================================================================
//	S4FileUtilities : deleteDiskItemAtPath
//============================================================================
+ (void)deleteDiskItemAtPath: (NSString *)itemPath
{
	if (STR_NOT_EMPTY(itemPath))
	{
		[[S4FileUtilities getFileManager] removeItemAtPath: itemPath error: NULL];
	}
}


//============================================================================
//	S4FileUtilities : writeData:toFileAtPath:
//============================================================================
+ (void)writeData: (NSData *)data toFileAtPath: (NSString *)file
{
	if ((IS_NOT_NULL(data)) && (STR_NOT_EMPTY(file)))
	{
		[data writeToFile: file atomically: YES];
	}
}


//============================================================================
//	S4FileUtilities : readDataFromFileAtPath
//============================================================================
+ (NSData *)readDataFromFileAtPath: (NSString *)file
{
    if (IS_NOT_NULL(file))
	{
        return ([NSData dataWithContentsOfFile: file]);
    }
    return (nil);
}


//============================================================================
//	S4FileUtilities : isDirectoryAtPath
//============================================================================
+ (BOOL)isDirectoryAtPath: (NSString *)path
{
	BOOL						result;

	[[S4FileUtilities getFileManager] fileExistsAtPath: path isDirectory: &result];
	return (result);
}


//============================================================================
//	S4FileUtilities : copyBundleFile:toDocfile:
//============================================================================
+ (BOOL)copyBundleFile: (NSString *)bundleFile toDocfile: (NSString *)docFile shouldOverwrite: (BOOL)bOverwrite
{
	NSFileManager			*fileManager;
	NSString				*docsFilePath;
	BOOL					bDocFileExists;
	NSString				*bundleFilePath;
	BOOL					bResult = NO;

	if ((STR_NOT_EMPTY(bundleFile)) && (STR_NOT_EMPTY(docFile)))
	{
		fileManager = [S4FileUtilities getFileManager];

		docsFilePath = [[S4FileUtilities documentsDirectory] stringByAppendingPathComponent: docFile];
		bDocFileExists = [fileManager fileExistsAtPath: docsFilePath];
		if ((YES == bOverwrite) || (NO == bDocFileExists))
		{
			bundleFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: bundleFile];
			if (YES == [fileManager fileExistsAtPath: bundleFilePath])
			{
				bResult = [fileManager copyItemAtPath: bundleFilePath toPath: docsFilePath error: NULL];
			}
		}
		else
		{
			bResult = YES;
		}
	}
	return (bResult);
}



+ (void)writeObject: (id)object toPropListFile: (NSString *)file
{
	NSData* plistData = [NSPropertyListSerialization dataFromPropertyList: object
																   format: NSPropertyListBinaryFormat_v1_0
														 errorDescription: NULL];
	
	if (plistData != nil)
	{
		[plistData writeToFile: file atomically: YES];
	}
	if (object == nil)
	{
		[[S4FileUtilities getFileManager] removeItemAtPath:file error:NULL];
	}
}



+ (id)readObjectFromPropListFile: (NSString *)file
{
    if (file == nil) {
        return nil;
    }
	
    id result = nil;
    {
        NSData* data = [NSData dataWithContentsOfFile:file];
        if (data != nil) {
            result = [NSPropertyListSerialization propertyListFromData:data
                                                      mutabilityOption:NSPropertyListImmutable
                                                                format:NULL
                                                      errorDescription:NULL];
        }
    }
    return result;
}


//============================================================================
//	S4FileUtilities : readPlistFromBundleFile
//============================================================================
+ (NSDictionary *)readPlistFromBundleFile: (NSString *)fileName
{
	NSPropertyListFormat			format;
	NSString						*errorDesc = nil;
	NSString						*plistPath;
	NSData							*plistXML;
	NSDictionary					*dictResult = nil;

	if (STR_NOT_EMPTY(fileName))
	{
		plistPath = [[NSBundle mainBundle] pathForResource: fileName ofType: @"plist"];
		plistXML = [[S4FileUtilities getFileManager] contentsAtPath: plistPath];
		dictResult = (NSDictionary *)[NSPropertyListSerialization propertyListFromData: plistXML
																	  mutabilityOption: NSPropertyListMutableContainersAndLeaves
																				format: &format
																	  errorDescription: &errorDesc];

		if (nil != errorDesc)
		{
			S4DebugLog(@"S4FileUtilities::readPlistFromBundleFile error: %@", errorDesc);
			[errorDesc release];
		}
	}
	return (dictResult);
}	


//============================================================================
//	S4FileUtilities : readPlistFromCFURL
//============================================================================
+ (CFPropertyListRef)readPlistFromCFURL: (CFURLRef)fileURL
{
	CFStringRef						errorString;
	CFDataRef						resourceData;
	Boolean							status;
	SInt32							errorCode;
	CFPropertyListRef				propertyList = NULL;

	// Read the XML file.
	status = CFURLCreateDataAndPropertiesFromResource(kCFAllocatorDefault,
													  fileURL,
													  &resourceData,            // place to put file data
													  NULL,
													  NULL,
													  &errorCode);

	// Reconstitute the dictionary using the XML data.
	propertyList = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, resourceData, kCFPropertyListImmutable, &errorString);

	if (resourceData)
	{
		CFRelease(resourceData);
	}
	else
	{
		CFRelease(errorString);
	}
	return (propertyList);
}


//============================================================================
//	S4FileUtilities : writePlist:toCFURL: 
//============================================================================
+ (BOOL)writePlist: (CFPropertyListRef)propertyList toCFURL: (CFURLRef)fileURL
{
	CFDataRef					xmlData;
	Boolean						status;
	SInt32						errorCode;
	BOOL						bResult = NO;

	// Convert the property list into XML data.
	xmlData = CFPropertyListCreateXMLData(kCFAllocatorDefault, propertyList);

	// Write the XML data to the file.
	status = CFURLWriteDataAndPropertiesToResource(fileURL, xmlData, NULL, &errorCode);
	CFRelease(xmlData);
	return (bResult);
}


//============================================================================
//	S4FileUtilities : pathForFileNamed:onPath:
//============================================================================
+ (NSString *)pathForFileNamed: (NSString *)filename onPath: (NSString *)path
{
	return ([NSFileManager pathForItemNamed: filename inFolder: path]);
}


//============================================================================
//	S4FileUtilities : pathForFileNamed:
//============================================================================
+ (NSString *)pathForFileNamed: (NSString *)filename
{
	return ([NSFileManager pathForDocumentNamed: filename]);
}


//============================================================================
//	S4FileUtilities : pathForBundleFileNamed:
//============================================================================
+ (NSString *)pathForBundleFileNamed: (NSString *)filename
{
	return ([NSFileManager pathForBundleDocumentNamed: filename]);
}


//============================================================================
//	S4FileUtilities : pathsForFilesWithExtension:onPath:
//============================================================================
+ (NSArray *)pathsForFilesWithExtension: (NSString *)fileExtension onPath: (NSString *)path
{
	return ([NSFileManager pathsForItemsMatchingExtension: fileExtension inFolder: path]);
}


//============================================================================
//	S4FileUtilities : pathsForFilesWithExtension:
//============================================================================
+ (NSArray *)pathsForFilesWithExtension: (NSString *)fileExtension
{
	return ([NSFileManager pathsForDocumentsMatchingExtension: fileExtension]);
}


//============================================================================
//	S4FileUtilities : pathsForBundleFilesWithExtension:
//============================================================================
+ (NSArray *)pathsForBundleFilesWithExtension: (NSString *)fileExtension
{
	return ([NSFileManager pathsForBundleDocumentsMatchingExtension: fileExtension]);
}


//============================================================================
//	S4FileUtilities : getStringEncoding:forFileAtPath:
//============================================================================
+ (BOOL)getStringEncoding: (NSStringEncoding *)encodingPtr forFileAtPath: (NSString *)path
{
	NSString				*tmpStr;
	NSError					*error = nil;
	BOOL					bResult = NO;

	if (nil != encodingPtr)
	{
		if (YES == [S4FileUtilities fileExists: path])
		{
			tmpStr = [[NSString stringWithContentsOfFile: path usedEncoding: encodingPtr error: &error] autorelease];
			if ((STR_NOT_EMPTY(tmpStr)) && (IS_NULL(error)))
			{
				bResult = YES;
			}
		}
	}
	return (bResult);
}

@end
