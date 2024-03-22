//
//  CInssertBlankPageCell.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CInsertBlankPageCell;

typedef NS_ENUM(NSInteger, CInsertBlankPageCellType) {
    CInsertBlankPageCellSize = 0,
    CInsertBlankPageCellDirection,
    CInsertBlankPageCellLocation,
    CInsertBlankPageCellSizeSelect,
    CInsertBlankPageCellLocationSelect,
    CInsertBlankPageCellLocationTextFiled,
    CInsertBlankPageCellRangeSelect,
    CInsertBlankPageCellRangeTextFiled
};

@protocol CInsertBlankPageCellDelegate <NSObject>

@optional

- (void)insertBlankPageCell:(CInsertBlankPageCell *)insertBlankPageCell isSelect:(BOOL)isSelect;

- (void)insertBlankPageCell:(CInsertBlankPageCell *)insertBlankPageCell rotate:(NSInteger)rotate;

- (void)insertBlankPageCell:(CInsertBlankPageCell *)insertBlankPageCell pageIndex:(NSInteger)pageIndex;

- (void)insertBlankPageCellLocation:(CInsertBlankPageCell *)insertBlankPageCell button:(UIButton *)buttom;

- (void)insertBlankPageCellRange:(CInsertBlankPageCell *)insertBlankPageCell button:(UIButton *)buttom;

- (void)insertBlankPageCell:(CInsertBlankPageCell *)insertBlankPageCell pageRange:(NSString *)pageRange;

- (void)insertBlankPageCellLocationTextFieldBegin:(CInsertBlankPageCell *)insertBlankPageCell;

- (void)insertBlankPageCellRangeTextFieldBegin:(CInsertBlankPageCell *)insertBlankPageCell;

@end

@interface CInsertBlankPageCell : UITableViewCell

@property (nonatomic, assign) CInsertBlankPageCellType cellType;

@property (nonatomic, weak) id<CInsertBlankPageCellDelegate> delegate;

@property (nonatomic, strong) UILabel *sizeLabel;

@property (nullable, nonatomic, strong) UIButton *sizeSelectBtn;

@property (nonatomic, strong) UILabel *sizeSelectLabel;

@property (nullable, nonatomic, strong) UIButton *horizontalPageBtn;

@property (nullable, nonatomic, strong) UIButton *verticalPageBtn;

@property (nullable, nonatomic, strong) UIButton *locationSelectBtn;

@property (nonatomic, strong) UILabel *locationSelectLabel;

@property (nonatomic, strong) UILabel *rangeSelectLabel;

@property (nullable, nonatomic, strong) UITextField *locationTextField;

@property (nullable, nonatomic, strong) UIButton *rangeSelectBtn;

@property (nullable, nonatomic, strong) UITextField *rangeTextField;

@property (nonatomic, assign) BOOL  buttonSelectedStatus;


- (void)setCellStyle:(CInsertBlankPageCellType)cellType label:(NSString *)label;


@end

NS_ASSUME_NONNULL_END
