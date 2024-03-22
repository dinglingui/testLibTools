//
//  CPDFAnnotationBaseViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFAnnotationBaseViewController.h"
#import "CPDFAnnotationBaseViewController_Header.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface CPDFAnnotationBaseViewController () <UIColorPickerViewControllerDelegate, CPDFColorSelectViewDelegate, CPDFColorPickerViewDelegate, CPDFOpacitySliderViewDelegate>

@end

@implementation CPDFAnnotationBaseViewController

#pragma mark - Initializers

- (instancetype)initWithStyle:(CAnnotStyle *)annotStyle {
    if (self = [super init]) {
        self.annotStyle = annotStyle;
    }
    return self;
}

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.headerView = [[UIView alloc] init];
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.headerView addSubview:self.titleLabel];
    
    self.scrcollView = [[UIScrollView alloc] init];
    self.scrcollView.scrollEnabled = YES;
    [self.view addSubview:self.scrcollView];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBaseImageBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.backBtn];
    
    self.sampleBackgoundView = [[UIView alloc] init];
    self.sampleBackgoundView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.sampleBackgoundView.layer.borderWidth = 1.0;
    self.sampleBackgoundView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self.headerView addSubview:self.sampleBackgoundView];
    
    self.sampleView = [[CPDFSampleView alloc] init];
    self.sampleView.backgroundColor = [UIColor whiteColor];
    self.sampleView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.sampleView.layer.borderWidth = 1.0;
    self.sampleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.sampleBackgoundView addSubview:self.sampleView];
    
    self.colorView = [[CPDFColorSelectView alloc] init];
    self.colorView.delegate = self;
    self.colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrcollView addSubview:self.colorView];
    
    self.opacitySliderView = [[CPDFOpacitySliderView alloc] init];
    self.opacitySliderView.delegate = self;
    self.opacitySliderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrcollView addSubview:self.opacitySliderView];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
    self.scrcollView.frame = CGRectMake(0, 170, self.view.frame.size.width, 210);
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 170);
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 330);
    self.sampleBackgoundView.frame = CGRectMake(0, 50, self.view.bounds.size.width, 120);
    self.sampleView.frame  = CGRectMake((self.view.frame.size.width - 300)/2, 15, 300, self.sampleBackgoundView.bounds.size.height - 30);
    
    if (@available(iOS 11.0, *)) {
        self.colorPicker.frame = CGRectMake(self.view.safeAreaInsets.left, 0, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height);
        self.colorView.frame = CGRectMake(self.view.safeAreaInsets.left, 0,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        self.opacitySliderView.frame = CGRectMake(self.view.safeAreaInsets.left, 90, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 50);
    } else {
        self.colorView.frame = CGRectMake(0, 0, self.view.frame.size.width, 90);
        self.opacitySliderView.frame = CGRectMake(0, 90, self.view.frame.size.width, 90);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self commomInitTitle];
    [self commomInitFromAnnotStyle];
}

#pragma mark - Protect Methods

- (void)commomInitTitle {
    self.titleLabel.text = NSLocalizedString(@"Note", nil);
    self.sampleView.selecIndex = CPDFSamplesHighlight;
    self.colorView.colorLabel.text = NSLocalizedString(@"Color", nil);
    self.colorView.selectedColor = self.annotStyle.color;
    [self.colorView setNeedsLayout];
}

- (void)commomInitFromAnnotStyle {
    self.sampleView.color = self.annotStyle.color;
    self.sampleView.opcity = self.annotStyle.opacity;
    self.opacitySliderView.opacitySlider.value = self.annotStyle.opacity;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
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
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 420);
    }
}

#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CPDFColorSelectViewDelegate

- (void)selectColorView:(CPDFColorSelectView *)select {
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIDevice *currentDevice = [UIDevice currentDevice];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // This is an iPad
            _colorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 520)];
        } else {
            // This is an iPhone or iPod touch
            _colorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 320)];
        }
       
        _colorPicker.delegate = self;
        _colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _colorPicker.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        [self.view addSubview:self.colorPicker];
        [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    }
}

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    self.sampleView.color = color;
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    self.sampleView.color = color;
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
    [self.sampleView setNeedsDisplay];
    
}

@end
