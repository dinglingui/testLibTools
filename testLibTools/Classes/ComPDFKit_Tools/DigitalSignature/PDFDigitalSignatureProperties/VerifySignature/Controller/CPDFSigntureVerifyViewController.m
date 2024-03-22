//
//  CPDFSigntureVerifyViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CPDFSigntureVerifyViewController.h"

#import "CPDFSigntureListViewController.h"
#import "CPDFSigntureVerifyDetailsViewController.h"
#import "CNavigationController.h"

#import "CPDFSigntureVerifyCell.h"
#import "CPDFListView.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFSigntureVerifyViewController () <UITableViewDelegate,UITableViewDataSource,CPDFSigntureVerifyDetailsViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL expiredTrust;

@end

@implementation CPDFSigntureVerifyViewController

#pragma mark - Viewcontroller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Electronic Certificate", nil);
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CPDFViewImageBack" inBundle:[NSBundle bundleForClass:CPDFSigntureVerifyViewController.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemClicked_back:)];
    self.navigationItem.leftBarButtonItems = @[backItem];
    
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 60;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[CPDFSigntureVerifyCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CPDFSigntureVerifyCell class]) bundle:[NSBundle bundleForClass:self.class]] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
 
    self.expiredTrust = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Public Methods

- (void)reloadData {
    [self.tableView reloadData];
}

- (void)buttonItemClicked_back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)stateString:(NSInteger)row{
    CPDFSignature *signature = self.signatures[row];
    CPDFSigner *signer = signature.signers.firstObject;
    CPDFSignatureCertificate * certificate = signer.certificates.firstObject;
    
    BOOL isSignVerified = YES;
    BOOL isCertTrusted = YES;
    
    if (!signer.isCertTrusted) {
        isCertTrusted = NO;
    }

    if (!signer.isSignVerified) {
        isSignVerified = NO;
    }
        
    
    [certificate checkCertificateIsTrusted];
    
    NSDate *currentDate = [NSDate date];
    NSComparisonResult result = [currentDate compare:certificate.validityEnds];
    
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
    
    if(signature.modifyInfos.count > 0) {
        [array addObject:NSLocalizedString(@"The document has been altered or corrupted since it was signed by the current user.", nil)];
    } else {
        [array addObject:NSLocalizedString(@"The document has not been modified since this signature was applied.", nil)];
    }
    NSString *stateString = nil;
    for (NSString *string in array) {
        if(stateString) {
            stateString = [NSString stringWithFormat:@"%@%@",stateString,string];
        } else {
            stateString = string;
        }
    }

    return stateString;

}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.signatures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFSigntureVerifyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
        cell = [[CPDFSigntureVerifyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];

    CPDFSignature *signature = self.signatures[indexPath.row];
    CPDFSigner *signer = signature.signers.firstObject;
    
    BOOL isSignVerified = YES;
    BOOL isCertTrusted = YES;
    
    CPDFSignatureCertificate *certificate = signer.certificates.firstObject;
    [certificate checkCertificateIsTrusted];
    
    NSDate *currentDate = [NSDate date];
    NSComparisonResult result = [currentDate compare:certificate.validityEnds];
    
    if (result == NSOrderedAscending) {
        self.expiredTrust = YES;
    } else {
        self.expiredTrust = NO;
    }
    
    if (!signer.isCertTrusted) {
        isCertTrusted = NO;
    }

    if (!signer.isSignVerified) {
        isSignVerified = NO;
    }
        
    if (isSignVerified && isCertTrusted) {
        cell.verifyImageView.image = [UIImage imageNamed:@"ImageNameSigntureVerifySuccess"
                                          inBundle:[NSBundle bundleForClass:self.class]
                     compatibleWithTraitCollection:nil];
        
    } else if(isSignVerified && !isCertTrusted) {
        cell.verifyImageView.image = [UIImage imageNamed:@"ImageNameSigntureTrustedFailure"
                                          inBundle:[NSBundle bundleForClass:self.class]
                     compatibleWithTraitCollection:nil];
    } else if(!isSignVerified && !isCertTrusted){

        cell.verifyImageView.image = [UIImage imageNamed:@"ImageNameSigntureVerifyFailure"
                                          inBundle:[NSBundle bundleForClass:self.class]
                     compatibleWithTraitCollection:nil];
    } else {
        cell.verifyImageView.image = [UIImage imageNamed:@"ImageNameSigntureVerifyFailure"
                                          inBundle:[NSBundle bundleForClass:self.class]
                     compatibleWithTraitCollection:nil];
    }

    cell.grantorsubLabel.text = signature.name;
    cell.expiredDateSubLabel.text = [dateFormatter stringFromDate:signature.date]?:@"";
    NSString *stateString = [self stateString:indexPath.row];
    cell.stateSubLabel.text = stateString;
    __block typeof(self) blockSelf = self;

    cell.deleteCallback = ^{
        [blockSelf.PDFListView.document removeSignature:signature];
        
        CPDFSignatureWidgetAnnotation *signatureWidgetAnnotation = [signature signatureWidgetAnnotationWithDocument:blockSelf.PDFListView.document];
        [signatureWidgetAnnotation updateAppearanceStream];
        [blockSelf.PDFListView setNeedsDisplayForPage:signatureWidgetAnnotation.page];
        if(blockSelf.signatures.count > 0) {
            NSMutableArray *datas = [NSMutableArray arrayWithArray:blockSelf.signatures];
            if([datas containsObject:signature]) {
                [datas removeObject:signature];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CSignatureHaveChangeDidChangeNotification object:self.PDFListView];
            
            blockSelf.signatures = datas;
            [blockSelf.tableView reloadData];

        }
        
    };
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CPDFSignature *signature = self.signatures[indexPath.row];
    CPDFSigntureVerifyDetailsViewController *vc = [[CPDFSigntureVerifyDetailsViewController alloc] init];
    vc.delegate = self;
    CNavigationController *nav = [[CNavigationController alloc]initWithRootViewController:vc];
    vc.signature = signature;
    [self presentViewController:nav animated:YES completion:nil];

}

-  (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewAutomaticDimension;
}

#pragma mark - CPDFSigntureVerifyDetailsViewControllerDelegate

- (void)signtureVerifyDetailsViewControllerUpdate:(CPDFSigntureVerifyDetailsViewController *)signtureVerifyDetailsViewController {
    [self.tableView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(signtureVerifyViewControllerUpdate:)]) {
        [self.delegate signtureVerifyViewControllerUpdate:self];
    }
}

@end
