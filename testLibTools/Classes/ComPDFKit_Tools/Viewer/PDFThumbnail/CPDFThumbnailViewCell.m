//
//  PDFThumbnailViewCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFThumbnailViewCell.h"

@implementation CPDFThumbnailViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.layer.borderWidth = 1.0;
        _imageView.layer.borderColor = [UIColor colorWithRed:221/255.0 green:233/255.0 blue:255/255.0 alpha:1.0].CGColor;
        [self.contentView addSubview:_imageView];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 12, frame.size.width, 12)];
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:13];
        _textLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    _imageView.frame = CGRectMake((self.frame.size.width - self.imageSize.width)/2, (self.frame.size.height - 14 - self.imageSize.height) / 2, self.imageSize.width, self.imageSize.height);
    
    CGFloat startW = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:CGSizeMake(MAXFLOAT, 12)].width;
    //restSize
    _textLabel.frame = CGRectMake(self.frame.size.width/2 - (startW + 20)/2, self.imageSize.height + (self.frame.size.height - 14 - self.imageSize.height) / 2, startW + 20, 12);
}

- (void)setPageRef:(CGPDFPageRef)pageRef {
    CGRect boxRect = CGRectZero;
    if (pageRef) {
        boxRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
        CGRect displayBounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 12);
        CGAffineTransform transform = CGPDFPageGetDrawingTransform(pageRef,
                                                                   kCGPDFCropBox,
                                                                   displayBounds,
                                                                   0,
                                                                   true);
        boxRect = CGRectApplyAffineTransform(boxRect, transform);
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.textLabel.backgroundColor = [UIColor colorWithRed:20./255 green:96./255 blue:243./255 alpha:1];
        self.textLabel.textColor = [UIColor whiteColor];
        self.imageView.layer.borderColor = [UIColor colorWithRed:20./255 green:96./255 blue:243./255 alpha:1].CGColor;
        self.imageView.layer.borderWidth = 2;
        self.imageView.layer.cornerRadius = 4;
        self.imageView.clipsToBounds = YES;
    } else {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor blackColor];
        self.imageView.layer.borderColor = [UIColor colorWithRed:242/255. green:242/255. blue:242/255. alpha:1.].CGColor;
        self.imageView.layer.borderWidth = 1;
    }
}

@end
