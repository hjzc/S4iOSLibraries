//
//  SHKFacebook.m
//  ShareKit
//
//  Created by Nathan Weiner on 6/18/10.

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKFacebook.h"


@implementation SHKFacebook

@synthesize facebook;
@synthesize pendingFacebookAction;

static NSString *const SHKFacebookAccessToken = @"SHKFacebookAccessToken";
static NSString *const SHKFacebookExpirationDate = @"SHKFacebookExpirationDate";
static NSString *const SHKFacebookPendingItem = @"SHKFacebookPendingItem";

- (id)init {
	if ((self = [super init])) {
		permissions = [[NSArray alloc] initWithObjects:@"publish_stream", @"offline_access", nil];
	}
	
	return self;
}

- (void)dealloc {
	[facebook release], facebook = nil;
	[super dealloc];
}

- (Facebook*)facebook {
	if (!facebook) {
		facebook = [[Facebook alloc] initWithAppId:SHKFacebookAppId];
		facebook.sessionDelegate = self;
		facebook.accessToken = [self getAuthValueForKey:SHKFacebookAccessToken];
		facebook.expirationDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:SHKFacebookExpirationDate];
	}
	
	return facebook;
}

#pragma mark -
#pragma mark Configuration : Service Definition

+ (NSString *)sharerTitle
{
	return @"Facebook";
}

+ (BOOL)canShareURL
{
	return YES;
}

+ (BOOL)canShareText
{
	return YES;
}

+ (BOOL)canShareImage
{
	return YES;
}

+ (BOOL)canShareOffline
{
	return NO;  // TODO - would love to make this work
}

#pragma mark -
#pragma mark Configuration : Dynamic Enable

- (BOOL)shouldAutoShare
{
	return YES; // FBConnect presents its own dialog
}

#pragma mark -
#pragma mark Authentication

- (BOOL)isAuthorized {
	return [self.facebook isSessionValid];
}

- (void)promptAuthorization {
	// store the pending item in NSUserDefaults as the authorize could kick the user out to the Facebook app or Safari
	[[NSUserDefaults standardUserDefaults] setObject:[self.item dictionaryRepresentation] forKey:SHKFacebookPendingItem];
	[self.facebook authorize:permissions delegate:self];
}

- (void)authFinished:(SHKRequest *)request
{

}

+ (void)logout {
	Facebook *fb = [[[Facebook alloc] initWithAppId:SHKFacebookAppId] autorelease];
	fb.accessToken = [[[[self alloc] init] autorelease] getAuthValueForKey:SHKFacebookAccessToken];
	fb.expirationDate = (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:SHKFacebookExpirationDate];
	[fb logout:self];
	
	[SHK removeAuthValueForKey:SHKFacebookAccessToken forSharer:[self sharerId]];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:SHKFacebookExpirationDate];
}

#pragma mark -
#pragma mark Share API Methods

- (BOOL)send {
	if (item.shareType == SHKShareTypeURL) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   [item.URL absoluteString], @"link",
									   item.title, @"name",
									   item.text, @"caption",
									   nil];
		
		if ([item customValueForKey:@"image"]) {
			[params setObject:[item customValueForKey:@"image"] forKey:@"picture"];
		}

		if([self shouldAutoShare]) {
			[self.facebook requestWithGraphPath:@"me/feed" 
									  andParams:params 
								  andHttpMethod:@"POST" 
									andDelegate:self];
            [self sendDidStart];
        } else {
            [self.facebook dialog:@"feed" andParams:params andDelegate:self];
        }
	}
	else if (item.shareType == SHKShareTypeText) {
		NSString *actionLinks = [NSString stringWithFormat:@"{\"name\":\"Get %@\", \"link\":\"%@\"}",
								 SHKEncode(SHKMyAppName),
								 SHKEncode(SHKMyAppURL)];
		
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   item.text, @"message",
									   actionLinks, @"actions",
									   nil];

        if([self shouldAutoShare]) {
			[self.facebook requestWithGraphPath:@"me/feed" 
									  andParams:params 
								  andHttpMethod:@"POST" 
									andDelegate:self];
            [self sendDidStart];
        } else {
            [self.facebook dialog:@"feed" andParams:params andDelegate:self];
        }
	}
	else if (item.shareType == SHKShareTypeImage) {
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									   item.image, @"source",
									   item.title, @"message",
									   nil];
		
		[self.facebook requestWithGraphPath:@"me/photos" 
								  andParams:params 
							  andHttpMethod:@"POST" 
								andDelegate:self];
        [self sendDidStart];
	}
	
	return YES;
}

- (void)dialogDidComplete:(FBDialog *)dialog {
	if (pendingFacebookAction == SHKFacebookPendingStatus) {
		[self sendDidFinish];
	}
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
	if (pendingFacebookAction == SHKFacebookPendingStatus) {
		[self sendDidCancel];
	}
}

- (BOOL)dialog:(FBDialog *)dialog shouldOpenURLInExternalBrowser:(NSURL *)url {
	return YES;
}

#pragma mark -
#pragma mark FBSessionDelegate methods
- (void)fbDidLogin {
	// store the Facebook credentials for use in future requests
	[SHK setAuthValue:self.facebook.accessToken forKey:SHKFacebookAccessToken forSharer:[self sharerId]];
	[[NSUserDefaults standardUserDefaults] setObject:self.facebook.expirationDate forKey:SHKFacebookExpirationDate];
	
	// if the current device does not support multitasking, the shared item will still be set and we can skip restoring the item
	// if the current device does support multitasking, this instance of SHKFacebook will be different that the original one and we need to restore the shared item
	UIDevice *device = [UIDevice currentDevice];
	if ([device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported]) {
		self.item = [SHKItem itemFromDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:SHKFacebookPendingItem]];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:SHKFacebookPendingItem];
	}
	
	[self share];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	// not handling this
}

- (void)fbDidLogout {
	// not handling this
}

#pragma mark -
#pragma mark FBRequestDelegate methods

- (void)request:(FBRequest*)aRequest didLoad:(id)result {
	[self sendDidFinish];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	[self sendDidFailWithError:error];
}

@end
