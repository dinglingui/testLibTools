//
//  CPDFDisplayTableViewCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFDisplayTableViewCell.h"
#import "CPDFColorUtils.h"

@interface CPDFDisplayTableViewCell()

@property (nonatomic, strong) UIView * splitView;

@end

@implementation CPDFDisplayTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _modeSwitch = [[UISwitch alloc] init];
        _modeSwitch.hidden = YES;
        _modeSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
        [_modeSwitch sizeToFit];
        [_modeSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

        [self.contentView addSubview:_modeSwitch];
        
        _checkImageView = [[UIImageView alloc] init];
        _checkImageView.image = [UIImage imageNamed:@"CDisplayImageNameCheck"
                                           inBundle:[NSBundle bundleForClass:self.class]
                      compatibleWithTraitCollection:nil];
        _checkImageView.hidden = YES;
        [self.contentView addSubview:_checkImageView];
        
        _iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17.];
        [self.contentView addSubview:_titleLabel];
        
        _splitView = [[UIView alloc] init];
        _splitView.backgroundColor =[CPDFColorUtils CTableviewCellSplitColor];
        [self.contentView addSubview:_splitView];
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    _modeSwitch.frame = CGRectMake(self.contentView.frame.size.width - 50, (self.contentView.frame.size.height - 25)/2, 30, 40);
    
    _checkImageView.frame = CGRectMake(self.contentView.frame.size.width - 40, (self.contentView.frame.size.height - 30)/2, 30, 30);
    _iconImageView.frame = CGRectMake(20, 12, 20, 20);
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_iconImageView.frame) + 10, 12, self.contentView.frame.size.width - _modeSwitch.frame.size.width - 40 - _iconImageView.frame.size.width, 20);
    _splitView.frame = CGRectMake(0, self.contentView.frame.size.height-1, self.contentView.frame.size.width, 1);
}

#pragma mark - Action

- (void)switchAction:(UISwitch *)sender {
    if (self.switchBlock) {
        self.switchBlock();
    }
}

- (void)setHiddenSplitView:(BOOL)hiddenSplitView {
    _hiddenSplitView = hiddenSplitView;
    self.splitView.hidden = hiddenSplitView;
}

@end
