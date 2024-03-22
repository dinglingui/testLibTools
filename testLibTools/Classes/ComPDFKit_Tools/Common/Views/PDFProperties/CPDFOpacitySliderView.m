//
//  CPDFOpacitySliderView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFOpacitySliderView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface  CPDFOpacitySliderView()

@property (nonatomic,assign) int sliderCount;
@end

@implementation CPDFOpacitySliderView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.titleLabel.text = NSLocalizedString(@"Opacity", nil);
        self.titleLabel.textColor = [UIColor grayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.titleLabel];
        
        self.opacitySlider = [[UISlider alloc] init];
        self.opacitySlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.opacitySlider.value = 1;
        self.opacitySlider.maximumValue = 1;
        self.opacitySlider.minimumValue = 0;
        [self.opacitySlider addTarget:self action:@selector(buttonItemClicked_changes:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.opacitySlider];
        
        self.startLabel = [[UILabel alloc] init];
        self.startLabel.layer.borderWidth = 1.0;
        self.startLabel.textAlignment = NSTextAlignmentCenter;
        self.startLabel.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.startLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.startLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
        [self addSubview:self.startLabel];

        self.sliderCount = 10;
        
        self.leftMargin = self.rightMargin = self.rightTitleMargin = 0;
        
        self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    }
    return self;
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    self.backgroundColor = bgColor;
}

- (void)setDefaultValue:(CGFloat )defaultValue {
    _defaultValue = defaultValue;
    self.opacitySlider.value = defaultValue;
    self.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((defaultValue/1)*100)];;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(20-self.rightTitleMargin, 0, self.frame.size.width, self.frame.size.height/2);
    self.opacitySlider.frame = CGRectMake(20 - self.leftMargin, self.frame.size.height/2, self.frame.size.width - 130 + self.leftMargin + self.rightMargin, self.frame.size.height/2);

    self.startLabel.frame = CGRectMake(self.frame.size.width - 100 + self.rightMargin, self.frame.size.height/2 + 7.5, 80, self.frame.size.height/2 - 15);
}


#pragma mark - Action

- (void)buttonItemClicked_changes:(UISlider *)sender {
    
    self.sliderCount -- ;
    
    if(self.sliderCount == 3) {
        self.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((sender.value/1)*100)];
        if (self.delegate && [self.delegate respondsToSelector:@selector(opacitySliderView:opacity:)]) {
            [self.delegate opacitySliderView:self opacity:sender.value];
        }
        self.sliderCount = 10;
    }


}

@end
