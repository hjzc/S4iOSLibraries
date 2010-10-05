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
 * Name:		S4FullScreenMoviePlayer.h
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// ================================== Globals =========================================



// ============================= Forward Declarations =================================



// ================================== Protocols ========================================
// ======================= S4FullScreenMoviePlayer Delegate ============================

@protocol S4FullScreenMovieDelegate <NSObject>

@required
- (void)moviePlayBackDidFinish;

@optional

@end


// ========================= S4FullScreenMoviePlayer Class =============================

@interface S4FullScreenMoviePlayer : NSObject
{
@private
	NSURL										*m_contentURL;
	MPMoviePlayerController						*m_rawMovieController;
	MPMoviePlayerViewController					*m_movieViewController;
	id <S4FullScreenMovieDelegate>				m_delegate;
	BOOL										m_bIsPlaying;
}

// Properties
@property (nonatomic, copy) NSURL								*contentURL;
@property (readonly, nonatomic) BOOL							isPlaying;

// Class methods
+ (id)moviePlayerWithContentURL: (NSURL *)url;

// Instance methods
- (id)initWithContentURL: (NSURL *)url;
- (BOOL)playMovieForViewController: (UIViewController *)viewController withDelegate: (id <S4FullScreenMovieDelegate>)delegate;
- (void)stopMovie;

@end
