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
 * Name:		S4WebViewController.m
 * Module:		Test
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4WebViewController.h"
#import "S4FileUtilities.h"
#import "S4NetUtilities.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =================== Begin Class S4WebViewController (PrivateImpl) ===================

@interface S4WebViewController (PrivateImpl)

- (void)placeHolder1;
- (void)placeHolder2;

@end




@implementation S4WebViewController (PrivateImpl)

//============================================================================
//	S4WebViewController (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}


//============================================================================
//	S4WebViewController (PrivateImpl) :: placeHolder2
//============================================================================
- (void)placeHolder2
{
}

@end




// ===================== Begin Class S4WebViewController =====================

@implementation S4WebViewController

//============================================================================
//	S4WebViewController :: properties
//============================================================================
@synthesize browserView = m_browserView;
@synthesize loadingView = m_loadingView;


//============================================================================
//	S4WebViewController :: initWithNibName:
//============================================================================
- (id)initWithNibName: (NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
	id							idResult = nil;

	self = [super initWithNibName: @"S4WebView" bundle: nibBundleOrNil];
	if (nil != self)
	{
		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4WebViewController :: dealloc
//============================================================================
- (void)dealloc
{
	[super dealloc];
}


//============================================================================
//	S4WebViewController :: didReceiveMemoryWarning
//============================================================================
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}


//============================================================================
//	S4WebViewController :: loadUrl:
//============================================================================
-(BOOL)loadUrl: (NSString *)urlStr
{
	NSURL						*url;
	NSURLRequest				*request;
	BOOL						bResult = NO;
	
	if (STR_NOT_EMPTY(urlStr))
	{
		url = [S4NetUtilities createNSUrlForPathStr: urlStr baseStr: nil];
		if (IS_NOT_NULL(url))
		{
			request = [S4NetUtilities createSimpleRequestForURL: url useCache: YES];
			if (IS_NOT_NULL(request))
			{
				[self.browserView loadRequest: request];
				bResult = YES;
			}
		}
	}
	return (bResult);	
}


//============================================================================
//	S4WebViewController :: loadFileWithPath:
//============================================================================
-(BOOL)loadFileWithPath: (NSString *)fileNameWithPath
{
	NSURL						*url;
	NSURLRequest				*request;
	BOOL						bResult = NO;

	if (STR_NOT_EMPTY(fileNameWithPath))
	{
		if (YES == [S4FileUtilities fileExists: fileNameWithPath])
		{
			url = [NSURL fileURLWithPath: fileNameWithPath];
			if (IS_NOT_NULL(url))
			{
				request = [NSURLRequest requestWithURL: url];
				if (IS_NOT_NULL(request))
				{
					[self.browserView loadRequest: request];
					bResult = YES;
				}
			}
		}
	}
	return (bResult);
}




/****************************************  UIWebViewDelegate Protocol Methods *****************************************/

//============================================================================
//	S4WebViewController :: webViewDidStartLoad:
//============================================================================
- (void)webViewDidStartLoad: (UIWebView *)webView
{
	[self.loadingView startAnimating];
}


//============================================================================
//	S4WebViewController :: webViewDidFinishLoad:
//============================================================================
- (void)webViewDidFinishLoad: (UIWebView *)webView
{
	[self.loadingView stopAnimating];
}


//============================================================================
//	S4WebViewController :: didFailLoadWithError:
//============================================================================
- (void)webView: (UIWebView *)webView didFailLoadWithError: (NSError *)error
{
	UIAlertView				*alert;

	alert = [[UIAlertView alloc] initWithTitle: @"Page Load Error"
									   message: @"An error occured when loadng the page.  Please try again later."
									  delegate: nil
							 cancelButtonTitle: @"Okay"
							 otherButtonTitles: nil];
	[alert show];
	[alert release];
}


//============================================================================
//	S4WebViewController :: shouldStartLoadWithRequest:
//============================================================================
- (BOOL)webView: (UIWebView *)webView shouldStartLoadWithRequest: (NSURLRequest *)request navigationType: (UIWebViewNavigationType)navigationType
{
	return (YES);
}

@end
