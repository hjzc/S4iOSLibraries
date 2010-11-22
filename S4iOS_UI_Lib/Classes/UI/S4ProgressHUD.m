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
 * Name:		S4ProgressHUD.m
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4ProgressHUD.h"
#import "MBProgressHUD.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================== Begin Class S4ProgressHUD ================================

@implementation S4ProgressHUD


//============================================================================
//	S4ProgressHUD synthesize properties
//============================================================================


//============================================================================
//	S4ProgressHUD :: showHUDAddedTo:
//============================================================================
+ (MBProgressHUD *)showHUDAddedTo: (UIView *)view animated: (BOOL)bAnimated
{
	MBProgressHUD		*hudResult = nil;

	if (IS_NOT_NULL(view))
	{
		hudResult = [MBProgressHUD showHUDAddedTo: view animated: bAnimated];
	}
	return (hudResult);
}


+ (BOOL)hideHUDForView: (UIView *)view animated: (BOOL)bAnimated
{
	BOOL				bResult = NO;

	if (IS_NOT_NULL(view))
	{
		bResult = [MBProgressHUD hideHUDForView: view animated: bAnimated];
	}
	return (bResult);
}


- (id)init
{
	id			idResult = nil;

	self = [super init];
	if (nil != self)
	{
		m_mbHUD = nil;

		idResult = self;
	}
	return (idResult);
}


- (void)dealloc
{
	NS_SAFE_RELEASE(m_mbHUD)

	[super dealloc];
}


- (void)showWhileExecuting: (SEL)method onTarget: (id)target withObject: (id)object animated: (BOOL)animated
{
	if ((NULL != method) && (IS_NOT_NULL(target)))
	{
	}
}


- (void)showWhileExecuting: (SEL)method
				  onTarget: (id)target
				withObject: (id)object
				   forView: (UIView *)view
				 withLabel: (NSString *)label
				  animated: (BOOL)bAnimated
{
	if ((NULL != method) && (IS_NOT_NULL(target)) && (IS_NOT_NULL(view)))
	{
		// The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
		m_mbHUD = [[MBProgressHUD alloc] initWithView: view];
		if (IS_NOT_NULL(m_mbHUD))
		{
			// Add HUD to screen
			[view addSubview: m_mbHUD];

			// Regisete for HUD callbacks so we can remove it from the window at the right time
			m_mbHUD.delegate = self;

			if (STR_NOT_EMPTY(label))
			{
				m_mbHUD.labelText = label;
			}
			else
			{
				m_mbHUD.labelText = @"";
			}

			// Show the HUD while the provided method executes in a new thread
			[m_mbHUD showWhileExecuting: method onTarget: target withObject: object animated: bAnimated];
		}
	}
}


// MBProgressHUDDelegate methods

- (void)hudWasHidden
{
    // Remove HUD from screen when the HUD was hidded
    [m_mbHUD removeFromSuperview];
	NS_SAFE_RELEASE(m_mbHUD)
}

@end
