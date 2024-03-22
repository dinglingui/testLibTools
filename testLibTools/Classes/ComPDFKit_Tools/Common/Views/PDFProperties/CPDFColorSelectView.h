//
//  CPDFColorPickerView.h
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

@class CPDFColorSelectView;

@protocol CPDFColorSelectViewDelegate <NSObject>

@optional

- (void)selectColorView:(CPDFColorSelectView *)select;

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color;

@end

@interface CPDFColorSelectView : UIView

@property (nonatomic, strong) id<CPDFColorSelectViewDelegate> delegate;

@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) UILabel *colorLabel;

@property (nonatomic, strong) UIScrollView *colorPickerView;


@end

NS_ASSUME_NONNULL_END
