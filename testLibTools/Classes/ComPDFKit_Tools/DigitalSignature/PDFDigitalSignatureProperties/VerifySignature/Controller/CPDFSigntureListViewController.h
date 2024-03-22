//
//  CPDFSigntureListViewController.h
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
#import <ComPDFKit/ComPDFKit.h>

@class CPDFListView;
@class CPDFSigntureListViewController;

@protocol CPDFSigntureListViewControllerDelegate <NSObject>

@optional

- (void)signtureListViewControllerUpdate:(CPDFSigntureListViewController *)signtureListViewController;

@end

@interface CPDFSigntureModel : NSObject

@property (nonatomic,retain) CPDFSignatureCertificate *certificate;

@property (nonatomic,assign) NSInteger level;
@property (nonatomic,assign) NSInteger hide;
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,assign) BOOL isShow;

@end

@interface CPDFSigntureListViewController : UIViewController

@property (nonatomic, weak) id<CPDFSigntureListViewControllerDelegate> delegate;

@property (nonatomic, strong) CPDFSigner *signer;

@property (nonatomic, strong) CPDFListView *PDFListView;

@end
