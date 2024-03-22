//
//  CPageEditToolBar.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPageEditToolBar;
@class CPDFView;
@class CBlankPageModel;
@class CPDFDocument;

typedef NS_ENUM(NSInteger, CPageEditToolBarType) {
    CPageEditToolBarInsert = 0,
    CPageEditToolBarReplace,
    CPageEditToolBarExtract,
    CPageEditToolBarCopy,
    CPageEditToolBarRotate,
    CPageEditToolBarDelete
};

@protocol CPageEditToolBarDelegate <NSObject>

@optional

- (void)pageEditToolBarBlankPageInsert:(CPageEditToolBar *)pageEditToolBar pageModel:(CBlankPageModel*)pageModel;

- (void)pageEditToolBarPDFInsert:(CPageEditToolBar *)pageEditToolBar pageModel:(CBlankPageModel*)pageModel document:(CPDFDocument *)document;

- (void)pageEditToolBarExtract:(CPageEditToolBar *)pageEditToolBar;

- (void)pageEditToolBarRotate:(CPageEditToolBar *)pageEditToolBar;

- (void)pageEditToolBarDelete:(CPageEditToolBar *)pageEditToolBar;

- (void)pageEditToolBarCopy:(CPageEditToolBar *)pageEditToolBar;

- (void)pageEditToolBarReplace:(CPageEditToolBar *)pageEditToolBar document:(CPDFDocument *)document;

@end

@interface CPageEditToolBar : UIView

@property (nonatomic, weak) id<CPageEditToolBarDelegate> delegate;

@property (nonatomic, strong) CPDFView *pdfView;

@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, strong) UIViewController *parentVC;

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, readonly) NSArray *pageEditBtns;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
