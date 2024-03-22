//
//  CPDFSigntureDetailsFootView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSigntureDetailsFootView.h"
#import "CPDFColorUtils.h"
@implementation CPDFSigntureDetailsFootView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [CPDFColorUtils CViewBackgroundColor];
        
        UILabel *titlelabel = [[UILabel alloc] init];
        titlelabel.font = [UIFont boldSystemFontOfSize:14];
        if (@available(iOS 13.0, *)) {
            titlelabel.textColor = [UIColor labelColor];
        } else {
            titlelabel.textColor = [UIColor blackColor];
        }
        titlelabel.font = [UIFont systemFontOfSize:12.0];
        titlelabel.text = NSLocalizedString(@"Trust", nil);
        [titlelabel sizeToFit];
        titlelabel.frame = CGRectMake(10, 0,
                                    self.bounds.size.width - 20, 18);
        titlelabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:titlelabel];
        
        UILabel *sublabel = [[UILabel alloc] init];
        sublabel.font = [UIFont systemFontOfSize:14];
        if (@available(iOS 13.0, *)) {
            sublabel.textColor = [UIColor labelColor];
        } else {
            sublabel.textColor = [UIColor blackColor];
        }
        sublabel.text = NSLocalizedString(@"This Certificate Is Trusted to:", nil);
        [sublabel sizeToFit];
        sublabel.font = [UIFont systemFontOfSize:12.0];

        sublabel.adjustsFontSizeToFitWidth = YES;
        sublabel.frame = CGRectMake(10, CGRectGetMaxY(titlelabel.frame) + 20,
                                    self.bounds.size.width - 20, 18);
        sublabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:sublabel];
        
        _dataImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ImageNameSigntureTrustedIcon"
                                                                  inBundle:[NSBundle bundleForClass:self.class]
                                             compatibleWithTraitCollection:nil]];
        [_dataImage sizeToFit];
        _dataImage.frame = CGRectMake(20, CGRectGetMaxY(sublabel.frame) + 16,
                                    20, 20);

        [self addSubview:_dataImage];
        
        _dataLabel = [[UILabel alloc] init];
        _dataLabel.font = [UIFont systemFontOfSize:14];
        if (@available(iOS 13.0, *)) {
            _dataLabel.textColor = [UIColor labelColor];
        } else {
            _dataLabel.textColor = [UIColor blackColor];
        }
        _dataLabel.text = NSLocalizedString(@"Sign document or data", nil);
        [_dataLabel sizeToFit];
        _dataLabel.font = [UIFont systemFontOfSize:12.0];
        _dataLabel.adjustsFontSizeToFitWidth = YES;
        _dataLabel.frame = CGRectMake(CGRectGetMaxX(_dataImage.frame) + 5, CGRectGetMaxY(titlelabel.frame) + 20,
                                    self.bounds.size.width - CGRectGetMaxX(_dataImage.frame)  - 15, 18);
        _dataLabel.center = CGPointMake(_dataLabel.center.x, _dataImage.center.y);
        _dataLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_dataLabel];
        
        _certifyImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ImageNameSigntureTrustedIcon"
                                                                  inBundle:[NSBundle bundleForClass:self.class]
                                             compatibleWithTraitCollection:nil]];
        [_certifyImage sizeToFit];
        _certifyImage.frame = CGRectMake(20, CGRectGetMaxY(_dataImage.frame) + 16,
                                    20, 20);

        [self addSubview:_certifyImage];
        
        _certifyLabel = [[UILabel alloc] init];
        _certifyLabel.font = [UIFont systemFontOfSize:12];
        if (@available(iOS 13.0, *)) {
            _certifyLabel.textColor = [UIColor labelColor];
        } else {
            _certifyLabel.textColor = [UIColor blackColor];
        }
        _certifyLabel.text = NSLocalizedString(@"Certify document", nil);
        [_certifyLabel sizeToFit];
        _certifyLabel.adjustsFontSizeToFitWidth = YES;
        _certifyLabel.frame = CGRectMake(CGRectGetMaxX(_certifyImage.frame) + 5, CGRectGetMaxY(_dataLabel.frame) + 20,
                                    self.bounds.size.width - CGRectGetMaxX(_certifyImage.frame) - 15,18);
        _certifyLabel.center = CGPointMake(_certifyLabel.center.x, _certifyImage.center.y);
        _certifyLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_certifyLabel];

        self.trustedButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.trustedButton setTitle:NSLocalizedString(@"Add to Trusted Certificates", nil) forState:UIControlStateNormal];
        [self.trustedButton sizeToFit];
        self.trustedButton.frame = CGRectMake(10, CGRectGetMaxY(_certifyLabel.frame) + 20, self.frame.size.width - 20, 40);
        self.trustedButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.trustedButton.layer.cornerRadius = 5.0;
        self.trustedButton.layer.borderWidth = 1.0;
        self.trustedButton.layer.borderColor = [UIColor systemBlueColor].CGColor;
        [self.trustedButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        [self.trustedButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self addSubview:self.trustedButton];

    }
    return self;
}

@end
