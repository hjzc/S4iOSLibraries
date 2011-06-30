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
 * Name:		S4CrashManager.m
 * Module:		Application
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#include <libkern/OSAtomic.h>
#include <execinfo.h>
#include <unistd.h>
#import "S4CrashManager.h"
#import "S4SingletonClass.h"
#import "S4FileUtilities.h"


// ================================== Defines ==========================================

#define MAX_FRAMES_TO_DISPLAY							(int)30

// ALL S4 LIBS SHOULD DEFINE THIS:
#define LIB_DOMAIN_NAME_STR								@"S4CrashManager"


// ================================== Typedefs ==========================================



// ================================== Globals ==========================================

const NSInteger						kS4SkipAddressCount = 4;

// Crash log constants
S4_INTERN_CONSTANT_NSSTR			kS4CrashLogDirectory = @"CrashLogFolder";
S4_INTERN_CONSTANT_NSSTR			kS4CrashLogFileName = @"S4CrashLog.log";
S4_INTERN_CONSTANT_NSSTR			kS4CrashLogFmtStr = @"S4CrashManager Log Entry - Date and Time: %@\nName: %@\nReason: %@\nCall Stack:\n%@\n\n\n";
S4_INTERN_CONSTANT_NSSTR			kS4CrashLogBadFmtStr = @"S4CrashManager Log Entry - Date and Time: %@\nReason: No exception was passed.\nCall Stack:\n%@\n\n\n";

// S4CrashManager additions to the NSException userInfo dictionary
S4_INTERN_CONSTANT_NSSTR			kS4SignalExceptionName = @"SignalReceivedByApplication";
S4_INTERN_CONSTANT_NSSTR			kS4SignalKey = @"SignalNumber";
S4_INTERN_CONSTANT_NSSTR			kS4CallStackKey = @"CallStack";

volatile int32_t					g_failureCount = 0;


// ============================= Forward Declarations ==================================

void S4ExceptionHandler(NSException *exception);
void S4SignalHandler(int signal);
void InstallS4Handlers(void);


// ================================== Inlines ==========================================

//============================================================================
//	S4ExceptionHandler  -  PRIVATE
//============================================================================
void S4ExceptionHandler(NSException *exception)
{
	S4CrashManager							*s4CrashManager;

	// increment the failure count
	OSAtomicIncrement32(&g_failureCount);

	// call the CrashManager instance
	s4CrashManager = [S4CrashManager getInstance];
	if (IS_NOT_NULL(s4CrashManager))
	{
		[s4CrashManager performSelectorOnMainThread: @selector(handleException:) withObject: exception waitUntilDone: YES];
	}
	// and pass exception up
	[exception raise];
}


//============================================================================
//	S4SignalHandler  -  PRIVATE
//============================================================================
void S4SignalHandler(int signal)
{
	NSMutableDictionary						*localUserInfo;
	NSException								*localException = nil;
	S4CrashManager							*s4CrashManager;

	// increment the failure count
	OSAtomicIncrement32(&g_failureCount);

	// signals don't pass an exception as a parameter, so we have to build our own
	localUserInfo = [NSMutableDictionary dictionaryWithObject: [NSNumber numberWithInt: signal] forKey: kS4SignalKey];
	if (IS_NOT_NULL(localUserInfo))
	{
		localException = [NSException exceptionWithName: kS4SignalExceptionName
												 reason: [NSString stringWithFormat: @"Signal %d was received", signal]
											   userInfo: localUserInfo];
	}

	// call the CrashManager instance
	s4CrashManager = [S4CrashManager getInstance];
	if (IS_NOT_NULL(s4CrashManager))
	{
		[s4CrashManager performSelectorOnMainThread: @selector(handleException:) withObject: localException waitUntilDone: YES];
	}

	// and pass signal up
	kill(getpid(), signal);
}


//============================================================================
//	InstallS4Handlers  -  PUBLIC
//============================================================================
void InstallS4Handlers(void)
{
	NSSetUncaughtExceptionHandler(&S4ExceptionHandler);
	signal(SIGABRT, S4SignalHandler);
	signal(SIGILL, S4SignalHandler);
	signal(SIGSEGV, S4SignalHandler);
	signal(SIGFPE, S4SignalHandler);
	signal(SIGBUS, S4SignalHandler);
	signal(SIGPIPE, S4SignalHandler);
}



// ========================== Begin Class S4CrashManager () ============================

@interface S4CrashManager ()

@property (nonatomic, retain) id <S4CrashManagerDelegate>			m_delegate;
@property (nonatomic, readwrite) BOOL								handlerInstalled;

@end



// ==================== Begin Class S4CrashManager (PrivateImpl) =======================

@interface S4CrashManager (PrivateImpl)

- (void)oneTimeInit;
- (void)installCrashHandlers;
- (NSArray *)getCallStack;
- (NSString *)getLogFileNameAndPath;
- (void)writeErrorStringToLog: (NSString *)errorString;

@end



@implementation S4CrashManager (PrivateImpl)

//============================================================================
//	S4CrashManager (PrivateImpl) :: oneTimeInit
//============================================================================
- (void)oneTimeInit
{
	self.m_delegate = nil;
	self.handlerInstalled = NO;
	m_bDismissed = NO;
	m_bWriteToLog = NO;
}


//============================================================================
//	S4CrashManager (PrivateImpl) :: installCrashHandlers
//============================================================================
- (void)installCrashHandlers
{
	InstallS4Handlers();
}


//============================================================================
//	S4CrashManager (PrivateImpl) :: getCallStack
//============================================================================
- (NSArray *)getCallStack
{
	void							*callstack[128];
	int								frames;
	char							**strs;
	int								framesToDisplay;
	int								i;
	NSMutableArray					*callStkArrayResult;

	frames = backtrace(callstack, 128);
	strs = backtrace_symbols(callstack, frames);

	// display just a subset of the full frame stack
	if (MAX_FRAMES_TO_DISPLAY < frames)
	{
		framesToDisplay = MAX_FRAMES_TO_DISPLAY;
	}
	else
	{
		framesToDisplay = frames;
	}

	// build an array of strings with the call stack enumerated
	callStkArrayResult = [NSMutableArray arrayWithCapacity: frames];
	for (i = kS4SkipAddressCount; i < framesToDisplay; i++)
	{
	 	[callStkArrayResult addObject: [NSString stringWithCString: (const char *)strs[i] encoding: NSUTF8StringEncoding]];
	}
	free(strs);

	return (callStkArrayResult);
}


//============================================================================
//	S4CrashManager (PrivateImpl) :: getLogFileNameAndPath
//============================================================================
- (NSString *)getLogFileNameAndPath
{
	NSString						*baseDirectory;
	NSString						*logDirectory;
	NSString						*strResult = nil;

	baseDirectory = [S4FileUtilities documentsDirectory];
	if (STR_NOT_EMPTY(baseDirectory))
	{
		logDirectory = [baseDirectory stringByAppendingPathComponent: kS4CrashLogDirectory];
		if (STR_NOT_EMPTY(logDirectory))
		{
			if ([S4FileUtilities createDirectory: logDirectory])
			{
				strResult = [logDirectory stringByAppendingPathComponent: kS4CrashLogFileName];
			}
		}
	}
	return (strResult);
}


//============================================================================
//	S4CrashManager (PrivateImpl) :: writeErrorStringToLog:
//============================================================================
- (void)writeErrorStringToLog: (NSString *)errorString
{
	NSString						*fileNameAndPath;
	NSFileHandle					*fileHandle;
	NSData							*data;

	// if delegate wants us to use default logging...
	if (YES == m_bWriteToLog)
	{
		fileNameAndPath = [self getLogFileNameAndPath];
		if (STR_NOT_EMPTY(fileNameAndPath))
		{
			// see if file exists; if so, just append new data to it
			fileHandle = [NSFileHandle fileHandleForWritingAtPath: fileNameAndPath];
			if (IS_NOT_NULL(fileHandle))
			{
				data = [errorString dataUsingEncoding: NSUTF8StringEncoding];
				[fileHandle seekToEndOfFile];
				[fileHandle writeData: data];
				[fileHandle synchronizeFile];
				[fileHandle closeFile];
			}
			else
			{
				// no existing log file, write one out from scratch
				[errorString writeToFile: fileNameAndPath atomically: YES encoding: NSUTF8StringEncoding error: NULL];
			}
		}
	}
}

@end



// ======================= Begin Class S4CrashManager ========================

@implementation S4CrashManager


//============================================================================
//	S4CrashManager synthesize properties
//============================================================================
@synthesize m_delegate;
@synthesize handlerInstalled = m_bHandlerInstalled;
//@synthesize maxFailureRetries = m_iMaxRetries;


///////////////////////////////////// START SINGLETON METHODS /////////////////////////////////////


SYNTHESIZE_SINGLETON_CLASS(S4CrashManager)


//////////////////////////////////////// INSTANCE METHODS /////////////////////////////////////////


//============================================================================
//	S4CrashManager :: installCrashReportingForDelegate:shouldSaveLog:
//============================================================================
- (BOOL)installCrashReportingForDelegate: (id <S4CrashManagerDelegate>)delegate shouldSaveLog: (BOOL)bSaveLogs
{
	BOOL					bResult = NO;

	if ((IS_NOT_NULL(delegate)) && ([delegate conformsToProtocol: @protocol(S4CrashManagerDelegate)]) && (NO == self.handlerInstalled))
	{
		self.m_delegate = delegate;
		self.handlerInstalled = YES;
		m_bWriteToLog = bSaveLogs;
		[self performSelector: @selector(installCrashHandlers) withObject: nil afterDelay: 0];
		bResult = YES;
	}
	return (bResult);
}


//============================================================================
//	S4CrashManager :: handleException:
//============================================================================
- (void)handleException: (NSException *)originalException
{
	NSArray									*callStackStrArray;
	NSString								*errorString;
	NSDictionary							*originalUserInfo;
	NSNumber								*signalNumber;
	BOOL									bIsSignal = NO;
	NSMutableDictionary						*localUserInfo;
	NSException								*localException = nil;
	BOOL									bShouldContinue = NO;
	UIAlertView								*alert;
	CFRunLoopRef							runLoop;
	CFArrayRef								allRunLoopModesArray;

	// get the callstack
	callStackStrArray = [self getCallStack];

	// if a valid exception was passed in, build a new one with our additions
	if (IS_NOT_NULL(originalException))
	{
		// build a string to describe the error and log it
		errorString = [NSString stringWithFormat: kS4CrashLogFmtStr, [NSDate date], [originalException name], [originalException reason], callStackStrArray];

		// find out if we have a valid userInfo Dictionary in the original exception,
		// and find out if this was a signal - if so, then it is a fatal error
		originalUserInfo = [originalException userInfo];
		if (IS_NOT_NULL(originalUserInfo))
		{
			signalNumber = (NSNumber *)[originalUserInfo objectForKey: kS4SignalKey];
			if (IS_NOT_NULL(signalNumber))
			{
				bIsSignal = YES;
			}

			// copy the exception's userInfo dictionary into our own
			localUserInfo = [NSMutableDictionary dictionaryWithDictionary: originalUserInfo];
		}
		else
		{
			// no userInfo dictionary in the original exception
			localUserInfo = [NSMutableDictionary dictionaryWithCapacity: (NSUInteger)1];
		}

		if (IS_NOT_NULL(localUserInfo))
		{
			[localUserInfo setObject: callStackStrArray forKey: kS4CallStackKey];
			localException = [NSException exceptionWithName: [originalException name] reason: [originalException reason] userInfo: localUserInfo];
		}
	}
	else
	{
		errorString = [NSString stringWithFormat: kS4CrashLogBadFmtStr, [NSDate date], callStackStrArray];
	}

	// write the log file if we are configured to save logs
	[self writeErrorStringToLog: errorString];

	// let the delegate know an exception/signal has occurred and see if they want to continue (only for exceptions)
	if (IS_NOT_NULL(self.m_delegate))
	{
		if (IS_NOT_NULL(localException))
		{
			bShouldContinue = [self.m_delegate crashManager: self
										   examineException: localException
											  failuresSoFar: g_failureCount
													isFatal: bIsSignal];
		}
		else
		{
			bShouldContinue = [self.m_delegate crashManager: self
										   examineException: originalException
											  failuresSoFar: g_failureCount
													isFatal: bIsSignal];
		}
	}

	// always show the user an alert: if the application returns YES from the above protocol method AND the error is not a signal,
	// then give the user a choice.  Otherwise, just let them know that the application is about to exit.
	if ((YES == bShouldContinue) && (NO == bIsSignal))
	{
		alert = [[[UIAlertView alloc] initWithTitle: @"Application Error"
											message: @"An error has occurred. If you continue the application may be unstable."
										   delegate: self
								  cancelButtonTitle: @"Quit"
								  otherButtonTitles: @"Continue", nil] autorelease];
	}
	else			// application wants to exit, let the user know
	{
		alert = [[[UIAlertView alloc] initWithTitle: @"Application Error"
											message: @"An error has occurred. The application must exit."
										   delegate: self
								  cancelButtonTitle: @"OK"
								  otherButtonTitles: nil, nil] autorelease];		
	}
	[alert show];

	// this runloop keeps us alive to display the dialog, and ostensibly keeps the appl executing if the user so decides
	runLoop = CFRunLoopGetCurrent();
	allRunLoopModesArray = CFRunLoopCopyAllModes(runLoop);
	while (NO == m_bDismissed)
	{
		for (NSString *mode in (NSArray *)allRunLoopModesArray)
		{
			CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
		}
	}
	CFRelease(allRunLoopModesArray);

	// the user has decided to quit the app, or the application has decided not to retry;
	// call the delgate to inform them that termination is imminent
	if (IS_NOT_NULL(self.m_delegate))
	{
		if (YES == bShouldContinue)
		{
			[self.m_delegate crashManager: self applFailedWithCause: kUserChoseQuit];
		}
		else
		{
			[self.m_delegate crashManager: self applFailedWithCause: kInternalApplExit];
		}
	}

	// uninstall all the handlers
	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
}


//============================================================================
//	S4CrashManager :: getCrashLog
//============================================================================
- (NSString *)getCrashLog
{
	NSString						*fileNameAndPath;
	NSString						*strResult = nil;

	fileNameAndPath = [self getLogFileNameAndPath];
	if (STR_NOT_EMPTY(fileNameAndPath))
	{
		strResult = [NSString stringWithContentsOfFile: fileNameAndPath encoding: NSUTF8StringEncoding error: NULL];
	}
	return (strResult);
}


//============================================================================
//	S4CrashManager :: deleteCrashLog
//============================================================================
- (void)deleteCrashLog
{
	NSString						*fileNameAndPath;

	fileNameAndPath = [self getLogFileNameAndPath];
	if (STR_NOT_EMPTY(fileNameAndPath))
	{
		[S4FileUtilities deleteDiskItemAtPath: fileNameAndPath];
	}
}


//============================================================================
//	S4CrashManager :: alertView:clickedButtonAtIndex:
//============================================================================
- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)index
{
	if (0 == index)
	{
		m_bDismissed = YES;
	}
}

@end
