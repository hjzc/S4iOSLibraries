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
 * Name:		S4FullScreenMoviePlayer.m
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4FullScreenMoviePlayer.h"
#import "S4CommonDefines.h"
#import "S4ObjC_Utilities.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ==================== Begin Class S4FullScreenMoviePlayer () =========================

@interface S4FullScreenMoviePlayer ()

@property (readwrite, nonatomic) BOOL									isPlaying;

@end



// ================ Begin Class S4FullScreenMoviePlayer (PrivateImpl) ================

@interface S4FullScreenMoviePlayer (PrivateImpl)

- (void)registerForNotifications;
- (void)moviePlayBackFinished: (NSNotification *)notification;

@end



@implementation S4FullScreenMoviePlayer (PrivateImpl)

//============================================================================
//	S4FullScreenMoviePlayer (PrivateImpl) :: registerForNotifications
//============================================================================
- (void)registerForNotifications
{
	// Register to receive a notification when the movie has finished playing. 
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(moviePlayBackFinished:) 
												 name: MPMoviePlayerPlaybackDidFinishNotification 
											   object: nil];	
}


//============================================================================
//	S4FullScreenMoviePlayer (PrivateImpl) :: registerForNotifications
//============================================================================
- (void)moviePlayBackFinished: (NSNotification *)notification
{
	// Send the update to our delegate
	if ((IS_NOT_NULL(m_delegate)) && ([m_delegate respondsToSelector: @selector(moviePlayBackDidFinish)]))
	{
		if (YES == self.isPlaying)
		{
			self.isPlaying = NO;
			[m_delegate moviePlayBackDidFinish];
		}
	}
}

@end



// =========================== Begin Class S4FullScreenMoviePlayer ==============================

@implementation S4FullScreenMoviePlayer


//============================================================================
//	S4FullScreenMoviePlayer synthesize properties
//============================================================================
@synthesize contentURL = m_contentURL;
@synthesize isPlaying = m_bIsPlaying;


//============================================================================
//	S4FullScreenMoviePlayer :: moviePlayerWithContentURL:
//============================================================================
+ (id)moviePlayerWithContentURL: (NSURL *)url
{
	return [[[[self class] alloc] initWithContentURL: url] autorelease];
}


//============================================================================
//	S4FullScreenMoviePlayer :: init
//============================================================================
- (id)init
{
	return ([self initWithContentURL: nil]);
}


//============================================================================
//	S4FullScreenMoviePlayer :: initWithContentURL
//============================================================================
- (id)initWithContentURL: (NSURL *)url
{
	id			idResult = nil;

	self = [super init];
	if (nil != self)
	{
		// private member vars
		self.contentURL = url;
		m_rawMovieController = nil;
		m_movieViewController = nil;
		m_delegate = nil;
		self.isPlaying = NO;

		[self registerForNotifications];

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4FullScreenMoviePlayer :: dealloc
//============================================================================
- (void)dealloc
{
	self.isPlaying = NO;

	self.contentURL = nil;

	if (IS_NOT_NULL(m_rawMovieController))
	{
		[m_rawMovieController release];
		m_rawMovieController = nil;
	}

	if (IS_NOT_NULL(m_movieViewController))
	{
		[m_movieViewController release];
		m_movieViewController = nil;
	}

	[super dealloc];
}


//============================================================================
//	S4FullScreenMoviePlayer :: playMovieForViewController:withDelegate:
//============================================================================
- (BOOL)playMovieForViewController: (UIViewController *)viewController withDelegate: (id <S4FullScreenMovieDelegate>)delegate
{
	MPMoviePlayerViewController			*tmpMovieVC;

	if ((IS_NOT_NULL(self.contentURL)) && (IS_NOT_NULL(viewController)))
	{
		m_delegate = delegate;
		self.isPlaying = NO;

		// if the client is reusing this instance, clear out previous member vars
		if (IS_NOT_NULL(m_movieViewController))
		{
			[m_movieViewController release];
			m_movieViewController = nil;
		}

		if (IS_NOT_NULL(m_rawMovieController))
		{
			[m_rawMovieController release];
			m_rawMovieController = nil;
		}

		// now see if we are on an OS that supports the MPMoviePlayerViewController class
		if (YES == [viewController respondsToSelector: @selector(presentMoviePlayerViewControllerAnimated:)])
		{
			tmpMovieVC = (MPMoviePlayerViewController *)[S4ObjC_Utilities instanceForClassName: @"MPMoviePlayerViewController" additionalInstanceBytes: 0];
			if (IS_NOT_NULL(tmpMovieVC))
			{
				m_movieViewController = [tmpMovieVC initWithContentURL: self.contentURL];
				if (IS_NOT_NULL(m_movieViewController))
				{
					[viewController presentMoviePlayerViewControllerAnimated: m_movieViewController];
					self.isPlaying = YES;
				}
			}
		}

		if (IS_NULL(m_movieViewController))		// no MPMoviePlayerViewController class; just use the older MPMoviePlayerController class
		{
			m_rawMovieController = [[MPMoviePlayerController alloc] initWithContentURL: self.contentURL];
			if (IS_NOT_NULL(m_rawMovieController))
			{
				[m_rawMovieController play];
				self.isPlaying = YES;
			}
		}
	}
	return (self.isPlaying);
}


//============================================================================
//	S4FullScreenMoviePlayer :: stopMovie
//============================================================================
- (void)stopMovie
{
	if (YES == self.isPlaying)
	{
		self.isPlaying = NO;
		if (IS_NOT_NULL(m_movieViewController))
		{
			[m_movieViewController.moviePlayer stop];
		}
		else if (IS_NOT_NULL(m_rawMovieController))
		{
			[m_rawMovieController stop];
		}
	}
}

@end
