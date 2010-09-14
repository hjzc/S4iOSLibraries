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
 * Name:		S4CrashManager.h
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================

typedef enum
{
	kInternalApplExit		= 0,
	kUserChoseQuit			= 2
}	ApplExitCause;


// =================================== Globals =========================================

S4_EXTERN_CONSTANT_NSSTR				kS4SignalExceptionName;
S4_EXTERN_CONSTANT_NSSTR				kS4SignalKey;
S4_EXTERN_CONSTANT_NSSTR				kS4CallStackKey;


// ============================= Forward Declarations ==================================

@class S4CrashManager;


// ================================== Protocols ========================================
// ============================ S4CrashManager Delegate ================================

@protocol S4CrashManagerDelegate <NSObject>

@required
// Delegates have this method called when an exception or signal occurs.  Delegates should examine exceptions/signals and decide
// if possible to resume normal application operation.  Return YES if you want to try to resume, NO if you want to exit.  Either
// return value will display a dialog to the user - the user also gets to choose to continue or quit if you return a value of YES
// from this method.  If the bIsFatal parameter is YES, then the return value is ignored - the CrashManager has determined that
// this is a non-recoverable error.
// You can also use this protocol method to implement your own logging functionality.  This method gives you all the information
// you need to create a crash log.  The NSException you receive has the call stack appended to the userInfo dictionary using the
// kS4CallStackKey defined above.
// NOTE:  when this method is called, you have a better chance to save data and put affairs in order as a new CFRunLoop will start.
// The applFailedWithCause: method is really a last gasp message to the application that termination is imminent.

- (BOOL)crashManager: (S4CrashManager *)crashManager
	examineException: (NSException *)exception
	   failuresSoFar: (int32_t)totalFailures
			 isFatal: (BOOL)bIsFatal;

// Delegates have this method called just before the application exits due to an exception/signal.  The cause parameter is determined
// by either the application returning NO from the examineException delegate method (above), or if the user decided to quit in
// response to the Application Failure dialog that is displayed after the examineException delegate method is called.  This call is
// the last chance an application has to save data or otherwise set affairs in order.  See the note above - when this method is
// called, application termination is imminent.  It is certain any UI interactions and most file/network operations will fail.

- (void)crashManager: (S4CrashManager *)crashManager applFailedWithCause: (ApplExitCause)cause;

@optional

@end


// ============================= Class S4CrashManager ==================================

@interface S4CrashManager : NSObject
{
@private
	id <S4CrashManagerDelegate>					m_delegate;
	BOOL										m_bHandlerInstalled;
	BOOL										m_bDismissed;
	BOOL										m_bWriteToLog;
}

// Properties
@property (nonatomic, readonly) BOOL								handlerInstalled;

// Class methods
+ (S4CrashManager *)getInstance;

// Instance methods
- (BOOL)installCrashReportingForDelegate: (id <S4CrashManagerDelegate>)delegate shouldSaveLog: (BOOL)bSaveLogs;
- (void)handleException: (NSException *)originalException;
- (NSString *)getCrashLog;
- (void)deleteCrashLog;

@end
