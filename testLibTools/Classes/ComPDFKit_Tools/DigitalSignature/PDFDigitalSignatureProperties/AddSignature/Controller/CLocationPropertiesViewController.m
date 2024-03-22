//
//  CLocationPropertiesViewController.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CLocationPropertiesViewController.h"
#import "CHeaderView.h"
#import "CPDFColorUtils.h"
#import "CInputTextField.h"

@interface CLocationPropertiesViewController () <CHeaderViewDelegate,CInputTextFieldDelegate>

@property (nonatomic, strong) CHeaderView *headerView;

@property (nonatomic, strong) UILabel *selectLabel;

@property (nonatomic, strong) UISwitch *selectSwitch;

@property (nonatomic, strong) UIView *splitView;

@property (nonatomic, strong) CInputTextField *locationTextField;

@end

@implementation CLocationPropertiesViewController

#pragma mark - Viewcontroller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.headerView = [[CHeaderView alloc] init];
    self.headerView.titleLabel.text = NSLocalizedString(@"Location", nil);
    self.headerView.cancelBtn.hidden = YES;
    self.headerView.delegate = self;
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.selectLabel = [[UILabel alloc] init];
    self.selectLabel.text = NSLocalizedString(@"Location", nil);
    self.selectLabel.textColor = [UIColor grayColor];
    self.selectLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:self.selectLabel];
    
    self.selectSwitch = [[UISwitch alloc] init];
    [self.selectSwitch addTarget:self action:@selector(selectChange_switch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.selectSwitch];
    
    self.splitView = [[UIView alloc] init];
    self.splitView.backgroundColor = [CPDFColorUtils CMessageLabelColor];
    [self.view addSubview:self.splitView];
    
    self.locationTextField = [[CInputTextField alloc] init];
    self.locationTextField.delegate = self;
    self.locationTextField.titleLabel.text = NSLocalizedString(@"Location", nil);
    if ([self.loactionProperties isEqual:NSLocalizedString(@"Closes",nil)]) {
        self.locationTextField.inputTextField.text = @"";
    } else {
        self.locationTextField.inputTextField.text = self.loactionProperties;
    }
    [self.view addSubview:self.locationTextField];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    if (self.isLocation) {
        [self.selectSwitch setOn:YES];
        self.splitView.hidden = NO;
        self.locationTextField.hidden = NO;
    } else {
        self.splitView.hidden = YES;
        self.locationTextField.hidden = YES;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    self.selectLabel.frame = CGRectMake(25, 50, 100, 50);
    self.selectSwitch.frame = CGRectMake(self.view.frame.size.width - 75, 55, 50, 50);
    self.splitView.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
    self.locationTextField.frame = CGRectMake(25, CGRectGetMaxY(self.splitView.frame), self.view.frame.size.width - 50, 90);
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

#pragma mark - Private Methods

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat mWidth = fmin(width, height);
    CGFloat mHeight = fmax(width, height);
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // This is an iPad
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.8 : mHeight*0.8);
    } else {
        // This is an iPhone or iPod touch
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.9);
    }
}


#pragma mark - Action

- (void)selectChange_switch:(UISwitch *)sender {
    if (sender.isOn) {
        self.locationTextField.hidden = NO;
        self.splitView.hidden = NO;
    } else {
        self.locationTextField.hidden = YES;
        self.splitView.hidden = YES;
    }
}

#pragma mark - CHeaderViewDelegate

- (void)CHeaderViewBack:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(CLocationPropertiesViewController:properties:isLocation:)]) {
        [self.delegate CLocationPropertiesViewController:self properties:self.locationTextField.inputTextField.text isLocation:self.selectSwitch.isOn];
    }
}


#pragma mark - CInputTextFieldDelegate

- (void)setCInputTextFieldChange:(CInputTextField *)inputTextField text:(NSString *)text {
   
}

@end
