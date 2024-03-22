//
//  CPDFAnnotationViewController.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFView;
@class CPDFAnnotation;
@class CPDFAnnotationViewController;

@protocol CPDFAnnotationViewControllerDelegate <NSObject>

- (void)annotationViewController:(CPDFAnnotationViewController *)annotationViewController jumptoPage:(NSInteger)pageIndex selectAnnot:(CPDFAnnotation*)annot;

@end


@interface CPDFAnnotationViewController : UIViewController

@property (nonatomic, readonly) CPDFView *pdfView;

@property (nonatomic, weak) id<CPDFAnnotationViewControllerDelegate> delegate;

- (instancetype)initWithPDFView:(CPDFView *)pdfView;

@end

NS_ASSUME_NONNULL_END
