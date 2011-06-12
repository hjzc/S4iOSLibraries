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
 * Name:		CSNearbyVendorsCell.m
 * Module:		Test
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "CSNearbyVendorsCell.h"
#import "AppDelegate_Shared.h"
#import "S4HttpInvokeOperation.h"
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================

#define MIN_PHONE_NUM_LEN				8		// "555-5555"


// ================================== Typedefs =========================================



// =================================== Globals =========================================

// Yahoo Search with location string
const char						*g_YahooSearchUrlPath = "http://www.google.com/webhp?hl=en";


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =================== Begin Class CSNearbyVendorsCell (PrivateImpl) ===================

@interface CSNearbyVendorsCell (PrivateImpl)

- (void)placeHolder1;
- (void)placeHolder2;

@end




@implementation CSNearbyVendorsCell (PrivateImpl)

//============================================================================
//	CSNearbyVendorsCell (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}


//============================================================================
//	CSNearbyVendorsCell (PrivateImpl) :: placeHolder2
//============================================================================
- (void)placeHolder2
{
}

@end




// ========================= Begin Class CSNearbyVendorsCell =========================

@implementation CSNearbyVendorsCell

@synthesize addressLabel, brandImage, distanceLabel, favImage, nameLabel;


//============================================================================
//	CSNearbyVendorsCell :: dealloc
//============================================================================
- (void)dealloc
{
	[super dealloc];
}


//============================================================================
//	CSNearbyVendorsCell :: asyncDataResponse
//============================================================================
- (void)asyncDataResponse: (id)data
{
	self.brandImage.image = [UIImage imageWithData: data];
	[self setNeedsDisplay];
	NSLog(@"CSNearbyVendorsCell asyncDataResponse received %d bytes of data", [data length]);
}


- (void)asyncErrorResponse: (id)error
{
	NSLog(@"CSNearbyVendorsCell asyncErrorResponse  %@", [error localizedFailureReason]);
}



//============================================================================
//	CSNearbyVendorsCell :: setCoffeeVendor
//============================================================================
- (void)loadImage
{
	NSString						*path;
	NSURLRequest					*urlRequest;
	AppDelegate_Shared				*appDelegate;
	S4HttpInvokeOperation			*invokeOperation;
	NSInvocation					*dataInv;
	NSInvocation					*errInv;

	if (YES)
	{
		// this works
		path = @"http://a2.twimg.com/profile_images/1303409503/avatar_normal.png";
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
					appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
					[appDelegate.operationsQueue addOperation: invokeOperation];
				}
				[invokeOperation release];
			}
			[urlRequest release];
		}
	}
}

@end
