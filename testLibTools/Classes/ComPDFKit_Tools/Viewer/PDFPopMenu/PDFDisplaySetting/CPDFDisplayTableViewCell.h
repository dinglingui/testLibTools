//
//  CPDFDisplayTableViewCell.h
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

@interface CPDFDisplayTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *checkImageView;

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel  * titleLabel;

@property (nonatomic, strong) UISwitch *modeSwitch;

@property (nonatomic, copy) void(^switchBlock)(void);

@property (nonatomic, assign) BOOL hiddenSplitView;

@end

NS_ASSUME_NONNULL_END
