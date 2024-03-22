//
//  CStampCustomizeTableViewCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CCustomizeStampTableViewCell.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CCustomizeStampTableViewCell ()

@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation CCustomizeStampTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.customizeStampImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.customizeStampImageView];
        
        self.deleteButton = [[UIButton alloc] init];
        [self.deleteButton setImage:[UIImage imageNamed:@"CPDFSignatureImageDelete" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(buttonItemClicked_delete:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.deleteButton];
        self.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = self.contentView.bounds.size.height-10;
    CGFloat width  = height * (self.customizeStampImageView.image.size.width / self.customizeStampImageView.image.size.height);
    width = MIN(width, self.contentView.bounds.size.width - 80.0);
    [self.customizeStampImageView setFrame:CGRectMake((self.bounds.size.width - width)/2.0, 5.0, width, height)];
    self.customizeStampImageView.center = self.contentView.center;
    self.deleteButton.frame = CGRectMake(self.bounds.size.width - 50, 0.0, 50, 50);
}

#pragma mark - Action

- (void)buttonItemClicked_delete:(id)sender {
    if (self.deleteDelegate && [self.deleteDelegate respondsToSelector:@selector(customizeStampTableViewCell:)]) {
        [self.deleteDelegate customizeStampTableViewCell:self];
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

@end
