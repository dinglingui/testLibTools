//
//  CPDFSignatureEditViewController.h
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

typedef NS_ENUM(NSInteger, CSignatureTopBarSelectedIndex) {
    CSignatureTopBarDefault = 0,
    CSignatureTopBarText,
    CSignatureTopBarImage
};

@class CPDFSignatureEditViewController;

@protocol CPDFSignatureEditViewControllerDelegate <NSObject>

@optional

- (void)signatureEditViewController:(CPDFSignatureEditViewController *)signatureEditViewController image:(UIImage *)image;

- (void)signatureEditViewControllerCancel:(CPDFSignatureEditViewController *)signatureEditViewController;

@end

@interface CPDFSignatureEditViewController : UIViewController

@property (nonatomic, weak) id<CPDFSignatureEditViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger customType;

@end

NS_ASSUME_NONNULL_END
