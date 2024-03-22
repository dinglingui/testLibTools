//
//  CSignatureDrawView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CSignatureDrawView.h"

static CGPoint _points[5];
static NSInteger _index;

@interface CSignatureDrawView ()

@property (nonatomic, strong) UIBezierPath *bezierPath;

@property (nonatomic, assign) CGRect textRect;

@property (nonatomic, assign) CGContextRef context;

@end

@implementation CSignatureDrawView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bezierPath = [[UIBezierPath alloc] init];
        self.lineWidth = 1;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplayInRect:self.bounds];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.context = UIGraphicsGetCurrentContext();
    
    if (CSignatureDrawText == self.selectIndex) {
        [self.color set];
        [self.bezierPath setLineWidth:self.lineWidth];
        [self.bezierPath setLineCapStyle:kCGLineCapRound];
        [self.bezierPath setLineJoinStyle:kCGLineJoinRound];
        [self.bezierPath stroke];
    } else if (CSignatureDrawImage) {
        if (self.image) {
            CGRect imageFrame = [self imageFrameInRect:rect];
            [self.image drawInRect:imageFrame];
            if (self.delegate && [self.delegate respondsToSelector:@selector(signatureDrawViewStart:)]) {
                [self.delegate signatureDrawViewStart:self];
            }
        }
    }
}

#pragma mark - Draw Methods

- (CGRect)imageFrameInRect:(CGRect)rect {
    CGRect imageRect;
    if (self.image.size.width < rect.size.width &&
        self.image.size.height < rect.size.height) {
        imageRect.origin.x = (rect.size.width-self.image.size.width)/2.0;
        imageRect.origin.y = (rect.size.height-self.image.size.height)/2.0;
        imageRect.size = self.image.size;
    } else {
        if (self.image.size.width/self.image.size.height >
            rect.size.width/rect.size.height) {
            imageRect.size.width = rect.size.width;
            imageRect.size.height = rect.size.width*self.image.size.height/self.image.size.width;
        } else {
            imageRect.size.height = rect.size.height;
            imageRect.size.width = rect.size.height*self.image.size.width/self.image.size.height;
        }
        imageRect.origin.x = (rect.size.width-imageRect.size.width)/2.0;
        imageRect.origin.y = (rect.size.height-imageRect.size.height)/2.0;
    }
    return imageRect;
}

#pragma mark - Public Methods

- (UIImage *)signatureImage {
    CGRect rect = CGRectZero;
    CGRect imageFrame = [self imageFrameInRect:self.frame];
    if (self.image) {
        if (self.bezierPath.empty) {
            rect = imageFrame;
        } else {
            CGRect pathFrame = self.bezierPath.bounds;
            rect.origin.x = MIN(CGRectGetMinX(imageFrame), CGRectGetMinX(pathFrame));
            rect.origin.y = MIN(CGRectGetMinY(imageFrame), CGRectGetMinY(pathFrame));
            rect.size.width = MAX(CGRectGetMaxX(imageFrame), CGRectGetMaxX(pathFrame))-rect.origin.x;
            rect.size.height = MAX(CGRectGetMaxY(imageFrame), CGRectGetMaxY(pathFrame))-rect.origin.y;
        }
    } else {
        if (self.bezierPath.empty) {
            return nil;
        } else {
            rect = self.bezierPath.bounds;
        }
    }
    
    CGSize size = CGSizeMake(rect.size.width+self.bezierPath.lineWidth,
                             rect.size.height+self.bezierPath.lineWidth);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-rect.origin.x+self.bezierPath.lineWidth/2.0,  -rect.origin.y+self.bezierPath.lineWidth/2.0);
    CGContextConcatCTM(context, transform);
    if (self.image) {
        [self.image drawInRect:imageFrame];
    }
    if (!self.bezierPath.empty) {
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextSetLineWidth(context, self.bezierPath.lineWidth);
        CGContextSetLineCap(context, self.bezierPath.lineCapStyle);
        CGContextSetLineJoin(context, self.bezierPath.lineJoinStyle);
        CGContextAddPath(context, self.bezierPath.CGPath);
        CGContextStrokePath(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Public Methods

- (void)signatureClear {
    self.image = nil;
    [self.bezierPath removeAllPoints];
    [self setNeedsDisplay];
}

#pragma mark - Action

- (void)buttonItemClicked_clear:(UIButton *)button {
    self.image = nil;
    [self.bezierPath removeAllPoints];
    [self setNeedsDisplay];
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    _index = 0;
    _points[0] = point;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(signatureDrawViewStart:)]) {
        [self.delegate signatureDrawViewStart:self];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    _index++;
    _points[_index] = point;
    if (_index == 4) {
        _points[3] = CGPointMake((_points[2].x + _points[4].x)/2.0,
                                 (_points[2].y + _points[4].y)/2.0);
        [self.bezierPath moveToPoint:_points[0]];
        [self.bezierPath addCurveToPoint:_points[3]
                           controlPoint1:_points[1]
                           controlPoint2:_points[2]];
        _points[0] = _points[3];
        _points[1] = _points[4];
        _index = 1;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (_index < 4) {
        for (int i=0; i<_index; i++) {
            [self.bezierPath moveToPoint:_points[i]];
        }
        [self setNeedsDisplay];
    }
}

@end
