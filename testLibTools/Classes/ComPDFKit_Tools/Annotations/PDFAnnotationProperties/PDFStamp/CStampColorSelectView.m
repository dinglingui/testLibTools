//
//  CStampColorSelectView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CStampColorSelectView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface CStampColorSelectView ()

@property (nonatomic, strong) UIView *colorPickerView;
@property (nonatomic, strong) NSMutableArray *colorArray;

@end

@implementation CStampColorSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.colorLabel = [[UILabel alloc] init];
        self.colorLabel.text = NSLocalizedString(@"Color", nil);
        self.colorLabel.textColor = [UIColor grayColor];
        self.colorLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.colorLabel];
        
        self.colorPickerView = [[UIView alloc] init];
        self.colorPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.colorPickerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.colorLabel.frame = CGRectMake(20, 0, 50, self.bounds.size.height-15);
    self.colorPickerView.frame = CGRectMake(70, 0, self.bounds.size.width-70, self.bounds.size.height);
    [self pickerBarInit];
}

- (void)pickerBarInit {
    NSArray *colors = @[[UIColor blackColor],
                        [UIColor colorWithRed:0.57 green:0.06 blue:0.02 alpha:1.0],
                        [UIColor colorWithRed:0.25 green:0.42 blue:0.13 alpha:1.0],
                        [UIColor colorWithRed:0.09 green:0.15 blue:0.39 alpha:1.0]];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < colors.count; i++) {
        UIView *view = [[UIButton alloc] init];
        view.tag = i;
        view.frame = CGRectMake((self.colorPickerView.bounds.size.width - ((self.colorPickerView.bounds.size.height - 20)*4))/5 * (i+1) + (self.colorPickerView.bounds.size.height - 20) * i, 5, self.colorPickerView.bounds.size.height - 20, self.colorPickerView.bounds.size.height - 20);
        [[view layer] setCornerRadius:(self.colorPickerView.bounds.size.height - 20)/2];
        view.layer.masksToBounds = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        view.layer.borderColor = [UIColor whiteColor].CGColor;
        view.layer.borderWidth = 1.0;
        
        if(self.selectedColor) {
            CGFloat red1, green1, blue1, alpha1;
            [self.selectedColor getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];

            CGFloat red2, green2, blue2, alpha2;
            [colors[i] getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
            
            if (fabs(red1 - red2) < FLT_EPSILON &&
                fabs(green1 - green2) < FLT_EPSILON &&
                fabs(blue1 - blue2) < FLT_EPSILON) {
                view.layer.borderColor = [UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0].CGColor;
            } else {
                view.layer.borderColor = [UIColor whiteColor].CGColor;
            }
        } else {
            view.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        
        view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
        [array addObject:view];
        [self.colorPickerView addSubview:view];
        
        UIButton *button = [[UIButton alloc] init];
        button.frame = CGRectInset(view.frame, 3, 3);
        [[button layer] setCornerRadius:(self.colorPickerView.bounds.size.height - 26)/2];
        button.layer.masksToBounds = YES;
        button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self.colorPickerView addSubview:button];
        button.backgroundColor = colors[i];
        button.tag = i;
        [button addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.colorArray = array;
}

#pragma mark - Action

- (void)buttonItemClicked_select:(UIButton *)button {
    for (int i = 0; i < self.colorArray.count; i++) {
        ((UIView *)self.colorArray[i]).layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    ((UIView *)self.colorArray[button.tag]).layer.borderColor = [UIColor blueColor].CGColor;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stampColorSelectView:tag:)]) {
        [self.delegate stampColorSelectView:self tag:button.tag];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
}

@end
