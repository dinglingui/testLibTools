//
//  CCreateCertificateViewPasswordController.h
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

@class CCreateCertificateViewPasswordController;
@class CPDFSignatureCertificate;
@class CPDFSignatureWidgetAnnotation;
@class CPDFSignatureConfig;

@protocol CCreateCertificateViewControllerDelegate <NSObject>

@optional

- (void)createCertificateViewController:(CCreateCertificateViewPasswordController *)createCertificateViewController PKCS12Cert:(NSString *)path password:(NSString *)password config:(CPDFSignatureConfig *)config;

- (void)createCertificateViewPasswordControllerCancel:(CCreateCertificateViewPasswordController *)createCertificateViewController;

@end

@interface CCreateCertificateViewPasswordController : UIViewController

@property (nonatomic, weak) id<CCreateCertificateViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL isSaveFile;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, assign) NSInteger certUsage;

@property (nonatomic, strong) NSDictionary *certificateInfo;

- (instancetype)initWithAnnotation:(CPDFSignatureWidgetAnnotation *)annotation;

@end

NS_ASSUME_NONNULL_END
