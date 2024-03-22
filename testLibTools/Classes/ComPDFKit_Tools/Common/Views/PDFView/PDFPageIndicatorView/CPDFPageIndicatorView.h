//
//  CPDFPageIndicatorView.h
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

typedef NS_ENUM(NSInteger, CPDFPageIndicatorViewPosition) {
    CPDFPageIndicatorViewPositionLeftBottom,
    CPDFPageIndicatorViewPositionCenterBottom
};

NS_ASSUME_NONNULL_BEGIN

@interface CPDFPageIndicatorView : UIView

@property (nonatomic, copy) void(^touchCallBack)(void);
@property (nonatomic, strong) UIColor *indicatorBackgroudColor;
@property (nonatomic, assign) CGFloat indicatorCornerRadius;

- (void)showInView:(UIView *)subView position:(CPDFPageIndicatorViewPosition)position;

- (void)updatePageCount:(NSUInteger)pageCount currentPageIndex:(NSUInteger)currentPageIndex;

@end

NS_ASSUME_NONNULL_END
