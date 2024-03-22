//
//  CPDFDigitalSignatureEditViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CPDFDigitalSignatureEditViewController.h"
#import "CPDFSignatureEditViewController_Header.h"

@interface CPDFDigitalSignatureEditViewController ()

@end

@implementation CPDFDigitalSignatureEditViewController

#pragma mark - Viewcontroller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.customType = 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [UIViewController attemptRotationToDeviceOrientation];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.segmentedControl.frame = CGRectMake((self.view.frame.size.width - 300)/2, 10, 300, 30);
}

#pragma mark - Public Methods

- (void)refreshViewController {
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    [UIViewController attemptRotationToDeviceOrientation];
}

#pragma mark - Private Methods

- (void)initSegmentedControl {
    NSArray *segmmentArray = [NSArray arrayWithObjects:NSLocalizedString(@"Trackpad", nil), NSLocalizedString(@"Keyboard", nil), NSLocalizedString(@"Image", nil),NSLocalizedString(@"None", nil),nil];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmmentArray];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged_singature:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
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
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        
        CGFloat mWidth = fmin(width, height);
        CGFloat mHeight = fmax(width, height);
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // This is an iPad
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.5 : mHeight*0.6);
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth : mHeight);
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - Action

- (void)segmentedControlValueChanged_singature:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self initDrawSignatureViewProperties];
        self.customType = 1;
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self initTextSignatureViewProperties];
        self.customType = 2;
    } else if (self.segmentedControl.selectedSegmentIndex == 2) {
        [self initImageSignatureViewProperties];
        self.customType = 3;
    } else if (self.segmentedControl.selectedSegmentIndex == 3) {
        self.customType = 4;
        if (self.delegate && [self.delegate respondsToSelector:@selector(signatureEditViewController:image:)]) {
            UIImage *image = [[UIImage alloc] init];
            [self.delegate signatureEditViewController:self image:image];
        }
    }
}

- (void)buttonItemClicked_Cancel:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(signatureEditViewControllerCancel:)]) {
        [self.delegate signatureEditViewControllerCancel:self];
    }
}

@end
