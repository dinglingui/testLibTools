//
//  CPDFStampViewController.h
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

typedef NSString* const PDFAnnotationStampKey NS_STRING_ENUM;

extern PDFAnnotationStampKey PDFAnnotationStampKeyType;        // NSIntger
extern PDFAnnotationStampKey PDFAnnotationStampKeyImagePath;   // NSString
extern PDFAnnotationStampKey PDFAnnotationStampKeyText;        // NSString
extern PDFAnnotationStampKey PDFAnnotationStampKeyShowDate;    // BOOL
extern PDFAnnotationStampKey PDFAnnotationStampKeyShowTime;    // BOOL
extern PDFAnnotationStampKey PDFAnnotationStampKeyStyle;       // NSIntger
extern PDFAnnotationStampKey PDFAnnotationStampKeyShape;       // NSIntger

@class CPDFStampViewController;

@protocol CPDFStampViewControllerDelegate <NSObject>

@optional

- (void)stampViewController:(CPDFStampViewController *)stampViewController selectedIndex:(NSInteger)selectedIndex stamp:(NSDictionary *)stamp;

- (void)stampViewControllerDismiss:(CPDFStampViewController *)stampViewController;

@end

@interface CPDFStampViewController : UIViewController

@property (nonatomic, weak) id<CPDFStampViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
