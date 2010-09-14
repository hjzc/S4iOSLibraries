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
 * Name:		S4NetUtilities.h
 * Module:		Network
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "S4HttpConnection.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// ================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Protocols ========================================



// ============================ Class S4NetUtilities ===================================

@interface S4HttpInvokeOperation : NSOperation <S4HttpConnectionDelegate>
{
@private
	NSURLRequest								*m_UrlRequest;
	S4HttpConnection							*m_S4HttpConnection;
	NSInvocation								*m_DataInvocation;
	NSInvocation								*m_ErrInvocation;
	BOOL										m_bStarted;
	BOOL										m_bCancelled;
	BOOL										m_bExecuting;
	BOOL										m_bFinished;
	BOOL										m_bReady;
}

// Class methods

// Instance method called before Operation is placed in Queue
- (BOOL)prepareForRequest: (NSURLRequest *)request dataInvocation: (NSInvocation *)dataInvoke errInvocation: (NSInvocation *)errInvoke;


/********************* NSOperation subclassed methods *********************/
// Begins the execution of the operation
- (void)start;
// Performs the receiver’s non-concurrent task
- (void)main;
// Advises the operation object that it should stop executing its task
- (void)cancel;
// Returns a Boolean value indicating whether the operation has been cancelled
- (BOOL)isCancelled;
// Returns a Boolean value indicating whether the operation is currently executing
- (BOOL)isExecuting;
// Returns a Boolean value indicating whether the operation is done executing
- (BOOL)isFinished;
// Returns a Boolean value indicating whether the operation runs asynchronously
- (BOOL)isConcurrent;
// Returns a Boolean value indicating whether the receiver’s operation can be performed now
- (BOOL)isReady;

@end
