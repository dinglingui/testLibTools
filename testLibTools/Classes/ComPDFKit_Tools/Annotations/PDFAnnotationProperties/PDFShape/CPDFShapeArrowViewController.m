//
//  CPDFShapeArrowViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFShapeArrowViewController.h"
#import "CPDFShareCircleViewController_Header.h"
#import "CPDFArrowStyleView.h"
#import "CShapeSelectView.h"
#import "CPDFDrawArrowView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CPDFShapeArrowViewController () <UIColorPickerViewControllerDelegate, CPDFArrowStyleViewDelegate, CShapeSelectViewDelegate, CPDFColorPickerViewDelegate>

@property (nonatomic, strong) UILabel *arrowLabel;

@property (nonatomic, strong) UIButton *arrowBtn;

@property (nonatomic, strong) UILabel *trialLabel;

@property (nonatomic, strong) UIButton *trialBtn;

@property (nonatomic, strong) CPDFArrowStyleView *startArrowStyleView;

@property (nonatomic, strong) CPDFArrowStyleView *endArrowStyleView;

@property (nonatomic, strong) CPDFDrawArrowView *startDrawView;

@property (nonatomic, strong) CPDFDrawArrowView *endDrawView;

@property (nonatomic, strong) NSMutableArray *dashPattern;

@property (nonatomic, strong) CShapeSelectView *shapeSelectView;

@property (nonatomic, strong) UIColorPickerViewController *picker API_AVAILABLE(ios(14.0));

@property (nonatomic, strong) UIColorPickerViewController *fillPicker API_AVAILABLE(ios(14.0));

@end

@implementation CPDFShapeArrowViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arrowLabel = [[UILabel alloc] init];
    self.arrowLabel.text = NSLocalizedString(@"Start", nil);
    self.arrowLabel.textColor = [UIColor grayColor];
    self.arrowLabel.font = [UIFont systemFontOfSize:12.0];
    [self.scrcollView addSubview:self.arrowLabel];

    self.arrowBtn = [[UIButton alloc] init];
    [self.arrowBtn setImage:[UIImage imageNamed:@"CPDFShapeArrowImageStart" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.arrowBtn.layer.borderWidth = 1.0;
    self.arrowBtn.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.arrowBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.arrowBtn addTarget:self action:@selector(buttonItemClicked_start:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrcollView addSubview:self.arrowBtn];
    
    self.startDrawView = [[CPDFDrawArrowView alloc] init];
    self.startDrawView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.arrowBtn addSubview:self.startDrawView];
    
    self.trialLabel = [[UILabel alloc] init];
    self.trialLabel.text = NSLocalizedString(@"End", nil);
    self.trialLabel.textColor = [UIColor grayColor];
    self.trialLabel.font = [UIFont systemFontOfSize:12.0];
    self.trialLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.scrcollView addSubview:self.trialLabel];
    
    self.trialBtn = [[UIButton alloc] init];
    [self.trialBtn setImage:[UIImage imageNamed:@"CPDFShapeArrowImageEnd" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.trialBtn.layer.borderWidth = 1.0;
    self.trialBtn.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    [self.trialBtn addTarget:self action:@selector(buttonItemClicked_trial:) forControlEvents:UIControlEventTouchUpInside];
    self.trialBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.scrcollView addSubview:self.trialBtn];
    
    self.endDrawView = [[CPDFDrawArrowView alloc]init];
    self.endDrawView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.trialBtn addSubview:self.endDrawView];
    
    self.fillColorSelectView.hidden = YES;
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrcollView.frame = CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170);
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 500);
    
    if (@available(iOS 11.0, *)) {
        CGFloat offsetY = 0;
        self.colorView.frame = CGRectMake(self.view.safeAreaInsets.left, 0,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        offsetY+= self.colorView.frame.size.height;
        self.opacitySliderView.frame = CGRectMake(self.view.safeAreaInsets.left, offsetY, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        offsetY+= self.opacitySliderView.frame.size.height;

        self.thicknessView.frame = CGRectMake(self.view.safeAreaInsets.left, offsetY, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        offsetY+= self.thicknessView.frame.size.height;

        self.dottedView.frame = CGRectMake(self.view.safeAreaInsets.left, offsetY, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        offsetY+= self.dottedView.frame.size.height;

        self.arrowLabel.frame = CGRectMake(self.view.safeAreaInsets.left+20, offsetY, 100, 45);
        self.arrowBtn.frame = CGRectMake(self.view.frame.size.width - 100 - self.view.safeAreaInsets.right, offsetY + 7.5, 80, 30);
        offsetY+= self.arrowLabel.frame.size.height;
        self.startDrawView.frame = CGRectMake(0, 0, 40, 30);
        
        self.trialLabel.frame = CGRectMake(self.view.safeAreaInsets.left+20, offsetY, 100, 45);
        self.trialBtn.frame = CGRectMake(self.view.frame.size.width - 100- self.view.safeAreaInsets.right, offsetY + 7.5, 80, 30);
        self.endDrawView.frame = CGRectMake(0, 0, 40, 30);
    } else {
        CGFloat offsetY = 0;
        self.colorView.frame = CGRectMake(0, 0,self.view.frame.size.width, 90);
        offsetY+= self.colorView.frame.size.height;
        self.opacitySliderView.frame = CGRectMake(0, offsetY, self.view.frame.size.width - 0, 90);
        offsetY+= self.opacitySliderView.frame.size.height;

        self.thicknessView.frame = CGRectMake(0, offsetY, self.view.frame.size.width, 90);
        offsetY+= self.thicknessView.frame.size.height;

        self.dottedView.frame = CGRectMake(0, offsetY, self.view.frame.size.width, 90);
        offsetY+= self.dottedView.frame.size.height;

        self.arrowLabel.frame = CGRectMake(20, offsetY, 100, 45);
        self.arrowBtn.frame = CGRectMake(self.view.frame.size.width - 100, offsetY + 7.5, 80, 30);
        offsetY+= self.arrowLabel.frame.size.height;
        self.startDrawView.frame = CGRectMake(0, 0, 40, 30);
        
        self.trialLabel.frame = CGRectMake(20, offsetY, 100, 45);
        self.trialBtn.frame = CGRectMake(self.view.frame.size.width - 100, offsetY + 7.5, 80, 30);
        self.endDrawView.frame = CGRectMake(0, 0, 40, 30);
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
    self.sampleView.dotted = self.dottedView.thicknessSlider.value;
    self.sampleView.interiorColor = self.annotStyle.interiorColor;
    self.sampleView.startArrowStyleIndex = (NSInteger)self.annotStyle.startLineStyle;
    self.sampleView.endArrowStyleIndex = (NSInteger)self.annotStyle.endLineStyle;
    [self.sampleView setNeedsDisplay];

    self.startDrawView.selectIndex = (NSInteger)self.annotStyle.startLineStyle;
    [self.startDrawView setNeedsDisplay];
    self.endDrawView.selectIndex = (NSInteger)self.annotStyle.endLineStyle;
    [self.endDrawView setNeedsDisplay];
}
    

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    if([self.startArrowStyleView superview] || [self.endArrowStyleView superview]) {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 120);
    } else if ([self.colorPicker superview]) {
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

#pragma mark - Action

- (void)buttonItemClicked_start:(id)sender {
    self.startArrowStyleView = [[CPDFArrowStyleView alloc] initWirhTitle:NSLocalizedString(@"Arrow Style",nil)];
    self.startArrowStyleView.frame = self.view.frame;
    self.startArrowStyleView.delegate = self;
    self.startArrowStyleView.selectIndex = self.startDrawView.selectIndex;
    self.startArrowStyleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.startArrowStyleView];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

- (void)buttonItemClicked_trial:(id)sender {
    self.endArrowStyleView = [[CPDFArrowStyleView alloc] initWirhTitle:NSLocalizedString(@"Arrowtail style",nil)];
    self.endArrowStyleView.frame = self.view.frame;
    self.endArrowStyleView.delegate = self;
    self.endArrowStyleView.selectIndex = self.endDrawView.selectIndex;
    self.endArrowStyleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.endArrowStyleView];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

#pragma mark - CPDFArrowStyleViewDelegate

- (void)arrowStyleView:(CPDFArrowStyleView *)arrowStyleView selectIndex:(NSInteger)selectIndex {
    if (arrowStyleView == self.startArrowStyleView) {
        self.sampleView.startArrowStyleIndex = selectIndex;
        self.annotStyle.startLineStyle = selectIndex;
        if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(arrowViewController:annotStyle:)]) {
            [self.lineDelegate arrowViewController:self annotStyle:self.annotStyle];
        }
        [self.sampleView setNeedsDisplay];
        
        self.startDrawView.selectIndex = selectIndex;
        [self.startDrawView setNeedsDisplay];
    } else if (arrowStyleView == self.endArrowStyleView) {
        self.sampleView.endArrowStyleIndex = selectIndex;
        self.annotStyle.endLineStyle = selectIndex;
        if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(arrowViewController:annotStyle:)]) {
            [self.lineDelegate arrowViewController:self annotStyle:self.annotStyle];
        }
        [self.sampleView setNeedsDisplay];
        
        self.endDrawView.selectIndex = selectIndex;
        [self.endDrawView setNeedsDisplay];
    }
}

- (void)arrowStyleRemoveView:(CPDFArrowStyleView *)arrowStyleView {
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

#pragma mark - CPDFOpacitySliderViewDelegate

- (void)opacitySliderView:(CPDFOpacitySliderView *)opacitySliderView opacity:(CGFloat)opacity {
    self.sampleView.opcity = opacity;
    self.annotStyle.opacity = opacity;
    if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(arrowViewController:annotStyle:)]) {
        [self.lineDelegate arrowViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFThicknessSliderViewDelegate

- (void)thicknessSliderView:(CPDFThicknessSliderView *)thicknessSliderView thickness:(CGFloat)thickness {
    if (thicknessSliderView == self.thicknessView) {
        self.sampleView.thickness = thickness;
        self.annotStyle.lineWidth = thickness;
        [self.sampleView setNeedsDisplay];
        if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(arrowViewController:annotStyle:)]) {
            [self.lineDelegate arrowViewController:self annotStyle:self.annotStyle];
        }
    } else if (thicknessSliderView == self.dottedView) {
        self.sampleView.dotted = thickness;
        self.annotStyle.style = CPDFBorderStyleDashed;
        self.annotStyle.dashPattern = @[[NSNumber numberWithFloat:(float)thickness]];
        if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(arrowViewController:annotStyle:)]) {
            [self.lineDelegate arrowViewController:self annotStyle:self.annotStyle];
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
    }
}

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    if (select == self.colorView) {
        self.sampleView.color = color;
        self.annotStyle.color = color;
        [self.sampleView setNeedsDisplay];
        if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(arrowViewController:annotStyle:)]) {
            [self.lineDelegate arrowViewController:self annotStyle:self.annotStyle];
        }
    } else if (select == self.fillColorSelectView) {
        self.sampleView.interiorColor = color;
        self.annotStyle.interiorColor = color;
        [self.sampleView setNeedsDisplay];
        if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(arrowViewController:annotStyle:)]) {
            [self.lineDelegate arrowViewController:self annotStyle:self.annotStyle];
        }
    }
}

#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    if (colorPickerView == self.colorPicker) {
        self.sampleView.color = color;
        self.annotStyle.color = color;
        [self.sampleView setNeedsDisplay];
        if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(arrowViewController:annotStyle:)]) {
            [self.lineDelegate arrowViewController:self annotStyle:self.annotStyle];
        }
    }
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    self.opacitySliderView.opacitySlider.value = alpha;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    if (viewController == self.picker) {
        self.sampleView.color = viewController.selectedColor;
        self.annotStyle.color = self.sampleView.color;
        if (self.lineDelegate && [self.lineDelegate respondsToSelector:@selector(arrowViewController:annotStyle:)]) {
            [self.lineDelegate arrowViewController:self annotStyle:self.annotStyle];
        }
        [self.sampleView setNeedsDisplay];
    }
    CGFloat red, green, blue, alpha;
    [viewController.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.opacitySliderView.opacitySlider.value = alpha;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
}

@end
