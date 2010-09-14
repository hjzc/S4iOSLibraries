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
 *			Erica Sadun
 *
 * ***** END LICENSE BLOCK ***** */

/* ***** FILE BLOCK ******
 *
 * Name:		NSObject+S4Utilities.m
 * Module:		Categories
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "NSObject+S4Utilities.h"
#import <UIKit/UIKit.h>
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ========================= Begin Class NSObject (PrivateImpl) ========================

@interface NSObject (PrivateImpl)

- (NSInvocation *)invocationWithSelector: (SEL)selector andArguments: (va_list)arguments;
- (BOOL)performSelector: (SEL)selector withReturnValue: (void *)result andArguments: (va_list)arglist;
- (NSError *)createErrorForDescription: (NSString *)errorStr;

@end



@implementation NSObject (PrivateImpl)

//============================================================================
//	NSObject (PrivateImpl) :: invocationWithSelector:
//		Return an invocation based on a selector and variable arguments
//============================================================================
- (NSInvocation *)invocationWithSelector: (SEL)selector andArguments: (va_list)arguments
{
	NSMethodSignature			*methodSignature;
	int							argcount;
	int							totalArgs;
	char						*argtype;
	NSInvocation				*invocationResult = nil;

	if ([self respondsToSelector: selector])
	{
		methodSignature = [self methodSignatureForSelector: selector];
		if (nil != methodSignature)
		{
			invocationResult = [NSInvocation invocationWithMethodSignature: methodSignature];
			if (nil != invocationResult)
			{
				[invocationResult setTarget: self];
				[invocationResult setSelector: selector];

				argcount = 2;
				totalArgs = [methodSignature numberOfArguments];
				while (argcount < totalArgs)
				{
					argtype = (char *)[methodSignature getArgumentTypeAtIndex: argcount];
					if (strcmp(argtype, @encode(id)) == 0)
					{
						id argument = va_arg(arguments, id);
						[invocationResult setArgument: &argument atIndex: argcount++];
					}
					else if ((strcmp(argtype, @encode(char)) == 0) ||
							 (strcmp(argtype, @encode(unsigned char)) == 0) ||
							 (strcmp(argtype, @encode(short)) == 0) ||
							 (strcmp(argtype, @encode(unsigned short)) == 0) ||
							 (strcmp(argtype, @encode(int)) == 0) ||
							 (strcmp(argtype, @encode(unsigned int)) == 0))
					{
						int i = va_arg(arguments, int);
						[invocationResult setArgument: &i atIndex: argcount++];
					}
					else if ((strcmp(argtype, @encode(long)) == 0) || (strcmp(argtype, @encode(unsigned long)) == 0))
					{
						long l = va_arg(arguments, long);
						[invocationResult setArgument: &l atIndex: argcount++];
					}
					else if ((strcmp(argtype, @encode(long long)) == 0) || (strcmp(argtype, @encode(unsigned long long)) == 0))
					{
						long long ll = va_arg(arguments, long long);
						[invocationResult setArgument: &ll atIndex: argcount++];
					}
					else if ((strcmp(argtype, @encode(float)) == 0) || (strcmp(argtype, @encode(double)) == 0))
					{
						double d = va_arg(arguments, double);
						[invocationResult setArgument: &d atIndex: argcount++];
					}
					else if (strcmp(argtype, @encode(Class)) == 0)
					{
						Class cls = va_arg(arguments, Class);
						[invocationResult setArgument: &cls atIndex: argcount++];
					}
					else if (strcmp(argtype, @encode(SEL)) == 0)
					{
						SEL sel = va_arg(arguments, SEL);
						[invocationResult setArgument: &sel atIndex: argcount++];
					}
					else if (strcmp(argtype, @encode(char *)) == 0)
					{
						char *str = va_arg(arguments, char *);
						[invocationResult setArgument: str atIndex: argcount++];
					}
					else
					{
						NSString *type = [NSString stringWithCString: argtype encoding: NSASCIIStringEncoding];
						if ([type isEqualToString: @"{CGRect={CGPoint=ff}{CGSize=ff}}"])
						{
							CGRect arect = va_arg(arguments, CGRect);
							[invocationResult setArgument: &arect atIndex: argcount++];
						}
						else if ([type isEqualToString: @"{CGPoint=ff}"])
						{
							CGPoint apoint = va_arg(arguments, CGPoint);
							[invocationResult setArgument: &apoint atIndex: argcount++];
						}
						else if ([type isEqualToString: @"{CGSize=ff}"])
						{
							CGSize asize = va_arg(arguments, CGSize);
							[invocationResult setArgument: &asize atIndex: argcount++];
						}
						else
						{
							// assume its a pointer and punt
							void *ptr = va_arg(arguments, void *);
							[invocationResult setArgument: ptr atIndex: argcount++];
						}
					}
				}

				// sanity check
				if (argcount != totalArgs) 
				{
					@throw [NSException exceptionWithName: NSInvalidArgumentException
												   reason: @"NSObject+S4Utilities invocation argument count mismatch"
												 userInfo: nil];
					invocationResult = NULL;
				}
			}
		}
	}
	return (invocationResult);
}


//============================================================================
//	NSObject (PrivateImpl) :: performSelector:
//		Peform the selector using va_list arguments
//============================================================================
- (BOOL)performSelector: (SEL)selector withReturnValue: (void *)result andArguments: (va_list)arglist
{
	NSInvocation				*invocation;
	BOOL						bResult = NO;

	invocation = [self invocationWithSelector: selector andArguments: arglist];
	if (nil != invocation)
	{
		[invocation invoke];
		if (NULL != result)
		{
			[invocation getReturnValue: result];
		}
		bResult = YES;
	}
	return (bResult);
}


//============================================================================
//	NSObject (PrivateImpl) :: createErrorForDescription:
//============================================================================
- (NSError *)createErrorForDescription: (NSString *)errorStr
{
	NSDictionary			*errDict;
	NSError					*errorResult = nil;

	if (STR_NOT_EMPTY(errorStr))
	{
		errDict = [NSDictionary dictionaryWithObject: errorStr forKey: NSLocalizedDescriptionKey];
		if (IS_NOT_NULL(errDict))
		{
			errorResult = [NSError errorWithDomain: @"NSCocoaErrorDomain" code: -1 userInfo: errDict];
		}
	}
	return (errorResult);
}

@end




// ========================= Begin Class NSObject (S4Utilities) =========================

@implementation NSObject (S4Utilities)

//============================================================================
//	NSObject (S4Utilities) :: allocInSameZoneAsObject:
//		Return a new instance in the same zone as the object passed in
//============================================================================
+ (id)allocInSameZoneAsObject: (id)object
{
	id				idResult;

	if (IS_NOT_NULL(object))
	{
		idResult = [[self class] allocWithZone: [object zone]];
	}
	else
	{
		idResult = [[self class] allocWithZone: nil];
	}
	return (idResult);
}


//============================================================================
//	NSObject (S4Utilities) :: superclasses
//		Return an array of an object's superclasses
//============================================================================
- (NSArray *)superclasses
{
	Class					cls;
	NSMutableArray			*resultsArray;

	cls = [self class];
	resultsArray = [NSMutableArray arrayWithObject: cls];
	if (![cls isEqual: [NSObject class]])
	{
		do 
		{
			cls = [cls superclass];
			[resultsArray addObject: cls];
		}
		while (![cls isEqual: [NSObject class]]) ;
	}
	return (resultsArray);
}


//============================================================================
//	NSObject (S4Utilities) :: returnTypeForSelector:
//		Return a C-string with a selector's return type
//		may extend this idea to return a class
//============================================================================
- (const char *)returnTypeForSelector: (SEL)selector
{
	NSMethodSignature			*methodSignature;

	methodSignature = [self methodSignatureForSelector: selector];
	return ([methodSignature methodReturnType]);
}


//============================================================================
//	NSObject (S4Utilities) :: returnTypeForSelector:
//		Choose the first selector that an object can respond to
//============================================================================
- (SEL)chooseSelector: (SEL)firstSelector, ...
{
	va_list			selectors;
	SEL				curSelector;
	SEL				selResult = NULL;

	if ([self respondsToSelector: firstSelector])
	{
		selResult = firstSelector;
	}
	else
	{
		va_start(selectors, firstSelector);
		curSelector = va_arg(selectors, SEL);
		while (curSelector)
		{
			if ([self respondsToSelector: curSelector])
			{
				selResult = curSelector;
				break;
			}
			curSelector = va_arg(selectors, SEL);
		}
	}
	return (selResult);
}


//============================================================================
//	NSObject (S4Utilities) :: returnTypeForSelector:
//		Return an invocation with the given arguments
//============================================================================
- (NSInvocation *)invocationWithSelectorAndArguments: (SEL)selector, ...
{
	va_list					arglist;
	NSInvocation			*invocationResult;

	va_start(arglist, selector);
	invocationResult = [self invocationWithSelector: selector andArguments: arglist];
	va_end(arglist);
	return (invocationResult);	
}


//============================================================================
//	NSObject (S4Utilities) :: returnTypeForSelector:
//		Perform a selector with an arbitrary number of arguments
//============================================================================
- (BOOL)performSelector: (SEL)selector withReturnValueAndArguments: (void *)result, ...
{
	va_list						arglist;
	BOOL						bResult;

	va_start(arglist, result);
	bResult = [self performSelector: selector withReturnValue: result andArguments: arglist];
	va_end(arglist);
	return (bResult);		
}


//============================================================================
//	NSObject (S4Utilities) :: returnTypeForSelector:
//		Returning objects by performing selectors
//============================================================================
- (id)objectByPerformingSelectorWithArguments: (SEL)selector, ...
{
	va_list					arglist;
	void					*result;
	id						idResult = nil;

	va_start(arglist, selector);
	if ([self performSelector: selector withReturnValue: result andArguments: arglist])
	{
		idResult = (id)result;
	}
	va_end(arglist);
//	CFShow(idResult);
	return (idResult);
}



- (id)objectByPerformingSelector: (SEL)selector withObject: (id)object1 withObject: (id)object2
{
	if (![self respondsToSelector:selector]) return nil;
	
	// Retrieve method signature and return type
	NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
	const char *returnType = [methodSignature methodReturnType];
	
	// Create invocation using method signature and invoke it
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
	[invocation setTarget:self];
	[invocation setSelector:selector];
	if (object1) [invocation setArgument:&object1 atIndex:2];
	if (object2) [invocation setArgument:&object2 atIndex:3];
	[invocation invoke];
	
	// return object
	if (strcmp(returnType, @encode(id)) == 0)
	{
		id riz = nil;
		[invocation getReturnValue:&riz];
		return riz;
	}
	
	// return double
	if ((strcmp(returnType, @encode(float)) == 0) ||
		(strcmp(returnType, @encode(double)) == 0))
	{
		double f;
		[invocation getReturnValue:&f];
		return [NSNumber numberWithDouble:f];
	}
	
	// return NSNumber version of byte. Use valueBy version for recovering chars
	if ((strcmp(returnType, @encode(char)) == 0) ||
		(strcmp(returnType, @encode(unsigned char)) == 0))
	{
		unsigned char c;
		[invocation getReturnValue:&c];
		return [NSNumber numberWithInt:(unsigned int)c];
	}
	
	// return c-string
	if (strcmp(returnType, @encode (char*)) == 0)
	{
		char *s;
		[invocation getReturnValue:s];
		return [NSString stringWithCString: s encoding: NSASCIIStringEncoding];
	}
	
	// return integer
	long l;
	[invocation getReturnValue:&l];
	return [NSNumber numberWithLong:l];
}


//============================================================================
//	NSObject (S4Utilities) :: objectByPerformingSelector:
//============================================================================
- (id)objectByPerformingSelector: (SEL)selector withObject: (id)object
{
	return ([self objectByPerformingSelector: selector withObject: object withObject: nil]);
}


//============================================================================
//	NSObject (S4Utilities) :: objectByPerformingSelector:
//============================================================================
- (id)objectByPerformingSelector: (SEL)selector
{
	return ([self objectByPerformingSelector: selector withObject: nil withObject: nil]);
}


//============================================================================
//	NSObject (S4Utilities) :: performSelector:
//============================================================================
- (void)performSelector: (SEL)selector withCPointer: (void *)cPointer afterDelay: (NSTimeInterval)delay
{
	NSMethodSignature				*methodSignature;
	NSInvocation					*invocation;

	if ([self respondsToSelector: selector])
	{
		methodSignature = [self methodSignatureForSelector: selector];
		if (nil != methodSignature)
		{
			invocation = [NSInvocation invocationWithMethodSignature: methodSignature];
			if (nil != invocation)
			{
				[invocation setTarget: self];
				[invocation setSelector: selector];
				[invocation setArgument: cPointer atIndex: 2];
				[invocation performSelector: @selector(invoke) withObject: nil afterDelay: delay];
			}
		}
	}
}


//============================================================================
//	NSObject (S4Utilities) :: performSelector:
//============================================================================
- (void)performSelector: (SEL)selector withBool: (BOOL)boolValue afterDelay: (NSTimeInterval)delay
{
	[self performSelector: selector withCPointer: &boolValue afterDelay: delay];
}


//============================================================================
//	NSObject (S4Utilities) :: performSelector:
//============================================================================
- (void)performSelector: (SEL)selector withInt: (int)intValue afterDelay: (NSTimeInterval)delay
{
	[self performSelector: selector withCPointer: &intValue afterDelay: delay];
}


//============================================================================
//	NSObject (S4Utilities) :: performSelector:
//============================================================================
- (void)performSelector: (SEL)selector withFloat: (float)floatValue afterDelay: (NSTimeInterval)delay
{
	[self performSelector: selector withCPointer: &floatValue afterDelay: delay];
}


//============================================================================
//	NSObject (S4Utilities) :: performSelector:
//============================================================================
- (void)performSelector: (SEL)selector afterDelay: (NSTimeInterval)delay
{
	[self performSelector: selector withObject: nil afterDelay: delay];
}

// private. only sent to an invocation
- (void) getReturnValue: (void *) result
{
	NSInvocation *invocation = (NSInvocation *) self;
	[invocation invoke];
	if (result) [invocation getReturnValue:result];
}


//============================================================================
//	NSObject (S4Utilities) :: performSelector:
//		Delayed selector
//============================================================================
- (void)performSelector: (SEL)selector withDelayAndArguments: (NSTimeInterval)delay, ...
{
	va_list						arglist;
	NSInvocation				*invocation;

	va_start(arglist, delay);
	invocation = [self invocationWithSelector: selector andArguments: arglist];
	va_end(arglist);
	if (nil != invocation)
	{
		[invocation performSelector: @selector(invoke) afterDelay: delay];
	}
}


//============================================================================
//	NSObject (S4Utilities) :: valueByPerformingSelector:
//============================================================================
- (NSValue *)valueByPerformingSelector: (SEL)selector withObject: (id)object1 withObject: (id)object2
{
	NSMethodSignature					*methodSignature;
	NSInvocation						*invocation;
	void								*bytes;
	NSValue								*returnValue = nil;

	if ([self respondsToSelector: selector])
	{
		// Retrieve method signature and return type
		methodSignature = [self methodSignatureForSelector: selector];
		if (nil != methodSignature)
		{
			const char *returnType = [methodSignature methodReturnType];

			// Create invocation using method signature and invoke it
			invocation = [NSInvocation invocationWithMethodSignature: methodSignature];
			if (nil != invocation)
			{
				[invocation setTarget: self];
				[invocation setSelector: selector];

				if (nil != object1)
				{
					[invocation setArgument: &object1 atIndex: 2];
				}

				if (nil != object2)
				{
					[invocation setArgument: &object2 atIndex: 3];
				}

				[invocation invoke];

				// Place results into value
				bytes = malloc(16);
				if (NULL != bytes)
				{
					[invocation getReturnValue: bytes];
					returnValue = [NSValue valueWithBytes: bytes objCType: returnType];
					free(bytes);
				}
			}
		}
	}
	return (returnValue);
}


//============================================================================
//	NSObject (S4Utilities) :: valueByPerformingSelector:
//============================================================================
- (NSValue *)valueByPerformingSelector: (SEL)selector withObject: (id)object
{
	return ([self valueByPerformingSelector: selector withObject: object withObject: nil]);
}


//============================================================================
//	NSObject (S4Utilities) :: valueByPerformingSelector:
//============================================================================
- (NSValue *)valueByPerformingSelector: (SEL)selector
{
	return ([self valueByPerformingSelector: selector withObject: nil withObject: nil]);
}


//============================================================================
//	NSObject (S4Utilities) :: className
//============================================================================
- (NSString *)className
{
	return (NSStringFromClass([self class]));
}

@end


