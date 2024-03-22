//
//  CPDFOpacitySliderView.h
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

@class CPDFOpacitySliderView;

@protocol CPDFOpacitySliderViewDelegate <NSObject>

@optional

- (void)opacitySliderView:(CPDFOpacitySliderView *)opacitySliderView opacity:(CGFloat)opacity;

@end

@interface CPDFOpacitySliderView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UISlider *opacitySlider;

@property (nonatomic, strong) UILabel *startLabel;

@property (nonatomic, strong) UIColor * bgColor;

@property (nonatomic, assign) CGFloat  defaultValue;

@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;
@property (nonatomic, assign) CGFloat rightTitleMargin;


@property (nonatomic, weak) id<CPDFOpacitySliderViewDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
