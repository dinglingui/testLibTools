//
//  CPDFPDFInsertViewController.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFDocument;
@class CBlankPageModel;
@class CPDFPDFInsertViewController;

typedef NS_ENUM(NSInteger, CPDFPDFInsertType) {
    CPDFPDFInsertTypeNone,
    CPDFPDFInsertTypeBefore,
    CPDFPDFInsertTypeAfter
};

@protocol CPDFPDFInsertViewControllerDelegate <NSObject>

@optional

- (void)pdfInsertViewControllerSave:(CPDFPDFInsertViewController *)PageInsertViewController document:(CPDFDocument*)document pageModel:(CBlankPageModel *)pageModel;

- (void)pdfInsertViewControllerCancel:(CPDFPDFInsertViewController *)PageInsertViewController;

@end

@interface CPDFPDFInsertViewController : UIViewController

- (instancetype)initWithDocument:(CPDFDocument *)document;

@property (nonatomic, weak) id<CPDFPDFInsertViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic, assign) NSInteger currentPageCout;

@property (nonatomic, readonly) CPDFDocument *document;

@end

NS_ASSUME_NONNULL_END
