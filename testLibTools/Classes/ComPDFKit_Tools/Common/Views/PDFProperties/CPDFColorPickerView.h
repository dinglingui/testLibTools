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

@class CPDFColorPickerView;

@protocol CPDFColorPickerViewDelegate <NSObject>

@optional

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color;

@end

@interface CPDFColorPickerView : UIView

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, weak) id<CPDFColorPickerViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
