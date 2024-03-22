//
//  CPDFAnnotationBarButton.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFAnnotationBarButton.h"
#import "CPDFListView.h"

@implementation CPDFAnnotationBarButton

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGRect imageFrame = self.imageView.frame;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    if (self.tag == CPDFViewAnnotationModeHighlight) {
        CGContextMoveToPoint(ctx, CGRectGetMinX(imageFrame)-2, CGRectGetMidY(imageFrame));
        CGContextSetLineWidth(ctx, CGRectGetHeight(imageFrame));
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(imageFrame)+2, CGRectGetMidY(imageFrame));
    }else if (self.tag == CPDFViewAnnotationModeUnderline) {
        CGContextMoveToPoint(ctx, CGRectGetMinX(imageFrame), CGRectGetMaxY(imageFrame));
        CGContextSetLineWidth(ctx, 2.0);
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(imageFrame), CGRectGetMaxY(imageFrame));
    } else if (self.tag == CPDFViewAnnotationModeStrikeout) {
        CGContextMoveToPoint(ctx, CGRectGetMinX(imageFrame), CGRectGetMidY(imageFrame));
        CGContextSetLineWidth(ctx, 2.0);
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(imageFrame), CGRectGetMidY(imageFrame));
    } else if (self.tag == CPDFViewAnnotationModeSquiggly) {
        float tWidth = imageFrame.size.width / 6.0;
        CGContextMoveToPoint(ctx, CGRectGetMinX(imageFrame), CGRectGetMaxY(imageFrame));
        CGContextSetLineWidth(ctx, 2.0);
        CGContextAddCurveToPoint(ctx,
                                 CGRectGetMinX(imageFrame)+tWidth,CGRectGetMaxY(imageFrame)+4,
                                 CGRectGetMinX(imageFrame)+tWidth*2.0,CGRectGetMaxY(imageFrame)-4,
                                 CGRectGetMinX(imageFrame)+tWidth*3.0,CGRectGetMaxY(imageFrame));
        CGContextAddCurveToPoint(ctx,
                                 CGRectGetMinX(imageFrame)+tWidth*4.0,CGRectGetMaxY(imageFrame)+4,
                                 CGRectGetMinX(imageFrame)+tWidth*5.0,CGRectGetMaxY(imageFrame)-4,
                                 CGRectGetMinX(imageFrame)+tWidth*6.0,CGRectGetMaxY(imageFrame));
    } else if (self.tag == CPDFViewAnnotationModeInk) {
        float tWidth = imageFrame.size.width / 6.0;
        CGContextMoveToPoint(ctx, CGRectGetMinX(imageFrame), CGRectGetMaxY(imageFrame));
        CGContextSetLineWidth(ctx, 2.0);
        CGContextAddCurveToPoint(ctx,
                                 CGRectGetMinX(imageFrame)+tWidth,CGRectGetMaxY(imageFrame)+4,
                                 CGRectGetMinX(imageFrame)+tWidth*2.0,CGRectGetMaxY(imageFrame)-4,
                                 CGRectGetMinX(imageFrame)+tWidth*3.0,CGRectGetMaxY(imageFrame));
        CGContextAddCurveToPoint(ctx,
                                 CGRectGetMinX(imageFrame)+tWidth*4.0,CGRectGetMaxY(imageFrame)+4,
                                 CGRectGetMinX(imageFrame)+tWidth*5.0,CGRectGetMaxY(imageFrame)-4,
                                 CGRectGetMinX(imageFrame)+tWidth*6.0,CGRectGetMaxY(imageFrame));
    }
    CGContextStrokePath(ctx);
}

@end
