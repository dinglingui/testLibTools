//
//  CCreateCertificateViewPasswordController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CCreateCertificateViewPasswordController.h"
#import "CPDFColorUtils.h"
#import "CHeaderView.h"
#import "CInputTextField.h"
#import "CPDFDigitalSignatureEditViewController.h"
#import "CAddSignatureViewController.h"
#import "AAPLCustomPresentationController.h"
#import "SignatureCustomPresentationController.h"

#import <ComPDFKit/ComPDFKit.h>

@interface  CCreateCertificateViewPasswordController () <UIDocumentPickerDelegate,CHeaderViewDelegate,CInputTextFieldDelegate, CPDFSignatureEditViewControllerDelegate, CAddSignatureViewControllerDelegate>

@property (nonatomic, strong) CHeaderView *headerView;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) CInputTextField *fileTextField;

@property (nonatomic, strong) CInputTextField *passwordTextField;

@property (nonatomic, strong) CInputTextField *confirmPasswordTextField;

@property (nonatomic, strong) UILabel *warningLabel;

@property (nonatomic, strong) UIButton *OKBtn;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) CPDFSignatureWidgetAnnotation *annotation;

@property (nonatomic, strong) CPDFSignatureCertificate *signatureCertificate;

@property (nonatomic, strong) UIButton *shareBtn;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *tempFilePath;

@property (nonatomic, strong) CPDFDigitalSignatureEditViewController * digitalSignatureEditViewController;

@end

@implementation CCreateCertificateViewPasswordController

#pragma mark - Initializers

- (instancetype)initWithAnnotation:(CPDFSignatureWidgetAnnotation *)annotation {
    if (self = [super init]) {
        self.annotation = annotation;
    }
    return self;
}

#pragma mark - Viewcontroller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.headerView = [[CHeaderView alloc] init];
    self.headerView.titleLabel.text = NSLocalizedString(@"Create A Self-Signed Digital ID to A File", nil);
    self.headerView.cancelBtn.hidden = YES;
    self.headerView.delegate = self;
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [UIFont systemFontOfSize:12];
    self.messageLabel.numberOfLines = 3;
    self.messageLabel.layer.cornerRadius = 4.0;
    self.messageLabel.layer.masksToBounds = YES;
    self.messageLabel.text = NSLocalizedString(@"After you create and save this Digital ID, it can be used again.", nil);
    self.messageLabel.backgroundColor = [CPDFColorUtils CMessageLabelColor];
    self.messageLabel.adjustsFontSizeToFitWidth = YES;
    [self.messageLabel sizeToFit];
    [self.scrollView addSubview:self.messageLabel];
    
    
    if (self.isSaveFile) {
        self.fileTextField = [[CInputTextField alloc] init];
        self.fileTextField.delegate = self;
        self.fileTextField.titleLabel.text = NSLocalizedString(@"Save Location", nil);
        self.fileTextField.inputTextField.text = self.filePath;
        UIView *hiddenView = [[UIView alloc] initWithFrame:CGRectZero];
        self.fileTextField.inputTextField.inputView = hiddenView;
        [self.scrollView addSubview:self.fileTextField];
        
        self.shareBtn = [[UIButton alloc] init];
        self.shareBtn.backgroundColor = [UIColor clearColor];
        [self.shareBtn addTarget:self action:@selector(buttonItemClicked_share:) forControlEvents:UIControlEventTouchUpInside];
        [self.fileTextField addSubview:self.shareBtn];
    }
    
    self.passwordTextField = [[CInputTextField alloc] init];
    self.passwordTextField.delegate = self;
    self.passwordTextField.titleLabel.text = NSLocalizedString(@"Set A Password", nil);
    self.passwordTextField.inputTextField.placeholder = NSLocalizedString(@"Please enter your password", nil);
    self.passwordTextField.inputTextField.secureTextEntry = YES;
    [self.scrollView addSubview:self.passwordTextField];
    
    self.confirmPasswordTextField = [[CInputTextField alloc] init];
    self.confirmPasswordTextField.delegate = self;
    self.confirmPasswordTextField.titleLabel.text = NSLocalizedString(@"Confirm A Password", nil);
    self.confirmPasswordTextField.inputTextField.placeholder = NSLocalizedString(@"Enter the password again", nil);
    self.confirmPasswordTextField.inputTextField.secureTextEntry = YES;
    [self.scrollView addSubview:self.confirmPasswordTextField];
    
    self.warningLabel = [[UILabel alloc] init];
    self.warningLabel.text = NSLocalizedString(@"Password and confirm password does not match", nil);
    self.warningLabel.textColor = [UIColor redColor];
    self.warningLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:self.warningLabel];
    self.warningLabel.hidden = YES;
    
    self.OKBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.OKBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    self.OKBtn.enabled = NO;
    [self.OKBtn addTarget:self action:@selector(buttonItemClicked_ok:) forControlEvents:UIControlEventTouchUpInside];
    [self.OKBtn setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
    [self.scrollView addSubview:self.OKBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardwillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat top = 0;
    CGFloat botton = 0;
    CGFloat left = 0;
    CGFloat right = 0;
    if (@available(iOS 11.0, *)) {
        botton += self.view.safeAreaInsets.bottom;
        top += self.view.safeAreaInsets.top;
        left += self.view.safeAreaInsets.left;
        right += self.view.safeAreaInsets.right;
    }
    
    self.headerView.frame = CGRectMake(0, top, self.view.frame.size.width, 55);
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIDeviceOrientationPortrait || currentOrientation == UIDeviceOrientationPortraitUpsideDown) {
        self.scrollView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 70);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        self.OKBtn.frame = CGRectMake(25 + left, CGRectGetMaxY(self.scrollView.frame)-150-botton, self.view.frame.size.width - 50 - left - right, 50);
    } else {
        self.scrollView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height+200);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+450);
        self.OKBtn.frame = CGRectMake(25 + left, CGRectGetMaxY(self.scrollView.frame)-150, self.view.frame.size.width - left - right - 50, 50);
    }
    
    self.messageLabel.frame = CGRectMake(25 + left, 20, self.view.frame.size.width - 50 - left - right, 90);
    if (self.isSaveFile) {
        self.fileTextField.frame = CGRectMake(25 + left, CGRectGetMaxY(self.messageLabel.frame)+10, self.view.frame.size.width - 50 - left - right, 90);
        self.passwordTextField.frame = CGRectMake(25 + left, CGRectGetMaxY(self.fileTextField.frame)+10, self.view.frame.size.width - 50 - left - right, 90);
        self.confirmPasswordTextField.frame = CGRectMake(25 + left, CGRectGetMaxY(self.passwordTextField.frame)+10, self.view.frame.size.width - 50 - left - right, 90);
        self.warningLabel.frame = CGRectMake(25 + left, CGRectGetMaxY(self.confirmPasswordTextField.frame)+10, self.view.frame.size.width - 50 - left - right, 30);
        self.shareBtn.frame = self.fileTextField.bounds;
    } else {
        self.passwordTextField.frame = CGRectMake(25 + left, CGRectGetMaxY(self.messageLabel.frame)+10, self.view.frame.size.width - 50 - left - right, 90);
        self.confirmPasswordTextField.frame = CGRectMake(25 + left, CGRectGetMaxY(self.passwordTextField.frame)+10, self.view.frame.size.width - 50 - left - right, 90);
        self.warningLabel.frame = CGRectMake(25 + left, CGRectGetMaxY(self.confirmPasswordTextField.frame)+10, self.view.frame.size.width - 50 - left - right, 30);
        self.shareBtn.frame = self.fileTextField.bounds;
    }
}

#pragma mark - CHeaderViewDelegate

- (void)CHeaderViewBack:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)CHeaderViewCancel:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CInputTextFieldDelegate

- (void)setCInputTextFieldChange:(CInputTextField *)inputTextField text:(NSString *)text {
    self.fileTextField.inputTextField.layer.borderWidth = 0.0;
    self.passwordTextField.inputTextField.layer.borderWidth = 0.0;
    self.confirmPasswordTextField.inputTextField.layer.borderWidth = 0.0;
    self.fileTextField.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordTextField.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.confirmPasswordTextField.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.warningLabel.hidden = YES;
    
    if (self.isSaveFile) {
        if (self.fileTextField.inputTextField.text.length > 0) {
            self.OKBtn.enabled = YES;
            self.OKBtn.backgroundColor = [UIColor blueColor];
        } else {
            self.OKBtn.enabled = NO;
            self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
            self.fileTextField.inputTextField.borderStyle = UITextBorderStyleNone;
            self.fileTextField.inputTextField.layer.borderWidth = 1.0;
            self.fileTextField.inputTextField.layer.borderColor = [UIColor redColor].CGColor;
        }
    } else {
        if (self.passwordTextField.inputTextField.text.length > 0 && self.confirmPasswordTextField.inputTextField.text.length > 0) {
            self.OKBtn.enabled = YES;
            self.OKBtn.backgroundColor = [UIColor blueColor];
            self.fileTextField.inputTextField.layer.borderColor = [UIColor redColor].CGColor;
        } else {
            self.OKBtn.enabled = NO;
            self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
        }
    }
}

- (void)setCInputTextFieldBegin:(CInputTextField *)inputTextField {
    
}

#pragma mark - Action

- (void)buttonItemClicked_ok:(UIButton *)button {
    if ([self.confirmPasswordTextField.inputTextField.text isEqual:self.passwordTextField.inputTextField.text]) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setValue:self.fileTextField.inputTextField.text?:@"" forKey:SAVEFILEPATH_KEY];
        if (self.passwordTextField.inputTextField.text.length > 0) {
            [dic setValue:self.passwordTextField.inputTextField.text forKey:PASSWORD_KEY];
        }
        
        switch (self.certUsage) {
            case 0:
                self.certUsage = CPDFCertUsageDigSig;
                break;
            case 1:
                self.certUsage = CPDFCertUsageDataEnc;
                break;
            default:
            case 2:
                self.certUsage = CPDFCertUsageAll;
                break;
        }
        
        BOOL save = [CPDFSignature generatePKCS12CertWithInfo:self.certificateInfo password:self.passwordTextField.inputTextField.text toPath:self.filePath certUsage:self.certUsage ? : CPDFCertUsageDigSig];
        
        if (!save) {
            NSLog(@"Save failed!");
        }
        
        
        self.signatureCertificate = [CPDFSignatureCertificate certificateWithPKCS12Path:self.filePath password:self.passwordTextField.inputTextField.text];
        
        self.password = self.passwordTextField.inputTextField.text;
        
        self.digitalSignatureEditViewController = [[CPDFDigitalSignatureEditViewController alloc] init];
        self.digitalSignatureEditViewController.delegate = self;
        SignatureCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
        presentationController = [[SignatureCustomPresentationController alloc] initWithPresentedViewController:self.digitalSignatureEditViewController presentingViewController:self];
        self.digitalSignatureEditViewController.transitioningDelegate = presentationController;
        [self presentViewController:self.digitalSignatureEditViewController animated:YES completion:nil];
        
    } else {
        self.OKBtn.enabled = NO;
        self.warningLabel.hidden = NO;
        self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.passwordTextField.inputTextField.borderStyle = UITextBorderStyleNone;
        self.passwordTextField.inputTextField.layer.borderWidth = 1.0;
        self.confirmPasswordTextField.inputTextField.borderStyle = UITextBorderStyleNone;
        self.confirmPasswordTextField.inputTextField.layer.borderWidth = 1.0;
        self.passwordTextField.inputTextField.layer.borderColor = [UIColor redColor].CGColor;
        self.confirmPasswordTextField.inputTextField.layer.borderColor = [UIColor redColor].CGColor;
    }
}

- (void)buttonItemClicked_share:(UIButton *)button {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *writeDirectoryPath = [NSString stringWithFormat:@"%@/%@", path, @"Signature"];
    
    self.tempFilePath = [NSString stringWithFormat:@"%@/%@", writeDirectoryPath, self.filePath.lastPathComponent];
    
    [CPDFSignature generatePKCS12CertWithInfo:self.certificateInfo password:@"1" toPath: self.tempFilePath certUsage:CPDFCertUsageDigSig];
    
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithURL:[NSURL fileURLWithPath: self.tempFilePath] inMode:UIDocumentPickerModeExportToService];
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)openFileWithURL:(NSURL *)url {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[url] applicationActivities:nil];
    activityVC.definesPresentationContext = YES;
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        activityVC.popoverPresentationController.sourceView = self.fileTextField;
        activityVC.popoverPresentationController.sourceRect = self.fileTextField.bounds;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        
        if (completed) {
            NSLog(@"Success!");
        } else {
            NSLog(@"Failed Or Canceled!");
        }
    };
}

- (NSArray *)sortContens:(NSArray *)contens {
    NSMutableArray *tContens = [NSMutableArray array];
    
    CPDFSignatureConfigItem *nameItem = nil;
    CPDFSignatureConfigItem *dnItem = nil;
    CPDFSignatureConfigItem *reaItem = nil;
    CPDFSignatureConfigItem *locaItem = nil;
    CPDFSignatureConfigItem *dateItem = nil;
    CPDFSignatureConfigItem *verItem = nil;
    
    for (CPDFSignatureConfigItem *item in contens) {
        if ([item.key isEqual:NAME_KEY]) {
            nameItem = item;
        } else if ([item.key isEqual:DN_KEY]) {
            dnItem = item;
        } else if ([item.key isEqual:REASON_KEY]) {
            reaItem = item;
        } else if ([item.key isEqual:LOCATION_KEY]) {
            locaItem = item;
        } else if ([item.key isEqual:DATE_KEY]) {
            dateItem = item;
        } else if ([item.key isEqual:VERSION_KEY]) {
            verItem = item;
        }
    }
    
    if (nameItem) {
        [tContens addObject:nameItem];
    }
    if (dateItem) {
        [tContens addObject:dateItem];
    }
    
    if (reaItem) {
        [tContens addObject:reaItem];
    }
    
    if (dnItem) {
        [tContens addObject:dnItem];
    }
    
    
    if (verItem) {
        [tContens addObject:verItem];
    }
    if (locaItem) {
        [tContens addObject:locaItem];
    }
    
    return tContens;
}


#pragma mark - CPDFSignatureEditViewControllerDelegate

- (void)signatureEditViewController:(CPDFSignatureEditViewController *)signatureEditViewController image:(UIImage *)image{
    CPDFSignatureConfig *signatureConfig = [[CPDFSignatureConfig alloc] init];
    if (signatureEditViewController.customType == 4) {
        signatureConfig.image = nil;
        signatureConfig.text = nil;
        signatureConfig.isDrawOnlyContent = YES;
    } else {
        signatureConfig.image = image;
        
    }
    signatureConfig.isContentAlginLeft = NO;
    signatureConfig.isDrawLogo = YES;
    signatureConfig.isDrawKey = YES;
    signatureConfig.logo = [UIImage imageNamed:@"ImageNameDigitalSignature" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    NSMutableArray *contents = [NSMutableArray arrayWithArray:signatureConfig.contents];
    CPDFSignatureConfigItem *configItem = [[CPDFSignatureConfigItem alloc]init];
    configItem.key = NAME_KEY;
    configItem.value = NSLocalizedString([self.signatureCertificate.issuerDict objectForKey:@"CN"], nil);
    [contents addObject:configItem];
    
    CPDFSignatureConfigItem *configItem1 = [[CPDFSignatureConfigItem alloc]init];
    configItem1.key = DATE_KEY;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    configItem1.value = [dateFormatter stringFromDate:[NSDate date]];
    [contents addObject:configItem1];
    
    signatureConfig.contents = [self sortContens:contents];
    [self.annotation signAppearanceConfig:signatureConfig];
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    CAddSignatureViewController *addSignatureViewController = [[CAddSignatureViewController alloc] initWithAnnotation:self.annotation SignatureConfig:signatureConfig];
    addSignatureViewController.customType = signatureEditViewController.customType;
    addSignatureViewController.delegate = self;
    addSignatureViewController.signatureCertificate = self.signatureCertificate;
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:addSignatureViewController presentingViewController:signatureEditViewController];
    addSignatureViewController.transitioningDelegate = presentationController;
    [signatureEditViewController presentViewController:addSignatureViewController animated:YES completion:nil];
}

- (void)signatureEditViewControllerCancel:(CPDFSignatureEditViewController *)signatureEditViewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(createCertificateViewPasswordControllerCancel:)]) {
        [self.delegate createCertificateViewPasswordControllerCancel:self];
    }
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *pickedURL = [urls firstObject];
    [pickedURL startAccessingSecurityScopedResource];
       
    self.filePath = [pickedURL path];
    self.fileTextField.inputTextField.text = self.filePath;
    
    [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:self.tempFilePath] error:nil];
    NSError *error;
    
    NSURL *parentURL = [pickedURL URLByDeletingLastPathComponent];
    BOOL save = [[NSFileManager defaultManager] setAttributes:@{ NSFilePosixPermissions: @(0644) } ofItemAtPath:pickedURL.path error:&error];
    if (!save) {
        
        NSLog(@"Failed to set the file permission：%@", error.localizedDescription);
    }
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:&error];
    if (!success) {
        
        NSLog(@"File deletion failure：%@", error.localizedDescription);
    }
}

#pragma mark - NSNotification

- (void)keyboardwillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = value.CGRectValue;
    CGRect rect = [self.confirmPasswordTextField.inputTextField convertRect:self.confirmPasswordTextField.frame toView:self.view];
    if(CGRectGetMaxY(rect) > self.view.frame.size.height - frame.size.height) {
        UIEdgeInsets insets = self.scrollView.contentInset;
        insets.bottom = frame.size.height + self.confirmPasswordTextField.frame.size.height;
        self.scrollView.contentInset = insets;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom = 0;
    self.scrollView.contentInset = insets;
}

#pragma mark - CAddSignatureViewControllerDelegate

- (void)CAddSignatureViewControllerSave:(CAddSignatureViewController *)addSignatureViewController signatureConfig:(nonnull CPDFSignatureConfig *)config {
    self.password = self.passwordTextField.inputTextField.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(createCertificateViewController:PKCS12Cert:password:config:)]) {
        [self.delegate createCertificateViewController:self PKCS12Cert:self.filePath password:self.password config:config];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)CAddSignatureViewControllerCancel:(CAddSignatureViewController *)addSignatureViewController {
    [self.digitalSignatureEditViewController refreshViewController];
}

@end
