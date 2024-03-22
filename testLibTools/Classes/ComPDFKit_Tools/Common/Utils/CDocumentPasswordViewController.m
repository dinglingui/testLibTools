//
//  CDocumentPasswordViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CDocumentPasswordViewController.h"
#import "CPDFColorUtils.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CDocumentPasswordViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UIImageView *passwordImageView;

@property (nonatomic, strong) UILabel *titleLablel;

@property (nonatomic, strong) UIView *enterView;

@property (nonatomic, strong) UILabel *passLabel;

@property (nonatomic, strong) UIView *splitVidew;

@property (nonatomic, strong) UITextField *enterTextField;

@property (nonatomic, strong) UILabel *warningLabel;

@property (nonatomic, strong) UIButton *OKBtn;

@property (nonatomic, strong) CPDFDocument *document;

@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation CDocumentPasswordViewController

#pragma mark - Initializers

- (instancetype)initWithDocument:(CPDFDocument *)document {
    if (self = [super init]) {
        self.document = document;
    }
    return self;
}


#pragma mark - UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[UIImage imageNamed:@"CDocumentPasswordImageBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    self.passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CDocumentPasswordImagePassword" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
    [self.view addSubview:self.passwordImageView];
    
    self.titleLablel = [[UILabel alloc] init];
    self.titleLablel.text = NSLocalizedString(@"Please Enter The Password", nil);
    self.titleLablel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:self.titleLablel];
    
    self.enterView = [[UIView alloc] init];
    [self.view addSubview:self.enterView];
    [self initEnterView];
    
    self.warningLabel = [[UILabel alloc] init];
    self.warningLabel.text = NSLocalizedString(@"Wrong Password", nil);
    self.warningLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.warningLabel];
    self.warningLabel.hidden = YES;

    self.OKBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.OKBtn setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.OKBtn addTarget:self action:@selector(buttonItemClicked_ok:) forControlEvents:UIControlEventTouchUpInside];
    [self.OKBtn setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
    [self.view addSubview:self.OKBtn];
    
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
}

- (void)viewWillLayoutSubviews {
    if (@available(iOS 11.0, *)) {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - self.view.safeAreaInsets.right - 70, self.view.safeAreaInsets.top, 50, 50);
        self.passwordImageView.frame = CGRectMake((self.view.frame.size.width - 100)/2, CGRectGetMaxY(self.backBtn.frame), 100, 100);
        self.titleLablel.frame = CGRectMake((self.view.frame.size.width - 200)/2, CGRectGetMaxY(self.passwordImageView.frame), 200, 50);
        self.enterView.frame = CGRectMake((self.view.frame.size.width - 300)/2, CGRectGetMaxY(self.titleLablel.frame), 300, 60);
        self.warningLabel.frame = CGRectMake((self.view.frame.size.width - 300)/2, CGRectGetMaxY(self.enterView.frame), 300, 40);
        self.OKBtn.frame = CGRectMake((self.view.frame.size.width - 300)/2, CGRectGetMaxY(self.warningLabel.frame), 300, 60);
    } else {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 65, 50, 50);
        self.passwordImageView.frame = CGRectMake((self.view.frame.size.width - 100)/2, CGRectGetMaxY(self.backBtn.frame), 100, 100);
        self.titleLablel.frame = CGRectMake((self.view.frame.size.width - 100)/2, CGRectGetMaxY(self.passwordImageView.frame), 200, 50);
        self.enterView.frame = CGRectMake((self.view.frame.size.width - 300)/2, CGRectGetMaxY( self.titleLablel.frame), 300, 60);
        self.warningLabel.frame = CGRectMake((self.view.frame.size.width - 300)/2, CGRectGetMaxY(self.enterView.frame), 300, 40);
        self.OKBtn.frame = CGRectMake((self.view.frame.size.width - 300)/2, CGRectGetMaxY(self.warningLabel.frame), 300, 60);
    }
    self.passLabel.frame = CGRectMake(0, 0, 80, self.enterView.frame.size.height-1);
    self.enterTextField.frame = CGRectMake(80, 0, self.enterView.frame.size.width-80, self.enterView.frame.size.height-1);
    self.splitVidew.frame = CGRectMake(0, self.enterView.frame.size.height-1, self.enterView.frame.size.width, 1);
    self.clearButton.frame = CGRectMake(self.enterView.frame.size.width-30, (self.enterView.frame.size.height-24)/2, 24, 24);
}

#pragma mark - Private Methods

- (void)initEnterView {
    self.passLabel = [[UILabel alloc] init];
    self.passLabel.text = NSLocalizedString(@"Password", nil);
    [self.enterView addSubview:self.passLabel];
    
    self.enterTextField = [[UITextField alloc] init];
    self.enterTextField.borderStyle = UITextBorderStyleNone;
    self.enterTextField.secureTextEntry = YES;
    self.enterTextField.delegate = self;
    self.enterTextField.font = [UIFont systemFontOfSize:13];
    self.enterTextField.returnKeyType = UIReturnKeyDone;
    self.enterTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    self.enterTextField.leftViewMode = UITextFieldViewModeAlways;
    self.enterTextField.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    self.enterTextField.rightViewMode = UITextFieldViewModeAlways;
    self.enterTextField.placeholder = NSLocalizedString(@"Please enter the password", nil);
    [self.enterTextField becomeFirstResponder];
    [self.enterTextField addTarget:self action:@selector(textField_change:) forControlEvents:UIControlEventEditingChanged];
    [self.enterView addSubview:self.enterTextField];
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clearButton.layer.cornerRadius = 12;
    self.clearButton.layer.masksToBounds = YES;
    [self.clearButton setImage:[UIImage imageNamed:@"CDocumentPasswordImageClear" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.clearButton addTarget:self action:@selector(buttonItemClicked_clear:) forControlEvents:UIControlEventTouchUpInside];
    [self.enterView addSubview:self.clearButton];
    self.clearButton.hidden = YES;
    
    self.splitVidew = [[UIView alloc] init];
    self.splitVidew.backgroundColor = [CPDFColorUtils CTableviewCellSplitColor];
    [self.enterView addSubview:self.splitVidew];
}

#pragma mark - Action

- (void)buttonItemClicked_back:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(documentPasswordViewControllerCancel:)]) {
            [self.delegate documentPasswordViewControllerCancel:self];
        }
    }];
}

- (void)buttonItemClicked_ok:(UIButton *)button {
    if ([self.document unlockWithPassword:self.enterTextField.text]) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(documentPasswordViewControllerOpen:document:)]) {
                [self.delegate documentPasswordViewControllerOpen:self document:self.document];
            }
        }];
    } else {
        self.warningLabel.hidden = NO;
    }
}

- (void)buttonItemClicked_clear:(UIButton *)button {
    self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.warningLabel.hidden = YES;
    self.enterTextField.text = @"";
    self.clearButton.hidden = YES;
}

- (void)textField_change:(UITextField *)sender {
    if ([sender.text length] == 0) {
        self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.warningLabel.hidden = YES;
        self.clearButton.hidden = YES;
    } else {
        self.OKBtn.backgroundColor = [UIColor blueColor];
        self.clearButton.hidden = NO;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.OKBtn.backgroundColor = [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:255.0/255.0 alpha:1.0];
    self.warningLabel.hidden = YES;
    return YES;
}

@end
