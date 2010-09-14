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
 *			Michael Papp
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		NSInvocation+S4Utilities.m
 * Module:		Categories
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "NSInvocation+S4Utilities.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// =========================== Begin S4InvocationProxy =================================

@interface S4InvocationProxy : NSProxy
{
@private
	id										m_target;
	NSInvocation							*m_invocation;
}

//	Properties
@property (retain) id									target;
@property (retain) NSInvocation							*invocation;

//	Class methods

//	Instance methods
- (id)initWithTarget: (id)newTarget;
- (void)forwardInvocation: (NSInvocation *)fwdInvocation;
- (NSMethodSignature *)methodSignatureForSelector: (SEL)selector;
- (void)dealloc;

@end



@implementation S4InvocationProxy


//============================================================================
//	S4InvocationProxy synthesize properties
//============================================================================
@synthesize target = m_target;
@synthesize invocation = m_invocation;


//============================================================================
//	S4InvocationProxy :: initWithTarget:
//============================================================================
- (id)initWithTarget: (id)newTarget
{
    self.target = newTarget;
    return (self);
}


//============================================================================
//	S4InvocationProxy :: forwardInvocation:
//============================================================================
- (void)forwardInvocation: (NSInvocation *)fwdInvocation
{
	[fwdInvocation setTarget: self.target];
	self.invocation = fwdInvocation;
}


//============================================================================
//	S4InvocationProxy :: methodSignatureForSelector:
//============================================================================
- (NSMethodSignature *)methodSignatureForSelector: (SEL)selector
{
	NSMethodSignature			*methodSigResult = nil;

	if ((IS_NOT_NULL(self.target)) && (NULL != selector))
	{
		methodSigResult = [self.target methodSignatureForSelector: selector];
	}
	return (methodSigResult);
}


//============================================================================
//	S4InvocationProxy :: dealloc
//============================================================================
- (void)dealloc
{
	self.target = nil;
	self.invocation = nil;

	[super dealloc];
}

@end



// ====================== Begin Class NSInvocation (S4Utilities) =======================

@implementation NSInvocation (S4Utilities)


//============================================================================
//	NSInvocation (S4Utilities) :: invocationWithTarget:block:
//============================================================================
+ (id)invocationWithTarget: (id)newTarget block: (void (^)(id target))blockToExecute
{
	S4InvocationProxy				*proxy;
	id								idResult = nil;

	if (IS_NOT_NULL(newTarget))
	{
		proxy = [[[S4InvocationProxy alloc] initWithTarget: newTarget] autorelease];
		if (IS_NOT_NULL(proxy))
		{
			blockToExecute(proxy);
			idResult = proxy.invocation;
		}
	}
	return (idResult);
}

@end