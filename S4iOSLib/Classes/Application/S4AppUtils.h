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
 * Name:		S4AppUtils.h
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// =============================== Class S4AppUtils =====================================

@interface S4AppUtils : NSObject
{
@private
	NSString									*m_productName;
	NSString									*m_productVersion;
}

// Class methods
+ (S4AppUtils *)getInstance;

// Instance methods

// retrieve name of application from info.plist
- (NSString *)productName;

// retrieve the version from the info.plist
- (NSString *)productVersion;

// Generic "open URL" with another application method
- (void)openApplicationWithUrlStr: (NSString *)urlStr;

// Mail methods
- (void)sendCCMailWithAddressStr: (NSString *)addressStr cc: (NSString *)ccStr  subject: (NSString *)subjectStr body: (NSString *)bodyStr;
- (void)sendHtmlCCMailWithAddressStr: (NSString *)addressStr cc: (NSString *)ccStr  subject: (NSString *)subjectStr htmlBody: (NSString *)htmlBodyStr;
- (BOOL)canUseMailComposer;
- (BOOL)sendComposerMailForController: (UIViewController *)viewController
						  toAddresses: (NSArray *)toRecipients
						  ccAddresses: (NSArray *)ccRecipients
						 bccAddresses: (NSArray *)bccRecipients
						  mailBodyStr: (NSString *)emailBody
							   isHTML: (BOOL)bIsHTML
					   attachmentData: (NSData *)attachData
				   attachmentMimeType: (NSString *)attachMimeType
				   attachmentFileName: (NSString *)attachFileName
						  mailSubject: (NSString *)subject;

// HTTP method
- (void)openSafariWithUrl: (NSString *)urlRawStr;

// Map methods
- (void)openMapsWithAddressStr: (NSString *)addressStr city: (NSString *)cityStr state: (NSString *)stateStr zip: (NSString *)zipStr;
- (void)openMapsWithLatitude: (double)dLatitude longitude: (double)dLongitude;
- (void)openMapsAtStartingAddress: (NSString *)srcAddressStr
						  srcCity: (NSString *)srcCityStr
						 srcState: (NSString *)srcStateStr
						   srcZip: (NSString *)srcZipStr
					   dstAddress: (NSString *)dstAddressStr
						  dstCity: (NSString *)dstCityStr
						 dstState: (NSString *)dstStateStr
						   dstZip: (NSString *)dstZipStr;
- (void)placeCallWithPhoneNumStr: (NSString *)phoneNumberStr;
- (void)sendSmsTextMsgWithPhoneNumStr: (NSString *)phoneNumberStr;

- (BOOL)isLocaleMetric;
- (NSString *)isoCountry;
- (NSString *)isoLanguage;
- (NSString *)displayCountry;
- (NSString *)displayLanguage: (NSString *)isoLanguage;
- (NSString *)displayLanguage;

@end
