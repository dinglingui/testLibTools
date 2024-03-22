//
//  CStampCollectionViewCell.h
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

#pragma mark - StampCollectionHeaderView

@interface StampCollectionHeaderView : UICollectionReusableView

@property (nonatomic,retain) UILabel *textLabel;

@end

#pragma mark - StampCollectionHeaderView1

@class StampCollectionHeaderView1;

@protocol StampHeaderViewDelegate <NSObject>

@optional
- (void)addTextWithHeaderView:(StampCollectionHeaderView1 *)headerView;

- (void)addImageWithHeaderView:(StampCollectionHeaderView1 *)headerView;

@end

#pragma mark - StampCollectionHeaderView1

@interface StampCollectionHeaderView1 : UICollectionReusableView

@property (nonatomic,retain)UILabel *textLabel;

@property (nonatomic,assign) id<StampHeaderViewDelegate> delegate;

@end

#pragma mark - StampCollectionViewCell

@interface CStampCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *stampImage;

@property (nonatomic, assign) BOOL editing;

@end

NS_ASSUME_NONNULL_END
