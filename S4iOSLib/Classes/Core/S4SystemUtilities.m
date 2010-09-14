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
 * Name:		S4SystemUtilities.m
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <mach/mach.h>
#import <mach/mach_host.h>
#import "S4SystemUtilities.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ================== Begin Class S4SystemUtilities (PrivateImpl) ======================

@interface S4SystemUtilities (PrivateImpl)

- (void)placeHolder1;

@end



@implementation S4SystemUtilities (PrivateImpl)

//============================================================================
//	S4SystemUtilities (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}

@end




// ======================= Begin Class S4SystemUtilities ======================

@implementation S4SystemUtilities

//============================================================================
//	S4SystemUtilities :: getFreeMemBytes:
//============================================================================
+ (S4ResultCode)getFreeMemBytes: (NSNumber **)freeMemory
				   usedMemBytes: (NSNumber **)usedMemory
				  totalMemBytes: (NSNumber **)totalMemory
{
    mach_port_t					host_port;
    mach_msg_type_number_t		host_size;
    vm_size_t					pagesize;
	vm_statistics_data_t		vm_stat;
	UInt64						mem_used = 0;
	UInt64						mem_free = 0;
	UInt64						mem_total = 0;
	S4ResultCode				s4Result = S4ResultInvalidParams;

	if ((NULL != freeMemory) && (NULL != usedMemory) && (NULL != totalMemory))
	{
		*freeMemory = nil;
		*usedMemory = nil;
		*totalMemory = nil;

		// set up the params
		host_port = mach_host_self();
		host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
		host_page_size(host_port, &pagesize);

		// ...and make the call...
		if (KERN_SUCCESS == host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size))
		{
			// calculate the used memory 
			mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize;
			*usedMemory = [NSNumber numberWithDouble: mem_used];

			// calculate the free memory
			mem_free = vm_stat.free_count * pagesize;
			*freeMemory = [NSNumber numberWithDouble: mem_free];

			// sum to get the total memory
			mem_total = mem_used + mem_free;
			*totalMemory = [NSNumber numberWithDouble: mem_total];

			// set a successful result
			s4Result = S4ResultSuccess;
		}
	}
	return (s4Result);
}


//============================================================================
//	S4SystemUtilities :: testMemStats
//============================================================================
+ (BOOL)testMemStats
{
	NSNumber					*freeMemory = nil;
	NSNumber					*usedMemory = nil;
	NSNumber					*totalMemory = nil;

	if (S4ResultSuccess == [S4SystemUtilities getFreeMemBytes: &freeMemory usedMemBytes: &usedMemory totalMemBytes: &totalMemory])
	{
		NSLog(@"\nSystem memory used: %@ \nSystem memory free: %@ \nSystem memory total: %@", usedMemory, freeMemory, totalMemory);
		return (YES);
	}
    return (NO);
}




@end
