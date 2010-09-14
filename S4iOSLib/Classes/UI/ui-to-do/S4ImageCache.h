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
 * Name:		S4ImageCache.h
 * Module:		UI
 * Library:		S4 iPhone Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// =============================== Class S4ImageCache ==================================

@interface S4ImageCache : UITableViewCell
{
    IBOutlet UILabel					*addressLabel;
    IBOutlet UIImageView				*brandImage;
    IBOutlet UILabel					*distanceLabel;
    IBOutlet UIImageView				*favImage;
    IBOutlet UILabel					*nameLabel;
}

@property (nonatomic, retain) IBOutlet UILabel			*addressLabel;
@property (nonatomic, retain) IBOutlet UIImageView		*brandImage;
@property (nonatomic, retain) IBOutlet UILabel			*distanceLabel;
@property (nonatomic, retain) IBOutlet UIImageView		*favImage;
@property (nonatomic, retain) IBOutlet UILabel			*nameLabel;

@end
