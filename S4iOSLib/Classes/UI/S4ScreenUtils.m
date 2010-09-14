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
 * Name:		S4ScreenUtils.m
 * Module:		UI
 * Library:		S4 iOS Libraries
 *
 * ***** FILE BLOCK *****/


// ================================== Includes =========================================

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "S4ScreenUtils.h"
#import "S4CommonDefines.h"


// =================================== Defines =========================================



// ================================== Typedefs =========================================



// =================================== Globals =========================================

const static size_t kSCbitsPerComponent = 8;
const static size_t kSCbitsPerPixel = 32;


// ============================= Forward Declarations ==================================



// ================================== Inlines ==========================================



// ==================== Begin Class S4ScreenUtils (PrivateImpl) ========================

@interface S4ScreenUtils (PrivateImpl)

- (void)placeHolder1;

@end



@implementation S4ScreenUtils (PrivateImpl)

//============================================================================
//	S4ScreenUtils (PrivateImpl) :: placeHolder1
//============================================================================
- (void)placeHolder1
{
}

@end




// ========================= Begin Class S4ScreenUtils ========================

@implementation S4ScreenUtils


//============================================================================
//	S4ScreenUtils :: glCaptureScreenForHeight:
//============================================================================
+ (UIImage *)glCaptureScreenForHeight: (NSInteger)scrnHeight forWidth: (NSInteger)scrnWidth inCameraRoll: (BOOL)bAddToPhotos
{
	unsigned char					*screenBuf;
	CGDataProviderRef				cgDataRef;
	CGImageRef						inImageRef;
	CGImageRef						outImageRef;
	CGContextRef					contextRef;
	size_t							screenBufLen;
	size_t							cgImageWidth;
	size_t							cgImageHeight;
	size_t							pixelBufLen;
	uint32_t						*pixelBuf;
	UIImage							*imageResult = nil;

	screenBufLen = scrnWidth * scrnHeight * 4;
	screenBuf = (unsigned char *)malloc(screenBufLen);
	if (nil != screenBuf)
	{
		glReadPixels(0, 0, scrnWidth, scrnHeight, GL_RGBA, GL_UNSIGNED_BYTE, screenBuf);

		cgDataRef = CGDataProviderCreateWithData(NULL, screenBuf, screenBufLen, NULL);
		if (nil != cgDataRef)
		{
			inImageRef = CGImageCreate(scrnWidth, scrnHeight, kSCbitsPerComponent, kSCbitsPerPixel, scrnWidth * 4, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault, cgDataRef, NULL, TRUE, kCGRenderingIntentDefault);
			if (nil != inImageRef)
			{
				cgImageWidth = CGImageGetWidth(inImageRef);
				cgImageHeight = CGImageGetHeight(inImageRef);

				pixelBufLen = cgImageWidth * cgImageHeight * 4;
				pixelBuf = (uint32_t *)malloc(pixelBufLen);
				if (nil != pixelBuf)
				{
					contextRef = CGBitmapContextCreate(pixelBuf, cgImageWidth, cgImageHeight, kSCbitsPerComponent, cgImageWidth * 4, CGImageGetColorSpace(inImageRef), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
					if (nil != contextRef)
					{
						CGContextTranslateCTM(contextRef, 0.0, cgImageHeight);
						CGContextScaleCTM(contextRef, 1.0, -1.0);
						CGContextDrawImage(contextRef, CGRectMake(0.0, 0.0, cgImageWidth, cgImageHeight), inImageRef);

						outImageRef = CGBitmapContextCreateImage(contextRef);
						if (nil != outImageRef)
						{
							imageResult = [UIImage imageWithCGImage: outImageRef];
							if ((IS_NOT_NULL(imageResult)) && (YES == bAddToPhotos))
							{
								UIImageWriteToSavedPhotosAlbum(imageResult, nil, nil, nil);
							}
							CGImageRelease(outImageRef);
						}
						CGContextRelease(contextRef);
					}
					free(pixelBuf);
				}
				CGImageRelease(inImageRef);
			}
			CGDataProviderRelease(cgDataRef);
		}
		free(screenBuf);
	}
	return (imageResult);
}


//============================================================================
//	S4ScreenUtils :: glCaptureView:
//============================================================================
+ (UIImage *)glCaptureView: (UIView *)view
{
	GLuint						colorRenderbuffer;
	GLint						backingWidth;
	GLint						backingHeight;
	NSInteger					x;
	NSInteger					y;
	NSInteger					width;
	NSInteger					height;
	NSInteger					dataLength;
	GLubyte						*data;
    CGDataProviderRef			ref;
    CGColorSpaceRef				colorspace;
    CGImageRef					imageRef;
	NSInteger					widthInPoints;
	NSInteger					heightInPoints;
	CGFloat						scale;
	CGContextRef				cgcontext;
	UIImage						*imageResult = nil;
									
    // Get the size of the backing CAEAGLLayer
	glGenRenderbuffersOES(1, &colorRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

	// alloc a buffer for the glReadPixels call
    x = 0;
	y = 0;
	width = backingWidth;
	height = backingHeight;
    dataLength = width * height * 4;
    data = (GLubyte *)malloc(dataLength * sizeof(GLubyte));

    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
	
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    colorspace = CGColorSpaceCreateDeviceRGB();
    imageRef = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
							 ref, NULL, true, kCGRenderingIntentDefault);

    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    if (NULL != UIGraphicsBeginImageContextWithOptions)
	{
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        scale = view.contentScaleFactor;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else
	{
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    cgcontext = UIGraphicsGetCurrentContext();

    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), imageRef);

    // Retrieve the UIImage from the current context
    imageResult = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(imageRef);
    return (imageResult);
}


//============================================================================
//	S4ScreenUtils :: uikitScreenshotToCameraRoll:
//============================================================================
+ (UIImage *)uikitScreenshotToCameraRoll: (BOOL)bAddToPhotos
{
	CGSize					imageSize;
	CGContextRef			context;
	CGFloat					fWidth;
	CGFloat					fx;
	CGFloat					fHeight;
	CGFloat					fy;
	UIImage					*imageResult;
	
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
	imageSize = [[UIScreen mainScreen] bounds].size;

	if (NULL != UIGraphicsBeginImageContextWithOptions)
	{
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
	}
	else
	{
		UIGraphicsBeginImageContext(imageSize);
	}
	context = UIGraphicsGetCurrentContext();

	// Iterate over every window from back to front
	for (UIWindow *window in [[UIApplication sharedApplication] windows]) 
	{
		if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
		{
			// -renderInContext: renders in the coordinate space of the layer,
			// so we must first apply the layer's geometry to the graphics context
			CGContextSaveGState(context);

			// Center the context around the window's anchor point
			CGContextTranslateCTM(context, [window center].x, [window center].y);

			// Apply the window's transform about the anchor point
			CGContextConcatCTM(context, [window transform]);

			// Offset by the portion of the bounds left of and above the anchor point
			fWidth = -[window bounds].size.width;
			fx = [[window layer] anchorPoint].x;
			fHeight = -[window bounds].size.height;
			fy = [[window layer] anchorPoint].y;
            CGContextTranslateCTM(context, (fWidth * fx), (fHeight * fy));

			// Render the layer hierarchy to the current context
			[[window layer] renderInContext:context];

			// Restore the context
			CGContextRestoreGState(context);
		}
	}

	// Retrieve the screenshot image
	imageResult = UIGraphicsGetImageFromCurrentImageContext();
	if ((IS_NOT_NULL(imageResult)) && (YES == bAddToPhotos))
	{
		UIImageWriteToSavedPhotosAlbum(imageResult, nil, nil, nil);
	}	
	UIGraphicsEndImageContext();

	return (imageResult);
}

@end
