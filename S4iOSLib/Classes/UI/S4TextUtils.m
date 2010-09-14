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
 * Name:		S4TextUtils.m
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4TextUtils.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================

#define TEXT_BLOCK_BOOSTER			(CGFloat)20.0


// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ===================== Begin Class S4TextUtils (PrivateImpl) =========================

@interface S4TextUtils (PrivateImpl)

- (void)placeHolder1;

@end



@implementation S4TextUtils (PrivateImpl)

//============================================================================
//	S4TextUtils (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}

@end




// ========================== Begin Class S4TextUtils =========================

@implementation S4TextUtils

//============================================================================
//	S4TextUtils :: rectForTextBlock:
//============================================================================
+ (struct CGRect)rectForTextBlock: (NSString *)contents
					  originPoint: (struct CGPoint)origin
				constrainedToSize: (struct CGSize)constrainedSize
						  forFont: (UIFont *)font
{
	CGFloat					x;
	CGFloat					y;
	CGFloat					width;
	CGFloat					height;
	struct CGSize			textSize;
	struct CGRect			rectResult;

	x = origin.x;
	y = origin.y;

	if (STR_NOT_EMPTY(contents))
	{
		textSize = [contents sizeWithFont: font
						constrainedToSize: constrainedSize
							lineBreakMode: UILineBreakModeWordWrap];
		width = textSize.width;
		height = textSize.height + TEXT_BLOCK_BOOSTER;			
	}
	else
	{
		x = 0.0;
		y = 0.0;
		width = 0.0;
		height = 0.0;
	}

	// calculate the result
	rectResult = CGRectMake(x, y, width, height);
	return (rectResult);
}


//============================================================================
//	S4TextUtils :: setScrollView:
//============================================================================
+ (void)setScrollView: (UIScrollView *)scrollView contentHeight: (CGFloat)height contentWidth: (CGFloat)width
{
	if (IS_NOT_NULL(scrollView))
	{
		scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		scrollView.scrollEnabled = YES;
		scrollView.showsVerticalScrollIndicator = YES;
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.alwaysBounceVertical = NO;
		scrollView.contentSize = CGSizeMake(width, height);
	}
}

@end
