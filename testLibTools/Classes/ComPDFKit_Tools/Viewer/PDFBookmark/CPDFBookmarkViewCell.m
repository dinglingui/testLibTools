//
//  CPDFBookmarkViewCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// 

#import "CPDFBookmarkViewCell.h"

@interface CPDFBookmarkViewCell()

@property (nonatomic, strong) UIView * bottomView;

@end

@implementation CPDFBookmarkViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, self.bounds.size.width - 110, self.bounds.size.height - 10)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _pageIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 100, 5, 85, self.bounds.size.height - 10)];
        _pageIndexLabel.textAlignment = NSTextAlignmentRight;
        _pageIndexLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
        _bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.pageIndexLabel];
        [self.contentView addSubview:_bottomView];
    }
    return self;
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

- (void)buttonItemClicked_edit:(id)sender {
    UITableView *tableView = [self getTableView];
        if (tableView) {
            NSIndexPath *indexPath = [tableView indexPathForCell:self];
            [tableView setEditing:YES animated:YES];
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
}

- (UITableView *)getTableView {
    UIView *tableView = self.superview;
    while (![tableView isKindOfClass:[UITableView class]] && tableView != nil) {
        tableView = tableView.superview;
    }
    return (UITableView *)tableView;
}

@end
