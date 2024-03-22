//
//  CPDFShapeCircleViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFShapeCircleViewController.h"
#import "CPDFShareCircleViewController_Header.h"

@interface CPDFShapeCircleViewController () <UIColorPickerViewControllerDelegate, CPDFThicknessSliderViewDelegate, CPDFColorSelectViewDelegate, CPDFColorPickerViewDelegate>

@property (nonatomic, strong) NSMutableArray *dashPattern;

@property (nonatomic, strong) UIColorPickerViewController *picker API_AVAILABLE(ios(14.0));

@property (nonatomic, strong) UIColorPickerViewController *fillPicker API_AVAILABLE(ios(14.0));

@end

@implementation CPDFShapeCircleViewController

#pragma mark - Initializers

- (instancetype)initWithStyle:(CAnnotStyle *)annotStyle selectIndex:(NSInteger)index title:(NSString *)title {
    if (self = [super init]) {
        self.annotStyle = annotStyle;
        self.index = index;
        self.titles = title;
    }
    return self;
}

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _thicknessView = [[CPDFThicknessSliderView alloc] init];
    _thicknessView.delegate = self;
    _thicknessView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrcollView addSubview:self.thicknessView];
    
    self.dottedView = [[CPDFThicknessSliderView alloc] init];
    self.dottedView.delegate = self;
    self.dottedView.thicknessSlider.minimumValue = 0.0;
    self.dottedView.thicknessSlider.maximumValue = 10.0;
    self.dottedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrcollView addSubview:self.dottedView];
    
    self.fillColorSelectView = [[CPDFColorSelectView alloc] init];
    self.fillColorSelectView.delegate = self;
    self.fillColorSelectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrcollView addSubview:self.fillColorSelectView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrcollView.frame = CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170);
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 550);
    
    if (@available(iOS 11.0, *)) {
        self.colorView.frame = CGRectMake(self.view.safeAreaInsets.left, 0,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        self.fillColorSelectView.frame = CGRectMake(self.view.safeAreaInsets.left, 90, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        self.opacitySliderView.frame = CGRectMake(self.view.safeAreaInsets.left, 180, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        self.thicknessView.frame = CGRectMake(self.view.safeAreaInsets.left, 270, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        self.dottedView.frame = CGRectMake(self.view.safeAreaInsets.left, 360, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 50);
    } else {
        self.colorView.frame = CGRectMake(0, 0, self.view.frame.size.width, 90);
        self.opacitySliderView.frame = CGRectMake(0, 180, self.view.frame.size.width, 90);
        self.fillColorSelectView.frame = CGRectMake(0, 90, self.view.frame.size.width, 90);
        self.thicknessView.frame = CGRectMake(0, 270, self.view.frame.size.width, 90);
        self.dottedView.frame = CGRectMake(0, 360, self.view.frame.size.width, 90);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    }
    
}

#pragma mark - Protect Mehthods

- (void)commomInitFromAnnotStyle {
    self.opacitySliderView.opacitySlider.value = self.annotStyle.opacity;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
    self.thicknessView.thicknessSlider.value = self.annotStyle.lineWidth;
    self.thicknessView.startLabel.text = [NSString stringWithFormat:@"%d pt", (int)self.thicknessView.thicknessSlider.value];
    self.dashPattern = (NSMutableArray *)self.annotStyle.dashPattern;
    self.dottedView.thicknessSlider.value = [self.dashPattern.firstObject floatValue];
    self.dottedView.startLabel.text = [NSString stringWithFormat:@"%d pt", (int)self.dottedView.thicknessSlider.value];
    
    self.sampleView.color = self.annotStyle.color;
    self.sampleView.opcity = self.annotStyle.opacity;
    self.sampleView.thickness = self.annotStyle.lineWidth;
    self.sampleView.dotted = self.dottedView.thicknessSlider.value;
    self.sampleView.interiorColor = self.annotStyle.interiorColor?:[UIColor clearColor];
    [self.sampleView setNeedsDisplay];
}

- (void)commomInitTitle {
    self.sampleView.color = self.annotStyle.color;
    self.sampleView.interiorColor = [UIColor whiteColor];
    self.sampleView.thickness = 4.0;
    self.sampleView.selecIndex = (NSInteger)self.annotStyle.annotMode;
    switch (self.annotStyle.annotMode) {
        case CPDFViewAnnotationModeCircle:
        {
            self.titleLabel.text = NSLocalizedString(@"Circle", nil);
        }
            break;
        case CPDFViewAnnotationModeSquare:
        {
            self.titleLabel.text = NSLocalizedString(@"Square", nil);
        }
            break;
        case CPDFViewAnnotationModeArrow:
        {
            self.titleLabel.text = NSLocalizedString(@"Arrow", nil);
        }
            break;
        case CPDFViewAnnotationModeLine:
        {
            self.titleLabel.text = NSLocalizedString(@"Line", nil);
        }
            break;
            
        default:
            break;
    }
    
    self.fillColorSelectView.colorLabel.text = NSLocalizedString(@"Fill Color", nil);
    self.thicknessView.titleLabel.text = NSLocalizedString(@"Line Width", nil);
    self.colorView.colorLabel.text = NSLocalizedString(@"Stroke Color", nil);
    self.dottedView.titleLabel.text = NSLocalizedString(@"Line and Border Style", nil);
    self.colorView.selectedColor = self.annotStyle.color;
    self.fillColorSelectView.selectedColor = self.annotStyle.interiorColor;
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    if ([self.colorPicker superview] || [self.fillColorPicker superview]) {
        UIDevice *currentDevice = [UIDevice currentDevice];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // This is an iPad
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 520);
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 320);
        }
       
    } else {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 660);
    }
}

- (void)updateBordColor:(UIColor *)color {
    if(color) {
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        
        self.sampleView.color = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        self.sampleView.opcity = alpha;

        self.annotStyle.color = self.sampleView.color;
        self.annotStyle.opacity = self.sampleView.opcity;
        self.annotStyle.interiorOpacity = self.sampleView.opcity;
    } else {
        self.sampleView.color = color;
        self.sampleView.opcity = 0;

        self.annotStyle.color = color;
    }
    [self.sampleView setNeedsDisplay];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(circleViewController:annotStyle:)]) {
        [self.delegate circleViewController:self annotStyle:self.annotStyle];
    }
    self.opacitySliderView.opacitySlider.value = self.annotStyle.opacity;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];;
}

- (void)updateFillColor:(UIColor *)color {
    if(color) {
        CGFloat red, green, blue, alpha;
        [color getRed:&red green:&green blue:&blue alpha:&alpha];
        
        self.sampleView.interiorColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        self.sampleView.opcity = alpha;

        self.annotStyle.interiorColor = self.sampleView.interiorColor;
        self.annotStyle.opacity = self.sampleView.opcity;
        self.annotStyle.interiorOpacity = self.sampleView.opcity;
    } else {
        self.sampleView.interiorColor = color;
        self.sampleView.opcity = 0;

        self.annotStyle.color = color;
    }
    [self.sampleView setNeedsDisplay];
    if (self.delegate && [self.delegate respondsToSelector:@selector(circleViewController:annotStyle:)]) {
        [self.delegate circleViewController:self annotStyle:self.annotStyle];
    }
    self.opacitySliderView.opacitySlider.value = self.annotStyle.opacity;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];;

}

#pragma mark - CPDFOpacitySliderViewDelegate

- (void)opacitySliderView:(CPDFOpacitySliderView *)opacitySliderView opacity:(CGFloat)opacity {
    self.sampleView.opcity = opacity;

    self.annotStyle.opacity = opacity;
    self.annotStyle.interiorOpacity = opacity;

    if (self.delegate && [self.delegate respondsToSelector:@selector(circleViewController:annotStyle:)]) {
        [self.delegate circleViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFThicknessSliderViewDelegate

- (void)thicknessSliderView:(CPDFThicknessSliderView *)thicknessSliderView thickness:(CGFloat)thickness {
    if (thicknessSliderView == self.thicknessView) {
        self.sampleView.thickness = thickness;
        self.annotStyle.lineWidth = thickness;
        [self.sampleView setNeedsDisplay];
        if (self.delegate && [self.delegate respondsToSelector:@selector(circleViewController:annotStyle:)]) {
            [self.delegate circleViewController:self annotStyle:self.annotStyle];
        }
    } else if (thicknessSliderView == self.dottedView) {
        self.sampleView.dotted = thickness;
        self.annotStyle.style = CPDFBorderStyleDashed;
        self.annotStyle.dashPattern = @[[NSNumber numberWithFloat:(float)thickness]];
        if (self.delegate && [self.delegate respondsToSelector:@selector(circleViewController:annotStyle:)]) {
            [self.delegate circleViewController:self annotStyle:self.annotStyle];
        }
        [self.sampleView setNeedsDisplay];
    }
}

#pragma mark - CPDFColorSelectViewDelegate

- (void)selectColorView:(CPDFColorSelectView *)select {
    if (select == self.colorView) {
        if (@available(iOS 14.0, *)) {
            self.picker = [[UIColorPickerViewController alloc] init];
            self.picker.delegate = self;
            [self presentViewController:self.picker animated:YES completion:nil];
        } else {
            UIDevice *currentDevice = [UIDevice currentDevice];
            if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                // This is an iPad
                self.colorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 520)];
            } else {
                // This is an iPhone or iPod touch
                self.colorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 320)];
            }
            self.colorPicker.delegate = self;
            self.colorPicker.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:self.colorPicker];
            
            [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
        }
    } else if (select == self.fillColorSelectView) {
        if (@available(iOS 14.0, *)) {
            self.fillPicker = [[UIColorPickerViewController alloc] init];
            self.fillPicker.delegate = self;
            [self presentViewController:self.fillPicker animated:YES completion:nil];
        } else {
            UIDevice *currentDevice = [UIDevice currentDevice];
            if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                // This is an iPad
                self.fillColorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 520)];
            } else {
                // This is an iPhone or iPod touch
                self.fillColorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 320)];
            }
            self.fillColorPicker.delegate = self;
            self.fillColorPicker.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:self.fillColorPicker];
            
            [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
        }
    }
}

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    if (select == self.colorView) {
        [self updateBordColor:color];
    } else if (select == self.fillColorSelectView) {
        [self updateFillColor:color];
    }
}

#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    if (colorPickerView == self.colorPicker) {
        [self updateBordColor:color];
    } else if (colorPickerView == self.fillColorPicker) {
        [self updateFillColor:color];
    }
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    self.opacitySliderView.opacitySlider.value = alpha;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    UIColor *color = viewController.selectedColor;

    if (viewController == self.picker) {
        [self updateBordColor:color];
    } else if (viewController == self.fillPicker) {
        [self updateFillColor:color];
    }
    
    CGFloat red, green, blue, alpha;
    [viewController.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.opacitySliderView.opacitySlider.value = alpha;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
}

@end
