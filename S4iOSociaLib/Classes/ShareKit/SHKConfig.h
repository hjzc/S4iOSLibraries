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
 * Name:		S4CommonDefines.h
 * Module:		Common
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4CommonDefines.h"



// =================================== Defines =========================================

//	Basic UI Configuration - these settings control basic UI appearance

//	Toolbars
#define SHKBarStyle											@"UIBarStyleDefault"
#define SHKBarTintColorRed									-1		// Value between 0-255, set all to -1 for default
#define SHKBarTintColorGreen								-1		// Value between 0-255, set all to -1 for default
#define SHKBarTintColorBlue									-1		// Value between 0-255, set all to -1 for default

//	Forms
#define SHKFormFontColorRed									-1		// Value between 0-255, set all to -1 for default
#define SHKFormFontColorGreen								-1		// Value between 0-255, set all to -1 for default
#define SHKFormFontColorBlue								-1		// Value between 0-255, set all to -1 for default
#define SHKFormBgColorRed									-1		// Value between 0-255, set all to -1 for default
#define SHKFormBgColorGreen									-1		// Value between 0-255, set all to -1 for default
#define SHKFormBgColorBlue									-1		// Value between 0-255, set all to -1 for default


//	iPad Views
#define SHKModalPresentationStyle							@"UIModalPresentationFormSheet"
#define SHKModalTransitionStyle								@"UIModalTransitionStyleCoverVertical"

// ShareMenu Ordering - setting this to 1 will show list in Alphabetical Order, setting to 0 will follow the order in SHKShares.plist
#define SHKShareMenuAlphabeticalOrder						1

// Append 'Shared With 'Signature to Email (and related forms)
#define SHKSharedWithSignature								0

//	Advanced UI Configuration - these settings only need to be changed for uber custom installs
#define SHK_MAX_FAV_COUNT									3
#define SHK_FAVS_PREFIX_KEY									@"SHK_FAVS_"
#define SHK_AUTH_PREFIX										@"SHK_AUTH_"


// ================================== Typedefs =========================================



// =================================== Globals =========================================

// The string values listed below MUST be declared in your application, and your
//  AppDelegate.m file is probably a good place.  Use the "S4_INTERN_CONSTANT_NSSTR"
//  macro followed by an @"fill_in_the_string" value appropriate for your application.

// App Description - these values are used by any service that shows 'shared from XYZ'
S4_EXTERN_CONSTANT_NSSTR									SHKMyAppName;		// @"My App Name"
S4_EXTERN_CONSTANT_NSSTR									SHKMyAppURL;		// @"http://example.com"


/*
 API Keys
 --------
 This is the longest step to getting set up, it involves filling in API keys for the supported services.
 It should be pretty painless though and should hopefully take no more than a few minutes.
 
 Each key below as a link to a page where you can generate an api key.  Fill in the key for each service below.
 
 A note on services you don't need:
 If, for example, your app only shares URLs then you probably won't need image services like Flickr.
 In these cases it is safe to leave an API key blank.
 
 However, it is STRONGLY recommended that you do your best to support all services for the types of sharing you support.
 The core principle behind ShareKit is to leave the service choices up to the user.  Thus, you should not remove any services,
 leaving that decision up to the user.
 */

// Posterous  -  apidocs.posterous.com/
S4_EXTERN_CONSTANT_NSSTR									SHKPosterousAPIKey;

// Delicious  -  developer.apps.yahoo.com/projects
S4_EXTERN_CONSTANT_NSSTR									SHKDeliciousConsumerKey;
S4_EXTERN_CONSTANT_NSSTR									SHKDeliciousSecretKey;

// Read It Later  -  readitlaterlist.com/api/?shk
S4_EXTERN_CONSTANT_NSSTR									SHKReadItLaterKey;

// Evernote  -  www.evernote.com/about/developer/api/
S4_EXTERN_CONSTANT_NSSTR									SHKEvernoteUserStoreURL;
S4_EXTERN_CONSTANT_NSSTR									SHKEvernoteSecretKey;
S4_EXTERN_CONSTANT_NSSTR									SHKEvernoteConsumerKey;
S4_EXTERN_CONSTANT_NSSTR									SHKEvernoteNetStoreURLBase;

// Bit.ly  -  bit.ly/account/register, after signup: bit.ly/a/your_api_key
S4_EXTERN_CONSTANT_NSSTR									SHKBitLyLogin;
S4_EXTERN_CONSTANT_NSSTR									SHKBitLyKey;

// Flickr  -  www.flickr.com/services/apps/create/
S4_EXTERN_CONSTANT_NSSTR									SHKFlickrConsumerKey;		// The consumer key
S4_EXTERN_CONSTANT_NSSTR									SHKFlickrSecretKey;			// The secret key
S4_EXTERN_CONSTANT_NSSTR									SHKFlickrCallbackUrl;		// The user defined callback url

/*	Facebook settings to get right:
 
	URL Schemes
	---
	You must create a URL scheme in your Info.plist that is in the format fb[app_id]. See the documentation
	on the iOS SDK under Authentication and Authorization for more details. This is to allow
	the new Single Sign-on capabilities of the iOS SDK to callback to your application, should
	it use fast app switching to authenticate in the Facebook app or Safari.
 
	Modify AppDelegate class
	---
	You must implement the application:handleOpenURL: method in your AppDelegate class. In this method, call
	the handleOpenURL: method on the facebook property of an SHKFacebook instance.
	For example:

	- (BOOL)application: (UIApplication *)application handleOpenURL: (NSURL *)url
	{
		SHKFacebook *facebookSharer = [[[SHKFacebook alloc] init] autorelease];
		return [[facebookSharer facebook] handleOpenURL:url];
	}
*/
// Facebook  -  www.facebook.com/developers
// iOS SDK: github.com/facebook/facebook-ios-sdk 
S4_EXTERN_CONSTANT_NSSTR									SHKFacebookAppId;

/*	Twitter settings to get right:
 
	Differences between OAuth and xAuth
	--
	There are two types of authentication provided for Twitter, OAuth and xAuth.  OAuth is the default and will
	present a web view to log the user in.  xAuth presents a native entry form but requires Twitter to add xAuth
	to your app (you have to request it from them).  If your app has been approved for xAuth, set
	SHKTwitterUseXAuth to 1.

	Callback URL (important to get right for OAuth users)
	--
	1. Open your application settings at dev.twitter.com/apps/
	2. 'Application Type' should be set to BROWSER (not client)
	3. 'Callback URL' should match whatever you enter in SHKTwitterCallbackUrl.  The callback url doesn't have to
	be an actual existing url.  The user will never get to it because ShareKit intercepts it before the user is
	redirected.  It just needs to match.
*/
// Twitter  -  dev.twitter.com/apps/new
S4_EXTERN_CONSTANT_NSSTR									SHKTwitterConsumerKey;
S4_EXTERN_CONSTANT_NSSTR									SHKTwitterSecret;
// You need to set this if using OAuth, see note above (xAuth users can skip it)
S4_EXTERN_CONSTANT_NSSTR									SHKTwitterCallbackUrl;
// To use xAuth, set to 1
#define SHKTwitterUseXAuth									0
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
S4_EXTERN_CONSTANT_NSSTR									SHKTwitterUsername;


// ============================= Forward Declarations ==================================


