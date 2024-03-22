//
//  CSignatureDrawView.h
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

@class CSignatureDrawView;

@protocol CSignatureDrawViewDelegate <NSObject>

@optional

- (void)signatureDrawViewStart:(CSignatureDrawView *)signatureDrawView;

@end

typedef NS_ENUM(NSInteger, CSignatureDrawSelectedIndex) {
    CSignatureDrawText = 0,
    CSignatureDrawImage
};

@interface CSignatureDrawView : UIView

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) CGFloat lineWidth;

@property (nullable, nonatomic, strong) UIImage *image;

@property (nonatomic, weak) id<CSignatureDrawViewDelegate> delegate;

@property (nonatomic, assign) CSignatureDrawSelectedIndex selectIndex;

- (UIImage *)signatureImage;

- (void)signatureClear;

@end

NS_ASSUME_NONNULL_END
