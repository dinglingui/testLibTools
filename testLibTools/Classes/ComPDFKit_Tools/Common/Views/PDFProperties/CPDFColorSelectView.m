//
//  CPDFColorPickerView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFColorSelectView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface  CPDFColorSelectView ()

@property (nonatomic, strong) NSMutableArray *colorArray;

@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation CPDFColorSelectView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.colorLabel = [[UILabel alloc] init];
        self.colorLabel.text = NSLocalizedString(@"Color", nil);
        self.colorLabel.textColor = [UIColor grayColor];
        self.colorLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.colorLabel];
        
        self.colorArray = [NSMutableArray array];
        self.buttonArray = [NSMutableArray array];
        self.colorPickerView = [[UIScrollView alloc] init];
        self.colorPickerView.showsHorizontalScrollIndicator = NO;
        self.colorPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:self.colorPickerView];
        self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        
    }
    return self;
}

- (void)pickerBarInit {
    
    for (UIView * view in self.colorPickerView.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray *colors = @[[UIColor colorWithRed:233.0/255.0 green:27.0/255.0 blue:0.0 alpha:1.0],
                        [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0],
                        [UIColor colorWithRed:0.0/255.0 green:188.0/255.0 blue:162.0/255.0 alpha:1.0],
                        [UIColor colorWithRed:61.0/255.0 green:136.0/255.0 blue:71.0/255.0 alpha:1.0],
                        [UIColor colorWithRed:91.0/255.0 green:122.0/255.0 blue:162.0/255.0 alpha:1.0],
                        [UIColor colorWithRed:92.0/255.0 green:187.0/255.0 blue:247.0/255.0 alpha:1.0],
                        [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                        [UIColor clearColor]];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < colors.count; i++) {
        UIView *view = [[UIView alloc] init];
        view.tag = i;
        view.frame = CGRectMake((self.bounds.size.width + 100 - 16 - ((self.colorPickerView.bounds.size.height - 16)*8))/9 * (i+1) + (self.colorPickerView.bounds.size.height - 16) * i, 5, self.colorPickerView.bounds.size.height - 16, self.colorPickerView.bounds.size.height - 16);
        [[view layer] setCornerRadius:(self.colorPickerView.bounds.size.height - 16)/2];
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
        [self.colorPickerView addSubview:button];
        button.frame = CGRectInset(view.frame, 3, 3);
        [[button layer] setCornerRadius:(self.colorPickerView.bounds.size.height - 22)/2];
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        button.backgroundColor = colors[i];
        button.tag = i;
        [button addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 7) {
            [button setBackgroundImage:[UIImage imageNamed:@"CPDFColorSelectViewImageColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        }        
    }
    self.colorArray = array;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.colorLabel.frame = CGRectMake(20, 0, self.bounds.size.width, self.bounds.size.height/3);
    self.colorPickerView.frame = CGRectMake(20, self.bounds.size.height/3, self.bounds.size.width-40, 60);
    self.colorPickerView.contentSize = CGSizeMake(self.bounds.size.width+100, 60);
    [self pickerBarInit];
}

#pragma mark - Action

- (void)buttonItemClicked_select:(UIButton *)button {
    
    for (int i = 0; i < self.colorArray.count; i++) {
        ((UIView *)self.colorArray[i]).layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    ((UIView *)self.colorArray[button.tag]).layer.borderColor = [UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0].CGColor;
    switch (button.tag) {
        case 0 ... 6:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectColorView:color:)]) {
                [self.delegate selectColorView:self color:button.backgroundColor];
            }
        }
            break;
        case 7:{
            if ([self.delegate respondsToSelector:@selector(selectColorView:)]) {
                [self.delegate selectColorView:self];
            }
            break;
        }

        default:
            break;
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    
}
@end
