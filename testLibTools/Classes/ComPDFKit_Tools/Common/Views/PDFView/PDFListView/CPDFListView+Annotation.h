//
//  CPDFListView+Annotation.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
///

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CPDFListView (Annotation)

- (void)annotationTouchBeganAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

- (void)annotationTouchMovedAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

- (void)annotationTouchEndedAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

- (void)annotationTouchCancelledAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

- (void)annotationDrawPage:(CPDFPage *)page toContext:(CGContextRef)context;

- (NSArray<UIMenuItem *> *)annotationMenuItemsAtPoint:(CGPoint)point forPage:(CPDFPage *)page;

- (void)updateScrollEnabled;

- (void)showMenuForAnnotation:(CPDFAnnotation *)annotation;

@end

NS_ASSUME_NONNULL_END
