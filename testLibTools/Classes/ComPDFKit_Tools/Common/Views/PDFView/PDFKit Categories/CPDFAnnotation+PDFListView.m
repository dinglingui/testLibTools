//
//  CPDFAnnotation+PDFListView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFAnnotation+PDFListView.h"
#import "CPDFAnnotationHeader.h"

@implementation CPDFAnnotation (PDFListView)

- (NSSet *)keysForValuesToObserveForUndo {
    static NSSet *keys = nil;
    if (keys == nil)
        keys = [[NSSet alloc] initWithObjects:CPDFAnnotationBoundsKey,
                                              CPDFAnnotationborderWidthKey,
                                              CPDFAnnotationBorderKey,
                                              CPDFAnnotationOpacityKey,
                                              CPDFAnnotationColorKey, nil];
    return keys;
}

- (CPDFBorderStyle)borderStyle {
    return [[self border] style];
}

- (void)setBorderStyle:(CPDFBorderStyle)style {
    CPDFBorder *oldBorder = [self border];
    NSMutableArray *dashPattern = [NSMutableArray array];
    if (CPDFBorderStyleDashed == style) {
        [dashPattern addObjectsFromArray:@[@5]];
    }
    CPDFBorder *border = [[CPDFBorder alloc]initWithStyle:style lineWidth:oldBorder.lineWidth dashPattern:dashPattern];
    [self setBorder:border];
}

- (CGFloat)lineWidth {
    return self.borderWidth;
}

- (void)setLineWidth:(CGFloat)width {
    CPDFBorder *oldBorder = [self border];
    CPDFBorder *border = [[CPDFBorder alloc]initWithStyle:oldBorder.style lineWidth:width dashPattern:oldBorder.dashPattern];
    [self setBorder:border];
}

- (NSArray *)dashPattern {
    return [[self border] dashPattern];
}

- (void)setDashPattern:(NSArray *)pattern {
    CPDFBorder *oldBorder = [self border];
    CPDFBorder *border = [[CPDFBorder alloc]initWithStyle:oldBorder.style lineWidth:oldBorder.lineWidth dashPattern:pattern];
    [self setBorder:border];
}


@end
