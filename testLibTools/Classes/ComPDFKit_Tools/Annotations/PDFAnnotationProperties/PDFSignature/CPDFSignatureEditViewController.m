//
//  CPDFSignatureEditViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSignatureEditViewController.h"
#import "CPDFColorSelectView.h"
#import "CSignatureTopBar.h"
#import "CSignatureDrawView.h"
#import "CPDFSignatureEditViewController_Header.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

#define kKMSignayureTextMaxWidth 200

@interface CPDFSignatureEditViewController () <UIPopoverPresentationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIColorPickerViewControllerDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate, CPDFColorSelectViewDelegate, CPDFColorPickerViewDelegate, CSignatureDrawViewDelegate>

@property (nonatomic, strong) CPDFColorSelectView *colorSelectView;

@property (nonatomic, strong) UIButton *cacelButon;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) CSignatureDrawView *signatureDrawTextView;

@property (nonatomic, strong) CSignatureDrawView *signatureDrawImageView;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) CALayer *bottomBorder;

@property (nonatomic, strong) UIButton *createButton;

@property (nonatomic, assign) CSignatureTopBarSelectedIndex selecIndex;

@property (nonatomic, strong) UIView *thicknessView;

@property (nonatomic, strong) UILabel *thicknessLabel;

@property (nonatomic, strong) UISlider *thicknessSlider;

@property (nonatomic, strong) UIButton *clearButton;

@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, assign) BOOL isDrawSignature;

@property (nonatomic, assign) BOOL isTexrSignature;

@property (nonatomic, assign) BOOL isImageSignature;

@end

@implementation CPDFSignatureEditViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    self.headerView = [[UIView alloc] init];
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    [self initSegmentedControl];
    
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.font = [UIFont systemFontOfSize:22];
    self.emptyLabel.textColor = [UIColor grayColor];
    self.emptyLabel.text = NSLocalizedString(@"Enter your signature", nil);
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:self.emptyLabel];
    
    self.colorSelectView = [[CPDFColorSelectView alloc] init];
    [self.colorSelectView.colorLabel removeFromSuperview];
    self.colorSelectView.selectedColor = [UIColor blackColor];
    self.colorSelectView.delegate = self;
    [self.view addSubview:self.colorSelectView];
    
    self.thicknessView = [[UIView alloc] init];
    self.thicknessView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.thicknessView];
    
    self.thicknessLabel = [[UILabel alloc] init];
    self.thicknessLabel.text = NSLocalizedString(@"Thickness", nil);
    self.thicknessLabel.textColor = [UIColor grayColor];
    self.thicknessLabel.font = [UIFont systemFontOfSize:12.0];
    [self.thicknessView addSubview:self.thicknessLabel];
    
    self.thicknessSlider = [[UISlider alloc] init];
    self.thicknessSlider.maximumValue = 20;
    self.thicknessSlider.minimumValue = 1;
    self.thicknessSlider.value = 5;
    [self.thicknessSlider addTarget:self action:@selector(buttonItemClicked_changes:) forControlEvents:UIControlEventValueChanged];
    [self.thicknessView addSubview:self.thicknessSlider];
    
    self.signatureDrawTextView = [[CSignatureDrawView alloc] init];
    self.signatureDrawTextView.delegate = self;
    self.signatureDrawTextView.color = [UIColor blackColor];
    self.signatureDrawTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.signatureDrawTextView.lineWidth = self.thicknessSlider.value;
    [self.view addSubview:self.signatureDrawTextView];
    
    self.signatureDrawImageView = [[CSignatureDrawView alloc] init];
    self.signatureDrawImageView.delegate = self;
    self.signatureDrawImageView.color = [UIColor blackColor];
    self.signatureDrawImageView.lineWidth = 4;
    self.signatureDrawImageView.userInteractionEnabled = NO;
    [self.view addSubview:self.signatureDrawImageView];
    self.signatureDrawImageView.hidden = YES;
    
    self.cacelButon = [[UIButton alloc] init];
    [self.cacelButon setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    self.cacelButon.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.cacelButon setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cacelButon addTarget:self action:@selector(buttonItemClicked_Cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.cacelButon];
    
    self.saveButton = [[UIButton alloc] init];
    [self.saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.saveButton.enabled = NO;
    [self.saveButton addTarget:self action:@selector(buttonItemClicked_Save:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.saveButton];
    
    self.bottomBorder = [CALayer layer];
    self.bottomBorder.backgroundColor = [UIColor blackColor].CGColor;
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    self.textField.textColor = [UIColor blackColor];
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Enter your signature", nil);
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.font = [UIFont systemFontOfSize:30];
    [self.textField addTarget:self action:@selector(textTextField_change:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.textField];
    [self.textField.layer addSublayer:self.bottomBorder];
    self.textField.hidden = YES;
    
    self.createButton = [[UIButton alloc] init];
    self.createButton.layer.cornerRadius = 25.0;
    self.createButton.clipsToBounds = YES;
    [self.createButton setImage:[UIImage imageNamed:@"CPDFSignatureImageAdd" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.createButton.backgroundColor = [UIColor blueColor];
    [self.createButton addTarget:self action:@selector(buttonItemClicked_create:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createButton];
    self.createButton.hidden = YES;
    
    self.clearButton = [[UIButton alloc] init];
    [self.clearButton setImage:[UIImage imageNamed:@"CPDFSignatureImageClean" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.clearButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.clearButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.clearButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.clearButton.layer.borderWidth = 1.0;
    self.clearButton.layer.cornerRadius = 25.0;
    self.clearButton.layer.masksToBounds = YES;
    [self.clearButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.clearButton addTarget:self action:@selector(buttonItemClicked_clear:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearButton];
    
    self.selecIndex = CSignatureTopBarDefault;
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self createGestureRecognizer];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    self.isImageSignature = NO;
    self.isDrawSignature = NO;
    self.isImageSignature = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    self.segmentedControl.frame = CGRectMake((self.view.frame.size.width - 220)/2, 10, 220, 30);
    self.emptyLabel.frame = CGRectMake((self.view.frame.size.width - 200)/2, (self.view.frame.size.height - 50)/2, 200, 50);
   
    if (@available(iOS 11.0, *)) {
        UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsPortrait(currentOrientation)) {
            self.colorSelectView.frame = CGRectMake(self.view.safeAreaInsets.left, 50, 380, 60);
            self.colorSelectView.colorPickerView.frame = CGRectMake(0, 0, self.colorSelectView.frame.size.width, self.colorSelectView.frame.size.height);
            self.thicknessView.frame = CGRectMake(self.view.safeAreaInsets.left, 140, self.view.frame.size.width-self.view.safeAreaInsets.left-self.view.safeAreaInsets.right, 60);
            self.thicknessLabel.frame = CGRectMake(20, 15, 60, 30);
            self.thicknessSlider.frame = CGRectMake(90, 0, self.thicknessView.bounds.size.width-110, 60);
            self.signatureDrawTextView.frame = CGRectMake(self.view.safeAreaInsets.left, 210, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height-self.view.safeAreaInsets.top-self.view.safeAreaInsets.bottom-150);
        } else if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
            self.colorSelectView.frame = CGRectMake(self.view.safeAreaInsets.left, 50, 380, 60);
            self.thicknessView.frame = CGRectMake(380, 70, self.view.frame.size.width-380-self.view.safeAreaInsets.right, 60);
            self.thicknessLabel.frame = CGRectMake(20, 15, 60, 30);
            self.thicknessSlider.frame = CGRectMake(90, 0, self.thicknessView.bounds.size.width-110, 60);
            self.signatureDrawTextView.frame = CGRectMake(self.view.safeAreaInsets.left, 130, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height-self.view.safeAreaInsets.top-self.view.safeAreaInsets.bottom-130);
        }
        self.saveButton.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 40);
        self.cacelButon.frame = CGRectMake( self.view.safeAreaInsets.left+20, 5, 50, 40);
        self.signatureDrawImageView.frame = CGRectMake(self.view.safeAreaInsets.left, 50, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height-self.view.safeAreaInsets.top-self.view.safeAreaInsets.bottom-150);
        self.createButton.frame = CGRectMake(self.view.frame.size.width - 70 - self.view.safeAreaInsets.right, self.view.frame.size.height - 100 - self.view.safeAreaInsets.bottom, 50, 50);
        self.clearButton.frame = CGRectMake(self.view.frame.size.width - 70 - self.view.safeAreaInsets.right, self.view.frame.size.height - 100 - self.view.safeAreaInsets.bottom, 50, 50);
    } else {
        UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsPortrait(currentOrientation)) {
            self.colorSelectView.frame = CGRectMake(10, 50, 380, 60);
            self.colorSelectView.colorPickerView.frame = CGRectMake(0, 0, self.colorSelectView.frame.size.width, self.colorSelectView.frame.size.height);
            self.thicknessView.frame = CGRectMake(10, 140, self.view.frame.size.width-20, 60);
            self.thicknessLabel.frame = CGRectMake(20, 15, 60, 30);
            self.thicknessSlider.frame = CGRectMake(90, 0, self.thicknessView.bounds.size.width-110, 60);
            self.signatureDrawTextView.frame = CGRectMake(10, 210, self.view.frame.size.width-20, self.view.frame.size.height-114-150);
        } else if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
            self.colorSelectView.frame = CGRectMake(10, 50, 380, 60);
            self.thicknessView.frame = CGRectMake(380, 70, self.view.frame.size.width-380-10, 60);
            self.thicknessLabel.frame = CGRectMake(20, 15, 60, 30);
            self.thicknessSlider.frame = CGRectMake(90, 0, self.thicknessView.bounds.size.width-110, 60);
            self.signatureDrawTextView.frame = CGRectMake(10, 130, self.view.frame.size.width-20, self.view.frame.size.height-114-130);
        }
        
        self.signatureDrawImageView.frame = self.signatureDrawTextView.frame;
        self.createButton.frame = CGRectMake(self.view.frame.size.width - 70, self.view.frame.size.height - 100, 50, 50);
        self.clearButton.frame = CGRectMake(self.view.frame.size.width - 70, self.view.frame.size.height - 100, 50, 50);
        self.saveButton.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 40);
        self.cacelButon.frame = CGRectMake(20, 5, 50, 40);
    }
    
    self.textField.frame = CGRectMake((self.view.frame.size.width - 300)/2, 200, 300, 100);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self.textField resignFirstResponder];
    } else if (self.segmentedControl.selectedSegmentIndex == 0 || self.segmentedControl.selectedSegmentIndex == 2) {
        [self.signatureDrawTextView signatureClear];
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - Private Methods

- (void)initSegmentedControl {
    NSArray *segmmentArray = [NSArray arrayWithObjects:NSLocalizedString(@"Trackpad", nil), NSLocalizedString(@"Keyboard", nil), NSLocalizedString(@"Image", nil),nil];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:segmmentArray];
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged_singature:) forControlEvents:UIControlEventValueChanged];
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
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.9);
        }
    }
}

- (void)createGestureRecognizer {
    [self.createButton setUserInteractionEnabled:YES];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panaddBookmarkBtn:)];
    [self.createButton addGestureRecognizer:panRecognizer];
}

- (void)panaddBookmarkBtn:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer translationInView:self.view];
    CGFloat newX = self.createButton.center.x + point.x;
    CGFloat newY = self.createButton.center.y + point.y;
    if (CGRectContainsPoint(self.view.frame, CGPointMake(newX, newY))) {
        self.createButton.center = CGPointMake(newX, newY);
    }
    [gestureRecognizer setTranslation:CGPointZero inView:self.view];
}

- (UIImage *)createTextSignature {
    if (self.textField.text.length < 1) {
        return [UIImage new];
    }

    NSString *string = self.textField.text;
    UIFont *font = self.textField.font;
    CGSize size = [self labelAutoCalculateRectWith:string Font:font];
    CGFloat sideH = size.height + 10;

    CGFloat w = size.width;
    if (w + 10 > kKMSignayureTextMaxWidth) {
        w = kKMSignayureTextMaxWidth - 10;
    }

    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w + 10, sideH)];
    backView.backgroundColor = [UIColor clearColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, w, size.height)];
    label.font = font;
    label.text = string;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 1;
    label.textColor = self.textField.textColor;
    label.adjustsFontSizeToFitWidth = YES;
    [backView addSubview:label];

    UIImage *newImage = [self imageWithUIView:backView];

    return newImage;
}

- (UIImage *)imageWithUIView:(UIView *) view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, 0.0, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

- (CGSize)labelAutoCalculateRectWith:(NSString*)text Font:(UIFont*)font {
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    CGSize maxSize = CGSizeMake(NSNotFound, NSNotFound);
    
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    
    NSDictionary* attributes =@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle};
    
    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    
    labelSize.height = ceil(labelSize.height);
    
    labelSize.width = ceil(labelSize.width);
    
    return labelSize;
}

- (void)initDrawSignatureViewProperties {
    self.colorSelectView.hidden = NO;
    self.signatureDrawTextView.hidden = NO;
    self.selecIndex = CSignatureTopBarDefault;
    self.colorSelectView.hidden = NO;
    self.clearButton.hidden = NO;
    self.signatureDrawTextView.selectIndex = CSignatureDrawText;
    self.emptyLabel.hidden = NO;
    self.thicknessView.hidden = NO;
    self.signatureDrawImageView.hidden = YES;
    self.createButton.hidden = YES;
    self.textField.hidden = YES;
    [self.textField resignFirstResponder];
    
    if (self.isDrawSignature) {
        [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.saveButton.enabled = YES;
    } else {
        [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.saveButton.enabled = NO;
    }
}

- (void)initTextSignatureViewProperties {
    self.colorSelectView.hidden = NO;
    self.signatureDrawTextView.hidden = YES;
    self.signatureDrawImageView.hidden = YES;
    self.textField.hidden = NO;
    self.selecIndex = CSignatureTopBarText;
    self.colorSelectView.hidden = NO;
    self.createButton.hidden = YES;
    self.thicknessView.hidden = YES;
    self.clearButton.hidden = NO;
    self.emptyLabel.hidden = YES;
    [self.textField becomeFirstResponder];
    
    if (self.isTexrSignature) {
        [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.saveButton.enabled = YES;
    } else {
        [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.saveButton.enabled = NO;
    }
}

- (void)initImageSignatureViewProperties {
    [self.textField resignFirstResponder];
    self.colorSelectView.hidden = YES;
    self.signatureDrawTextView.hidden = YES;
    self.signatureDrawImageView.hidden = NO;
    self.textField.hidden = YES;
    self.selecIndex = CSignatureTopBarImage;
    self.createButton.hidden = NO;
    self.colorSelectView.hidden = YES;
    self.signatureDrawImageView.selectIndex = CSignatureDrawImage;
    self.thicknessView.hidden = YES;
    self.clearButton.hidden = YES;
    self.emptyLabel.hidden = YES;
    [self.signatureDrawImageView setNeedsDisplay];
    
    if (self.isImageSignature) {
        [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.saveButton.enabled = YES;
    } else {
        [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.saveButton.enabled = NO;
    }
}

#pragma mark - Action

- (void)buttonItemClicked_Save:(id)sender {
    if (CSignatureTopBarDefault == self.selecIndex) {
        UIImage *image = [self.signatureDrawTextView signatureImage];
        if (self.delegate && [self.delegate respondsToSelector:@selector(signatureEditViewController:image:)]) {
            [self.delegate signatureEditViewController:self image:image];
        }
    } else if (CSignatureTopBarImage == self.selecIndex) {
        [self.signatureDrawTextView signatureClear];
        UIImage *image = [self.signatureDrawImageView signatureImage];
        if (self.delegate && [self.delegate respondsToSelector:@selector(signatureEditViewController:image:)]) {
            [self.delegate signatureEditViewController:self image:image];
        }
    }else if (CSignatureTopBarText == self.selecIndex) {
        UIImage *image = [self createTextSignature];
        if(self.textField.text.length == 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Info" message:@"Please input Signature" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        if (self.textField.text) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(signatureEditViewController:image:)]) {
                [self.delegate signatureEditViewController:self image:image];
            }
        }
    }
//    [self buttonItemClicked_Cancel:sender];
}

- (void)buttonItemClicked_Cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
   
}

- (void)buttonItemClicked_create:(id)sender {
    [self createImageSignature];
}

- (void)segmentedControlValueChanged_singature:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self initDrawSignatureViewProperties];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self initTextSignatureViewProperties];
    } else if (self.segmentedControl.selectedSegmentIndex == 2) {
        [self initImageSignatureViewProperties];
    }
}

- (void)buttonItemClicked_changes:(UISlider *)sender {
    self.signatureDrawTextView.lineWidth = sender.value;
    [self.signatureDrawTextView setNeedsDisplay];
}

- (void)buttonItemClicked_clear:(UIButton *)button {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.signatureDrawTextView signatureClear];
        self.emptyLabel.text = NSLocalizedString(@"Enter your signature", nil);
        self.isDrawSignature = NO;
        [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.saveButton.enabled = NO;
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        self.textField.text = @"";
        self.isTexrSignature = NO;
        [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.saveButton.enabled = NO;
    }
    
}

- (void)textTextField_change:(UITextField *)textField {
    if (self.textField.text.length > 0) {
        self.isTexrSignature = YES;
        [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.saveButton.enabled = YES;
    } else {
        self.isTexrSignature = NO;
        [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.saveButton.enabled = NO;
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^ {
            self.clearButton.center = CGPointMake(self.clearButton.center.x, self.clearButton.center.y-300);
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^ {
            self.clearButton.center = CGPointMake(self.clearButton.center.x, self.clearButton.center.y-150);
            self.textField.center = CGPointMake(self.textField.center.x, self.textField.center.y-150);
        } completion:nil];
        self.colorSelectView.hidden = YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^ {
            self.clearButton.center = CGPointMake(self.clearButton.center.x, self.clearButton.center.y+300);
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^ {
            self.clearButton.center = CGPointMake(self.clearButton.center.x, self.clearButton.center.y+150);
            self.textField.center = CGPointMake(self.textField.center.x, self.textField.center.y+150);
        } completion:nil];
        self.colorSelectView.hidden = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private Methods

- (void)createImageSignature {
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
        imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
        if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
            imagePickerController.popoverPresentationController.sourceView = self.segmentedControl;;
            imagePickerController.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMaxX(self.segmentedControl.bounds), CGRectGetMaxY(self.segmentedControl.bounds), 1, 1);
        }
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        actionSheet.popoverPresentationController.sourceView = self.segmentedControl;
        actionSheet.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMaxX(self.segmentedControl.bounds), CGRectGetMaxY(self.segmentedControl.bounds), 1, 1);
    }
    
    [actionSheet addAction:cameraAction];
    [actionSheet addAction:photoAction];
    [actionSheet addAction:cancelAction];
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image;
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if (image) {
        self.isImageSignature = YES;
        [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.saveButton.enabled = YES;
    }
    
    UIImageOrientation imageOrientation = image.imageOrientation;
    if (imageOrientation!=UIImageOrientationUp) {
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    if (imageData == nil || [imageData length] <= 0) {
        return;
    }
    image = [UIImage imageWithData:imageData];
    
    const CGFloat colorMasking[6] = {222, 255, 222, 255, 222, 255};
    CGImageRef imageRef = CGImageCreateWithMaskingColors(image.CGImage, colorMasking);
    if (imageRef) {
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    
    self.signatureDrawImageView.image = image;
    [self.signatureDrawImageView setNeedsDisplay];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CPDFColorSelectViewDelegate

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    self.textField.textColor = color;

    self.signatureDrawTextView.color = color;
    [self.signatureDrawTextView setNeedsDisplay];
}

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
        self.colorPicker.delegate = self;
        self.colorPicker.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        [self.view addSubview:self.colorPicker];
        [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    }
}

#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    self.signatureDrawTextView.color = color;

    self.textField.textColor = self.signatureDrawTextView.color;
    [self.signatureDrawImageView setNeedsDisplay];
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    self.signatureDrawTextView.color = viewController.selectedColor;
    self.textField.textColor = self.signatureDrawTextView.color;
    [self.signatureDrawTextView setNeedsDisplay];
}

#pragma mark - CSignatureDrawViewDelegate

- (void)signatureDrawViewStart:(CSignatureDrawView *)signatureDrawView {
    [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.saveButton.enabled = YES;
    self.isDrawSignature = YES;
    self.emptyLabel.text = @"";
}

- (void)appWillResignActive:(NSNotification *)notification {
    [self.textField resignFirstResponder];
}

@end
