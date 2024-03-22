//
//  CAddSignatureCell.h
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

@class CAddSignatureCell;

typedef NS_ENUM(NSInteger, CAddSignatureCellType) {
    CAddSignatureCellAlignment = 0,
    CAddSignatureCellAccess,
    CAddSignatureCellSelect,
};

@protocol CAddSignatureCellDelegate <NSObject>

@optional

- (void)CAddSignatureCell:(CAddSignatureCell *)addSignatureCell Alignment:(BOOL)isLeft;

- (void)CAddSignatureCellAccess:(CAddSignatureCell *)addSignatureCell;

- (void)CAddSignatureCell:(CAddSignatureCell *)addSignatureCell Button:(UIButton *)button;

@end

@interface CAddSignatureCell : UITableViewCell

@property (nonatomic, weak) id<CAddSignatureCellDelegate> delegate;

@property (nonatomic, assign) CAddSignatureCellType cellType;

@property (nullable, nonatomic, strong) UIButton *leftAlignmentBtn;

@property (nullable, nonatomic, strong) UIButton *rightAlignmentBtn;

@property (nonatomic, strong) UILabel *accessLabel;

@property (nonatomic, strong) UILabel *accessSelectLabel;

@property (nonatomic, strong) UIButton *accessSelectBtn;

@property (nonatomic, strong) UIButton *textSelectBtn;

@property (nonatomic, strong) UILabel *textSelectLabel;

- (void)setCellStyle:(CAddSignatureCellType)cellType label:(NSString *)label;

- (void)setLeftAlignment:(BOOL)isLeftAlignment;

@end

NS_ASSUME_NONNULL_END
