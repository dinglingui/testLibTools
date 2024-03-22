//
//  CPDFDrawArrowView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFDrawArrowView.h"

@interface CPDFDrawArrowView ()

@end

@implementation CPDFDrawArrowView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint start = CGPointMake(CGRectGetMinX(rect)+10, CGRectGetMidY(rect));
    CGPoint end = CGPointMake(CGRectGetMaxX(rect)-10, CGRectGetMidY(rect));
    [self drawArrow:context startPoint:start endPoint:end];
}

#pragma mark - Private Methods

- (void)drawArrow:(CGContextRef)context startPoint:(CGPoint)start endPoint:(CGPoint)end {
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:151.0/255.0 green:151.0/255.0 blue:151.0/255.0 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 2);
    switch (self.selectIndex) {
        case CPDFDrawNone:
        {
            CGContextMoveToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, end.x, end.y);
            CGContextStrokePath(context);
        }
            break;
        case CPDFDrawArrow:
        {
            CGContextMoveToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, end.x, end.y);
            
            CGContextMoveToPoint(context, end.x-5, end.y-5);
            CGContextAddLineToPoint(context, end.x, end.y);
            CGContextAddLineToPoint(context, end.x-5, end.y+5);
            CGContextStrokePath(context);
        }
            break;
        case CPDFDrawTriangle:
        {
            CGContextMoveToPoint(context, start.x-5, start.y);
            CGContextAddLineToPoint(context, end.x-5, end.y);
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, end.x-5, end.y-5);
            CGContextAddLineToPoint(context, end.x, end.y);
            CGContextAddLineToPoint(context, end.x-5, end.y+5);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
            break;
        case CPDFDrawSquare:
        {
            CGContextMoveToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, end.x-10, end.y);
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, end.x-10, end.y-5);
            CGContextAddLineToPoint(context, end.x-10, end.y+5);
            CGContextAddLineToPoint(context, end.x, end.y+5);
            CGContextAddLineToPoint(context, end.x, end.y-5);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
            break;
        case CPDFDrawCircle:
        {
            CGContextMoveToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, end.x-10, end.y);
            CGContextStrokePath(context);
            
            CGContextAddArc(context, end.x-7, end.y, 5, 0, 2*M_PI, 0);
            CGContextDrawPath(context, kCGPathStroke);
        }
            break;
        case CPDFDrawDiamond:
        {
            CGContextMoveToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, end.x-10, end.y);
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, end.x-10, end.y);
            CGContextAddLineToPoint(context, end.x-5, end.y+5);
            CGContextAddLineToPoint(context, end.x, end.y);
            CGContextAddLineToPoint(context, end.x-5, end.y-5);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
            break;
        default:
            break;
    }
}

- (UIImage *)shotShareImage {
    UIGraphicsBeginImageContext(CGSizeMake(self.layer.bounds.size.width, self.layer.bounds.size.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

@end
