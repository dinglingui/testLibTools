//
//  CPDFBookmarkViewCell.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPDFBookmarkViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *pageIndexLabel;

@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, strong) UIButton *deleteButton;

@property (nonatomic, strong) UIButton *editButton;

@end

NS_ASSUME_NONNULL_END
