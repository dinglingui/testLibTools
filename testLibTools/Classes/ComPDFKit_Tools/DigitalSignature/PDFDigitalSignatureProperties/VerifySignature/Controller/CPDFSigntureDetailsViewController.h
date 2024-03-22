//
//  CPDFSigntureDetailsViewController.h
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
#import <ComPDFKit/CPDFSignature.h>

@class CPDFSigntureDetailsViewController;

@protocol CPDFSigntureDetailsViewControllerDelegate <NSObject>

@optional

- (void)signtureDetailsViewControllerTrust:(CPDFSigntureDetailsViewController *)signtureDetailsViewController;

@end

@interface CPDFSigntureDetailsViewController : UIViewController

@property (nonatomic, weak) id<CPDFSigntureDetailsViewControllerDelegate> delegate;

@property (nonatomic, strong) CPDFSignatureCertificate *certificate;

@end
