//
//  CPDFSigntureDetailsViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSigntureDetailsViewController.h"
#import "CPDFSigntureDetailsCell.h"
#import "CPDFSigntureDetailsFootView.h"
#import "CPDFSigntureVerifyViewController.h"

@interface CPDFSigntureDetailsViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CPDFSigntureDetailsFootView *footView;

@property (nonatomic, assign) BOOL expiredTrust;

@end

@implementation CPDFSigntureDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Details", nil);
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CPDFViewImageBack" inBundle:[NSBundle bundleForClass:CPDFSigntureDetailsViewController.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemClicked_back:)];
    self.navigationItem.leftBarButtonItems = @[backItem];
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 230)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 60;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CPDFSigntureDetailsCell class]) bundle:[NSBundle bundleForClass:self.class]] forCellReuseIdentifier:@"cell"];

    [self.view addSubview:_tableView];
    
    _footView = [[CPDFSigntureDetailsFootView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tableView.frame) + 5, self.view.bounds.size.width, 225)];
    [_footView.trustedButton addTarget:self action:@selector(buttonItemClick_Trusted:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_footView];
    
    [self updateDatas];
    
    self.expiredTrust = NO;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 230);
    if (@available(iOS 11.0, *)) {
        _footView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(_tableView.frame) + 5, self.view.bounds.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 225);
    } else {
        _footView.frame = CGRectMake(0, CGRectGetMaxY(_tableView.frame) + 5, self.view.bounds.size.width, 225);
    }
}

- (void)buttonItemClicked_back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateDatas {
    [self.tableView reloadData];
    
    NSDate *currentDate = [NSDate date];
    NSComparisonResult result = [currentDate compare:self.certificate.validityEnds];
    
    if (result == NSOrderedAscending) {
        self.expiredTrust = YES;
    } else {
        self.expiredTrust = NO;
    }
    
    if(self.certificate.isTrusted) {
        _footView.certifyImage.image = _footView.dataImage.image = [UIImage imageNamed:@"ImageNameSigntureTrustedIcon"
                                                                              inBundle:[NSBundle bundleForClass:self.class]
                                                         compatibleWithTraitCollection:nil];
        self.footView.trustedButton.enabled = NO;
        [self.footView.trustedButton setTitleColor:[UIColor systemGrayColor] forState:UIControlStateNormal];
        self.footView.trustedButton.layer.borderColor = [UIColor systemGrayColor].CGColor;
    } else {
        _footView.certifyImage.image = _footView.dataImage.image = [UIImage imageNamed:@"ImageNameSigntureTrustedFailureIcon"
                                                                              inBundle:[NSBundle bundleForClass:self.class]
                                                         compatibleWithTraitCollection:nil];
        self.footView.trustedButton.enabled = YES;
        
        [self.footView.trustedButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        self.footView.trustedButton.layer.borderColor = [UIColor systemBlueColor].CGColor;

    }
}

#pragma mark Action

- (void)buttonItemClick_Trusted:(id)sender {
    BOOL success = [self.certificate addToTrustedCertificates];
    if (success) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CSignatureTrustCerDidChangeNotification object:nil];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Trusted certificate Succeeded!", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateDatas];
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:addAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(signtureDetailsViewControllerTrust:)]) {
            [self.delegate signtureDetailsViewControllerTrust:self];
        }
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Trusted certificate Failure!", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:addAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 5;
    } else  {
        return 18;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFSigntureDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CPDFSigntureDetailsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSString * titleLabelString;
    NSString * content;
    NSString *string;
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {
            titleLabelString = NSLocalizedString(@"Issued to:", nil);
            string = [self.certificate.subject stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
            content = string;
        } else if (indexPath.row == 1) {
            titleLabelString = NSLocalizedString(@"Issuer:", nil);
            string = [self.certificate.issuer stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
            content = string;
        } else if (indexPath.row == 2) {
            titleLabelString = NSLocalizedString(@"Valid from:", nil);
            content = [dateFormatter stringFromDate:self.certificate.validityStarts];
        }else if (indexPath.row == 3) {
            titleLabelString = NSLocalizedString(@"Valid to:", nil);
            content = [dateFormatter stringFromDate:self.certificate.validityEnds];
        } else if (indexPath.row == 4) {
            NSMutableArray *innerAtt = [NSMutableArray array];
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeEncipherOnly) {
                [innerAtt addObject:NSLocalizedString(@"Encipher Only",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeCRLSignature) {
                [innerAtt addObject:NSLocalizedString(@"CRL Signature",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeCertificateSignature) {
                [innerAtt addObject:NSLocalizedString(@"Certificate Signature",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeKeyAgreement) {
                [innerAtt addObject:NSLocalizedString(@"Key Agreement",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeDataEncipherment) {
                [innerAtt addObject:NSLocalizedString(@"Data Encipherment",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeKeyEncipherment) {
                [innerAtt addObject:NSLocalizedString(@"Key Encipherment",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeNonRepudiation) {
                [innerAtt addObject:NSLocalizedString(@"Non-Repudiation",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeDigitalSignature) {
                [innerAtt addObject:NSLocalizedString(@"Digital Signature",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeDDecipherOnly) {
                [innerAtt addObject:NSLocalizedString(@"Decipher Only",nil)];
            }
            NSString *innerUsageString;
            for (NSString *usz in innerAtt) {
                NSString *us = usz;
                if (us) {
                    if (!innerUsageString) {
                        innerUsageString = NSLocalizedString(us, nil);
                    } else {
                        us = NSLocalizedString(us, nil);
                        innerUsageString = [NSString stringWithFormat:@"%@,%@",innerUsageString,us];
                    }
                }
            }
            titleLabelString = NSLocalizedString(@"Intended Usage:", nil);
            content = innerUsageString;
            
        }
    } else if (indexPath.section == 1)  {
        if (indexPath.row == 0) {
            titleLabelString = NSLocalizedStringFromTable(@"Version:", @"Signture", nil);
            content = self.certificate.version;
        }else if (indexPath.row == 1){
            titleLabelString = NSLocalizedString(@"Algorithm:", nil);
            
            switch (self.certificate.signatureAlgorithmType) {
                case CPDFSignatureAlgorithmTypeRSA_RSA:
                    content = [NSString stringWithFormat:@"%@(%@)",@"RSA_RSA",self.certificate.signatureAlgorithmOID];

                    break;
                case CPDFSignatureAlgorithmTypeMD2RSA:
                    content = [NSString stringWithFormat:@"%@(%@)",@"MD2RSA",self.certificate.signatureAlgorithmOID];

                    break;
                case CPDFSignatureAlgorithmTypeMD4RSA:
                    content = [NSString stringWithFormat:@"%@(%@)",@"MD4RSA",self.certificate.signatureAlgorithmOID];

                    break;
                case CPDFSignatureAlgorithmTypeSHA1RSA:
                    content = [NSString stringWithFormat:@"%@(%@)",@"SHA1RSA",self.certificate.signatureAlgorithmOID];

                    break;
                case CPDFSignatureAlgorithmTypeSHA256RSA:
                    content = [NSString stringWithFormat:@"%@(%@)",@"SHA256RSA",self.certificate.signatureAlgorithmOID];

                    break;
                default:
                case CPDFSignatureAlgorithmTypeSM3SM2:
                    content = [NSString stringWithFormat:@"%@(%@)",@"SM3SM2",self.certificate.signatureAlgorithmOID];

                    break;
            }
        } else if (indexPath.row == 2){
            titleLabelString = NSLocalizedString(@"Subject:", nil);
            content = [self.certificate.subject stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
        } else if (indexPath.row == 3){
            titleLabelString = NSLocalizedString(@"Issuer:", nil);
            NSString * string = [self.certificate.issuer stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
            content = string;
        } else if (indexPath.row == 4){
            titleLabelString = NSLocalizedString(@"Serial number:", nil);
            content = self.certificate.serialNumber;
        } else if (indexPath.row == 5){
            titleLabelString = NSLocalizedString(@"Valid from:", nil);
            content = [dateFormatter stringFromDate:self.certificate.validityStarts];
        } else if (indexPath.row == 6){
            titleLabelString = NSLocalizedString(@"Valid to:", nil);
            content = [dateFormatter stringFromDate:self.certificate.validityEnds];
        } else if (indexPath.row == 7) {
            titleLabelString = NSLocalizedString(@"Certificate Policy:", nil);
            content = self.certificate.certificatePolicies;
        } else if (indexPath.row == 8) {
            titleLabelString = NSLocalizedString(@"CRL Distribution Points:", nil);
            NSString *innerString;
            
            for (NSString * tString in self.certificate.CRLDistributionPoints) {
                if (!innerString) {
                    innerString = tString;
                } else {
                    innerString =  [innerString stringByAppendingFormat:@"\n"];
                    innerString =  [innerString stringByAppendingFormat:@"%@",tString];
                }
            }
            content = innerString;
        } else if (indexPath.row == 9) {
            titleLabelString = NSLocalizedString(@"Issuer Information Access:", nil);
            for (NSDictionary * dic in self.certificate.authorityInfoAccess) {
                if (!content) {
                    content = [NSString stringWithFormat:@"%@ = %@",dic[@"Method"],dic[@"Method"]];
                    content =  [content stringByAppendingFormat:@"\n"];
                    NSString *tString = [NSString stringWithFormat:@"URL = %@",dic[@"URI"]];
                    content = [content stringByAppendingFormat:@"%@",tString];
                } else {
                    content =  [content stringByAppendingFormat:@"\n"];
                    content =  [content stringByAppendingFormat:@"\n"];
                    NSString *tString = [NSString stringWithFormat:@"Method = %@",dic[@"Method"]];
                    content = [content stringByAppendingFormat:@"%@",tString];
                    content =  [content stringByAppendingFormat:@"\n"];
                    tString = [NSString stringWithFormat:@"URL = %@",dic[@"URI"]];
                    content = [content stringByAppendingFormat:@"%@",tString];
                }
            }
            
        } else if (indexPath.row == 10) {
            titleLabelString = NSLocalizedString(@"Issuer‘s Key Identifier:", nil);
            content = [self.certificate.authorityKeyIdentifier uppercaseString]?:@"";
        } else if (indexPath.row == 11) {
            titleLabelString = NSLocalizedString(@"Subject‘s Key Identifier::", nil);
            content = [self.certificate.subjectKeyIdentifier uppercaseString]?:@"";
        } else if (indexPath.row == 12) {
            titleLabelString = NSLocalizedString(@"Basic Constraints:", nil);
            content = self.certificate.basicConstraints;
        }  else if (indexPath.row == 13){
            NSMutableArray *att = [NSMutableArray array];
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeEncipherOnly) {
                [att addObject:NSLocalizedString(@"Encipher Only",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeCRLSignature) {
                [att addObject:NSLocalizedString(@"CRL Signature",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeCertificateSignature) {
                [att addObject:NSLocalizedString(@"Certificate Signature",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeKeyAgreement) {
                [att addObject:NSLocalizedString(@"Key Agreement",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeDataEncipherment) {
                [att addObject:NSLocalizedString(@"Data Encipherment",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeKeyEncipherment) {
                [att addObject:NSLocalizedString(@"Key Encipherment",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeNonRepudiation) {
                [att addObject:NSLocalizedString(@"Non-Repudiation",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeDigitalSignature) {
                [att addObject:NSLocalizedString(@"Digital Signature",nil)];
            }
            if (self.certificate.keyUsage & CPDFSignatureKeyUsageTypeDDecipherOnly) {
                [att addObject:NSLocalizedString(@"Decipher Only",nil)];
            }
            NSString *usageString = nil;
            for (NSString *usz in att) {
                NSString *us = usz;
                if (us) {
                    if (!usageString) {
                        usageString = NSLocalizedString(us, nil);
                    } else {
                        us = NSLocalizedString(us, nil);
                        usageString = [NSString stringWithFormat:@"%@,%@",usageString,us];
                    }
                }
            }
            titleLabelString = NSLocalizedString(@"Key Usage:", nil);
            content = usageString;
        }
        else if (indexPath.row == 14){
            titleLabelString = NSLocalizedString(@"Public Key:", nil);
            content = self.certificate.publicKey;
        } else if (indexPath.row == 15){
            titleLabelString = NSLocalizedString(@"X.509 Data:", nil);
            content = self.certificate.X509Data;
        } else if (indexPath.row == 16) {
            titleLabelString = NSLocalizedString(@"SHA1 digest:", nil);
            content = self.certificate.SHA1Digest;
        } else if (indexPath.row == 17) {
            titleLabelString = NSLocalizedString(@"MD5 digest:", nil);
            content = self.certificate.MD5Digest;
            
        }
    }
    
    cell.titleLabel.text = titleLabelString;
    cell.contentLabel.text = content.length > 0 ? content : @" ";
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *sublabel = [[UILabel alloc] init];
    sublabel.font = [UIFont boldSystemFontOfSize:14];
    if (@available(iOS 13.0, *)) {
        sublabel.textColor = [UIColor labelColor];
    } else {
        sublabel.textColor = [UIColor blackColor];
    }
    [sublabel sizeToFit];
    sublabel.frame = CGRectMake(10, 0,
                                view.bounds.size.width - 20, view.bounds.size.height);
    sublabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [view.contentView addSubview:sublabel];
    
    if(section == 0) {
        sublabel.text = NSLocalizedString(@"Summary",nil);
    } else if (section == 1) {
        sublabel.text = NSLocalizedString(@"Details",nil);
        
    }
    return view;
}

@end
