//
//  CPDFSlider.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSlider.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFSlider ()

@property (nonatomic, strong) UIImageView *valueView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, assign) BOOL isTouchBegan;

@property (nonatomic, assign) CGFloat height;

@end

@implementation CPDFSlider

#pragma mark - Accessors

- (UIImageView *)valueView {
    if (!_valueView) {
        _valueView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-26, 0, 24, 36)];
        _valueView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _valueView.image = [UIImage imageNamed:@"CPDFSliderImageSlidepage" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    }
    return _valueView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.backgroundColor = [UIColor blackColor];
        _label.layer.cornerRadius = 2.0;
        _label.layer.borderWidth = 1.0;
        _label.hidden = YES;
    }
    return _label;
}

#pragma mark - Initializers

- (instancetype)initWithPDFView:(CPDFView *)pdfview {
    if (self = [super init]) {
        _pdfView = pdfview;
        
        self.valueView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-26, 0, 24,36)];
        self.valueView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.valueView.image = [UIImage imageNamed:@"CPDFSliderImageSlidepage" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        
        self.label = [[UILabel alloc] init];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor blackColor];
        self.label.layer.cornerRadius = 2.0;
        self.label.layer.borderWidth = 1.0;
        self.label.font = [UIFont systemFontOfSize:12.0];
        self.label.hidden = YES;
        
        [self addSubview:self.label];
        [self addSubview:self.valueView];
    }
    return self;
}

#pragma mark - Public Methods

- (void)reloadData {
    CGPoint center = self.valueView.center;
    NSInteger pageIndex = [self.pdfView currentPageIndex];
    CGFloat height = CGRectGetHeight(self.valueView.frame);
    CGFloat pageHeight = CGRectGetHeight(self.frame)/[self.pdfView.document pageCount];
    if (center.y >= pageIndex*pageHeight &&
        center.y <= (pageIndex+1)*pageHeight) {
        return;
    }
    center.y = pageIndex*pageHeight+pageHeight/2.0;
    center.y = MAX(height/2.0, center.y);
    center.y = MIN(center.y, CGRectGetHeight(self.frame)-height/2.0);
    self.valueView.center = center;
}

#pragma mark - Private Merhods

- (void)updateLabelFrame {
    CGPoint center = self.valueView.center;
    CGFloat height = CGRectGetHeight(self.valueView.frame);
    CGFloat pageHeight = (CGRectGetHeight(self.frame)-height)/[self.pdfView.document pageCount];
    NSInteger pageIndex = (center.y-height/2.0)/pageHeight;
    pageIndex = MAX(0, pageIndex);
    pageIndex = MIN(pageIndex, [self.pdfView.document pageCount]-1);
    
    self.label.text = [NSString stringWithFormat:@"%@",@(pageIndex+1)];
    [self.label sizeToFit];
    self.label.frame = CGRectMake(0, 0,
                                  CGRectGetWidth(self.label.frame)+20,
                                  CGRectGetHeight(self.label.frame)+10);
    self.label.center = CGPointMake(-CGRectGetWidth(self.label.frame)/2.0-10, center.y);
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    self.isTouchBegan = CGRectContainsPoint(self.valueView.frame, location);
    if (self.isTouchBegan) {
        self.label.hidden = NO;
        [self updateLabelFrame];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTouchBegan) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGPoint center = self.valueView.center;
    if (location.y < CGRectGetHeight(self.valueView.frame)/2.0) {
        center.y = CGRectGetHeight(self.valueView.frame)/2.0;
    } else if (location.y > CGRectGetHeight(self.frame)-CGRectGetHeight(self.valueView.frame)/2.0) {
        center.y = CGRectGetHeight(self.frame)-CGRectGetHeight(self.valueView.frame)/2.0;
    } else {
        center.y = location.y;
    }
    self.valueView.center = center;
    [self updateLabelFrame];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isTouchBegan) {
        return;
    }
    self.label.hidden = YES;
    NSInteger pageIndex = [self.label.text integerValue]-1;
    [self.pdfView goToPageIndex:pageIndex animated:NO];
}

@end
