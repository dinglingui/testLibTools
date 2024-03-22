//
//  CPDFLinkViewController.h
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

typedef NS_ENUM(NSInteger, CPDFFormLinkType) {
    CPDFFormLinkTypeLink = 0,
    CPDFFormLinkTypePage
};

@class CPDFFormLinkViewController;
@class CAnnotStyle;

NS_ASSUME_NONNULL_BEGIN

@protocol CPDFLinkViewControllerDelegate <NSObject>

- (void)linkViewController:(CPDFFormLinkViewController *)linkViewController linkType:(CPDFFormLinkType)linkType linkString:(NSString *)linkString;

- (void)linkViewControllerDismiss:(CPDFFormLinkViewController *)linkViewController isLink:(BOOL)isLink;

@optional

@end

@interface CPDFFormLinkViewController : UIViewController

@property (nonatomic, readonly) CAnnotStyle *annotStyle;

@property (nonatomic, assign) NSInteger pageCount;

- (instancetype)initWithStyle:(CAnnotStyle *)annotStyle;

@property (nonatomic, weak) id<CPDFLinkViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
