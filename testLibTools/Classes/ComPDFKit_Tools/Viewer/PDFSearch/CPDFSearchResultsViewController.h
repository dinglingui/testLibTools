//
//  CPDFSearchResultsViewController.h
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

@class CPDFSelection;
@class CPDFDocument;
@class CPDFSearchResultsViewController;
@class CPDFListView;

@protocol CPDFSearchResultsDelegate <NSObject>

- (void)searchResultsView:(CPDFSearchResultsViewController *)resultVC forSelection:(CPDFSelection *)selection indexPath:(NSIndexPath *)indexPath;

- (void)searchResultsViewControllerDismiss:(CPDFSearchResultsViewController *)searchResultsViewController;

- (void)searchResultsViewControllerReplace:(CPDFSearchResultsViewController *)searchResultsViewController;


@end

@interface CPDFSearchResultsViewController : UIViewController

@property (nonatomic, weak) id<CPDFSearchResultsDelegate> delegate;

@property (nonatomic, strong) CPDFListView * pdfListView;

@property (nonatomic, strong) NSString* searchString;

- (instancetype)initWithResultArray:(NSArray *)resultArray
                            keyword:(NSString *)keyword
                           document:(CPDFDocument *) document;


@end

NS_ASSUME_NONNULL_END
