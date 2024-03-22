//
//  CStampCustomizeTableViewCell.h
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

@class CCustomizeStampTableViewCell;

@protocol CCustomizeStampTableViewCellDelegate <NSObject>

@optional

- (void)customizeStampTableViewCell:(CCustomizeStampTableViewCell *)customizeStampTableViewCell;

@end

@interface CCustomizeStampTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *customizeStampImageView;

@property (nonatomic, weak) id<CCustomizeStampTableViewCellDelegate> deleteDelegate;

@end

NS_ASSUME_NONNULL_END
