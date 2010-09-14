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
 * Name:		S4PdfSearcher.m
 * Module:		Core
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4PdfSearcher.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================

void arrayCallback(CGPDFScannerRef inScanner, void *userInfo)
{
    S4PdfSearcher * searcher = (S4PdfSearcher *)userInfo;
	
    CGPDFArrayRef array;
    
    bool success = CGPDFScannerPopArray(inScanner, &array);
    
    for(size_t n = 0; n < CGPDFArrayGetCount(array); n += 2)
    {
        if(n >= CGPDFArrayGetCount(array))
            continue;
        
        CGPDFStringRef string;
        success = CGPDFArrayGetString(array, n, &string);
        if(success)
        {
            NSString *data = (NSString *)CGPDFStringCopyTextString(string);
            [searcher.m_currentData appendFormat:@"%@", data];
            [data release];
        }
    }
}


void stringCallback(CGPDFScannerRef inScanner, void *userInfo)
{
    S4PdfSearcher *searcher = (S4PdfSearcher *)userInfo;
    
    CGPDFStringRef string;
    
    bool success = CGPDFScannerPopString(inScanner, &string);
	
    if(success)
    {
        NSString *data = (NSString *)CGPDFStringCopyTextString(string);
        [searcher.m_currentData appendFormat:@" %@", data];
        [data release];
    }
}



// ========================== Begin Class S4PdfSearcher () =============================

@interface S4PdfSearcher ()

@end



// =========================== Begin Class S4PdfSearcher ===============================

@implementation S4PdfSearcher


//============================================================================
//	S4PdfSearcher synthesize properties
//============================================================================
@synthesize m_currentData;


//============================================================================
//	S4PdfSearcher :: init
//============================================================================
- (id)init
{
	id			idResult = nil;

	self = [super init];
	if (nil != self)
	{
		// private member vars
        m_cgOperatorTable = CGPDFOperatorTableCreate();
		self.m_currentData = nil;

		// set up the operator table
        CGPDFOperatorTableSetCallback(m_cgOperatorTable, "TJ", arrayCallback);
        CGPDFOperatorTableSetCallback(m_cgOperatorTable, "Tj", stringCallback);

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4PdfSearcher :: dealloc
//============================================================================
- (void)dealloc
{
	self.m_currentData = nil;

	[super dealloc];
}


//============================================================================
//	S4PdfSearcher :: page:containsString:
//============================================================================
- (BOOL)page: (CGPDFPageRef)inPage containsString: (NSString *)searchStr
{
	CGPDFContentStreamRef			contentStream;
	CGPDFScannerRef					scanner;
	BOOL							bResult = NO;

    self.m_currentData = [NSMutableString string];
    contentStream = CGPDFContentStreamCreateWithPage(inPage);
	if (NULL != contentStream)
	{
		scanner = CGPDFScannerCreate(contentStream, m_cgOperatorTable, self);
		if (NULL != scanner)
		{
			if (CGPDFScannerScan(scanner))
			{
				bResult = ([[self.m_currentData uppercaseString] rangeOfString: [searchStr uppercaseString]].location != NSNotFound);
			}
			CGPDFScannerRelease(scanner);
		}
		CGPDFContentStreamRelease(contentStream);
	}
    return (bResult);
}

@end
