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
 * Name:		S4ProgressHUD.h
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// ================================== Globals =========================================



// ============================= Forward Declarations =================================

@class MBProgressHUD;
@protocol MBProgressHUDDelegate;


// ================================== Protocols ========================================



// ============================== S4ProgressHUD Class ==================================

@interface S4ProgressHUD : NSObject <MBProgressHUDDelegate>
{
@private
	MBProgressHUD				*m_mbHUD;
}

// Properties

// Class methods
+ (MBProgressHUD *)showHUDAddedTo: (UIView *)view animated: (BOOL)animated;
+ (BOOL)hideHUDForView: (UIView *)view animated: (BOOL)animated;

// Instance methods
- (void)showWhileExecuting: (SEL)method onTarget: (id)target withObject: (id)object animated: (BOOL)animated;

- (void)showWhileExecuting: (SEL)method
				  onTarget: (id)target
				withObject: (id)object
				   forView: (UIView *)view
				 withLabel: (NSString *)label
				  animated: (BOOL)animated;

@end
