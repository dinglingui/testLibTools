//
//  CPDFOutlineViewCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFOutlineViewCell.h"
#import "CPDFOutlineModel.h"

@implementation CPDFOutlineViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIButton *arrowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 4, 36, 26)];
        [arrowButton addTarget:self action:@selector(buttonItemClicked_Arrow:) forControlEvents:UIControlEventTouchUpInside];
        [arrowButton setImage:[UIImage imageNamed:@"CPDFOutlineImageBotaMore" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [arrowButton setImage:[UIImage imageNamed:@"CPDFOutlineImageBotaMoreLeft" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        _arrowButton = arrowButton;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70 + self.offsetX.constant, 0, self.bounds.size.width - self.offsetX.constant - 120, 26)];
        _nameLabel = nameLabel;
        _nameLabel.font = [UIFont systemFontOfSize:14.];
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-55, 0, 50, 26)];
        
        countLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _countLabel = countLabel;
        _countLabel.font = [UIFont systemFontOfSize:14.];
        
        [self.contentView addSubview:arrowButton];
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:countLabel];
    }
    return self;
}

- (void)setOutline:(CPDFOutlineModel *)outline {
    if (_outline != outline) {
        _outline = outline;
    }
    
    self.nameLabel.text = outline.title;
    self.countLabel.text = [NSString stringWithFormat:@"%ld", outline.number + 1];
    self.offsetX.constant = 10 * outline.level;
    if (outline.count>0) {
        [self.arrowButton setHidden:NO];
        if (outline.isShow) {
            self.arrowButton.selected = YES;
        } else {
            self.arrowButton.selected = NO;
        }
    } else{
        [self.arrowButton setHidden:YES];
        
    }
    
    self.nameLabel.frame = CGRectMake(25 + 10 * outline.level,10, self.bounds.size.width - self.offsetX.constant - 100, 16);
    self.countLabel.frame = CGRectMake(self.bounds.size.width-55, 10, 55, 14);
    
}

- (void)setIsShow:(BOOL)isShow {
    _isShow = isShow;
    
    self.outline.isShow = self.isShow;
    
    if (self.outline.count>0) {
        if (self.outline.isShow) {
            self.arrowButton.selected = YES;
        } else {
            self.arrowButton.selected = NO;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Action

- (void)buttonItemClicked_Arrow:(id)sender {
    if ([self.delegate respondsToSelector:@selector(buttonItemClicked_Arrow:)]) {
        [self.delegate buttonItemClicked_Arrow:self];
    }
}

@end
