//
//  CPDFOutlineViewCell.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFOutlineModel;
@class CPDFOutlineViewCell;

@protocol CPDFOutlineViewCellDelegate <NSObject>

@optional
- (void)buttonItemClicked_Arrow:(CPDFOutlineViewCell *)cell;

@end

@interface CPDFOutlineViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIButton *arrowButton;

@property (nonatomic, strong) CPDFOutlineModel *outline;
@property (nonatomic, strong) NSLayoutConstraint  *offsetX;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, weak) id<CPDFOutlineViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
