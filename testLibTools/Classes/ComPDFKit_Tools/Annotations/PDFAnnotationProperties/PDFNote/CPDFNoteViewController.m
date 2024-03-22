//
//  CPDFNoteViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFNoteViewController.h"
#import "CPDFSampleView.h"
#import "CPDFColorSelectView.h"
#import "CPDFColorPickerView.h"
#import "CAnnotStyle.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface CPDFNoteViewController () <UIColorPickerViewControllerDelegate, CPDFColorSelectViewDelegate, CPDFColorPickerViewDelegate>

@property (nonatomic, strong) CPDFSampleView *sampleView;

@property (nonatomic, strong) UIView *sampleBackgoundView;

@property (nonatomic, strong) CPDFColorSelectView *colorView;

@property (nonatomic, strong) CPDFColorPickerView *colorPicker;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) CAnnotStyle *annotStyle;

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation CPDFNoteViewController

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
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    self.titleLabel.text = NSLocalizedString(@"Note", nil);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:self.titleLabel];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBaseImageBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    self.sampleBackgoundView = [[UIView alloc] init];
    self.sampleBackgoundView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.sampleBackgoundView.layer.borderWidth = 1.0;
    self.sampleBackgoundView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self.view addSubview:self.sampleBackgoundView];
    
    self.sampleView = [[CPDFSampleView alloc] init];
    self.sampleView.backgroundColor = [UIColor whiteColor];
    self.sampleView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.sampleView.layer.borderWidth = 1.0;
    self.sampleView.opcity = 1.0;
    self.sampleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [self.sampleBackgoundView addSubview:self.sampleView];
    
    self.colorView = [[CPDFColorSelectView alloc] init];
    self.colorView.selectedColor = self.annotStyle.color;
    self.colorView.delegate = self;
    self.colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.colorView];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, ((self.view.frame.size.height)/7));
    self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, ((self.view.frame.size.height)/7));
    self.sampleBackgoundView.frame = CGRectMake(0, ((self.view.frame.size.height)/7), self.view.bounds.size.width, ((self.view.frame.size.height)/7)*3);
    self.sampleView.frame  = CGRectMake((self.view.frame.size.width - 300)/2, 15, 300, self.sampleBackgoundView.bounds.size.height - 30);
    self.colorView.frame = CGRectMake(0, ((self.view.frame.size.height)/7)*4, self.view.frame.size.width, ((self.view.frame.size.height)/7)*2);
    if (@available(iOS 11.0, *)) {
        self.colorPicker.frame = CGRectMake(self.view.safeAreaInsets.left, 0, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height);
        self.colorView.frame = CGRectMake(self.view.safeAreaInsets.left, ((self.view.frame.size.height)/7)*4,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, ((self.view.frame.size.height)/7)*2);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, ((self.view.frame.size.height)/7));
    } else {
        self.colorPicker.frame = self.view.frame;
        self.colorView.frame = CGRectMake(0, ((self.view.frame.size.height)/7)*4, self.view.frame.size.width, ((self.view.frame.size.height)/7)*2);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, ((self.view.frame.size.height)/7));
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)viewWillAppear:(BOOL)animated {
    self.sampleView.color = self.annotStyle.color;
    self.sampleView.selecIndex = CPDFSamplesNote;
    [self.sampleView setNeedsDisplay];
}

#pragma mark - Protect Methods

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection
{
    self.preferredContentSize = CGSizeMake(MIN(self.view.bounds.size.width, self.view.bounds.size.height), traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 320 : 320);
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
        _colorPicker = [[CPDFColorPickerView alloc] initWithFrame:self.view.frame];
        _colorPicker.delegate = self;
        _colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _colorPicker.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.colorPicker];
    }
}

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    self.sampleView.color = color;
    self.annotStyle.color = color;
    [self.sampleView setNeedsDisplay];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(noteViewController:annotSytle:)]) {
        [self.delegate noteViewController:self annotSytle:self.annotStyle];
    }
}

#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    self.sampleView.color = color;
    self.annotStyle.color = color;
    [self.sampleView setNeedsDisplay];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(noteViewController:annotSytle:)]) {
        [self.delegate noteViewController:self annotSytle:self.annotStyle];
    }
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    self.sampleView.color = viewController.selectedColor;
    self.annotStyle.color = self.sampleView.color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(noteViewController:annotSytle:)]) {
        [self.delegate noteViewController:self annotSytle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

@end
