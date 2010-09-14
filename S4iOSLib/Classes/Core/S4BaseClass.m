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
 * Name:		S4BaseClass.m
 * Module:		Core
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4BaseClass.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =========================== Begin Class S4BaseClass =================================

@implementation S4BaseClass

//============================================================================
//	S4BaseClass :: init
//============================================================================
- (id)init
{
	id			idResult = nil;
	
	self = [super init];
	if (nil != self)
	{		
		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4BaseClass :: dealloc
//============================================================================
- (void)dealloc
{	
    [super dealloc];
}


//============================================================================
//	S4BaseClass :: showErrorWithTitle:
//============================================================================
- (void)showErrorWithTitle: (NSString *)titleStr errorString: (NSString *)errorStr withTag: (NSInteger)tag
{
	UIAlertView				*alertView;

	alertView = [[UIAlertView alloc] initWithTitle: titleStr
										   message: errorStr
										  delegate: self
								 cancelButtonTitle: @"Dismiss"
								 otherButtonTitles: nil];
	if IS_NOT_NULL(alertView)
	{
		alertView.tag = tag;
		[alertView show];
		[alertView release];
	}
}



/****************************************  UIAlertViewDelegate Protocol Methods ***************************************/

//============================================================================
//	S4BaseClass :: alertView:clickedButtonAtIndex:
//============================================================================
- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
	switch (alertView.tag)
	{
		case ALERT_VIEW_ERROR_TAG:
			//			[self.navigationController popViewControllerAnimated:YES];
			break;
			
		default: // all yes/no alerts
		{
			if (buttonIndex == 1)
			{
				switch (alertView.tag)
				{
					default:
						break;
				}
			}
		}
	}
}



/*********************************************  NSCoding Protocol Methods *********************************************/

//============================================================================
//	S4BaseClass :: encodeWithCoder
//============================================================================
- (void)encodeWithCoder: (NSCoder *)coder
{
	// encode the class member vars
	//  -- none to encode --
}


//============================================================================
//	S4BaseClass :: encodeWithCoder
//============================================================================
- (id)initWithCoder: (NSCoder *)coder
{
	id			idResult = nil;

	// just a simple init
	self = [super init];
	if (nil != self)
	{
		// decode the class member vars
		//  -- none to decode --

		idResult = self;
	}
	return (idResult);
}

@end
