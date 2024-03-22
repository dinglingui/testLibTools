//
//  CPDFInkViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFInkViewController.h"
#import "CPDFAnnotationBaseViewController_Header.h"
#import "CPDFThicknessSliderView.h"
#import "CPDFInkTopToolBar.h"

@interface CPDFInkViewController () <CPDFThicknessSliderViewDelegate>

@property (nonatomic, strong) CPDFThicknessSliderView *thicknessView;

@end

@implementation CPDFInkViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _thicknessView = [[CPDFThicknessSliderView alloc] init];
    _thicknessView.delegate = self;
    _thicknessView.thicknessSlider.value = 4.0;
    _thicknessView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrcollView addSubview:self.thicknessView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrcollView.frame = CGRectMake(0, 170, self.view.frame.size.width, 310);
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 400);
    if (@available(iOS 11.0, *)) {
        self.thicknessView.frame = CGRectMake(self.view.safeAreaInsets.left, 180, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
    } else {
        self.colorView.frame = CGRectMake(0, 0, self.view.frame.size.width, 90);
        self.thicknessView.frame = CGRectMake(0, 180, self.view.frame.size.width, 90);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.delegate && [self.delegate respondsToSelector:@selector(inkViewControllerDimiss:)]) {
        [self.delegate inkViewControllerDimiss:self];
    }
}

#pragma mark - Private Methods

- (void)commomInitTitle {
    self.titleLabel.text = NSLocalizedString(@"Ink", nil);
    self.thicknessView.titleLabel.text = NSLocalizedString(@"Line Width", nil);
    self.sampleView.selecIndex = CPDFSamplesFreehand;
    self.sampleView.thickness = 4.0;
    self.colorView.selectedColor = self.annotStyle.color;
}

- (void)commomInitFromAnnotStyle {
    self.sampleView.color = self.annotStyle.color;
    self.sampleView.opcity = self.annotStyle.opacity;
    self.sampleView.thickness = self.annotStyle.lineWidth;
    
    self.opacitySliderView.opacitySlider.value = self.annotStyle.opacity;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
    self.thicknessView.thicknessSlider.value = self.annotStyle.lineWidth;
    self.thicknessView.startLabel.text = [NSString stringWithFormat:@"%d pt", (int)self.thicknessView.thicknessSlider.value];
    [self.sampleView setNeedsDisplay];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    if ([self.colorPicker superview]) {
        UIDevice *currentDevice = [UIDevice currentDevice];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // This is an iPad
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 520);
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 320);
        }
    } else {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 520);
    }
}

#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inkViewControllerDimiss:)]) {
        [self.delegate inkViewControllerDimiss:self];
    }
}

#pragma mark - CPDFThicknessSliderViewDelegate

- (void)thicknessSliderView:(CPDFThicknessSliderView *)thicknessSliderView thickness:(CGFloat)thickness {
    self.sampleView.thickness = thickness;
    self.annotStyle.lineWidth = thickness;
    if (self.delegate && [self.delegate respondsToSelector:@selector(inkViewController:annotStyle:)]) {
        [self.delegate inkViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFColorSelectViewDelegate

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    self.sampleView.color = color;
    self.annotStyle.color = color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(inkViewController:annotStyle:)]) {
        [self.delegate inkViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    self.sampleView.color = color;
    self.annotStyle.color = color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(inkViewController:annotStyle:)]) {
        [self.delegate inkViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    self.opacitySliderView.opacitySlider.value = alpha;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

#pragma mark - CPDFOpacitySliderViewDelegate

- (void)opacitySliderView:(CPDFOpacitySliderView *)opacitySliderView opacity:(CGFloat)opacity {
    self.sampleView.opcity = opacity;
    self.annotStyle.opacity = opacity;
    if (self.delegate && [self.delegate respondsToSelector:@selector(inkViewController:annotStyle:)]) {
        [self.delegate inkViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    self.sampleView.color = viewController.selectedColor;
    self.annotStyle.color = self.sampleView.color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(inkViewController:annotStyle:)]) {
        [self.delegate inkViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
    
    CGFloat red, green, blue, alpha;
    [viewController.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.opacitySliderView.opacitySlider.value = alpha;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
}

@end
