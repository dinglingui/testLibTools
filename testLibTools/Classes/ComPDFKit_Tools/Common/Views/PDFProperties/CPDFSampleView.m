//
//  CPDFSampleView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSampleView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

#define PI 3.14159265358979323846

@interface CPDFSampleView ()

@property (nonatomic, assign) CGRect centerRect;

@property (nonatomic, assign) CGRect arrowRect;

@property (nonatomic, assign) CGRect textRect;

@property (nonatomic, assign) CGRect inkRect;

@end

@implementation CPDFSampleView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    self.centerRect = CGRectInset(rect, (self.bounds.size.width/20)*9, (self.bounds.size.height/8)*3);
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    self.arrowRect = CGRectMake(centerPoint.x-self.bounds.size.height/4, centerPoint.y-self.bounds.size.height/4, self.bounds.size.height/2, self.bounds.size.height/2);
    
    self.textRect = CGRectInset(rect, self.bounds.size.width/3+3, self.bounds.size.height/3);
    self.inkRect = CGRectInset(rect, self.bounds.size.width/4, self.bounds.size.height/3);
    
    CGContextSetFillColorWithColor(context, [CPDFColorUtils CAnnotationSampleDrawBackgoundColor].CGColor);
    CGContextFillRect(context, self.bounds);
    
    [self drawSamples:context rect:self.centerRect];
}

#pragma mark - Private Methods

- (void)drawSamples:(CGContextRef)context rect:(CGRect)rect {
    switch (self.selecIndex) {
        case CPDFSamplesNote:
        {
            CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);

            if(self.color) {
                CGFloat red, green, blue, alpha;
                [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
                UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:self.opcity];
                CGContextSetFillColorWithColor(context, color.CGColor);
            } else {
                CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
                CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            }

            // Draw outer boxes.
            CGFloat width = 1.0;
            CGFloat size = rect.size.height / 5;
            CGRect outerRect1 = CGRectInset(rect, 0, 0);
            outerRect1.size.height -= size;
            CGRect outerRect2 = outerRect1;
            outerRect2.origin.x += size;
            outerRect2.origin.y += size*4;
            outerRect2.size.width = size;
            outerRect2.size.height = size;
            
            CGContextSetLineWidth(context, width);
            CGContextMoveToPoint(context, CGRectGetMinX(outerRect1), CGRectGetMinY(outerRect1));
            CGContextAddLineToPoint(context, CGRectGetMinX(outerRect1), CGRectGetMaxY(outerRect1));
            CGContextAddLineToPoint(context, CGRectGetMinX(outerRect2), CGRectGetMinY(outerRect2));
            CGContextAddLineToPoint(context, CGRectGetMidX(outerRect2), CGRectGetMaxY(outerRect2));
            CGContextAddLineToPoint(context, CGRectGetMidX(outerRect2), CGRectGetMinY(outerRect2));
            CGContextAddLineToPoint(context, CGRectGetMaxX(outerRect1), CGRectGetMaxY(outerRect1));
            CGContextAddLineToPoint(context, CGRectGetMaxX(outerRect1), CGRectGetMinY(outerRect1));
            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathFillStroke);

            // Draw inner lines.
            int count = 3;
            CGFloat xDelta = rect.size.width / 10;
            CGFloat yDelta = outerRect1.size.height / (count + 1);
            
            CGRect lineRect = outerRect1;
            lineRect.origin.x += xDelta;
            lineRect.size.width -= 2*xDelta;
            
            for (int i=0; i<count; i++) {
                CGFloat y = CGRectGetMaxY(lineRect) - yDelta * (i + 1);
                CGContextMoveToPoint(context, CGRectGetMinX(lineRect), y);
                CGContextAddLineToPoint(context, CGRectGetMaxX(lineRect), y);
                CGContextStrokePath(context);
            }
        }
            break;
        case CPDFSamplesHighlight:
        {
            CGFloat red, green, blue, alpha;
            [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:self.opcity].CGColor);
            CGContextFillRect(context, self.textRect);
            NSString *sampleStr = @"Sample";
            UIFont *font = [UIFont systemFontOfSize:27];
            NSDictionary *dic = @{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor blackColor]};
            [sampleStr drawInRect:self.textRect withAttributes:dic];
        }
            break;
        case CPDFSamplesUnderline:
        {
            NSString *sampleStr = @"Sample";
            CGFloat red, green, blue, alpha;
            [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:self.opcity].CGColor);
            CGRect strikeoutRect = CGRectInset(self.textRect, 0, (self.textRect.size.height/7)*3);
            CGRect underLineRect = CGRectOffset(strikeoutRect, 0, (self.textRect.size.height/7)*3);
            CGContextFillRect(context, underLineRect);
            UIFont *font = [UIFont systemFontOfSize:27];
            NSDictionary *dic = @{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor blackColor]};
            [sampleStr drawInRect:self.textRect withAttributes:dic];
        }
            break;
        case CPDFSamplesStrikeout:
        {
            NSString *sampleStr = @"Sample";
            CGFloat red, green, blue, alpha;
            [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetFillColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:self.opcity].CGColor);
            CGRect strikeoutRect = CGRectInset(self.textRect, 0, (self.textRect.size.height/7)*3);
            CGRect underLineRect = CGRectOffset(strikeoutRect, 0, (self.textRect.size.height/7));
            CGContextFillRect(context, underLineRect);
            UIFont *font = [UIFont systemFontOfSize:27];
            NSDictionary *dic = @{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor blackColor]};
            [sampleStr drawInRect:self.textRect withAttributes:dic];
        }
            break;
        case CPDFSamplesSquiggly:
        {
            NSString *sampleStr = @"Sample";
            CGFloat red, green, blue, alpha;
            [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:self.opcity].CGColor);
            
            float tWidth = self.textRect.size.width / 12.0;
            CGContextMoveToPoint(context, CGRectGetMinX(self.textRect), CGRectGetMaxY(self.textRect));
            CGContextSetLineWidth(context, 2.0);
            CGContextAddCurveToPoint(context,
                                     CGRectGetMinX(self.textRect)+tWidth,CGRectGetMaxY(self.textRect)+5,
                                     CGRectGetMinX(self.textRect)+tWidth*2.0,CGRectGetMaxY(self.textRect)-5,
                                     CGRectGetMinX(self.textRect)+tWidth*3.0,CGRectGetMaxY(self.textRect));
            CGContextAddCurveToPoint(context,
                                     CGRectGetMinX(self.textRect)+tWidth*4.0,CGRectGetMaxY(self.textRect)+5,
                                     CGRectGetMinX(self.textRect)+tWidth*5.0,CGRectGetMaxY(self.textRect)-5,
                                     CGRectGetMinX(self.textRect)+tWidth*6.0,CGRectGetMaxY(self.textRect));
            CGContextAddCurveToPoint(context,
                                     CGRectGetMinX(self.textRect)+tWidth*7.0,CGRectGetMaxY(self.textRect)+5,
                                     CGRectGetMinX(self.textRect)+tWidth*8.0,CGRectGetMaxY(self.textRect)-5,
                                     CGRectGetMinX(self.textRect)+tWidth*9.0,CGRectGetMaxY(self.textRect));
            CGContextAddCurveToPoint(context,
                                     CGRectGetMinX(self.textRect)+tWidth*10.0,CGRectGetMaxY(self.textRect)+5,
                                     CGRectGetMinX(self.textRect)+tWidth*11.0,CGRectGetMaxY(self.textRect)-5,
                                     CGRectGetMinX(self.textRect)+tWidth*12.0,CGRectGetMaxY(self.textRect));
            
            
            CGContextStrokePath(context);
            
            UIFont *font = [UIFont systemFontOfSize:27];
            NSDictionary *dic = @{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor blackColor]};
            [sampleStr drawInRect:self.textRect withAttributes:dic];
        }
            break;
        case CPDFSamplesFreehand:
        {
            CGFloat red, green, blue, alpha;
            [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:self.opcity].CGColor);
            
            float tWidth = self.inkRect.size.width / 3.0;
            CGContextMoveToPoint(context, CGRectGetMinX(self.inkRect), CGRectGetMidY(self.inkRect));
            CGContextSetLineWidth(context, self.thickness);
            CGContextAddCurveToPoint(context,
                                     CGRectGetMinX(self.inkRect)+tWidth,CGRectGetMidY(self.inkRect)-20,
                                     CGRectGetMinX(self.inkRect)+tWidth*2.0,CGRectGetMidY(self.inkRect)+20,
                                     CGRectGetMinX(self.inkRect)+tWidth*3.0,CGRectGetMidY(self.inkRect));
            
            CGContextStrokePath(context);
        }
            break;
        case CPDFSamplesShapeCircle:
        {
            CGFloat red, green, blue, alpha;
            [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:self.opcity].CGColor);
            
            if (!([self.interiorColor isEqual:[UIColor clearColor]])) {
                CGFloat interRed, interGreen, interBlue, interAlpha;
                [self.interiorColor getRed:&interRed green:&interGreen blue:&interBlue alpha:&interAlpha];
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:interRed green:interGreen blue:interBlue alpha:self.opcity].CGColor);
            } else {
                CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            }
            
            CGFloat dashLengths[2] = {6, self.dotted};
            CGContextSetLineDash(context, 0, dashLengths, 2);
            CGContextSetLineWidth(context, self.thickness);
            CGContextAddArc(context, CGRectGetMaxX(self.bounds)/2, CGRectGetMaxY(self.bounds)/2, 30, 0, 2*PI, 0);
            CGContextDrawPath(context, kCGPathStroke);
            CGContextAddArc(context, CGRectGetMaxX(self.bounds)/2, CGRectGetMaxY(self.bounds)/2, 30, 0, 2*PI, 0);
            CGContextDrawPath(context, kCGPathFill);
        }
            break;
        case CPDFSamplesShapeSquare:
        {
            CGFloat red, green, blue, alpha;
            [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:self.opcity].CGColor);
            
            if (!([self.interiorColor isEqual:[UIColor clearColor]])) {
                CGFloat interRed, interGreen, interBlue, interAlpha;
                [self.interiorColor getRed:&interRed green:&interGreen blue:&interBlue alpha:&interAlpha];
                CGContextSetFillColorWithColor(context, [UIColor colorWithRed:interRed green:interGreen blue:interBlue alpha:self.opcity].CGColor);
            } else {
                CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            }
            CGContextSetLineWidth(context, self.thickness);
            CGFloat dashLengths[2] = {6, self.dotted};
            CGContextSetLineDash(context, 0, dashLengths, 2);
            CGContextMoveToPoint(context, CGRectGetMinX(self.centerRect), CGRectGetMinY(self.centerRect));
            CGContextAddLineToPoint(context, CGRectGetMaxX(self.centerRect)+0.1, CGRectGetMinY(self.centerRect));
            CGContextAddLineToPoint(context, CGRectGetMaxX(self.centerRect), CGRectGetMaxY(self.centerRect));
            CGContextAddLineToPoint(context, CGRectGetMinX(self.centerRect), CGRectGetMaxY(self.centerRect));
            CGContextAddLineToPoint(context, CGRectGetMinX(self.centerRect), CGRectGetMinY(self.centerRect));
            CGContextAddLineToPoint(context, CGRectGetMinX(self.centerRect)+0.1, CGRectGetMinY(self.centerRect));
            CGContextStrokePath(context);
            
            CGContextFillRect(context, rect);
        }
            break;
        case CPDFSamplesShapeArrow ... CPDFSamplesShapeLine:
        {
            CGFloat red, green, blue, alpha;
            [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:self.opcity].CGColor);
            CGContextSetLineWidth(context, self.thickness);
            CGPoint start = CGPointMake(CGRectGetMinX(self.arrowRect), CGRectGetMaxY(self.arrowRect));
            CGPoint end = CGPointMake(CGRectGetMaxX(self.arrowRect), CGRectGetMinY(self.arrowRect));
            [self drawEndArrow:context startPoint:start endPoint:end];
            [self drawStartArrow:context startPoint:start endPoint:end];
            CGFloat dashLengths[2] = {6, self.dotted};
            CGContextSetLineDash(context, 0, dashLengths, 2);
            CGContextMoveToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, end.x, end.y);
            CGContextStrokePath(context);
        }
            break;
        case CPDFSamplesFreeText:
        {
            CGFloat red, green, blue, alpha;
            [self.color getRed:&red green:&green blue:&blue alpha:&alpha];
            NSString *sampleStr = @"Sample";
            UIFont *font = [UIFont fontWithName:self.fontName size:self.thickness];
            if (!self.color) {
                self.color = [UIColor whiteColor];
            }
            NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:sampleStr attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor colorWithRed:red green:green blue:blue alpha:self.opcity]}];
            CGSize textSize = [attributedText boundingRectWithSize:self.bounds.size options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size;
            
            CGFloat x = 0;
            CGFloat y = 0;
            
            switch (self.textAlignment) {
                case NSTextAlignmentLeft:
                {
                    x = self.bounds.origin.x;
                    y = self.bounds.origin.y + (self.bounds.size.height - textSize.height) / 2.0;
                }
                    break;
                case NSTextAlignmentCenter:
                {
                    x = self.bounds.origin.x + (self.bounds.size.width - textSize.width) / 2.0;
                    y = self.bounds.origin.y + (self.bounds.size.height - textSize.height) / 2.0;
                }
                    break;
                case NSTextAlignmentRight:
                {
                    x = (self.bounds.size.width - textSize.width);
                    y = self.bounds.origin.y + (self.bounds.size.height - textSize.height) / 2.0;
                }
                    break;
                default:
                {
                    x = self.bounds.origin.x + (self.bounds.size.width - textSize.width) / 2.0;
                    y = self.bounds.origin.y + (self.bounds.size.height - textSize.height) / 2.0;
                }
                    break;
            }

           
            CGPoint center = CGPointMake(x, y);
            [attributedText drawAtPoint:center];
        }
            break;
        default:
            break;
    }
}

- (void)drawStartArrow:(CGContextRef)context startPoint:(CGPoint)start endPoint:(CGPoint)end {
    switch (self.startArrowStyleIndex) {
        case CPDFArrowStyleOpenArrow:
        {
            CGContextMoveToPoint(context, start.x+10, start.y);
            CGContextAddLineToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, start.x, start.y-10);
            CGContextStrokePath(context);
        }
            break;
        case CPDFArrowStyleClosedArrow:
        {
            CGContextMoveToPoint(context, start.x-5, start.y-5);
            CGContextAddLineToPoint(context, start.x-5, start.y+5);
            CGContextAddLineToPoint(context, start.x+5, start.y+5);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
            break;
        case CPDFArrowStyleSquare:
        {
            CGContextMoveToPoint(context, start.x-2.5, start.y-2.5);
            CGContextAddLineToPoint(context, start.x-7.5, start.y+2.5);
            CGContextAddLineToPoint(context, start.x-2.5, start.y+7.5);
            CGContextAddLineToPoint(context, start.x+2.5, start.y+2.5);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
            break;
        case CPDFArrowStyleCircle:
        {
            CGContextAddArc(context, start.x-2.5, start.y+2.5, 5, 0, 2*3.14159265358979323846, 0);
            CGContextDrawPath(context, kCGPathStroke);
        }
            break;
        case CPDFArrowStyleDiamond:
        {
            CGContextMoveToPoint(context, start.x, start.y);
            CGContextAddLineToPoint(context, start.x-5, start.y);
            CGContextAddLineToPoint(context, start.x-5, start.y+5);
            CGContextAddLineToPoint(context, start.x, start.y+5);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
            break;
        default:
            break;
    }
}

- (void)drawEndArrow:(CGContextRef)context startPoint:(CGPoint)start endPoint:(CGPoint)end {
    switch (self.endArrowStyleIndex) {
        case CPDFArrowStyleOpenArrow:
        {
            CGContextMoveToPoint(context, end.x-10, end.y);
            CGContextAddLineToPoint(context, end.x, end.y);
            CGContextAddLineToPoint(context, end.x, end.y+10);
            CGContextStrokePath(context);
        }
            break;
        case CPDFArrowStyleClosedArrow:
        {
            CGContextMoveToPoint(context, end.x-5, end.y-5);
            CGContextAddLineToPoint(context, end.x+5, end.y-5);
            CGContextAddLineToPoint(context, end.x+5, end.y+5);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
            break;
        case CPDFArrowStyleSquare:
        {
            CGContextMoveToPoint(context, end.x-2.5, end.y-2.5);
            CGContextAddLineToPoint(context, end.x+2.5, end.y+2.5);
            CGContextAddLineToPoint(context, end.x+7.5, end.y-2.5);
            CGContextAddLineToPoint(context, end.x+2.5, end.y-7.5);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
            break;
        case CPDFArrowStyleCircle:
        {
            CGContextAddArc(context, end.x+2.5, end.y-2.5, 5, 0, 2*3.14159265358979323846, 0);
            CGContextDrawPath(context, kCGPathStroke);
        }
            break;
        case CPDFArrowStyleDiamond:
        {
            CGContextMoveToPoint(context, end.x, end.y);
            CGContextAddLineToPoint(context, end.x+5, end.y);
            CGContextAddLineToPoint(context, end.x+5, end.y-5);
            CGContextAddLineToPoint(context, end.x, end.y-5);
            CGContextClosePath(context);
            CGContextStrokePath(context);
        }
            break;
        default:
            break;
    }
}

@end
