//
//  CPDFThicknessSliderView.h
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

@class CPDFThicknessSliderView;

@protocol CPDFThicknessSliderViewDelegate <NSObject>

@optional

- (void)thicknessSliderView:(CPDFThicknessSliderView *)thicknessSliderView thickness:(CGFloat)thickness;

@end

@interface CPDFThicknessSliderView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UISlider *thicknessSlider;

@property (nonatomic, strong) UILabel *startLabel;

@property (nonatomic, strong) UILabel *endLabel;

@property (nonatomic, assign) CGFloat defaultValue;

@property (nonatomic, assign) CGFloat thick;

@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;
@property (nonatomic, assign) CGFloat leftTitleMargin;

@property (nonatomic, weak) id<CPDFThicknessSliderViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
