//
//  CPDFEditTextSampleView.h
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

@interface CPDFEditTextSampleView : UIView

@property (nonatomic, strong) UIColor * textColor;

@property (nonatomic, assign) CGFloat textOpacity;

@property (nonatomic,  copy)  NSString * fontName;

@property (nonatomic, assign) BOOL isBold;

@property (nonatomic, assign) BOOL isItalic;

@property (nonatomic, assign) NSTextAlignment textAlignmnet;

@property (nonatomic, assign) CGFloat fontSize;
@end

NS_ASSUME_NONNULL_END
