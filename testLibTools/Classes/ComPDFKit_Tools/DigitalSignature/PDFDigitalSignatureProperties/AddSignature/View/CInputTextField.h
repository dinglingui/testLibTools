//
//  CInputTextField.h
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

@class CInputTextField;

@protocol CInputTextFieldDelegate <NSObject>

@optional

- (void)setCInputTextFieldClear:(CInputTextField *)inputTextField;

- (void)setCInputTextFieldBegin:(CInputTextField *)inputTextField;

- (void)setCInputTextFieldChange:(CInputTextField *)inputTextField text:(NSString *)text;

@end

@interface CInputTextField : UIView

@property (nonatomic, weak)   id<CInputTextFieldDelegate> delegate;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *inputTextField;

@property (nonatomic, strong) UIButton *featureBtn;

@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;
@property (nonatomic, assign) CGFloat rightTitleMargin;

@end

NS_ASSUME_NONNULL_END
