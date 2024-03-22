//
//  CAnnotationManage.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CAnnotationManage.h"
#import "CPDFListView.h"
#import "CAnnotStyle.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CAnnotationManage ()

@property (nonatomic, strong) CPDFListView *pdfListView;

@property (nonatomic, strong) CPDFAnnotation *annotation;

@property (nonatomic, strong) CAnnotStyle *annotStyle;

@end

@implementation CAnnotationManage

- (instancetype)initWithPDFView:(CPDFListView *)pdfListView {
    if (self = [super init]) {
        self.pdfListView = pdfListView;
    }
    return self;
}

#pragma mark - Publice Methods

- (void)setAnnotStyleFromAnnotations:(NSArray<CPDFAnnotation *> *)annotations {
    self.annotStyle = [[CAnnotStyle alloc] initWithAnnotionMode:CPDFViewAnnotationModeNone annotations:annotations];
}

- (void)refreshPageWithAnnotations:(NSArray *)annotations {
    NSMutableArray *pages = [NSMutableArray array];
    for (CPDFAnnotation * annotation in annotations) {
        CPDFPage *page = annotation.page;
        if(![pages containsObject:page]) {
            [pages addObject:page];
        }
        
    }
    for (CPDFPage *page in pages) {
           [self.pdfListView setNeedsDisplayForPage:page];
    }
}

- (void)setAnnotStyleFromMode:(CPDFViewAnnotationMode)annotationMode {
    self.annotStyle = [[CAnnotStyle alloc] initWithAnnotionMode:annotationMode annotations:@[]];
}

+ (CPDFKitPlatformColor *)highlightAnnotationColor {
    CPDFKitPlatformColor *highlightAnnotationColor = nil;
    CAnnotStyle *annotStyle = [[CAnnotStyle alloc] initWithAnnotionMode:CPDFViewAnnotationModeHighlight annotations:@[]];
    CGFloat red, green, blue, alpha;
    [annotStyle.color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    highlightAnnotationColor = [CPDFKitPlatformColor colorWithRed:red green:green blue:blue alpha:annotStyle.opacity];
    return highlightAnnotationColor;
}

+ (CPDFKitPlatformColor *)underlineAnnotationColor {
    CPDFKitPlatformColor *underlineAnnotationColor = nil;
    CAnnotStyle *annotStyle = [[CAnnotStyle alloc] initWithAnnotionMode:CPDFViewAnnotationModeUnderline annotations:@[]];
    CGFloat red, green, blue, alpha;
    [annotStyle.color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    underlineAnnotationColor = [CPDFKitPlatformColor colorWithRed:red green:green blue:blue alpha:annotStyle.opacity];
    return underlineAnnotationColor;
}

+ (CPDFKitPlatformColor *)strikeoutAnnotationColor {
    CPDFKitPlatformColor *strikeoutAnnotationColor = nil;
    CAnnotStyle *annotStyle = [[CAnnotStyle alloc] initWithAnnotionMode:CPDFViewAnnotationModeStrikeout annotations:@[]];
    CGFloat red, green, blue, alpha;
    [annotStyle.color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    strikeoutAnnotationColor = [CPDFKitPlatformColor colorWithRed:red green:green blue:blue alpha:annotStyle.opacity];
    return strikeoutAnnotationColor;
}

+ (CPDFKitPlatformColor *)squigglyAnnotationColor {
    CPDFKitPlatformColor *squigglyAnnotationColor = nil;
    CAnnotStyle *annotStyle = [[CAnnotStyle alloc] initWithAnnotionMode:CPDFViewAnnotationModeSquiggly annotations:@[]];
    CGFloat red, green, blue, alpha;
    [annotStyle.color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    squigglyAnnotationColor = [CPDFKitPlatformColor colorWithRed:red green:green blue:blue alpha:annotStyle.opacity];
    return squigglyAnnotationColor;
}

+ (CPDFKitPlatformColor *)freehandAnnotationColor {
    CPDFKitPlatformColor *freehandAnnotationColor = nil;
    CAnnotStyle *annotStyle = [[CAnnotStyle alloc] initWithAnnotionMode:CPDFViewAnnotationModeInk annotations:@[]];
    CGFloat red, green, blue, alpha;
    [annotStyle.color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    freehandAnnotationColor = [CPDFKitPlatformColor colorWithRed:red green:green blue:blue alpha:annotStyle.opacity];
    return freehandAnnotationColor;
}

@end
