//
//  CPDFSigntureVerifyDetailsViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CPDFSigntureVerifyDetailsViewController.h"

#import "CNavigationController.h"
#import "CPDFSigntureListViewController.h"
#import "CPDFListView.h"
#import "CPDFSigntureVerifyDetailsCell.h"
#import "CPDFSigntureVerifyDetailsTopCell.h"
#import "CPDFColorUtils.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFSigntureVerifyDetailsViewController ()<UITableViewDelegate,UITableViewDataSource,CPDFSigntureListViewControllerDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UIButton *detailsButton;

@property (nonatomic,strong) NSArray *detailsArray;

@property (nonatomic, assign) BOOL expiredTrust;

@end

@implementation CPDFSigntureVerifyDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Digital Signature Details", nil);
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CPDFViewImageBack" inBundle:[NSBundle bundleForClass:CPDFSigntureVerifyDetailsViewController.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemClicked_back:)];
    self.navigationItem.leftBarButtonItems = @[backItem];
    
    [self detailInfo];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 100) style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CPDFSigntureVerifyDetailsCell class]) bundle:[NSBundle bundleForClass:self.class]] forCellReuseIdentifier:@"cell1"];
    [self.view addSubview:self.tableView];

    self.detailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.detailsButton setTitle:NSLocalizedString(@"View Certificate", nil) forState:UIControlStateNormal];
    [self.detailsButton sizeToFit];
    self.detailsButton.frame = CGRectMake(10, CGRectGetMaxY(self.tableView.frame), self.view.frame.size.width - 20, 40);
    self.detailsButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.detailsButton addTarget:self action:@selector(buttonClickItem_Details:) forControlEvents:UIControlEventTouchUpInside];
    self.detailsButton.layer.cornerRadius = 5.0;
    self.detailsButton.layer.borderWidth = 1.0;
    self.detailsButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
    [self.detailsButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [self.view addSubview:self.detailsButton];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    self.expiredTrust = NO;
}

- (void)detailInfo {
    BOOL isSignVerified = YES;
    BOOL isCertTrusted = YES;
    CPDFSigner *signer = self.signature.signers.firstObject;
    CPDFSignatureCertificate * certificate = signer.certificates.firstObject;
    
    [certificate checkCertificateIsTrusted];
    
    NSDate *currentDate = [NSDate date];
    NSComparisonResult result = [currentDate compare:certificate.validityEnds];
    
    if (!signer.isCertTrusted) {
        isCertTrusted = NO;
    }

    if (!signer.isSignVerified) {
        isSignVerified = NO;
    }
    
    if (result == NSOrderedAscending) {
        self.expiredTrust = YES;
    } else {
        self.expiredTrust = NO;
    }

    NSMutableArray *array = [NSMutableArray array];
    if (!signer.isCertTrusted) {
        isCertTrusted = NO;
        [array addObject:NSLocalizedString(@"The signer's identity is invalid.", nil)];
    } else {
        [array addObject:NSLocalizedString(@"The signer's identity is valid.", nil)];
    }

    if (!signer.isSignVerified) {
        isSignVerified = NO;
    }
        
    if (isSignVerified && isCertTrusted) {
        [array addObject:NSLocalizedString(@"The signature is valid.", nil)];
    } else if(isSignVerified && !isCertTrusted) {
        [array addObject:NSLocalizedString(@"Signature validity is unknown because it has not been included in your list of trusted certificates and none of its parent certificates are trusted certificates.", nil)];
    } else if(!isSignVerified && !isCertTrusted){
        [array addObject:NSLocalizedString(@"The signature is invalid.", nil)];
    } else {
        [array addObject:NSLocalizedString(@"The signature is invalid.", nil)];
    }
    
    BOOL isNoExpired = YES;

    for (CPDFSignatureCertificate *certificate in signer.certificates) {
        NSComparisonResult result = [currentDate compare:certificate.validityEnds];
        if(result == NSOrderedDescending) {
            isNoExpired = NO;
            break;
        }
    }
        
    if(!isNoExpired) {
        [array addObject:NSLocalizedString(@"The file was signed with a certificate that has expired. If you acquired this file recently, it may not be authentic.", nil)];
    }
    
    if(self.signature.modifyInfos.count > 0) {
        [array addObject:NSLocalizedString(@"The document has been altered or corrupted since it was signed by the current user.", nil)];
    } else {
        [array addObject:NSLocalizedString(@"The document has not been modified since this signature was applied.", nil)];
    }
    self.detailsArray = array;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.detailsButton.frame = CGRectMake(10, CGRectGetMaxY(self.tableView.frame), self.view.frame.size.width - 20, 40);

}

- (void)buttonItemClicked_back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else {
        return self.detailsArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFSigner *signer = self.signature.signers.firstObject;
    CPDFSignatureCertificate * cer = signer.certificates.firstObject;
    if(indexPath.section == 0) {
        CPDFSigntureVerifyDetailsTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        if (!cell) {
            cell = [[CPDFSigntureVerifyDetailsTopCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell2"];
        }
        if(indexPath.row == 0) {
            cell.nameLabel.text = NSLocalizedString(@"Signer:", nil);
            cell.countLabel.text = self.signature.name;
        } else {
            cell.nameLabel.text = NSLocalizedString(@"Signer Time:", nil);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            cell.countLabel.text = [dateFormatter stringFromDate:self.signature.date]?:@"";
        }
        return cell;
    } else {
        CPDFSigntureVerifyDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        if (!cell) {
            cell = [[CPDFSigntureVerifyDetailsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell1"];
        }
        cell.titleLabel.text = [self.detailsArray objectAtIndex:indexPath.row];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 20)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    UILabel *sublabel = [[UILabel alloc] init];
    sublabel.font = [UIFont boldSystemFontOfSize:10];
    if (@available(iOS 13.0, *)) {
        sublabel.textColor = [UIColor labelColor];
    } else {
        sublabel.textColor = [UIColor blackColor];
    }
    [sublabel sizeToFit];
    sublabel.frame = CGRectMake(10, 0,
                                view.bounds.size.width - 20, view.bounds.size.height);
    sublabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    view.contentView.backgroundColor = [CPDFColorUtils CMessageLabelColor];
    [view.contentView addSubview:sublabel];
    
    view.backgroundColor = [CPDFColorUtils CMessageLabelColor];

    if(section == 0) {
        sublabel.text = NSLocalizedString(@"Signatures",nil);
    } else if (section == 1) {
        sublabel.text = NSLocalizedString(@"Certification Authority Statement",nil);

    }
    return view;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action

- (void)buttonClickItem_Details:(id)sender {
    CPDFSigner *signer = self.signature.signers.firstObject;
    CPDFSigntureListViewController *vc = [[CPDFSigntureListViewController alloc] init];
    vc.delegate = self;
    CNavigationController *nav = [[CNavigationController alloc]initWithRootViewController:vc];
    vc.signer = signer;
    [self presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark - CPDFSigntureListViewControllerDelegate

- (void)signtureListViewControllerUpdate:(CPDFSigntureListViewController *)signtureListViewController {
    [self detailInfo];
    [self.tableView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(signtureVerifyDetailsViewControllerUpdate:)]) {
        [self.delegate signtureVerifyDetailsViewControllerUpdate:self];
    }
}

@end
