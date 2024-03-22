//
//  CPDFSigntureViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CPDFSigntureViewController.h"
#import "CActivityIndicatorView.h"

#import <ComPDFKit/ComPDFKit.h>
#import "CPDFColorUtils.h"

typedef NS_OPTIONS(NSUInteger, CPromptSignaturesState) {
    CPromptSignaturesState_Failure = 0,
    CPromptSignaturesState_Unknown,
    CPromptSignaturesState_Success,
};

@interface CPDFSigntureViewController ()

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UILabel *textLabel;

@property (nonatomic,strong) NSArray <CPDFSignature *>*signatures;

@property (nonatomic,strong) UIButton *button;

@property (nonatomic,assign) CPromptSignaturesState type;

@end

@implementation CPDFSigntureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height/2-16, 32, 32)];
    [self.view addSubview:_imageView];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:NSLocalizedString(@"Details", nil) forState:UIControlStateNormal];
    [self.button sizeToFit];
    self.button.frame = CGRectMake(self.view.frame.size.width - 10 - self.button.frame.size.width, (self.view.frame.size.height -  self.button.frame.size.height)/2, 68, self.button.frame.size.height);
    self.button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.button setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [self.view addSubview:self.button];
    
    _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_imageView.frame) + 8, (self.view.frame.size.height -  20)/2, self.view.frame.size.width - 44 - self.button.frame.size.width, 20)];
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    _textLabel.font = [UIFont systemFontOfSize:14.0];
    if (@available(iOS 13.0, *)) {
        _textLabel.textColor = [UIColor labelColor];
    } else {
        _textLabel.textColor = [UIColor blackColor];
    }
    [self.view addSubview:self.textLabel];
    
    self.textLabel.text = NSLocalizedString(@"Authenticating…", nil);
    [self.button setTitle:NSLocalizedString(@"Details", nil) forState:UIControlStateNormal];
    [self updateCertState:self.signatures];
    
    self.view.backgroundColor = [CPDFColorUtils CVerifySignatureBackgroundColor];
    self.expiredTrust = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.button.frame = CGRectMake(self.view.frame.size.width - 10 - self.button.frame.size.width, (self.view.frame.size.height -  self.button.frame.size.height)/2, self.button.frame.size.width, self.button.frame.size.height);

    _textLabel.frame = CGRectMake(CGRectGetMaxX(_imageView.frame) + 8, (self.view.frame.size.height -  20)/2, self.view.frame.size.width - 44 - self.button.frame.size.width, 20);
    
    _imageView.frame = CGRectMake(10, self.view.frame.size.height/2-16, 32, 32);
}

-(void)updateCertState:(NSArray *)signatures
{
    self.signatures = signatures;
    [self reloadData];
}

- (void)reloadData {
    BOOL isSignVerified = YES;
    BOOL isCertTrusted = YES;
    
    for (CPDFSignature *signature in self.signatures) {
        CPDFSigner *signer = signature.signers.firstObject;
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
            break;
        }
        
    }
    
    for (CPDFSignature *signature in self.signatures) {
        CPDFSigner *signer = signature.signers.firstObject;
        if (!signer.isSignVerified) {
            isSignVerified = NO;
            break;
        }
    }
    
    if (isSignVerified && isCertTrusted) {
        self.type = CPromptSignaturesState_Success;
        self.imageView.image = [UIImage imageNamed:@"ImageNameSigntureVerifySuccess"
                                          inBundle:[NSBundle bundleForClass:self.class]
                     compatibleWithTraitCollection:nil];
        self.textLabel.text = NSLocalizedString(@"Signature is valid.", nil);
        
    } else if(isSignVerified && !isCertTrusted) {
        self.type = CPromptSignaturesState_Unknown;
        self.imageView.image = [UIImage imageNamed:@"ImageNameSigntureTrustedFailure"
                                          inBundle:[NSBundle bundleForClass:self.class]
                     compatibleWithTraitCollection:nil];
        if(self.signatures.count > 1) {
            self.textLabel.text = NSLocalizedString(@"Signature validity is unknown.", nil);
        } else {
            self.textLabel.text = NSLocalizedString(@"Signature validity is unknown.", nil);
        }
    } else {
        self.type = CPromptSignaturesState_Failure;
        self.imageView.image = [UIImage imageNamed:@"ImageNameSigntureVerifyFailure"
                                          inBundle:[NSBundle bundleForClass:self.class]
                     compatibleWithTraitCollection:nil];
        self.textLabel.text = NSLocalizedString(@"At least one signature is invalid.", nil);
        if(self.signatures.count > 1) {
            self.textLabel.text = NSLocalizedString(@"At least one signature is invalid.", nil);
        } else {
            self.textLabel.text = NSLocalizedString(@"The signature is invalid.", nil);
        }
    }
}

- (void)buttonAction:(id)sender {
    if (self.callback) {
        self.callback();
    }
}

@end
