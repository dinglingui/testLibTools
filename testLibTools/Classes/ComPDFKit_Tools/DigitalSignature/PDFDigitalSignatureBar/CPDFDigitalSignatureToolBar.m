//
//  CPDFDigitalSignatureToolBar.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFDigitalSignatureToolBar.h"
#import "CPDFColorUtils.h"
#import "CPDFListView.h"
#import "CAnnotationManage.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFDigitalSignatureToolBar ()

@property (nonatomic, strong) CPDFListView *pdfListView;

@property (nonatomic, strong) UIButton *addDigitalSignatureBtn;

@property (nonatomic, strong) UIButton *verifyDigitalSignatureBtn;

@property(nonatomic, strong) CAnnotationManage *annotationManage;

@end

@implementation CPDFDigitalSignatureToolBar

#pragma mark - Initializers

- (instancetype)initWithPDFListView:(CPDFListView *)pdfListView {
    if (self = [super init]) {
        self.pdfListView = pdfListView;
        
        self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        
        self.addDigitalSignatureBtn = [[UIButton alloc] init];
        [self.addDigitalSignatureBtn setTitle:NSLocalizedString(@"Add Signatures", nil) forState:UIControlStateNormal];
        [self.addDigitalSignatureBtn setTitleColor:[CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        [self.addDigitalSignatureBtn setImage:[UIImage imageNamed:@"CPDFDigitalSignatureAdd" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.addDigitalSignatureBtn addTarget:self action:@selector(buttonItemClicked_add:) forControlEvents:UIControlEventTouchUpInside];
        self.addDigitalSignatureBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
        self.addDigitalSignatureBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.addDigitalSignatureBtn.layer.cornerRadius = 10.0;
        self.addDigitalSignatureBtn.layer.masksToBounds = YES;
        self.addDigitalSignatureBtn.selected = NO;
        [self addSubview:self.addDigitalSignatureBtn];
        
        self.verifyDigitalSignatureBtn = [[UIButton alloc] init];
        [self.verifyDigitalSignatureBtn setTitle:NSLocalizedString(@"Verify the Signature", nil) forState:UIControlStateNormal];
        [self.verifyDigitalSignatureBtn setTitleColor:[CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        [self.verifyDigitalSignatureBtn setImage:[UIImage imageNamed:@"CPDFDigitalSignatureVerify" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.verifyDigitalSignatureBtn addTarget:self action:@selector(buttonItemClicked_verify:) forControlEvents:UIControlEventTouchUpInside];
        self.verifyDigitalSignatureBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
        [self.verifyDigitalSignatureBtn setBackgroundImage:[self imageWithColor:[CPDFColorUtils CAnnotationBarSelectBackgroundColor]] forState:UIControlStateHighlighted];
        self.verifyDigitalSignatureBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.verifyDigitalSignatureBtn.layer.cornerRadius = 10.0;
        self.verifyDigitalSignatureBtn.layer.masksToBounds = YES;
        self.addDigitalSignatureBtn.selected = NO;
        [self addSubview:self.verifyDigitalSignatureBtn];
        
        self.annotationManage = [[CAnnotationManage alloc] initWithPDFView:pdfListView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.addDigitalSignatureBtn.frame = CGRectMake((self.frame.size.width-310)/2, 5, 140, 50);
    self.verifyDigitalSignatureBtn.frame = CGRectMake(self.addDigitalSignatureBtn.frame.origin.x + 170, 5, 140, 50);
}

#pragma mark - Private Methods

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Action

- (void)buttonItemClicked_add:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        button.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        self.verifyDigitalSignatureBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
        self.pdfListView.annotationMode = CPDFViewFormModeSign;
        self.pdfListView.toolModel = CToolModelForm;
        [self.annotationManage setAnnotStyleFromMode:CPDFViewFormModeSign];
    } else {
        button.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
        self.pdfListView.toolModel = CToolModelViewer;
        self.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
    }
    
    if ([self.delegate respondsToSelector:@selector(addSignatureBar:souceButton:)]) {
        [self.delegate addSignatureBar:self souceButton:button];
    }
    
}

- (void)buttonItemClicked_verify:(UIButton *)button {
    if (button.selected) {
        self.addDigitalSignatureBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    }
    if ([self.delegate respondsToSelector:@selector(verifySignatureBar:souceButton:)]) {
        [self.delegate verifySignatureBar:self souceButton:button];
    }
}

- (void)updateStatusWithsignatures:(NSArray<CPDFSignature *> *) signatures {
    if(signatures.count > 0) {
        self.verifyDigitalSignatureBtn.enabled = YES;
    } else {
        self.verifyDigitalSignatureBtn.enabled = NO;
    }
}

@end
