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
 * Name:		S4ImageFetcher.h
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================

typedef enum
{
	S4ImageFetcherNoError					= 0,
	S4ImageFetcherInvalidDataError			= 1,
	S4ImageFetcherAllocationError			= 2,
	S4ImageFetcherInvalidImageError			= 3,
	S4ImageFetcherUnknownError				= 4
} S4ImageFetcherError;


// =================================== Globals =========================================

S4_EXTERN_CONSTANT_NSSTR				S4ImageFetcherErrorDomain;


// ============================= Forward Declarations ==================================

@class S4ImageFetcher;


// ================================== Protocols ========================================

@protocol S4ImageFetcherDelegate <NSObject>

@required
// Called by the parser when parsing has begun.
- (void)imageFetcher: (S4ImageFetcher *)fetcher loadedImage: (UIImage *)image context: (id)userObject;

@optional
// Called by the retriever in the case of an error.
- (void)imageFetcher: (S4ImageFetcher *)fetcher didFailWithError: (NSError *)error;

@end


// ============================ Class S4ImageFetcher ===================================

@interface S4ImageFetcher : NSObject
{
@private
	id													m_userObject;
	id <S4ImageFetcherDelegate>							m_delegate;
	NSString											*m_imageTag;
	NSOperationQueue									*m_operationQueue;
}

// Properties
@property (nonatomic, assign) NSOperationQueue					*operationQueue;
@property (nonatomic, readonly) NSString						*imageTag;

// Class methods
+ (id)fetcherForImageAtURL: (NSString *)urlStr
			  withDelegate: (id <S4ImageFetcherDelegate>)delegate
				   context: (id)userObject
	   usingOperationQueue: (NSOperationQueue *)queue;

// Instance methods
- (BOOL)loadImageAtURL: (NSString *)urlStr withDelegate: (id <S4ImageFetcherDelegate>)delegate context: (id)userObject;

@end
