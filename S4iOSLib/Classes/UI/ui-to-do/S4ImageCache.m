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
 * All software created by the Initial Developer are Copyright (C) 2008-2010
 * the Initial Developer. All Rights Reserved.
 *
 * Original Author:
 *			Michael Papp, San Francisco, CA, USA
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		S4ImageCache.m
 * Module:		UI
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4ImageCache.h"
#import "S4HttpInvokeOperation.h"
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================

#define MIN_PHONE_NUM_LEN				8		// "555-5555"


// ================================== Typedefs =========================================



// =================================== Globals =========================================

static NSOperationQueue			*g_OperationDownloadQueue;
static BOOL						*g_Initialized = NO;

static UIImage					*genericCupIcon = nil;
static UIImage					*favOnIcon = nil;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ====================== Begin Class S4ImageCache (PrivateImpl) =======================

@interface S4ImageCache (PrivateImpl)

- (void)placeHolder1;
- (void)placeHolder2;

@end




@implementation S4ImageCache (PrivateImpl)

//============================================================================
//	S4ImageCache (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}


//============================================================================
//	S4ImageCache (PrivateImpl) :: placeHolder2
//============================================================================
- (void)placeHolder2
{
}

@end




// ======================== Begin Class S4ImageCache =========================

@implementation S4ImageCache

@synthesize addressLabel, brandImage, distanceLabel, favImage, nameLabel;


//============================================================================
//	S4ImageCache :: initializeGraphics
//============================================================================
+ (void)initialize
{
	if (NO == g_Initialized)
	{
		g_OperationDownloadQueue = [[NSOperationQueue alloc] init];
		[g_OperationDownloadQueue setMaxConcurrentOperationCount:6];
	}
}


//============================================================================
//	S4ImageCache :: dealloc
//============================================================================
- (void)dealloc
{
	[super dealloc];
}


- (void)asyncDataResponse: (id)data
{
	self.brandImage.image = [UIImage imageWithData: data];
	[self setNeedsDisplay];
//	NSLog(@"S4ImageCache asyncDataResponse received %d bytes of data", [data length]);
}


- (void)asyncErrorResponse: (id)error
{
	NSLog(@"S4ImageCache asyncErrorResponse  %@", [error localizedFailureReason]);
}



//============================================================================
//	S4ImageCache :: loadImage
//============================================================================
- (void)loadImage
{
	NSString					*path;
	NSURLRequest				*urlRequest;
	S4HttpInvokeOperation		*invokeOperation;
	NSInvocation				*dataInv;
	NSInvocation				*errInv;

	self.brandImage.image = genericCupIcon;

	UIFont *addressLabelFont = [UIFont systemFontOfSize: 12.5];
	self.addressLabel.font = addressLabelFont;
	self.favImage.image = favOnIcon;
	
	UIColor *labelColor = [UIColor blackColor];
	
	self.distanceLabel.textColor = labelColor;
	self.addressLabel.textColor = labelColor;
	self.nameLabel.textColor = labelColor;

	if (YES)
	{
		// this works
		path = @"http://a2.twimg.com/a/1250809294/images/frontpage-bird.png";
		// this 404's
//		path = @"http://www.seastonessoftware.com/images/squirrels";
		// this is a raw NSURLError
//		path = @"http://www.kjdflsjkjfdsl.com/";

		urlRequest = [S4NetUtilities createRequestForPath: path
												 useCache: NO
										  timeoutInterval: 0.0
												 postData: nil
											   dataIsForm: NO
											handleCookies: YES];
		// create a properly escaped NSURL from the string params
		if (nil != urlRequest)
		{
			invokeOperation = [[S4HttpInvokeOperation alloc] init];
			if (nil != invokeOperation)
			{
				dataInv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector: @selector(asyncDataResponse:)]];
				[dataInv setSelector: @selector(asyncDataResponse:)];
				[dataInv setTarget: self];

				errInv = [NSInvocation invocationWithMethodSignature: [self methodSignatureForSelector: @selector(asyncErrorResponse:)]];
				[errInv setSelector: @selector(asyncErrorResponse:)];
				[errInv setTarget: self];

				if ([invokeOperation prepareForRequest: urlRequest dataInvocation: dataInv errInvocation: errInv])
				{
					[g_OperationDownloadQueue addOperation: invokeOperation];
					[invokeOperation release];
				}
			}
		}
	}
}

@end
