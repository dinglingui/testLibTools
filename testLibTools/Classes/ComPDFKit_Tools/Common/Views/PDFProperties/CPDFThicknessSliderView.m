//
//  CPDFThicknessSliderView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFThicknessSliderView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/CPDFColorUtils.h>
#else
#import "CPDFColorUtils.h"
#endif
@interface CPDFThicknessSliderView()

@property (nonatomic,assign) int sliderCount;

@end

@implementation CPDFThicknessSliderView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = NSLocalizedString(@"Thickeness", nil);
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.titleLabel.textColor = [UIColor grayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.titleLabel];
        
        self.thicknessSlider = [[UISlider alloc] init];
        self.thicknessSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.thicknessSlider.maximumValue = 10.0;
        self.thicknessSlider.minimumValue = 0.1;
        [self.thicknessSlider addTarget:self action:@selector(buttonItemClicked_changes:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.thicknessSlider];
        
        self.startLabel = [[UILabel alloc] init];
        self.startLabel.text = NSLocalizedString(@"10pt", nil);
        self.startLabel.layer.borderWidth = 1.0;
        self.startLabel.textAlignment = NSTextAlignmentCenter;
        self.startLabel.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.startLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.startLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];;
        [self addSubview:self.startLabel];
        
        self.thick = 1;
        self.sliderCount  = 10;
        self.leftTitleMargin = self.rightMargin = self.leftMargin = 0;
        
        self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    }
    return self;
}

- (void)setThick:(CGFloat)thick {
    _thick = thick;
}

- (void)setDefaultValue:(CGFloat)defaultValue {
    _defaultValue = defaultValue;
    self.thicknessSlider.value = (float) (defaultValue * 10);
    self.startLabel.text = [NSString stringWithFormat:@"%d pt", (int)(defaultValue * 100)];
}



- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(20 -self.leftTitleMargin, 0, self.frame.size.width, self.frame.size.height/2);
    self.thicknessSlider.frame = CGRectMake(20-self.leftMargin, self.frame.size.height/2, self.frame.size.width - 130 + self.leftMargin + self.rightMargin, self.frame.size.height/2);
    self.startLabel.frame = CGRectMake(self.frame.size.width - 100 + self.rightMargin, self.frame.size.height/2 + 7.5, 80, self.frame.size.height/2 -15);
}

#pragma mark - Action

- (void)buttonItemClicked_changes:(UISlider *)sender {
    NSLog(@"senderValue %f",sender.value);
    self.sliderCount -- ;
    if(self.sliderCount == 3) {
        self.startLabel.text = [NSString stringWithFormat:@"%.0f pt", sender.value * self.thick];
        if (self.delegate && [self.delegate respondsToSelector:@selector(thicknessSliderView:thickness:)]) {
            [self.delegate thicknessSliderView:self thickness:sender.value];
        }
        self.sliderCount = 10;
    }
   
}


@end
