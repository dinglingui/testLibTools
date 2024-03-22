//
//  CPDFLinkViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormLinkViewController.h"
#import "CPDFColorUtils.h"
#import "CAnnotStyle.h"

@interface CPDFFormLinkViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) CAnnotStyle *annotStyle;

@property (nonatomic, strong) UIScrollView *scrcollView;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UITextField *pageTextField;

@property (nonatomic, strong) UITextField *urlTextField;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, assign) CPDFFormLinkType linkType;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation CPDFFormLinkViewController

#pragma mark - Initializers

- (instancetype)initWithStyle:(CAnnotStyle *)annotStyle {
    if (self = [super init]) {
        self.annotStyle = annotStyle;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    
    self.headerView = [[UIView alloc] init];
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];

    [self initWithView];
    
   if([self.annotStyle.annotations.firstObject isKindOfClass:[CPDFButtonWidgetAnnotation class]]){
        self.segmentedControl.selectedSegmentIndex = 0;
       CPDFButtonWidgetAnnotation * mAnnotation = (CPDFButtonWidgetAnnotation*)self.annotStyle.annotations.firstObject;
       if([mAnnotation.action isKindOfClass:[CPDFURLAction class]]){
           CPDFURLAction * mAction =(CPDFURLAction*)mAnnotation.action;
           self.linkType = CPDFFormLinkTypeLink;
           self.urlTextField.text = mAction.url;
           if(self.urlTextField.text.length > 0 ) {
               [self.saveButton setEnabled:YES];
               self.saveButton.backgroundColor = [UIColor systemBlueColor];
               [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
           }
       }else if([mAnnotation.action isKindOfClass:[CPDFGoToAction class]]){
           CPDFButtonWidgetAnnotation * mAnnotation = (CPDFButtonWidgetAnnotation*)self.annotStyle.annotations.firstObject;
           CPDFGoToAction * mAction =(CPDFGoToAction*)mAnnotation.action;

           NSUInteger pageIndex = [mAction destination].pageIndex;
           self.linkType = CPDFFormLinkTypePage;
           self.pageTextField.text = [NSString stringWithFormat:@"%@", @(pageIndex+1)];
           self.segmentedControl.selectedSegmentIndex = 1;
           if(self.pageTextField.text.length > 0 ) {
               [self.saveButton setEnabled:YES];
               self.saveButton.backgroundColor = [UIColor systemBlueColor];
               [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
           }
       }else{
           CPDFURLAction * mAction =(CPDFURLAction*)mAnnotation.action;
           self.linkType = CPDFFormLinkTypeLink;
           self.urlTextField.text = mAction.url;
       }

    }
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UITextField *currentTextField = nil;

    switch (_linkType) {
        case CPDFFormLinkTypeLink:
            currentTextField = self.urlTextField;
            break;
        default:
        case CPDFFormLinkTypePage:
            currentTextField = self.pageTextField;
            break;
    }
    
    [currentTextField becomeFirstResponder];
}

- (void)setLinkType:(CPDFFormLinkType)linkType {
    _linkType = linkType;
    
    UITextField *currentTextField = nil;

    switch (_linkType) {
        case CPDFFormLinkTypeLink:
            self.pageTextField.hidden = YES;
            self.urlTextField.hidden = NO;
            currentTextField = self.urlTextField;
            break;
        default:
        case CPDFFormLinkTypePage:
            self.urlTextField.hidden = YES;
            self.pageTextField.hidden = NO;
            currentTextField = self.pageTextField;
            break;
    }
    
    [currentTextField becomeFirstResponder];

    if(currentTextField.text.length > 0) {
        self.saveButton.enabled = YES;
        self.saveButton.backgroundColor = [UIColor systemBlueColor];
        [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.saveButton.enabled = NO;
        self.saveButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [self.saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.titleLabel.frame = CGRectMake(0, 17.5, self.view.frame.size.width, 25.0);
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    
    if (@available(iOS 11.0, *)) {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 50);
    } else {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    }
    
    if (@available(iOS 11.0, *)) {
        _scrcollView.frame = CGRectMake(self.view.safeAreaInsets.left, 50, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height);
    } else {
        _scrcollView.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.scrcollView.contentSize = CGSizeMake(_scrcollView.frame.size.width, self.scrcollView.contentSize.height);
    self.saveButton.frame  = CGRectMake((self.scrcollView.frame.size.width - 120)/2, self.saveButton.frame.origin.y, 120, 32);
    
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}


- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 600);

    [self.urlTextField resignFirstResponder];
    [self.pageTextField resignFirstResponder];

}

#pragma mark - Private

- (void)initWithView {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleLabel.text = NSLocalizedString(@"Link to", nil);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:20];
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.headerView addSubview:_titleLabel];
    
    _scrcollView = [[UIScrollView alloc] init];
    _scrcollView.frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height);
    _scrcollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrcollView.scrollEnabled = YES;
    [self.view addSubview:_scrcollView];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (@available(iOS 11.0, *)) {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 50);
    } else {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    }
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBaseImageBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.backBtn];
    
    CGFloat offstY = 10;
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"URL", nil),NSLocalizedString(@"Page",nil)]];
    _segmentedControl.frame = CGRectMake(30, offstY, self.scrcollView.frame.size.width - 30 *2, 32.0);
    _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged_Mode:) forControlEvents:UIControlEventValueChanged];
    [self.scrcollView addSubview:_segmentedControl];
    offstY +=_segmentedControl.frame.size.height;

    offstY+= 32.0;
    _urlTextField = [[UITextField alloc]initWithFrame:CGRectMake(30.0, offstY, self.scrcollView.frame.size.width - 60.0, 28.0)];
    _urlTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    _urlTextField.layer.borderWidth = 1.0;
    _urlTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _urlTextField.layer.cornerRadius = 5.0;
    _urlTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    _urlTextField.leftViewMode = UITextFieldViewModeAlways;
    _urlTextField.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    _urlTextField.rightViewMode = UITextFieldViewModeAlways;
    _urlTextField.delegate = self;
    _urlTextField.hidden = YES;
    _urlTextField.font = [UIFont systemFontOfSize:18.0];
    _urlTextField.placeholder = @"https://www.compdf.com";
    [self.scrcollView addSubview:_urlTextField];

    
    _pageTextField = [[UITextField alloc]initWithFrame:CGRectMake(30.0, offstY, self.view.frame.size.width - 60.0, 28.0)];
    _pageTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _pageTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    _pageTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _pageTextField.leftViewMode = UITextFieldViewModeAlways;
    _pageTextField.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    _pageTextField.rightViewMode = UITextFieldViewModeAlways;
    _pageTextField.hidden = YES;
    _pageTextField.layer.borderWidth = 1.0;
    _pageTextField.layer.cornerRadius = 5.0;
    _pageTextField.delegate = self;
    _pageTextField.font = [UIFont systemFontOfSize:18.0];
    NSString *str = [NSString stringWithFormat:@"Add a Page Number Between 1~%ld", self.pageCount];
    _pageTextField.placeholder = NSLocalizedString(str, nil);
    [self.scrcollView addSubview:_pageTextField];
    offstY +=_urlTextField.frame.size.height;
    
    [_pageTextField addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    [_urlTextField addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    
    offstY+= 30.0;
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.frame  = CGRectMake((self.scrcollView.frame.size.width - 120)/2, offstY, 120, 32);
    self.saveButton.layer.cornerRadius = 5.0;
    self.saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.saveButton setTitle:NSLocalizedString(@"Save",nil) forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(buttonItemClicked_Save:) forControlEvents:UIControlEventTouchUpInside];
    self.saveButton.backgroundColor = [UIColor systemBlueColor];
    [self.scrcollView addSubview:self.saveButton];

    offstY += self.saveButton.frame.size.height;
    
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardwillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {
    NSString *currentTextField = nil;

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            currentTextField = self.urlTextField.text;
            break;
     
        default:
        case 1:
            currentTextField = self.pageTextField.text;
            break;
    }
    
    BOOL isLink;
    if (!([currentTextField isEqual:@""])) {
        isLink = YES;
    } else {
        isLink = NO;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(linkViewControllerDismiss:isLink:)]) {
            [self.delegate linkViewControllerDismiss:self isLink:isLink];
        }
    }];
}

- (void)segmentedControlValueChanged_Mode:(id)sender {
    UITextField *currentTextField = nil;

    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.linkType = CPDFFormLinkTypeLink;
            currentTextField = self.urlTextField;
            break;
        default:
        case 1:
            self.linkType = CPDFFormLinkTypePage;
            currentTextField = self.pageTextField;
            break;
    }
}

- (void)buttonItemClicked_Save:(id)sender {
    NSString *string = nil;
    if(CPDFFormLinkTypeLink == self.linkType) {
        string = self.urlTextField.text;
        string = [string lowercaseString];
        if (![string hasPrefix:@"https://"] && ![string hasPrefix:@"http://"]) {
            string = [NSString stringWithFormat:@"https://%@",string];
        }

    } else if (CPDFFormLinkTypePage == self.linkType) {
        string = self.pageTextField.text;
        CPDFAnnotation *annotation = self.annotStyle.annotations.firstObject;
        CPDFDocument *document = annotation.page.document;
        
        if([string integerValue] > document.pageCount || [string intValue] < 1) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:NSLocalizedString(@"Config Error", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.pageTextField.text = @"";
            }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:nil];

            return;
        }
        
    }
    if([self.annotStyle.annotations.firstObject isKindOfClass:[CPDFButtonWidgetAnnotation class]]){
        CPDFButtonWidgetAnnotation *mAnnotation = (CPDFButtonWidgetAnnotation*)self.annotStyle.annotations.firstObject;
        
        if(self.linkType == CPDFFormLinkTypeLink){
            CPDFURLAction * urlAction = [[CPDFURLAction alloc] initWithURL:string];
            [mAnnotation setAction:urlAction];
        }else if(self.linkType == CPDFFormLinkTypePage){
            CPDFDestination * destination = [[CPDFDestination alloc] initWithDocument:mAnnotation.page.document pageIndex:[string intValue] - 1];
            CPDFGoToAction * goToAction = [[CPDFGoToAction alloc] initWithDestination:destination];
            [mAnnotation setAction:goToAction];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
            if([self.delegate respondsToSelector:@selector(linkViewController:linkType:linkString:)]) {
                [self.delegate linkViewController:self linkType:self.linkType linkString:string];
            }
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldTextChange:(UITextField *)textField {
    if(textField.text.length > 0) {
        self.saveButton.enabled = YES;
        self.saveButton.backgroundColor = [UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0];
        [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.saveButton.enabled = NO;
        self.saveButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [self.saveButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - NSNotification

- (void)keyboardwillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = value.CGRectValue;
    CGRect rect = [self.urlTextField convertRect:self.urlTextField.frame toView:self.view];
    if(CGRectGetMaxY(rect) > self.view.frame.size.height - frame.size.height) {
        UIEdgeInsets insets = self.scrcollView.contentInset;
        insets.bottom = frame.size.height + self.urlTextField.frame.size.height;
        self.scrcollView.contentInset = insets;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets insets = self.scrcollView.contentInset;
    insets.bottom = 0;
    self.scrcollView.contentInset = insets;
}

@end
