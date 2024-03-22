//
//  CPDFPageInsertViewController.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFPageInsertViewController;
@class CBlankPageModel;

typedef NS_ENUM(NSInteger, CPDFPageInsertType) {
    CPDFPageInsertTypeNone,
    CPDFPageInsertTypeBefore,
    CPDFPageInsertTypeAfter
};

@protocol CPDFPageInsertViewControllerDelegate <NSObject>

@optional

- (void)pageInsertViewControllerSave:(CPDFPageInsertViewController *)PageInsertViewController pageModel:(CBlankPageModel *)pageModel;

- (void)pageInsertViewControllerCancel:(CPDFPageInsertViewController *)PageInsertViewController;

@end

@interface CPDFPageInsertViewController : UIViewController

@property (nonatomic, weak) id<CPDFPageInsertViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, assign) NSInteger currentPageCout;

@end

NS_ASSUME_NONNULL_END
