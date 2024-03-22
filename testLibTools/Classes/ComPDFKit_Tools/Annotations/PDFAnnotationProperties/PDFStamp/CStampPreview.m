//
//  CStampPreview.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CStampPreview.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/CPDFColorUtils.h>
#else
#import "CPDFColorUtils.h"
#endif
static float c01, c02, c03, c11, c12, c13;

#define kStampPreview_OnlyText_Size     48.0
#define kStampPreview_Text_Size         30.0
#define kStampPreview_Date_Size         20.0

@implementation CStampPreview

@synthesize textStampText = _textStampText;
@synthesize textStampStyle = _textStampStyle;
@synthesize textStampColorStyle = _textStampColorStyle;
@synthesize textStampHaveDate = _textStampHaveDate;
@synthesize textStampHaveTime = _textStampHaveTime;
@synthesize leftMargin = _leftMargin;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        _scale = ([[UIScreen mainScreen] scale] == 2.0) ? 2.0f : 1.0f;
    }
    return self;
}

- (void)setTextStampColorStyle:(NSInteger)TextStampColorStyle {
    _textStampColorStyle = TextStampColorStyle;
    if (TextStampColorTypeRed == _textStampColorStyle) {
        color[0] = 0.57;
        color[1] = 0.06;
        color[2] = 0.02;
    } else if (TextStampColorTypeGreen == _textStampColorStyle) {
        color[0] = 0.25;
        color[1] = 0.42;
        color[2] = 0.13;
    } else if (TextStampColorTypeBlue == _textStampColorStyle) {
        color[0] = 0.09;
        color[1] = 0.15;
        color[2] = 0.39;
    } else if (TextStampColorTypeBlack == _textStampColorStyle) {
        color[0] = 0;
        color[1] = 0;
        color[2] = 0;
    }
}

- (NSString *)getDateTime {
    NSTimeZone* timename = [NSTimeZone systemTimeZone];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init ];
    [outputFormatter setTimeZone:timename ];
    
    NSString *tDate = nil;
    if (_textStampHaveDate && !_textStampHaveTime)
    {
        [outputFormatter setDateFormat:@"yyyy/MM/dd"];
        tDate = [outputFormatter stringFromDate:[NSDate date]];
    }
    else if (_textStampHaveTime && !_textStampHaveDate)
    {
        [outputFormatter setDateFormat:@"HH:mm:ss"];
        tDate = [outputFormatter stringFromDate:[NSDate date]];
    }
    else if (_textStampHaveDate && _textStampHaveTime)
    {
        [outputFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        tDate = [outputFormatter stringFromDate:[NSDate date]];
    }
    
    return tDate;
}

// Draw the fill effect
static void MyShaderProcedure(void *info, const CGFloat *in, CGFloat *out) {
    CGFloat v;
    size_t k, components;
    
    components = (size_t)info;
    
    v = *in;
    for (k = 0; k < components -1; k++)
    {
        if (0 == k) {
            *out++ = c01 + v * (c11-c01);
        }
        else if (1 == k)
        {
            *out++ = c02 + v * (c12-c02);
        }
        else if (2 == k) {
            *out++ = c03 + v * (c13-c03);
        }
    }
    *out++ = 0.85;
}

// Calculate Rect based on text
- (void)fitStampRect {
    UIFont *tTextFont = nil;
    UIFont *tTimeFont = nil;
    NSString *drawText = nil;
    NSString *dateText = nil;
    
    if (self.textStampText.length < 1 && !self.dateTime) {
        drawText = @"StampText";
        tTextFont = [UIFont fontWithName:@"Helvetica" size:kStampPreview_OnlyText_Size];
    } else if (self.textStampText.length > 0 && self.dateTime.length > 0) {
        tTextFont = [UIFont fontWithName:@"Helvetica" size:kStampPreview_Text_Size];
        tTimeFont = [UIFont fontWithName:@"Helvetica" size:kStampPreview_Date_Size];
        drawText = self.textStampText;
        dateText = self.dateTime;
    } else {
        if (self.dateTime) {
            drawText = self.dateTime;
        } else {
            drawText = self.textStampText;
        }
        tTextFont = [UIFont fontWithName:@"Helvetica" size:kStampPreview_OnlyText_Size];
    }
    
    CGSize tTextSize = [drawText sizeWithAttributes:@{ NSFontAttributeName : tTextFont }];
    CGSize tTimeSize = CGSizeZero;
    if (tTimeFont) {
        tTimeSize = [dateText sizeWithAttributes:@{ NSFontAttributeName : tTimeFont }];
    }
    
    int w = tTextSize.width > tTimeSize.width ? tTextSize.width : tTimeSize.width;
    int count = 0;
    for (int i = 0; i < drawText.length; ++i) {
        NSRange range = NSMakeRange(i,1);
        NSString *aStr = [drawText substringWithRange:range];
        if ([aStr isEqualToString:@" "]) {
            ++count;
        }
    }
    if (tTextSize.width < tTimeSize.width) {
        w += 15;
    } else {
        w += 13 + 5 * count;
    }
    
    int h = tTextSize.height + 5;
    if (dateText) {
        h = tTextSize.height + tTimeSize.height + 8.011;
    }
    
    if (_textStampStyle == TextStampTypeLeft) {
        
        w = w + h * 0.618033;
        
    } else if (_textStampStyle == TextStampTypeRight) {
        
        w = w + h * 0.618033;
    }
    float x = 0.0;
    float y = 0.0;
    
    _scale = 1.0;
    CGFloat maxW = 300 - _leftMargin;
    if (w > maxW ) {
        _scale = maxW/w;
        h = h*_scale;
        x = self.frame.size.width/2.0  - maxW/2.0;
        y = self.frame.size.height/2.0 - h/2.0;
        _stampBounds = CGRectMake(x + _leftMargin, y, maxW, h);
    } else {
        x = self.frame.size.width/2.0  - w/2.0;
        y = self.frame.size.height/2.0 - h/2.0;
        _stampBounds = CGRectMake(x + _leftMargin, y, w, h);
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.dateTime = [self getDateTime];
    [self fitStampRect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [CPDFColorUtils CAnnotationSampleDrawBackgoundColor].CGColor);
    CGContextFillRect(context, self.bounds);
    // Draw border background
    if (TextStampTypeNone != _textStampStyle) {
        [self drawBounder:context];
    }
    
    // Draws custom text
    [self drawText:context];
}

- (void)drawBounder:(CGContextRef)context {
    if (!context) {
        return;
    }
    
    CGContextSaveGState(context);
    
    const CGFunctionCallbacks callbacks = {
        .version = 0, .evaluate = &MyShaderProcedure, .releaseInfo = NULL
    };
    
    c01 = c02 = c03 = c11 = c12 = c13 = 1.0;
    if (color[0] > color[1] && color[0] > color[2]) {
        
        c01 = 1.0;
        c02 = 0.78;
        c03 = 0.78;
        
        c11 = 0.98;
        c12 = 0.92;
        c13 = 0.91;
    }
    else if (color[1] > color[0] && color[1] > color[2]) {
        
        c01 = 0.81;
        c02 = 0.88;
        c03 = 0.78;
        
        c11 = 0.95;
        c12 = 0.95;
        c13 = 0.95;
    }
    else if (color[2] > color[0] && color[2] > color[1])
    {
        c01 = 0.79;
        c02 = 0.81;
        c03 = 0.89;
        
        c11 = 0.90;
        c12 = 0.95;
        c13 = 1.0;
    }

    size_t components = 1 + CGColorSpaceGetNumberOfComponents(CGColorSpaceCreateDeviceRGB());
    CGFunctionRef funcRef = CGFunctionCreate((void *) components,
                                             1,
                                             (CGFloat[]){0.0f, 1.0f},
                                             4,
                                             //(CGFloat[]){0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f},
                                             (CGFloat[]){c01, c11, c02, c12, c03, c13, 0.0f, 1.0f},
                                             &callbacks);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGShadingRef shadingRef = CGShadingCreateAxial(colorSpaceRef,
                                                   CGPointMake(_stampBounds.origin.x+_stampBounds.size.width*0.75, _stampBounds.origin.y+_stampBounds.size.width*0.25),
                                                   CGPointMake(_stampBounds.origin.x+_stampBounds.size.width*0.25, _stampBounds.origin.y+_stampBounds.size.width*0.75),
                                                   funcRef, true, true);
    
    CGColorSpaceRelease(colorSpaceRef);
    
    CGFunctionRelease(funcRef);
    
    if (_textStampStyle == TextStampTypeCenter) {
        [self drawNormalRect:context];
    } else if (_textStampStyle == TextStampTypeLeft) {
        [self drawLeftBounder:context];
    } else if (_textStampStyle == TextStampTypeRight) {
        [self drawRightBounder:context];
    }
    CGContextClip (context);
    
    CGContextSaveGState(context);
    CGContextDrawShading(context, shadingRef);
    CGContextRestoreGState(context);
    
    CGShadingRelease(shadingRef);
    
    if (_textStampStyle == TextStampTypeCenter) {
        [self drawNormalRect:context];
    } else if (_textStampStyle == TextStampTypeLeft) {
        [self drawLeftBounder:context];
    } else if (_textStampStyle == TextStampTypeRight) {
        [self drawRightBounder:context];
    }
    CGContextStrokePath(context);
}

- (void)drawNormalRect:(CGContextRef)context {
    float tmpHeight = 11.0 * _stampBounds.size.height/50;
    float tmpWidth = 3.0 * _stampBounds.size.height/50;
    float hw1 = 5.54492 * _stampBounds.size.height/50;
    float hw2 = 4.40039 * _stampBounds.size.height/50;
    
    CGContextBeginPath (context);
    
    CGContextMoveToPoint(context, _stampBounds.origin.x+tmpWidth, _stampBounds.origin.y+_stampBounds.size.height-tmpHeight);
    
    CGContextAddCurveToPoint(context, _stampBounds.origin.x+tmpWidth, _stampBounds.origin.y+_stampBounds.size.height-tmpHeight+hw2, _stampBounds.origin.x+tmpHeight-hw1, _stampBounds.origin.y+_stampBounds.size.height-tmpWidth, _stampBounds.origin.x+tmpHeight, _stampBounds.origin.y+_stampBounds.size.height-tmpWidth);
    
    CGContextAddLineToPoint(context, _stampBounds.origin.x+_stampBounds.size.width-tmpHeight, _stampBounds.origin.y+_stampBounds.size.height-tmpWidth);
    
    CGContextAddCurveToPoint(context, _stampBounds.origin.x+_stampBounds.size.width-tmpHeight+hw1, _stampBounds.origin.y+_stampBounds.size.height-tmpWidth, _stampBounds.origin.x+_stampBounds.size.width-tmpWidth, _stampBounds.origin.y+_stampBounds.size.height-tmpHeight+hw2, _stampBounds.origin.x+_stampBounds.size.width-tmpWidth, _stampBounds.origin.y+_stampBounds.size.height-tmpHeight);
    
    CGContextAddLineToPoint(context, _stampBounds.origin.x+_stampBounds.size.width-tmpWidth, _stampBounds.origin.y+tmpHeight);
    
    CGContextAddCurveToPoint(context, _stampBounds.origin.x+_stampBounds.size.width-tmpWidth, _stampBounds.origin.y+tmpHeight-hw2, _stampBounds.origin.x+_stampBounds.size.width-tmpHeight+hw1, _stampBounds.origin.y+tmpWidth, _stampBounds.origin.x+_stampBounds.size.width-tmpHeight, _stampBounds.origin.y+tmpWidth);
    
    CGContextAddLineToPoint(context,_stampBounds.origin.x+tmpHeight, _stampBounds.origin.y+tmpWidth);
    
    CGContextAddCurveToPoint(context, _stampBounds.origin.x+tmpHeight-hw1, _stampBounds.origin.y+tmpWidth, _stampBounds.origin.x+tmpWidth, _stampBounds.origin.y+tmpHeight-hw2, _stampBounds.origin.x+tmpWidth, _stampBounds.origin.y+tmpHeight);
    
    CGContextAddLineToPoint(context,_stampBounds.origin.x+tmpWidth, _stampBounds.origin.y+_stampBounds.size.height-tmpHeight);
    
    CGContextClosePath (context);
}

- (void)drawLeftBounder:(CGContextRef)context {
    float tmpHeight = 11.0 * _stampBounds.size.height/50;
    float tmpWidth = 3.0 * _stampBounds.size.height/50;
    float hw1 = 5.54492 * _stampBounds.size.height/50;
    float hw2 = 4.40039 * _stampBounds.size.height/50;
    
    float x0 = _stampBounds.origin.x + _stampBounds.size.height * 0.618033;
    float y0 = _stampBounds.origin.y;
    
    float x1 = _stampBounds.origin.x + _stampBounds.size.width;
    float y1 = _stampBounds.origin.y + _stampBounds.size.height;
    
    float xp = _stampBounds.origin.x;
    float yp = _stampBounds.origin.y + _stampBounds.size.height / 2.0;
    
    CGContextBeginPath (context);
    
    CGContextMoveToPoint(context, x0 + tmpHeight, y1 - tmpWidth);
    CGContextAddLineToPoint(context, x1-tmpHeight, y1-tmpWidth);
    CGContextAddCurveToPoint(context, x1-tmpHeight+hw1, y1-tmpWidth, x1-tmpWidth, y1-tmpHeight+hw2, x1-tmpWidth, y1-tmpHeight);
    CGContextAddLineToPoint(context, x1-tmpWidth, y0+tmpHeight);
    CGContextAddCurveToPoint(context, x1-tmpWidth, y0+tmpHeight-hw2, x1-tmpHeight+hw1, y0+tmpWidth, x1-tmpHeight, y0+tmpWidth);
    
    CGContextAddLineToPoint(context, x0+tmpHeight, y0+tmpWidth);
    CGContextAddLineToPoint(context, xp+tmpHeight, yp);
    CGContextAddLineToPoint(context, x0+tmpHeight, y1-tmpWidth);
    
    CGContextClosePath (context);
}

- (void)drawRightBounder:(CGContextRef)context {
    float tmpHeight = 11.0 * _stampBounds.size.height/50;
    float tmpWidth = 3.0 * _stampBounds.size.height/50;
    float hw1 = 5.54492 * _stampBounds.size.height/50;
    float hw2 = 4.40039 * _stampBounds.size.height/50;
    
    float x0 = _stampBounds.origin.x;
    float y0 = _stampBounds.origin.y;
    
    float x1 = _stampBounds.origin.x + _stampBounds.size.width - _stampBounds.size.height * 0.618033;
    float y1 = _stampBounds.origin.y + _stampBounds.size.height;
    
    float xp = _stampBounds.origin.x + _stampBounds.size.width;
    float yp = _stampBounds.origin.y + _stampBounds.size.height / 2.0;
    
    CGContextBeginPath (context);
    
    CGContextMoveToPoint(context, x0 + tmpWidth, y1 - tmpHeight);
    CGContextAddCurveToPoint(context, x0+tmpWidth, y1-tmpHeight+hw2, x0+tmpHeight-hw1, y1-tmpWidth, x0+tmpHeight, y1-tmpWidth);
    CGContextAddLineToPoint(context, x1-tmpHeight, y1-tmpWidth);
    CGContextAddLineToPoint(context, xp-tmpHeight, yp);
    CGContextAddLineToPoint(context, x1-tmpHeight, y0+tmpWidth);
    CGContextAddLineToPoint(context, x0+tmpHeight, y0+tmpWidth);
    CGContextAddCurveToPoint(context, x0+tmpHeight-hw1, y0+tmpWidth, x0+tmpWidth, y0+tmpHeight-hw2, x0+tmpWidth, y0+tmpHeight);
    CGContextAddLineToPoint(context, x0+tmpWidth, y1-tmpHeight);
    
    CGContextClosePath (context);
}

- (void)drawText:(CGContextRef)context {
    if (!context) {
        return;
    }
    
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    
    NSString *drawText = nil;
    NSString *dateText = nil;
    
    if (self.textStampText.length < 1 && !self.dateTime) {
        drawText = @"StampText";
    } else if (self.textStampText.length > 0 && self.dateTime.length > 0) {
        drawText = self.textStampText;
        dateText = self.dateTime;
    } else {
        if (self.dateTime) {
            drawText = self.dateTime;
        } else {
            drawText = self.textStampText;
        }
    }
    
    if (!dateText) {
        float fontsize = kStampPreview_OnlyText_Size*_scale;
        UIFont* font = [UIFont fontWithName:@"Helvetica" size:fontsize];
        CGRect rt = CGRectInset(_stampBounds, 0, 0);
        rt.origin.x += 8.093 * _scale;
        
        if (_textStampStyle == TextStampTypeLeft) {
            rt.origin.x += rt.size.height * 0.618033;
        }
        
        UIGraphicsPushContext(context);
        
        [[UIColor colorWithRed:color[0] green:color[1] blue:color[2] alpha:1] set];
        [drawText drawInRect:rt withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
        UIGraphicsPopContext();
        
    } else {
        float tFontSize = kStampPreview_Text_Size*_scale;
        UIFont *tFont = [UIFont fontWithName:@"Helvetica" size:tFontSize];
        
        CGRect tTextRT = CGRectInset(_stampBounds, 0, 0);
        tTextRT.origin.x += 8.093 * _scale;
        
        if (_textStampStyle == TextStampTypeLeft) {
            tTextRT.origin.x += tTextRT.size.height * 0.618033;
        }
        
        UIGraphicsPushContext(context);
        [[UIColor colorWithRed:color[0] green:color[1] blue:color[2] alpha:1] set];
        if (drawText.length > 0) {
            [drawText drawInRect:tTextRT withFont:tFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
            
            CGRect tDateRT = CGRectInset(_stampBounds, 0, 0);
            tDateRT.origin.x += 8.093 * _scale;
            if (_textStampStyle == TextStampTypeLeft) {
                tDateRT.origin.x += tDateRT.size.height * 0.618033;
            }
            tDateRT.origin.y = tDateRT.origin.y + tFontSize + 6.103*_scale;
            
            tFontSize = kStampPreview_Date_Size*_scale;
            tFont = [UIFont fontWithName:@"Helvetica" size:tFontSize];
            
            [[UIColor colorWithRed:color[0] green:color[1] blue:color[2] alpha:1] set];
            [dateText drawInRect:tDateRT withFont:tFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
        } else {
            float fontsize = kStampPreview_Date_Size*_scale;
            UIFont* font = [UIFont fontWithName:@"Helvetica" size:fontsize];
            
            CGRect rt = CGRectInset(_stampBounds, 0, 0);
            rt.origin.x += 8.093 * _scale;
            
            if (_textStampStyle == TextStampTypeLeft) {
                rt.origin.x += rt.size.height * 0.618033;
            }
            
            [[UIColor colorWithRed:color[0] green:color[1] blue:color[2] alpha:1] set];
            [dateText drawInRect:rt withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
        }
        
        UIGraphicsPopContext();
    }
}

- (UIImage *)renderImage
{
    UIImage *image = [self renderImageFromView:self];
    return image;
}

/* Convert UIView to UIImage */
- (UIImage *)renderImageFromView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 1.0);
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 1.0, 1.0);
    
    [view.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
