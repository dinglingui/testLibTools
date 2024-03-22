//
//  CPDFFreeTextAnnotation+PDFListView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFreeTextAnnotation+PDFListView.h"
#import "CPDFAnnotationHeader.h"

@implementation CPDFFreeTextAnnotation (PDFListView)

- (NSSet *)keysForValuesToObserveForUndo {
    static NSSet *freetextKeys = nil;
    if (freetextKeys == nil) {
        NSMutableSet *mutableKeys = [[super keysForValuesToObserveForUndo] mutableCopy];
        [mutableKeys addObjectsFromArray:@[CPDFAnnotationFontKey,
                                           CPDFAnnotationFontColorKey,
                                           CPDFAnnotationAlignmentKey]];
        freetextKeys = [mutableKeys copy];
    }
    return freetextKeys;
}

@end
