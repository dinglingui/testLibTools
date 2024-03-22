//
//  CPDFSigntureVerifyCell.h
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

@class CActivityIndicatorView;

@interface CPDFSigntureVerifyCell : UITableViewCell

@property (nonatomic,assign) IBOutlet UIView *verifyConetentView;

@property (nonatomic,assign) IBOutlet UIImageView *verifyImageView;

@property (nonatomic,assign) IBOutlet UILabel *grantorLabel;

@property (nonatomic,assign) IBOutlet UILabel *grantorsubLabel;

@property (nonatomic,assign) IBOutlet UILabel *expiredDateLabel;

@property (nonatomic,assign) IBOutlet UILabel *expiredDateSubLabel;

@property (nonatomic,assign) IBOutlet UILabel *stateLabel;

@property (nonatomic,assign) IBOutlet UILabel *stateSubLabel;

@property (nonatomic,assign) IBOutlet UIButton *deleteButton;

@property (nonatomic,copy) void (^deleteCallback)(void);

@end
