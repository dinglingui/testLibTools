//
//  CSignatureTopBar.m
//  compdfkit-tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CSignatureTopBar.h"

@implementation CSignatureTopBar

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.drawButton = [[UIButton alloc] init];
        self.drawButton.tag = 0;
        [self.drawButton setImage:[UIImage imageNamed:@"CPDFSignatureImageDraw" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.drawButton addTarget:self action:@selector(buttonItemClicked_swith:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.drawButton];
        
        self.textButton = [[UIButton alloc] init];
        self.textButton.tag = 1;
        [self.textButton setImage:[UIImage imageNamed:@"CPDFSignatureImageText" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.textButton addTarget:self action:@selector(buttonItemClicked_swith:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.textButton];
        
        self.imageButton = [[UIButton alloc] init];
        self.imageButton.tag = 2;
        [self.imageButton setImage:[UIImage imageNamed:@"CPDFSignatureImageImage" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.imageButton addTarget:self action:@selector(buttonItemClicked_swith:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.imageButton];
        self.backgroundColor = [UIColor purpleColor];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.drawButton.frame = CGRectMake(10, 0, 50, self.bounds.size.height);
    self.textButton.frame = CGRectMake(70, 0, 50, self.bounds.size.height);
    self.imageButton.frame = CGRectMake(130, 0, 50, self.bounds.size.height);
}

#pragma mark - Action

- (void)buttonItemClicked_swith:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(signatureTopBar:selectIndex:)]) {
//        [self.delegate signatureTopBar:self selectIndex:button.tag];
    }
}

@end
