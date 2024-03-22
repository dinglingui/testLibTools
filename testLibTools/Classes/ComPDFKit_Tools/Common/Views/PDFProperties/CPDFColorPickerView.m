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

#import "CPDFColorPickerView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface CPDFColorPickerView ()

@property (nonatomic, strong) UILabel *selectedLabel;

@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UISlider *colorSlider;

@property (nonatomic, strong) UILabel *colorLabel;

@property (nonatomic, assign) CGFloat hue;

@property (nonatomic, assign) CGFloat saturation;

@property (nonatomic, assign) CGFloat brightness;

@property (nonatomic,retain) CAGradientLayer *gradientLayer;

@property (nonatomic,retain) CAGradientLayer *gradientLayers;

@end

@implementation CPDFColorPickerView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 120)/2, 0, 120, 50)];
        _titleLabel.text = NSLocalizedString(@"Custom Color", nil);
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
        
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, 50)];
        _backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_backBtn setImage:[UIImage imageNamed:@"CPFFormBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backBtn];
        
        _selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, self.bounds.size.width - 30, (self.bounds.size.height - 40)/6 * 3)];
        _selectedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _selectedLabel.userInteractionEnabled = YES;
        _gradientLayers = [CAGradientLayer layer];
        _gradientLayers.startPoint = CGPointMake(0.0f, 0.5f);
        _gradientLayers.endPoint = CGPointMake(1.0f, 0.5f);
        [self.selectedLabel.layer addSublayer:self.gradientLayers];
        [self addSubview:self.selectedLabel];
        
        _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, (self.bounds.size.height - 40)/6, 30, 30)];
        _selectBtn.backgroundColor = [UIColor clearColor];
        _selectBtn.layer.cornerRadius = 15;
        _selectBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_selectBtn addGestureRecognizer:panGesture];
        _selectBtn.layer.borderWidth = 1.0f;
        [self addSubview:self.selectBtn];
        
        _colorSlider = [[UISlider alloc] initWithFrame:CGRectMake(15, (self.bounds.size.height - 40)/6 * 4, self.bounds.size.width - 30, (self.bounds.size.height - 40)/6)];
        _colorSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
        _colorSlider.minimumValue = 0;
        _colorSlider.maximumValue = 1;
        _colorSlider.value = 1;
        [_colorSlider addTarget:self action:@selector(sliderValueChanged_Color:) forControlEvents:UIControlEventValueChanged];
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.startPoint = CGPointMake(0.0f, 0.5f);
        _gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
        [self.colorSlider.layer addSublayer:self.gradientLayer];
        [self addSubview:self.colorSlider];
        
        _colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (self.bounds.size.height - 40)/6 * 5, self.bounds.size.width - 30, (self.bounds.size.height - 40)/6)];
        _colorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.colorLabel];
        
        _hue = 0;
        _saturation = 1;
        _brightness = 1;
        
        [self reloadData];
        
        self.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = [self.colorSlider trackRectForBounds:self.colorSlider.bounds];
    rect.origin.y -= 5;
    rect.size.height += 10;
    self.gradientLayer.frame = rect;
    
    _gradientLayers.frame = self.selectedLabel.bounds;
}

#pragma mark - Private Methods

- (void)reloadData {
    NSMutableArray *colors = [NSMutableArray array];
    CGFloat hueStep = 1.0 / 8.0;
    CGFloat saturationStep = 1.0 / 4.0;
    for (int i = 0; i < 8; i++) {
        NSMutableArray *rowColors = [NSMutableArray array];
        for (int j = 0; j < 4; j++) {
            UIColor *color = [UIColor colorWithHue:(i * hueStep) saturation:(1.0 - j * saturationStep) brightness:self.brightness alpha:1];;
            [rowColors addObject:(id)color.CGColor];
        }
        [colors addObjectsFromArray:rowColors];
    }
    _gradientLayers.colors = colors;
    
    NSArray *colorArray = @[(id)[[UIColor colorWithHue:self.hue
                                            saturation:self.saturation
                                            brightness:0
                                                 alpha:1] CGColor],
                            (id)[[UIColor colorWithHue:self.hue
                                            saturation:self.saturation
                                            brightness:1
                                                 alpha:1] CGColor]];
    _gradientLayer.colors = colorArray;
   
    self.colorLabel.backgroundColor = [UIColor colorWithHue:self.hue saturation:self.saturation brightness:self.brightness alpha:1];
}

#pragma mark - Action

- (void)sliderValueChanged_Color:(UISlider *)sender {
    self.brightness = sender.value;
    [self reloadData];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer translationInView:self.selectedLabel];
    CGFloat newX = self.selectBtn.center.x + point.x;
    CGFloat newY = self.selectBtn.center.y + point.y;
    if (CGRectContainsPoint(self.selectedLabel.frame, CGPointMake(newX, newY))) {
        self.selectBtn.center = CGPointMake(newX, newY);
    }
    [gestureRecognizer setTranslation:CGPointZero inView:self.selectedLabel];
    
    if ([gestureRecognizer.view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)gestureRecognizer.view;
        CGRect newFrame = CGRectOffset(button.frame, point.x, point.y);
        self.hue = 0.125*((newFrame.origin.x - 15) / ((self.selectedLabel.bounds.size.width)/8));
        self.saturation = 1 - 0.5*((newFrame.origin.y - (self.bounds.size.height - 40)/6) / ((self.selectedLabel.bounds.size.height)/4));
    }
    [self reloadData];
}

- (void)buttonItemClicked_back:(id)sender {
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:color:)]) {
        [self.delegate pickerView:self color:self.colorLabel.backgroundColor];
    }
}

@end
