//
//  CSignatureTopBar.h
//  compdfkit-tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CSignatureTopBar;

@protocol CSignatureTopBarDelegate <NSObject>

@optional

//- (void)signatureTopBar:(CSignatureTopBar *)signatureTopBar selectIndex:(CSignatureTopBarSelectedIndex)selectIndex;

@end

@interface CSignatureTopBar : UIView

@property (nonatomic, strong) UIButton *drawButton;

@property (nonatomic, strong) UIButton *textButton;

@property (nonatomic, strong) UIButton *imageButton;

@property (nonatomic, weak) id<CSignatureTopBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
