//
//  CDocumentPasswordViewController.h
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

@class CPDFDocument;
@class CDocumentPasswordViewController;

@protocol CDocumentPasswordViewControllerDelegate <NSObject>

@optional

- (void)documentPasswordViewControllerCancel:(CDocumentPasswordViewController *)documentPasswordViewController;

- (void)documentPasswordViewControllerOpen:(CDocumentPasswordViewController *)documentPasswordViewController document:(CPDFDocument *)document;

@end

@interface CDocumentPasswordViewController : UIViewController

@property (nonatomic, weak) id<CDocumentPasswordViewControllerDelegate> delegate;

- (instancetype)initWithDocument:(CPDFDocument *)document;

@end

NS_ASSUME_NONNULL_END
