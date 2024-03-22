//
//  CPDFFormBaseViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormBaseViewController.h"
#import "CPDFColorUtils.h"

@interface CPDFFormBaseViewController ()

@property (nonatomic, strong) UIView * splitView;

@property (nonatomic, strong) UIButton * kisButton;
@end

@implementation CPDFFormBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView = [[UIView alloc] init];
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.splitView = [[UIView alloc] init];
    self.splitView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:self.splitView];
    
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
    [self.view addSubview:self.backBtn];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
    self.scrcollView.frame = CGRectMake(0, 50, self.view.frame.size.width, 210);
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 330);
    if (@available(iOS 11.0, *)) {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 0, 50,50);
        self.splitView.frame = CGRectMake(0, 49, self.view.bounds.size.width, 1);
    } else {
        self.splitView.frame = CGRectMake(0, 49, self.view.bounds.size.width, 1);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 420);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self commomInitTitle];
}

- (void)commomInitTitle {
    self.titleLabel.text = NSLocalizedString(@"Note", nil);
}
#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
