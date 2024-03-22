//
//  CAddSignatureViewController.h
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

@class CPDFSignatureWidgetAnnotation;
@class CPDFSignatureConfig;
@class CAddSignatureViewController;
@class CPDFSignatureCertificate;

#define NAME_KEY NSLocalizedString(@"Name",nil)
#define DN_KEY NSLocalizedString(@"DN",nil)
#define REASON_KEY NSLocalizedString(@"Reason",nil)
#define LOCATION_KEY NSLocalizedString(@"Location",nil)
#define DATE_KEY NSLocalizedString(@"Date",nil)
#define VERSION_KEY NSLocalizedString(@"ComPDFKit Version",nil)

#define ISDRAW_KEY @"isDrawKey"
#define ISDRAWLOGO_KEY @"isDrawLogo"
#define ISCONTENTALGINLEGF_KEY @"isContentAlginLeft"

#define SAVEFILEPATH_KEY @"FilePathKey"
#define PASSWORD_KEY @"PassWordKey"

@protocol CAddSignatureViewControllerDelegate <NSObject>

@optional

- (void)CAddSignatureViewControllerSave:(CAddSignatureViewController *)addSignatureViewController signatureConfig:(CPDFSignatureConfig*)config;

- (void)CAddSignatureViewControllerCancel:(CAddSignatureViewController *)addSignatureViewController;

@end

@interface CAddSignatureViewController : UIViewController

@property (nonatomic, assign) NSInteger customType;

@property (nonatomic, weak) id<CAddSignatureViewControllerDelegate> delegate;

- (instancetype)initWithAnnotation:(CPDFSignatureWidgetAnnotation *)annotation SignatureConfig:(CPDFSignatureConfig *)signatureConfig;

@property (nonatomic, strong) CPDFSignatureCertificate *signatureCertificate;

@end

NS_ASSUME_NONNULL_END
