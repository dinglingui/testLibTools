//
//  CSearchToolbar.h
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

@class CPDFListView;
@class CPDFSelection;
@class CSearchToolbar;

#pragma mark - CSearchToolbarDelegate

@protocol CSearchToolbarDelegate <NSObject>

@optional

- (void)searchToolbarOnExitSearch:(CSearchToolbar *)searchToolbar;

- (void)searchToolbarOnClearQuery:(CSearchToolbar *)searchToolbar;

- (void)searchToolbarOnSearchQueryBegin:(CSearchToolbar *)searchToolbar;

- (void)searchToolbarOnSearchQueryEnd:(CSearchToolbar *)searchToolbar;

- (void)searchToolbar:(CSearchToolbar *)searchToolbar onSearchQueryResults:(NSArray *)results;

@end

@interface CSearchToolbar : UIView

@property(nonatomic, readonly) CPDFListView *pdfView;

@property (nonatomic, readonly) NSArray *resultArray;

@property(nonatomic, readonly) NSString *searchKeyString;

@property (nonatomic, assign) id<CSearchToolbarDelegate> delegate;

- (instancetype)initWithPDFView:(CPDFListView *)pdfview;

- (void)showInView:(UIView *)subView;

- (void)clearDatas;

@end

NS_ASSUME_NONNULL_END
