//
//  CCreateCertificateViewController.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CCreateCertificateInfoViewController.h"
#import "CPDFColorUtils.h"
#import "CHeaderView.h"
#import "CInputTextField.h"
#import "CCreateCertificateViewPasswordController.h"
#include "CDigitalPropertyTableView.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CCreateCertificateInfoViewController () <CHeaderViewDelegate,CInputTextFieldDelegate,CCreateCertificateViewControllerDelegate,CDigitalPropertyTableViewDelegate>

@property (nonatomic, strong) CHeaderView *headerView;

@property (nonatomic, strong) CInputTextField *nameTextField;

@property (nonatomic, strong) CInputTextField *unitTextField;

@property (nonatomic, strong) CInputTextField *unitNameTextField;

@property (nonatomic, strong) CInputTextField *emailTextField;

@property (nonatomic, strong) CInputTextField *countryTextField;

@property (nonatomic, strong) UIButton *countryBtn;

@property (nonatomic, strong) CInputTextField *purposeTextField;

@property (nonatomic, strong) UIButton *purposeBtn;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UILabel *saveLabel;

@property (nonatomic, strong) UISwitch *saveSwitch;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *OKBtn;

@property (nonatomic, strong) NSArray * codes;

@property (nonatomic, strong) NSArray *coutryCodes;

@property (nonatomic, strong) NSString *coutryCode;

@property (nonatomic, strong) CPDFSignatureWidgetAnnotation *annotation;

@property (nonatomic, strong)  CDigitalPropertyTableView *coutryPropertyTableView;

@property (nonatomic, strong)  CDigitalPropertyTableView *purposePropertyTableView;

@end

@implementation CCreateCertificateInfoViewController

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
    self.headerView.titleLabel.text = NSLocalizedString(@"Create A Self-Signed Digital ID", nil);
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
    self.messageLabel.text = NSLocalizedString(@"Digital IDs that are self-signed by individuals do not provide the assurance that the identifying information is valid. For this reason, they may not be accepted in some cases.", nil);
    self.messageLabel.adjustsFontSizeToFitWidth = YES;
    self.messageLabel.backgroundColor = [CPDFColorUtils CMessageLabelColor];
    [self.messageLabel sizeToFit];
    [self.scrollView addSubview:self.messageLabel];
    
    self.nameTextField = [[CInputTextField alloc] init];
    self.nameTextField.delegate = self;
    self.nameTextField.titleLabel.attributedText = [self mergeAttributeString:NSLocalizedString(@"Names", nil)];
    self.nameTextField.inputTextField.placeholder = NSLocalizedString(@"Please enter your name", nil);
    [self.scrollView addSubview:self.nameTextField];
    
    self.unitTextField = [[CInputTextField alloc] init];
    self.unitTextField.delegate = self;
    self.unitTextField.titleLabel.text = NSLocalizedString(@"Organization Unit", nil);
    self.unitTextField.inputTextField.placeholder = NSLocalizedString(@"Enter the name of the organization unit", nil);
    [self.scrollView addSubview:self.unitTextField];
    
    self.unitNameTextField = [[CInputTextField alloc] init];
    self.unitNameTextField.delegate = self;
    self.unitNameTextField.titleLabel.text = NSLocalizedString(@"Organization Name", nil);
    self.unitNameTextField.inputTextField.placeholder = NSLocalizedString(@"Enter the name of the organization", nil);
    [self.scrollView addSubview:self.unitNameTextField];
    
    self.emailTextField = [[CInputTextField alloc] init];
    self.emailTextField.delegate = self;
    self.emailTextField.titleLabel.attributedText = [self mergeAttributeString:NSLocalizedString(@"Email Address", nil)];
    self.emailTextField.inputTextField.placeholder = NSLocalizedString(@"Please enter your email address", nil);
    [self.scrollView addSubview:self.emailTextField];
    
    self.countryTextField = [[CInputTextField alloc] init];
    self.countryTextField.delegate = self;
    UIView *hiddenView1 = [[UIView alloc] initWithFrame:CGRectZero];
    self.countryTextField.inputTextField.inputView = hiddenView1;
    self.countryTextField.titleLabel.text = NSLocalizedString(@"Country Region", nil);
    self.countryTextField.inputTextField.text = NSLocalizedString(@"CN - China mainland", nil);
    [self.scrollView addSubview:self.countryTextField];
    
    self.countryBtn = [[UIButton alloc] init];
    self.countryBtn.backgroundColor = [UIColor clearColor];
    [self.countryBtn addTarget:self action:@selector(buttonItemClicked_country:) forControlEvents:UIControlEventTouchUpInside];
    [self.countryTextField addSubview:self.countryBtn];
    
    self.purposeTextField = [[CInputTextField alloc] init];
    self.purposeTextField.delegate = self;
    UIView *hiddenView2 = [[UIView alloc] initWithFrame:CGRectZero];
    self.purposeTextField.inputTextField.inputView = hiddenView2;
    self.purposeTextField.titleLabel.text = NSLocalizedString(@"Purpose", nil);
    self.purposeTextField.inputTextField.text = NSLocalizedString(@"Digital Signatures", nil);
    [self.scrollView addSubview:self.purposeTextField];
    
    self.purposeBtn = [[UIButton alloc] init];
    self.purposeBtn.backgroundColor = [UIColor clearColor];
    [self.purposeBtn addTarget:self action:@selector(buttonItemClicked_purpose:) forControlEvents:UIControlEventTouchUpInside];
    [self.purposeTextField addSubview:self.purposeBtn];
    
    self.saveLabel = [[UILabel alloc] init];
    self.saveLabel.text = NSLocalizedString(@"Save to File", nil);
    [self.scrollView addSubview:self.saveLabel];
    
    self.saveSwitch = [[UISwitch alloc] init];
    [self.saveSwitch addTarget:self action:@selector(selectChange_switch:) forControlEvents:UIControlEventValueChanged];
    self.saveSwitch.on = YES;
    [self.scrollView addSubview:self.saveSwitch];
    
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
    
    self.codes = [NSArray array];
    self.coutryCodes = [NSArray array];
    self.coutryCode = @"CN";
    [self reloadData];
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
    } else {
       
        self.scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame)+5, self.view.frame.size.width, self.view.frame.size.height + 400);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+850);
    }
   
    self.messageLabel.frame = CGRectMake(25+left, 20, self.view.frame.size.width - 50 - left - right, 90);
    self.nameTextField.frame = CGRectMake(25+left, CGRectGetMaxY(self.messageLabel.frame), self.view.frame.size.width - 50-left - right, 90);
    self.unitTextField.frame = CGRectMake(25+left, CGRectGetMaxY(self.nameTextField.frame), self.view.frame.size.width - 50-left - right, 90);
    self.unitNameTextField.frame = CGRectMake(25+left, CGRectGetMaxY(self.unitTextField.frame), self.view.frame.size.width - 50-left - right, 90);
    self.emailTextField.frame = CGRectMake(25+left, CGRectGetMaxY(self.unitNameTextField.frame), self.view.frame.size.width - 50-left - right, 90);
    self.countryTextField.frame = CGRectMake(25+left, CGRectGetMaxY(self.emailTextField.frame), self.view.frame.size.width - 50-left - right, 90);
    self.purposeTextField.frame = CGRectMake(25+left, CGRectGetMaxY(self.countryTextField.frame), self.view.frame.size.width - 50-left - right, 90);
    self.saveLabel.frame = CGRectMake(25+left, CGRectGetMaxY(self.purposeTextField.frame), 100, 50);
    self.saveSwitch.frame = CGRectMake(self.view.frame.size.width - 75 -right, CGRectGetMaxY(self.purposeTextField.frame)+5, 50, 50);
    self.OKBtn.frame = CGRectMake(25+left, CGRectGetMaxY(self.saveLabel.frame)+10, self.view.frame.size.width - 50 -left - right, 50);
    self.countryBtn.frame = self.countryTextField.bounds;
    self.purposeBtn.frame = self.purposeTextField.bounds;
    
    if (self.coutryPropertyTableView) {
        self.coutryPropertyTableView.frame = self.view.frame;
    }
    
    if (self.purposePropertyTableView) {
        self.purposePropertyTableView.frame = self.view.frame;
    }
}

#pragma mark - CHeaderViewDelegate

- (void)CHeaderViewBack:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)CHeaderViewCancel:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CCreateCertificateViewControllerDelegate

- (void)createCertificateViewController:(CCreateCertificateViewPasswordController *)createCertificateViewController PKCS12Cert:(nonnull NSString *)path password:(nonnull NSString *)password config:(nonnull CPDFSignatureConfig *)config {
    if (self.delegate && [self.delegate respondsToSelector:@selector(createCertificateInfoViewControllerSave:PKCS12Cert:password:config:)]) {
        [self.delegate createCertificateInfoViewControllerSave:self PKCS12Cert:path password:password config:config];
    }
}

- (void)createCertificateViewPasswordControllerCancel:(CCreateCertificateViewPasswordController *)createCertificateViewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(createCertificateInfoViewControllerCancel:)]) {
        [self.delegate createCertificateInfoViewControllerCancel:self];
    }
}

#pragma mark - CInputTextFieldDelegate

- (void)setCInputTextFieldBegin:(CInputTextField *)inputTextField {
    
    if (self.countryTextField == inputTextField) {
        
        
    } else if (self.purposeTextField == inputTextField) {
       
    }
    
}

- (void)setCInputTextFieldChange:(CInputTextField *)inputTextField text:(NSString *)text {
    if ((self.nameTextField.inputTextField.text.length > 0) && (self.emailTextField.inputTextField.text.length > 0)) {
        self.OKBtn.backgroundColor = [UIColor blueColor];
        self.OKBtn.enabled = YES;
    } else {
        self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.OKBtn.enabled = NO;
    }
}

#pragma mark - Private Methodds

- (void)reloadData {
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    self.codes = countryCodes;
    NSMutableArray * codes = [NSMutableArray array];

    NSString *localeID = [NSLocale currentLocale].localeIdentifier;
    NSDictionary *components = [NSLocale componentsFromLocaleIdentifier:localeID];

    NSString *countryCode  = components[NSLocaleCountryCode];

    for (NSString *countryCode in countryCodes) {
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSString *country = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"] displayNameForKey: NSLocaleIdentifier value: identifier];
        [codes addObject:[NSString stringWithFormat:@"%@ - %@",countryCode,country]?:@""];
    }

    self.coutryCodes = [NSArray arrayWithArray:codes];
    
    NSInteger dex = [countryCodes indexOfObject:countryCode];
    if (dex >= 0 && dex < countryCodes.count) {
        
    }
    
    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
    
    NSString *loginName = CPDFKitConfig.sharedInstance.annotationAuthor ?: NSFullUserName();
    self.nameTextField.inputTextField.text = loginName ? : @"";
    self.unitTextField.inputTextField.text = [sud stringForKey:@"CAuthenticationDepartment"] ? : @"";
    self.unitNameTextField.inputTextField.text = [sud stringForKey:@"CAuthenticationCompanyName"] ? : @"";
    self.emailTextField.inputTextField.text = [sud stringForKey:@"CAuthenticationEmailAddress"]?: @"";
}

- (BOOL)validateEmail:(NSString *) strEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:strEmail];
}

- (void)popoverWarning {
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil)
                                                                   message:NSLocalizedString(@"Your message conforms to the format of an email.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)tagString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SS"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}

- (NSMutableAttributedString *)mergeAttributeString:(NSString *)normalText {
    NSString *requiredText = @"*";

 
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:normalText];

    NSMutableAttributedString *requiredAttributedText = [[NSMutableAttributedString alloc] initWithString:requiredText];
    [requiredAttributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, requiredAttributedText.length)];

    [attributedText appendAttributedString:requiredAttributedText];
    return attributedText;
}

#pragma mark - Action

- (void)buttonItemClicked_ok:(UIButton *)button {
    
    if (![self validateEmail:self.emailTextField.inputTextField.text] ) {
        [self popoverWarning];
        return;
    }
    
    NSMutableDictionary * cer = [NSMutableDictionary dictionary];
    [cer setValue:self.nameTextField.inputTextField.text forKey:@"CN"];
    [cer setValue:self.emailTextField.inputTextField.text forKey:@"emailAddress"];
    [cer setValue:self.coutryCode forKey:@"C"];
    
    if (self.unitTextField.inputTextField.text.length > 0) {
        [cer setValue:self.unitTextField.inputTextField.text forKey:@"OU"];
    }
    
    if (self.unitNameTextField.inputTextField.text.length > 0) {
        [cer setValue:self.unitNameTextField.inputTextField.text forKey:@"O"];
    }
    
    NSArray *purposes = @[NSLocalizedString(@"Digital Signatures", nil),NSLocalizedString(@"Data Encryption", nil),NSLocalizedString(@"Digital Signatures and Data Encryption", nil)];
    NSInteger certUsage = [purposes indexOfObject:self.purposeTextField.inputTextField.text];
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *writeDirectoryPath = [NSString stringWithFormat:@"%@/%@", path, @"Signature"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:writeDirectoryPath])
        [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:writeDirectoryPath] withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *currentDateString = [self tagString];
    
    NSString *writeFilePath = [NSString stringWithFormat:@"%@/%@-%@.pfx",writeDirectoryPath,@"CSignature",currentDateString];
    
//    BOOL save = [CPDFSignature generatePKCS12CertWithInfo:cer password:@"1" toPath:writeFilePath certUsage:CPDFCertUsageDigSig];
    
    CCreateCertificateViewPasswordController *createCertificateViewPasswordController = [[CCreateCertificateViewPasswordController alloc] initWithAnnotation:self.annotation];
    createCertificateViewPasswordController.delegate = self;
    createCertificateViewPasswordController.isSaveFile = self.saveSwitch.isOn;
    createCertificateViewPasswordController.certUsage = certUsage;
    createCertificateViewPasswordController.certificateInfo = cer;
    createCertificateViewPasswordController.filePath = writeFilePath;
    [self presentViewController:createCertificateViewPasswordController animated:YES completion:nil];
}

- (void)buttonItemClicked_country:(UIButton *)button {
    self.coutryPropertyTableView = [[CDigitalPropertyTableView alloc] initWithFrame:self.view.frame height:300];
    self.coutryPropertyTableView.dataArray = self.coutryCodes;
    self.coutryPropertyTableView.data = self.countryTextField.inputTextField.text;
    self.coutryPropertyTableView.delegate = self;
    self.coutryPropertyTableView.frame = self.view.frame;
    [self.coutryPropertyTableView showinView:self.view];
}

- (void)buttonItemClicked_purpose:(UIButton *)button {
    self.purposePropertyTableView = [[CDigitalPropertyTableView alloc] initWithFrame:self.view.frame height:150];
    self.purposePropertyTableView.dataArray = @[NSLocalizedString(@"Digital Signatures", nil),NSLocalizedString(@"Data Encryption", nil),NSLocalizedString(@"Digital Signatures and Data Encryption", nil)];
    self.purposePropertyTableView.data = self.purposeTextField.inputTextField.text;
    self.purposePropertyTableView.delegate = self;
    self.purposePropertyTableView.frame = self.view.frame;
    [self.purposePropertyTableView showinView:self.view];
}

- (void)selectChange_switch:(UISwitch *)sender {
    
}

#pragma mark - CDigitalPropertyTableViewDelegate

- (void)digitalPropertyTableViewSelect:(CDigitalPropertyTableView *)digitalPropertyTableView text:(NSString *)text index:(NSInteger)index {
    if (self.coutryPropertyTableView == digitalPropertyTableView) {
        self.countryTextField.inputTextField.text = text;
        self.coutryCode = self.codes[index];
        [self.countryTextField.inputTextField resignFirstResponder];
    } else if (self.purposePropertyTableView == digitalPropertyTableView) {
        self.purposeTextField.inputTextField.text = text;
        [self.purposeTextField.inputTextField resignFirstResponder];
    }
}


#pragma mark - NSNotification

- (void)keyboardwillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = value.CGRectValue;
    CGRect rect = [self.emailTextField.inputTextField convertRect:self.emailTextField.frame toView:self.view];
    if(CGRectGetMaxY(rect) > self.view.frame.size.height - frame.size.height) {
        UIEdgeInsets insets = self.scrollView.contentInset;
        insets.bottom = frame.size.height + self.emailTextField.frame.size.height;
        self.scrollView.contentInset = insets;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom = 0;
    self.scrollView.contentInset = insets;
}


@end
