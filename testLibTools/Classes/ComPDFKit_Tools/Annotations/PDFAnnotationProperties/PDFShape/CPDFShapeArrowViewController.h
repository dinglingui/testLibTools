//
//  CPDFShapeArrowViewController.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFShapeCircleViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class CPDFShapeArrowViewController;
@class CAnnotStyle;

@protocol CPDFShapeArrowViewControllerDelegate <NSObject>

@optional

- (void)arrowViewController:(CPDFShapeArrowViewController *)arrowViewController annotStyle:(CAnnotStyle *)annotStyle;

@end

@interface CPDFShapeArrowViewController : CPDFShapeCircleViewController

@property (nonatomic, weak) id<CPDFShapeArrowViewControllerDelegate> lineDelegate;

@end

NS_ASSUME_NONNULL_END
