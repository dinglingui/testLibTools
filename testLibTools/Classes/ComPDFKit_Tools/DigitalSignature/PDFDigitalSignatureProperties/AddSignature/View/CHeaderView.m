//
//  CHeaderView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CHeaderView.h"

@implementation CHeaderView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:20];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titleLabel];
        
        self.backBtn = [[UIButton alloc] init];
        self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.backBtn setImage:[UIImage imageNamed:@"CDigitalSignatureViewControllerBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backBtn];
        
        self.cancelBtn = [[UIButton alloc] init];
//        self.cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.cancelBtn setImage:[UIImage imageNamed:@"CDigitalSignatureViewControllerCancel" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(buttonItemClicked_cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(60, 5, self.frame.size.width - 120, 50);
    self.cancelBtn.frame = CGRectMake(self.frame.size.width - 60, 5, 50, 50);
    self.backBtn.frame = CGRectMake(10, 5, 50, 50);
}

#pragma mark - Action

- (void)buttonItemClicked_cancel:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(CHeaderViewCancel:)]) {
        [self.delegate CHeaderViewCancel:self];
    }
}

- (void)buttonItemClicked_back:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(CHeaderViewBack:)]) {
        [self.delegate CHeaderViewBack:self];
    }
}

@end
