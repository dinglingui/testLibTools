//
//  CPDFSquareAnnotation+PDFListView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSquareAnnotation+PDFListView.h"
#import "CPDFAnnotationHeader.h"

@implementation CPDFSquareAnnotation (PDFListView)

- (NSSet *)keysForValuesToObserveForUndo {
    static NSSet *circleKeys = nil;
    if (circleKeys == nil) {
        NSMutableSet *mutableKeys = [[super keysForValuesToObserveForUndo] mutableCopy];
        [mutableKeys addObject:CPDFAnnotationInteriorColorKey];
        [mutableKeys addObject:CPDFAnnotationInteriorOpacityKey];
        circleKeys = [mutableKeys copy];
    }
    return circleKeys;
}

@end
