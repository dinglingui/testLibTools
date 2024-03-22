//
//  CPDFUnderlineViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFUnderlineViewController.h"
#import "CPDFAnnotationBaseViewController_Header.h"

@interface CPDFUnderlineViewController ()

@end

@implementation CPDFUnderlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)commomInitTitle {
    self.titleLabel.text = NSLocalizedString(@"Underline", nil);
    self.sampleView.selecIndex = CPDFSamplesUnderline;
    self.colorView.selectedColor = self.annotStyle.color;
}

- (void)commomInitFromAnnotStyle {
    self.sampleView.color = self.annotStyle.color;
    self.sampleView.opcity = self.annotStyle.opacity;
    
    self.opacitySliderView.opacitySlider.value = self.annotStyle.opacity;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFColorSelectViewDelegate

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    self.sampleView.color = color;
    self.annotStyle.color = color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(underlineViewController:annotStyle:)]) {
        [self.delegate underlineViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    self.sampleView.color = color;
    self.annotStyle.color = color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(underlineViewController:annotStyle:)]) {
        [self.delegate underlineViewController:self annotStyle:self.annotStyle];
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(underlineViewController:annotStyle:)]) {
        [self.delegate underlineViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    self.sampleView.color = viewController.selectedColor;
    self.annotStyle.color = self.sampleView.color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(underlineViewController:annotStyle:)]) {
        [self.delegate underlineViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
    
    CGFloat red, green, blue, alpha;
    [viewController.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.opacitySliderView.opacitySlider.value = alpha;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
}

@end
