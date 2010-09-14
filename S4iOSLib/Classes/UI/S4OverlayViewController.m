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
 * Name:		S4OverlayViewController.m
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4OverlayViewController.h"
#import "S4RoundedRectView.h"
#import "S4SingletonClass.h"
#import <QuartzCore/QuartzCore.h>
#import "S4CommonDefines.h"


// =================================== Defines =========================================

#define TRANSITION_SCALE				1.2f


// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ====================== Begin Class S4OverlayViewController () =======================

@interface S4OverlayViewController ()

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL visible;

@end




// ===================== Begin Class S4OverlayViewController (PrivateImpl) ===================

@interface S4OverlayViewController (PrivateImpl)

- (CGImageRef)gradientBackgroundImage;
- (void)oneTimeInit;

@end




@implementation S4OverlayViewController (PrivateImpl)

//============================================================================
//	S4OverlayViewController (PrivateImpl) :: gradientBackgroundImage
//============================================================================
- (CGImageRef)gradientBackgroundImage
{
	CGContextRef					ctx;
	CGAffineTransform				transform;
	CGPoint							centerPoint;
	CGPoint							newCenter;
	CGFloat							alpha;
	NSArray							*colors;
	CGGradientRef					gradient;
	UIImage							*image;

	UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
	ctx = UIGraphicsGetCurrentContext();
	transform = CGAffineTransformMakeScale(1.0f, 1.1f);
	centerPoint = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
	newCenter = CGPointApplyAffineTransform(centerPoint, CGAffineTransformInvert(transform));
	transform = CGAffineTransformTranslate(transform, newCenter.x - centerPoint.x, newCenter.y - centerPoint.y);
	CGContextConcatCTM(ctx, transform);
	alpha = 0.4f;

	colors = [NSArray arrayWithObjects: (id)[UIColor colorWithWhite: 0.1f alpha: alpha].CGColor,
					   (id)[UIColor colorWithWhite: 0.7f alpha: alpha].CGColor, nil];

	gradient = CGGradientCreateWithColors(CGColorGetColorSpace((CGColorRef)[colors objectAtIndex:0]), (CFArrayRef)colors, NULL);

	CGContextDrawRadialGradient(ctx, gradient, centerPoint, 120, centerPoint, 0,
								kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return (image.CGImage);
}


//============================================================================
//	S4UserDefaultsManager (PrivateImpl) :: oneTimeInit
//============================================================================
- (void)oneTimeInit
{
	self.activityIndicator = nil;
	self.visible = NO;
}

@end




// ========================== Begin Class S4OverlayViewController ==========================

@implementation S4OverlayViewController

@synthesize activityIndicator = m_ActivityIndicator;
@synthesize visible = m_bIsVisible;


///////////////////////////////////// START SINGLETON METHODS /////////////////////////////////////


SYNTHESIZE_SINGLETON_CLASS(S4OverlayViewController)


///////////////////////////////////// INSTANCE METHODS /////////////////////////////////////


//============================================================================
//	S4OverlayViewController :: loadView
//============================================================================
- (void)loadView
{
	UIWindow								*overlay;
	S4RoundedRectView						*roundedRect;
	UIActivityIndicatorViewStyle			style;
	UIActivityIndicatorView					*indicator;
	UILabel									*label;
	
	overlay = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
	overlay.layer.contents = (id)[self gradientBackgroundImage];
	overlay.hidden = YES;
	
	// we want to show above the keyboard but below alerts
	// so lets split the difference
	overlay.windowLevel = (UIWindowLevelNormal + UIWindowLevelAlert) / 2.0f;
	
	roundedRect = [[S4RoundedRectView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
	roundedRect.center = CGPointMake(CGRectGetMidX(overlay.bounds), CGRectGetMidY(overlay.bounds));
	roundedRect.backgroundColor = [UIColor colorWithWhite: 0.2f alpha: 0.9f];
	
	style = UIActivityIndicatorViewStyleWhiteLarge;
	
	indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: style];
	indicator.center = CGPointMake(CGRectGetMidX(roundedRect.bounds), CGRectGetMidY(roundedRect.bounds));
	indicator.frame = CGRectIntegral(indicator.frame);
	[roundedRect addSubview: indicator];
	self.activityIndicator = indicator;
	[indicator release];
	
	label = [[UILabel alloc] initWithFrame: CGRectZero];
	label.font = [UIFont systemFontOfSize: [UIFont labelFontSize]];
	label.text = @"Loading...";
	[label sizeToFit];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.opaque = NO;
	label.center = CGPointMake(CGRectGetMidX(roundedRect.bounds), CGRectGetMaxY(roundedRect.bounds) - label.bounds.size.height);
	[roundedRect addSubview: label];
	label.frame = CGRectIntegral(label.frame);
	[label release];
	
	[overlay addSubview:roundedRect];
	[roundedRect release];
	
	self.view = overlay;
	[overlay release];
}


//============================================================================
//	S4OverlayViewController :: setView:
//============================================================================
- (void)setView: (UIView *)view
{
	[super setView: view];
	if (nil == view)
	{
		self.activityIndicator = nil;
	}
}


//============================================================================
//	S4OverlayViewController :: hide
//============================================================================
- (void)didReceiveMemoryWarning
{
	// check the activity indicator so we don't accidentally load our view just to remove it
	if (self.activityIndicator != nil)
	{
		if (self.view.hidden == YES)
		{
			// it's not showing, we can safely remove it
			self.view = nil;
		}
	}
}


//============================================================================
//	S4OverlayViewController :: show
//============================================================================
- (void)show
{
	BOOL					bPrevAnimationEnabled;

	if (NO == self.visible)
	{
		// if the view is still visible, then it must be in-flight, so don't touch it
		if (self.view.hidden == YES)
		{
			bPrevAnimationEnabled = [UIView areAnimationsEnabled];
			[UIView setAnimationsEnabled: NO];
			self.view.alpha = 0.0f;
			self.view.transform = CGAffineTransformMakeScale(TRANSITION_SCALE, TRANSITION_SCALE);
			self.view.hidden = NO;
			[UIView setAnimationsEnabled: bPrevAnimationEnabled];
		}

		[UIView beginAnimations: @"OverlayView showing" context: NULL];
		[UIView setAnimationBeginsFromCurrentState: YES];
		self.view.alpha = 1.0f;
		self.view.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
		[self.activityIndicator startAnimating];
		self.visible = YES;
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	}
}


//============================================================================
//	S4OverlayViewController :: hide
//============================================================================
- (void)hide
{
	if (YES == self.visible)
	{
		[self.activityIndicator stopAnimating];
		[UIView beginAnimations: @"OverlayView hiding" context: NULL];
		[UIView setAnimationDelegate: self];
		[UIView setAnimationDidStopSelector: @selector(animationFinished:finished:context:)];
		self.view.alpha = 0.0f;
		self.view.transform = CGAffineTransformMakeScale(TRANSITION_SCALE, TRANSITION_SCALE);
		[UIView commitAnimations];
		self.visible = NO;
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}
}


//============================================================================
//	S4OverlayViewController :: animationFinished:
//============================================================================
- (void)animationFinished: (NSString *)animationID finished: (BOOL)finished context: (void *)context
{
	// ignore the finished arg, it seems to be inverted and therefore untrustworthy
	if (NO == self.visible)
	{
		self.view.hidden = YES;
	}
}

@end
