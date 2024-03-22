//
//  CStampCollectionViewCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CStampCollectionViewCell.h"

#pragma mark - StampCollectionViewCell

@interface CStampCollectionViewCell ()

@end

@implementation CStampCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.stampImage = [[UIImageView alloc] init];
        self.stampImage.backgroundColor = [UIColor clearColor];
        self.stampImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.stampImage];
        
        self.contentView.layer.borderWidth = 0.5;
        self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.stampImage.frame = CGRectMake(10, (self.contentView.bounds.size.height - 50)/2,
                                   self.contentView.bounds.size.width - 20, 50);
}

@end

#pragma mark - StampCollectionHeaderView

@implementation StampCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0  blue:248.0/255.0  alpha:1.0];

        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor colorWithRed:36.0/255.0 green:36.0/255.0 blue:36.0/255.0 alpha:1.0];
        _textLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _textLabel.frame = CGRectMake(10, 0, self.bounds.size.width-20, 20);
}

@end

#pragma mark - StampCollectionHeaderView1

@interface StampCollectionHeaderView1()

@property (nonatomic,retain) UIView * headerView;

@property (nonatomic,retain) UIButton * textButton;

@property (nonatomic,retain) UIButton * imageButton;

@end

@implementation StampCollectionHeaderView1

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_headerView];
        
        self.textButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_textButton setTitle:NSLocalizedString(@"New Text Stamp", nil) forState:UIControlStateNormal];
        [_textButton setTitleColor:[UIColor colorWithRed:36.0/255.0 green:36.0/255.0 blue:36.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_textButton addTarget:self action:@selector(buttonItemClicked_AddText:) forControlEvents:UIControlEventTouchUpInside];
        _textButton.layer.borderWidth = 1;
        _textButton.layer.cornerRadius = 5;
        _textButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        _textButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _textButton.layer.borderColor = [UIColor colorWithRed:17.0/255.0 green:140.0/255.0 blue:1.0 alpha:1.0].CGColor;
        [_headerView addSubview:_textButton];
        
        self.imageButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_imageButton setTitle:NSLocalizedString(@"New Image Stamp", nil) forState:UIControlStateNormal];
        [_imageButton setTitleColor:[UIColor colorWithRed:36.0/255.0 green:36.0/255.0 blue:36.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        _imageButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        _imageButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_imageButton addTarget:self action:@selector(buttonItemClicked_AddImage:) forControlEvents:UIControlEventTouchUpInside];
        _imageButton.layer.borderWidth = 1;
        _imageButton.layer.cornerRadius = 5;
        _imageButton.layer.borderColor = [UIColor colorWithRed:17.0/255.0 green:140.0/255.0 blue:1.0 alpha:1.0].CGColor;
        [_headerView addSubview:_imageButton];
        
        self.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0  blue:248.0/255.0  alpha:1.0];
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor colorWithRed:36.0/255.0 green:36.0/255.0 blue:36.0/255.0 alpha:1.0];
        _textLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_textLabel];
    
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _headerView.frame = CGRectMake(0, 0, self.bounds.size.width, 80);
    _textButton.frame = CGRectMake(10, CGRectGetMinY(_headerView.frame)+10, (self.bounds.size.width-40)/2, 60);
    _imageButton.frame = CGRectMake(30 + (self.bounds.size.width-40)/2, CGRectGetMinY(_headerView.frame)+10, (self.bounds.size.width-40)/2, 60);
    _textLabel.frame = CGRectMake(10, CGRectGetMinY(_headerView.frame)+80, self.bounds.size.width-20, 20);
}

#pragma mark - Button Event Action

- (void)buttonItemClicked_AddImage:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addImageWithHeaderView:)]) {
        [self.delegate addImageWithHeaderView:self];
    }
}

- (void)buttonItemClicked_AddText:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addTextWithHeaderView:)]) {
        [self.delegate addTextWithHeaderView:self];
    }

}

@end
