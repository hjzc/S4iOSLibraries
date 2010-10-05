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
 * Name:		S4RoundedRectView.m
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4RoundedRectView.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ======================= Begin Class S4RoundedRectView (PrivateImpl) ========================

@interface S4RoundedRectView (PrivateImpl)

- (void)placeHolder1;

@end



@implementation S4RoundedRectView (PrivateImpl)

//============================================================================
//	S4RoundedRectView (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}

@end




// =========================== Begin Class S4RoundedRectView ==========================

@implementation S4RoundedRectView

@synthesize cornerRadius = m_CornerRadius;


//============================================================================
//	S4RoundedRectView :: initWithFrame:
//============================================================================
- (id)initWithFrame: (CGRect)frame
{
    if (self = [super initWithFrame: frame])
	{
        self.cornerRadius = 8.0f;
		self.backgroundColor = [UIColor darkGrayColor];
		super.opaque = NO;
    }
    return self;
}


//============================================================================
//	S4RoundedRectView :: setCornerRadius:
//============================================================================
- (void)setCornerRadius: (CGFloat)radius
{
	if (m_CornerRadius != radius)
	{
		m_CornerRadius = radius;
		[self setNeedsDisplay];
	}
}


//============================================================================
//	S4RoundedRectView :: setBackgroundColor:
//============================================================================
- (void)setBackgroundColor: (UIColor *)color
{
	if (m_BackgroundColor != color)
	{
		[m_BackgroundColor release];
		m_BackgroundColor = [color retain];
		[self setNeedsDisplay];
	}
}


//============================================================================
//	S4RoundedRectView :: backgroundColor
//============================================================================
- (UIColor *)backgroundColor
{
	return m_BackgroundColor;
}


//============================================================================
//	S4RoundedRectView :: setOpaque:
//============================================================================
- (void)setOpaque: (BOOL)opaque
{
	// do nothing
}


//============================================================================
//	S4RoundedRectView :: drawRect:
//============================================================================
- (void)drawRect: (CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextBeginPath(ctx);
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	CGFloat radius = self.cornerRadius;
	CGContextMoveToPoint(ctx, 0.0f, radius);
	CGContextAddLineToPoint(ctx, 0.0f, height - radius);
	CGContextAddArcToPoint(ctx, 0.0f, height, radius, height, radius);
	CGContextAddLineToPoint(ctx, width - radius, height);
	CGContextAddArcToPoint(ctx, width, height, width, height - radius, radius);
	CGContextAddLineToPoint(ctx, width, radius);
	CGContextAddArcToPoint(ctx, width, 0.0f, width - radius, 0.0f, radius);
	CGContextAddLineToPoint(ctx, radius, 0.0f);
	CGContextAddArcToPoint(ctx, 0.0f, 0.0f, 0.0f, radius, radius);
	CGContextSetFillColorWithColor(ctx, self.backgroundColor.CGColor);
	CGContextClip(ctx);
	CGContextFillRect(ctx, rect);
}


//============================================================================
//	S4RoundedRectView :: dealloc
//============================================================================
- (void)dealloc
{
	self.backgroundColor = nil;
	[super dealloc];
}

@end
