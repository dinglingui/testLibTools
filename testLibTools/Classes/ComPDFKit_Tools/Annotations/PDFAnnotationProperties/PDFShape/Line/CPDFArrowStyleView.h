//
//  CPDFArrowStyleView.h
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

@class CPDFArrowStyleView;

@protocol CPDFArrowStyleViewDelegate <NSObject>

@optional

- (void)arrowStyleView:(CPDFArrowStyleView *)arrowStyleView selectIndex:(NSInteger)selectIndex;

- (void)arrowStyleRemoveView:(CPDFArrowStyleView *)arrowStyleView;

@end

@interface CPDFArrowStyleView : UIView

@property (nonatomic, weak) id<CPDFArrowStyleViewDelegate> delegate;

@property (nonatomic, assign) NSInteger selectIndex;

- (instancetype)initWirhTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
