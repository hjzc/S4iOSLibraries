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
 * Name:		S4PdfView.m
 * Module:		Core
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import "S4PdfView.h"
#import "S4CommonDefines.h"


// ================================== Defines ==========================================



// ================================== Typedefs ==========================================



// ================================== Globals ==========================================



// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ============================ Begin Class S4PdfView () ===============================

@interface S4PdfView ()

@property (nonatomic, readwrite) NSUInteger							pageCount;
@property (nonatomic, readwrite) BOOL								isValidDocument;

@end



// ============================= Begin Class S4PdfView =================================

@implementation S4PdfView


//============================================================================
//	S4PdfView synthesize properties
//============================================================================
@synthesize pageCount = m_pageCount;
@synthesize currentPage = m_currentPage;
@synthesize isValidDocument = m_bIsValidDocument;


//============================================================================
//	S4PdfView :: init
//============================================================================
- (id)init
{
	return ([self initWithFrame: CGRectZero]);
}


//============================================================================
//	S4PdfView :: initWithPathToDocument:
//============================================================================
- (id)initWithFrame: (CGRect)aRect
{
	id			idResult = nil;

	self = [super initWithFrame: aRect];
	if (nil != self)
	{
		// private member vars
		m_pdfDocument = NULL;
		self.pageCount = 0;
		self.currentPage = 0;
		self.isValidDocument = NO;

		// UIView properties
		self.contentMode = UIViewContentModeRedraw;

		idResult = self;
	}
	return (idResult);
}


//============================================================================
//	S4PdfView :: dealloc
//============================================================================
- (void)dealloc
{
//	self.m_privateNSMutableArray = nil;
	if (NULL != m_pdfDocument)
	{
		CGPDFDocumentRelease (m_pdfDocument);
		m_pdfDocument = NULL;
	}

	[super dealloc];
}


//============================================================================
//	S4PdfView :: setPathToDocument:
//============================================================================
/*
- (BOOL)setDocumentWithPath: (NSString *)pathToPdfDoc
{
	NSURL				*pdfURL;
	BOOL				bResult = NO;

	if (CGPDFDocumentIsEncrypted(myDocument))
	{
		if (!CGPDFDocumentUnlockWithPassword (myDocument, ""))
		{
			printf ("Enter password: ");
			fflush (stdout);
			password = fgets(buffer, sizeof(buffer), stdin);
			if (password != NULL)
			{
				buffer[strlen(buffer) - 1] = '\0';
				if (!CGPDFDocumentUnlockWithPassword (myDocument, password))
					error("invalid password.");
			}
		}
	}

	if (!CGPDFDocumentIsUnlocked (myDocument))
	{
        error("can't unlock `%s'.", filename);
        CGPDFDocumentRelease(myDocument);
        return EXIT_FAILURE;
    }
}
*/


//============================================================================
//	S4PdfView :: setPathToDocument:
//============================================================================
- (BOOL)setDocumentWithPath: (NSString *)pathToPdfDoc
{
	NSURL				*pdfURL;
	BOOL				bResult = NO;
	
	if ((NO == self.isValidDocument) && (STR_NOT_EMPTY(pathToPdfDoc)))
	{
		pdfURL = [NSURL fileURLWithPath: pathToPdfDoc];
		if (IS_NOT_NULL(pdfURL))
		{
			m_pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
			if (NULL != m_pdfDocument)
			{
				self.pageCount = CGPDFDocumentGetNumberOfPages(m_pdfDocument);
				if (0 < self.pageCount)
				{
					self.currentPage = 1;
					self.isValidDocument = YES;
					bResult = YES;
					[self setNeedsDisplay];
				}
			}
		}
	}
	return (bResult);
}


//============================================================================
//	S4PdfView :: drawPDF:inContext:
//============================================================================
- (void)drawPDF: (CGRect)rect inContext: (CGContextRef)cgContext
{
	CGPDFPageRef				cgPdfPage;
	CGAffineTransform			pdfTransform;
	
    if (YES == self.isValidDocument)
    {
        // the currentPage parameter is 1 based
		cgPdfPage = CGPDFDocumentGetPage(m_pdfDocument, self.currentPage);

        CGContextSaveGState(cgContext);

		// PDF page drawing expects a lower-Left coordinate system, flip the coordinate system before drawing
        CGContextTranslateCTM(cgContext, 0.0, rect.size.height);
        CGContextScaleCTM(cgContext, 1.0, -1.0);

		// CGPDFPageGetDrawingTransform provides an easy way to get the transform for a PDF page
		pdfTransform = CGPDFPageGetDrawingTransform(cgPdfPage, kCGPDFCropBox, rect, 0, true);

		// Apply the transform
        CGContextConcatCTM(cgContext, pdfTransform);

		// Finally, we draw the page and restore the graphics state
        CGContextDrawPDFPage(cgContext, cgPdfPage);    
        CGContextRestoreGState(cgContext);
    }
}


//============================================================================
//	S4PdfView :: drawRect:
//============================================================================
- (void)drawRect: (CGRect)rect
{
	[self drawPDF: rect inContext: UIGraphicsGetCurrentContext()];
}


//============================================================================
//	S4PdfView :: drawInContext:
//============================================================================
-(void)drawInContext: (CGContextRef)cgContext
{
	[self drawPDF: self.bounds inContext: cgContext];
}

@end
