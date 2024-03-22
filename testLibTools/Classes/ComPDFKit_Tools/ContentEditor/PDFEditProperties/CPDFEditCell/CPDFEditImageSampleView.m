//
//  CPDFEditImageSampleView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import "CPDFEditImageSampleView.h"
#import "CPDFImagePropertyCell.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface CPDFEditImageSampleView ()

@end

@implementation CPDFEditImageSampleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.image = [UIImage imageNamed:@"CPDFEditImageSample" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        self.backgroundColor = [CPDFColorUtils CAnnotationSampleDrawBackgoundColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectInset(self.bounds, (self.bounds.size.width/7)*3, self.bounds.size.height/4);
}

@end
