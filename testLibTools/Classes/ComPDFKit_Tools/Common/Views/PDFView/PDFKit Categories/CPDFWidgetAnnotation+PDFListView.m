//
//  CPDFWidgetAnnotation+PDFListView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFWidgetAnnotation+PDFListView.h"
#import "CPDFAnnotationHeader.h"

@implementation CPDFWidgetAnnotation (PDFListView)

- (NSSet *)keysForValuesToObserveForUndo {
    static NSSet *widgetKeys = nil;
    if (widgetKeys == nil) {
        NSMutableSet *mutableKeys = [[super keysForValuesToObserveForUndo] mutableCopy];
        [mutableKeys addObjectsFromArray:@[CPDFAnnotationFontKey,
                                           CPDFAnnotationFontColorKey,
                                           CPDFAnnotationBorderColorKey,
                                           CPDFAnnotationBackgroundColorKey]];
        widgetKeys = [mutableKeys copy];
    }
    return widgetKeys;
}

-(void)drawWithBox:(CPDFDisplayBox)box inContext:(CGContextRef)context {
    if(self.isHidden)
        return;
    [super drawWithBox:box inContext:context];
}

@end
