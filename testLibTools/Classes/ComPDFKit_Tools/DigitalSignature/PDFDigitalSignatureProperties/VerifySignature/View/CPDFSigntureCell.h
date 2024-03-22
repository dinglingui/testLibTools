//
//  CPDFSigntureCell.h
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

#import "CPDFSigntureListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPDFSigntureCell : UITableViewCell

@property (nonatomic,assign) IBOutlet UIButton *arrowButton;

@property (nonatomic,assign) IBOutlet UILabel *titleLabel;

@property (nonatomic,assign) IBOutlet NSLayoutConstraint *contentOffsetX;

@property (nonatomic,strong) CPDFSigntureModel *model;

@property (nonatomic,assign) BOOL isShow;

@property (nonatomic,copy) void (^callback)(void);

@end

NS_ASSUME_NONNULL_END
