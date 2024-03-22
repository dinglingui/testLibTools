//
//  CCertificateViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CImportCertificateViewController.h"
#import "CPDFColorUtils.h"
#import "CHeaderView.h"
#import "CInputTextField.h"
#import "CPDFDigitalSignatureEditViewController.h"
#import "SignatureCustomPresentationController.h"
#import "CAddSignatureViewController.h"
#import "AAPLCustomPresentationController.h"
#import "CPDFSignatureEditViewController_Header.h"

#import <ComPDFKit/ComPDFKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CImportCertificateViewController () <CHeaderViewDelegate,CInputTextFieldDelegate,CAddSignatureViewControllerDelegate,CPDFSignatureEditViewControllerDelegate,UIDocumentPickerDelegate>

@property (nonatomic, strong) CHeaderView *headerView;

@property (nonatomic, strong) CInputTextField *documentTextField;

@property (nonatomic, strong) UIButton *documentButton;

@property (nonatomic, strong) CInputTextField *passwordTextField;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) NSURL *filePath;

@property (nonatomic, strong) CPDFSignatureCertificate *signatureCertificate;

@property (nonatomic, strong) CPDFSignatureWidgetAnnotation *annotation;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *OKBtn;

@property (nonatomic, strong) UILabel *warningLabel;

@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) CPDFDigitalSignatureEditViewController * digitalSignatureEditViewController;

@end

@implementation CImportCertificateViewController

#pragma mark - Initializers

- (instancetype)initWithP12FilePath:(NSURL *)filePath Annotation:(CPDFSignatureWidgetAnnotation *)annotation {
    if (self = [super init]) {
        self.filePath = filePath;
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
    
    self.password = @"";
    
    self.headerView = [[CHeaderView alloc] init];
    self.headerView.titleLabel.text = NSLocalizedString(@"Add A Digital ID", nil);
    self.headerView.delegate = self;
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.numberOfLines = 3;
    self.messageLabel.font = [UIFont systemFontOfSize:12];
    self.messageLabel.layer.cornerRadius = 4.0;
    self.messageLabel.layer.masksToBounds = YES;
    self.messageLabel.adjustsFontSizeToFitWidth = YES;
    self.messageLabel.text = NSLocalizedString(@"Browse digital ID files. The Digital ID file is password protected. If you do not konw its password, you cannot access the digital ID card.", nil);
    self.messageLabel.backgroundColor = [CPDFColorUtils CMessageLabelColor];
    [self.messageLabel sizeToFit];
    [self.scrollView addSubview:self.messageLabel];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button1 setImage:[UIImage imageNamed:@"CDigitalSignatureViewControllerRight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    button1.tintColor = [UIColor blackColor];
    [button1 addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setImage:[UIImage imageNamed:@"CDigitalSignatureViewControllerCancel" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    button2.tintColor = [UIColor grayColor];
    [button2 addTarget:self action:@selector(buttonItemClicked_cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    self.documentTextField = [[CInputTextField alloc] init];
    self.documentTextField.titleLabel.text = NSLocalizedString(@"Certificate File", nil);
    self.documentTextField.inputTextField.text = self.filePath.lastPathComponent;
    self.documentTextField.inputTextField.rightView = button1;
    self.documentTextField.inputTextField.rightViewMode = UITextFieldViewModeAlways;
    [self.scrollView addSubview:self.documentTextField];
    
    self.documentButton = [[UIButton alloc] init];
    self.documentButton.backgroundColor = [UIColor clearColor];
    [self.documentButton addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
    [self.documentTextField addSubview:self.documentButton];
    
    self.passwordTextField = [[CInputTextField alloc] init];
    self.passwordTextField.delegate = self;
    self.passwordTextField.titleLabel.text = NSLocalizedString(@"Passwords", nil);
    self.passwordTextField.inputTextField.placeholder = NSLocalizedString(@"Enter the password of the certificate file", nil);
    self.passwordTextField.inputTextField.secureTextEntry = YES;
    self.passwordTextField.inputTextField.clearButtonMode = UITextFieldViewModeAlways;
    [self.scrollView addSubview:self.passwordTextField];
    
    self.warningLabel = [[UILabel alloc] init];
    self.warningLabel.text = NSLocalizedString(@"Wrong Password", nil);
    self.warningLabel.textColor = [UIColor redColor];
    self.warningLabel.font = [UIFont systemFontOfSize:13];
    [self.scrollView addSubview:self.warningLabel];
    self.warningLabel.hidden = YES;
    
    self.OKBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.OKBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
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
        self.scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame)+5, self.view.frame.size.width, self.view.frame.size.height - 100);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        self.OKBtn.frame = CGRectMake(25+left, CGRectGetMaxY(self.scrollView.frame)-140-botton, self.view.frame.size.width - 50  -left - right, 50);
    } else {
       
        self.scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame)+5, self.view.frame.size.width, self.view.frame.size.height + 100);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+200);
        self.OKBtn.frame = CGRectMake(25+left, CGRectGetMaxY(self.scrollView.frame)-140-botton, self.view.frame.size.width - 50  -left - right, 50);
    }
    
    
    self.messageLabel.frame = CGRectMake(25+left, 20, self.view.frame.size.width - 50 -left - right, 90);
    self.documentTextField.frame = CGRectMake(25+left, CGRectGetMaxY(self.messageLabel.frame)+10, self.view.frame.size.width - 50  -left - right, 90);
    self.documentButton.frame = self.documentTextField.bounds;
    self.passwordTextField.frame = CGRectMake(25+left, CGRectGetMaxY(self.documentTextField.frame)+10, self.view.frame.size.width - 50  -left - right, 90);
    self.warningLabel.frame = CGRectMake(25+left, CGRectGetMaxY(self.passwordTextField.frame)+10, 120, 30);
   
}


#pragma mark - Action

- (void)buttonItemClicked_select:(UIButton *)button {
    __block CImportCertificateViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *documentTypes = @[(NSString *)kUTTypePKCS12];
            UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
                    documentPickerViewController.delegate = weakSelf;
            
            [self presentViewController:documentPickerViewController animated:YES completion:nil];
        });
    });
}

- (void)buttonItemClicked_cancel:(UIButton *)button {
    self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.warningLabel.hidden = YES;
    self.passwordTextField.inputTextField.text = @"";
}

- (void)buttonItemClicked_ok:(UIButton *)button {
    self.signatureCertificate = [CPDFSignatureCertificate certificateWithPKCS12Path:self.filePath.path password:self.password];
    if (self.signatureCertificate != nil) {

        self.digitalSignatureEditViewController = [[CPDFDigitalSignatureEditViewController alloc] init];
        self.digitalSignatureEditViewController.delegate = self;
        SignatureCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
        presentationController = [[SignatureCustomPresentationController alloc] initWithPresentedViewController:self.digitalSignatureEditViewController presentingViewController:self];
        self.digitalSignatureEditViewController.transitioningDelegate = presentationController;
        [self presentViewController:self.digitalSignatureEditViewController animated:YES completion:nil];
      
    } else {
        self.warningLabel.hidden = NO;
    }
}

#pragma mark - Private Methods

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

#pragma mark - CHeaderViewDelegate

- (void)CHeaderViewBack:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)CHeaderViewCancel:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CInputTextFieldDelegate

- (void)setCInputTextFieldClear:(CInputTextField *)inputTextField {
    self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.warningLabel.hidden = YES;
}

- (void)setCInputTextFieldChange:(CInputTextField *)inputTextField text:(NSString *)text {
    if ([text length] == 0) {
        self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.warningLabel.hidden = YES;
    } else {
        self.OKBtn.backgroundColor = [UIColor blueColor];
        self.warningLabel.hidden = YES;
    }
    self.password = text;
}

#pragma mark - NSNotification

- (void)keyboardwillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = value.CGRectValue;
    CGRect rect = [self.passwordTextField.inputTextField convertRect:self.passwordTextField.frame toView:self.view];
    if(CGRectGetMaxY(rect) > self.view.frame.size.height - frame.size.height) {
        UIEdgeInsets insets = self.scrollView.contentInset;
        insets.bottom = frame.size.height + self.passwordTextField.frame.size.height;
        self.scrollView.contentInset = insets;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom = 0;
    self.scrollView.contentInset = insets;
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if(fileUrlAuthozied){
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingFormat:@"/%@/%@", @"Documents",@"Files"];

            if (![[NSFileManager defaultManager] fileExistsAtPath:documentFolder])
                [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:documentFolder] withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSString * documentPath = [documentFolder stringByAppendingPathComponent:[newURL lastPathComponent]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
               [[NSFileManager defaultManager] copyItemAtPath:newURL.path toPath:documentPath error:NULL];

            }
            NSURL *url = [NSURL fileURLWithPath:documentPath];
            self.filePath = url;
            self.documentTextField.inputTextField.text = url.lastPathComponent;
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
    }
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(importCertificateViewControllerCancel:)]) {
        [self.delegate importCertificateViewControllerCancel:self];
    }
}

#pragma mark - CAddSignatureViewControllerDelegate

- (void)CAddSignatureViewControllerSave:(CAddSignatureViewController *)addSignatureViewController signatureConfig:(nonnull CPDFSignatureConfig *)config {
    self.password = self.passwordTextField.inputTextField.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(importCertificateViewControllerSave:PKCS12Cert:password:config:)]) {
        [self.delegate importCertificateViewControllerSave:self PKCS12Cert:self.filePath.path password:self.password config:config];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
 }

- (void)CAddSignatureViewControllerCancel:(CAddSignatureViewController *)addSignatureViewController {
    [self.digitalSignatureEditViewController refreshViewController];
}

@end
