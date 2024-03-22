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

typedef NS_ENUM(NSInteger, CPDFLinkType) {
    CPDFLinkTypeLink = 0,
    CPDFLinkTypePage,
    CPDFLinkTypeEmail
};

@class CPDFLinkViewController;
@class CAnnotStyle;

NS_ASSUME_NONNULL_BEGIN

@protocol CPDFLinkViewControllerDelegate <NSObject>

- (void)linkViewController:(CPDFLinkViewController *)linkViewController linkType:(CPDFLinkType)linkType linkString:(NSString *)linkString;

- (void)linkViewControllerDismiss:(CPDFLinkViewController *)linkViewController isLink:(BOOL)isLink;

@optional

@end

@interface CPDFLinkViewController : UIViewController

@property (nonatomic, readonly) CAnnotStyle *annotStyle;

@property (nonatomic, assign) NSInteger pageCount;

@property (nonatomic, assign) BOOL isLink;

- (instancetype)initWithStyle:(CAnnotStyle *)annotStyle;

@property (nonatomic, weak) id<CPDFLinkViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
