//
//  CPDFBookmarkViewController.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFView;
@class CPDFBookmarkViewController;

@protocol CPDFBookmarkViewControllerDelegate <NSObject>

@optional

- (void)boomarkViewController:(CPDFBookmarkViewController *)bookmarkViewController pageIndex:(NSInteger)pageIndex;

@end

@interface CPDFBookmarkViewController : UIViewController

@property (nonatomic, readonly) CPDFView *pdfView;

@property (nonatomic, weak) id<CPDFBookmarkViewControllerDelegate> delegate;

- (instancetype)initWithPDFView:(CPDFView *)pdfView;

@end

NS_ASSUME_NONNULL_END
