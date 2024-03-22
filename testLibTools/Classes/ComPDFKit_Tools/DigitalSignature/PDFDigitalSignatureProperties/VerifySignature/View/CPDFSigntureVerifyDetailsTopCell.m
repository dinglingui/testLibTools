//
//  CPDFSigntureVerifyDetailsTopCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSigntureVerifyDetailsTopCell.h"

@implementation CPDFSigntureVerifyDetailsTopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, 120, 26)];
        _nameLabel = nameLabel;
        _nameLabel.font = [UIFont systemFontOfSize:13];
        
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        countLabel.numberOfLines = 0;
        countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel = countLabel;
        _countLabel.font = [UIFont systemFontOfSize:13];
        
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:countLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSDictionary *attributes = @{NSFontAttributeName: self.countLabel.font};
    CGRect rect = [self.countLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width-150, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    CGFloat height = (rect.size.height > 26) ? rect.size.height : 26;
    self.countLabel.frame = CGRectMake(145, 0,self.bounds.size.width-150, height);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
