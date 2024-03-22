//
//  CPDFSignatureWidgetAnnotation+PDFListView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSignatureWidgetAnnotation+PDFListView.h"

@implementation CPDFSignatureWidgetAnnotation (PDFListView)

- (UIImage *)appearanceImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    CGContextRef imageContext = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM(imageContext, -self.bounds.origin.x, -self.bounds.origin.y);
    
    [self drawWithBox:CPDFDisplayMediaBox inContext:imageContext];
    
    CGContextRestoreGState(imageContext);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
