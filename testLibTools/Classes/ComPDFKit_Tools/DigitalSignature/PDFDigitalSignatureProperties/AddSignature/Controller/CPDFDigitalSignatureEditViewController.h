//
//  CPDFDigitalSignatureEditViewController.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CPDFSignatureEditViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CSignatureCustomType) {
    CSignatureCustomTypeText = 1,
    CSignatureCustomTypeDraw,
    CSignatureCustomTypeImage,
    CSignatureCustomTypeNone
};

@interface CPDFDigitalSignatureEditViewController : CPDFSignatureEditViewController

- (void)refreshViewController;

@end

NS_ASSUME_NONNULL_END
