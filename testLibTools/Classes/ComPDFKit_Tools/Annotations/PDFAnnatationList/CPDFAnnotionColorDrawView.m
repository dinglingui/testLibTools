//
//  CPDFAnnotionColorDrawView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import "CPDFAnnotionColorDrawView.h"

@implementation CPDFAnnotionColorDrawView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.7;
        self.userInteractionEnabled = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        return;
    }
    
    CGContextSetStrokeColorWithColor(ctx, _lineColor.CGColor);
    if (CPDFAnnotionMarkUpTypeUnderline == _markUpType ||
        CPDFAnnotionMarkUpTypeStrikeout == _markUpType) {
        CGContextMoveToPoint(ctx, 0, 0);
        CGContextSetLineWidth(ctx, self.frame.size.width);
        CGContextAddLineToPoint(ctx, self.frame.size.width,  0);
    }else if (CPDFAnnotionMarkUpTypeHighlight == _markUpType){
        CGContextMoveToPoint(ctx, 0, self.frame.size.height/2);
        CGContextSetLineWidth(ctx, self.frame.size.height);
        CGContextAddLineToPoint(ctx, self.frame.size.width, self.frame.size.height/2);
    } else if (CPDFAnnotionMarkUpTypeSquiggly == _markUpType || CPDFAnnotionMarkUpTypeFreehand == _markUpType) {
        float tWidth = self.frame.size.width / 6.0;
        CGContextMoveToPoint(ctx, 0, self.frame.size.height/2.0);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextAddCurveToPoint(ctx,tWidth,self.frame.size.height,tWidth*2.0,0.0,tWidth*3.0,self.frame.size.height/2.0);
        CGContextAddCurveToPoint(ctx,tWidth*4.0,self.frame.size.height,tWidth*5.0,0.0,tWidth*6.0,self.frame.size.height/2.0);
    }
    CGContextStrokePath(ctx);
}


@end
