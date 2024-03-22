//
//  CAnnotStyle.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CAnnotStyle.h"
#import "CPDFListView.h"
#import "CStringConstants.h"

#import "CPDFAnnotation+PDFListView.h"

#import "NSUserDefaults+Utils.h"


#pragma mark - CAnnotStyle

@interface CAnnotStyle ()

@property (nonatomic, strong) NSArray *headKeys;

@property (nonatomic, strong) NSArray *trialKeys;

@property (nonatomic, strong) NSArray *annotations;

@property (nonatomic, assign) CPDFViewAnnotationMode annotMode;

@property (nonatomic, assign) BOOL isSelectAnnot;

@end

@implementation CAnnotStyle


- (instancetype)initWithAnnotionMode:(CPDFViewAnnotationMode)annotionMode annotations:(NSArray *)annotations {
    if (self = [super init]) {
        if(annotations.count > 0) {
            self.isSelectAnnot = YES;
            self.annotations = annotations;
            self.annotMode = [self convertAnnotationType];
        } else {
            self.isSelectAnnot = NO;
            self.annotMode = annotionMode;
        }
    }
    return self;
}

- (CPDFAnnotation *)annotation {
    return self.annotations.firstObject;
}

- (CPDFViewAnnotationMode)convertAnnotationType {
    CPDFViewAnnotationMode annotationType = CPDFViewAnnotationModeNone;
    if ([self.annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
        annotationType = CPDFViewAnnotationModeFreeText;
    } else if ([self.annotation isKindOfClass:[CPDFTextAnnotation class]]) {
        annotationType = CPDFViewAnnotationModeNote;
    } else if ([self.annotation isKindOfClass:[CPDFCircleAnnotation class]]) {
        annotationType = CPDFViewAnnotationModeCircle;
    } else if ([self.annotation isKindOfClass:[CPDFSquareAnnotation class]]) {
        annotationType = CPDFViewAnnotationModeSquare;
    } else if ([self.annotation isKindOfClass:[CPDFMarkupAnnotation class]]) {
        CPDFMarkupAnnotation *markup = (CPDFMarkupAnnotation *)self.annotation;
        if (CPDFMarkupTypeHighlight == markup.markupType) {
            annotationType = CPDFViewAnnotationModeHighlight;
        } else if (CPDFMarkupTypeStrikeOut == markup.markupType) {
            annotationType = CPDFViewAnnotationModeStrikeout;
        } else if (CPDFMarkupTypeUnderline == markup.markupType) {
            annotationType = CPDFViewAnnotationModeUnderline;
        } else if (CPDFMarkupTypeSquiggly == markup.markupType) {
            annotationType = CPDFViewAnnotationModeSquiggly;
        }
    } else if ([self.annotation isKindOfClass:[CPDFLineAnnotation class]]) {
        CPDFLineAnnotation *line = (CPDFLineAnnotation *)self.annotation;
        if (CPDFLineStyleNone == line.endLineStyle && CPDFLineStyleNone == line.startLineStyle) {
            annotationType = CPDFViewAnnotationModeLine;
        } else {
            annotationType = CPDFViewAnnotationModeArrow;
        }
    } else if ([self.annotation isKindOfClass:[CPDFInkAnnotation class]]) {
        annotationType = CPDFViewAnnotationModeInk;
    } else if ([self.annotation isKindOfClass:[CPDFLinkAnnotation class]]) {
        annotationType = CPDFViewAnnotationModeLink;
    } else if ([self.annotation isKindOfClass:[CPDFSignatureAnnotation class]]) {
        annotationType = CPDFViewAnnotationModeSignature;
    } else if ([self.annotation isKindOfClass:[CPDFStampAnnotation class]]) {
        annotationType = CPDFViewAnnotationModeStamp;
    } else if ([self.annotation isKindOfClass:[CPDFSoundAnnotation class]]) {
        annotationType = CPDFViewAnnotationModeSound;
    }else if([self.annotation isKindOfClass:[CPDFTextWidgetAnnotation class]]){
        annotationType = CPDFViewFormModeText;
    }else if([self.annotation isKindOfClass:[CPDFButtonWidgetAnnotation class]]) {
        CPDFButtonWidgetAnnotation * annotation = (CPDFButtonWidgetAnnotation*)self.annotation;
        if(annotation.controlType == CPDFWidgetCheckBoxControl) {
            annotationType = CPDFViewFormModeCheckBox;
        }else if(annotation.controlType == CPDFWidgetRadioButtonControl) {
            annotationType = CPDFViewFormModeRadioButton;
        }else if(annotation.controlType == CPDFWidgetPushButtonControl) {
            annotationType = CPDFViewFormModeButton;
        }
    }else if([self.annotation isKindOfClass:[CPDFChoiceWidgetAnnotation class]]){
        CPDFChoiceWidgetAnnotation * annotation = (CPDFChoiceWidgetAnnotation*)self.annotation;
        if(annotation.isListChoice){
            annotationType = CPDFViewFormModeList;
        }else {
            annotationType = CPDFViewFormModeCombox;
        }
    }

    return annotationType;
}

#pragma mark - Common

- (UIColor *)color {
    UIColor  *color = nil;
    if (self.isSelectAnnot) {
        color = [self annotation].color;
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (_annotMode) {
            case CPDFViewAnnotationModeNote:
                color = [userDefaults PDFListViewColorForKey:CAnchoredNoteColorKey];
                break;
            case CPDFViewAnnotationModeCircle:
                color = [userDefaults PDFListViewColorForKey:CCircleNoteColorKey];
                break;
            case CPDFViewAnnotationModeSquare:
                color = [userDefaults PDFListViewColorForKey:CSquareNoteColorKey];
                break;
            case CPDFViewAnnotationModeHighlight:
                color = [userDefaults PDFListViewColorForKey:CHighlightNoteColorKey];
                break;
            case CPDFViewAnnotationModeUnderline:
                color = [userDefaults PDFListViewColorForKey:CUnderlineNoteColorKey];
                break;
            case CPDFViewAnnotationModeStrikeout:
                color = [userDefaults PDFListViewColorForKey:CStrikeOutNoteColorKey];
                break;
            case CPDFViewAnnotationModeSquiggly:
                color = [userDefaults PDFListViewColorForKey:CSquigglyNoteColorKey];
                break;
            case CPDFViewAnnotationModeLine:
                color = [userDefaults PDFListViewColorForKey:CLineNoteColorKey];
                break;
            case CPDFViewAnnotationModeArrow:
                color = [userDefaults PDFListViewColorForKey:CArrowNoteColorKey];
                break;
            case CPDFViewAnnotationModeInk:
                color = [CPDFKitConfig sharedInstance].freehandAnnotationColor;
                break;
            default:
                break;
        }
    }
    return color;
}

- (void)setColor:(UIColor *)color {
    if (self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            annotation.color = color;
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeNote:
                [userDefaults setPDFListViewColor:color forKey:CAnchoredNoteColorKey];
                break;
            case CPDFViewAnnotationModeCircle:
                [userDefaults setPDFListViewColor:color forKey:CCircleNoteColorKey];
                break;
            case CPDFViewAnnotationModeSquare:
                [userDefaults setPDFListViewColor:color forKey:CSquareNoteColorKey];
                break;
            case CPDFViewAnnotationModeHighlight:
                [userDefaults setPDFListViewColor:color forKey:CHighlightNoteColorKey];
                break;
            case CPDFViewAnnotationModeUnderline:
                [userDefaults setPDFListViewColor:color forKey:CUnderlineNoteColorKey];
                break;
            case CPDFViewAnnotationModeStrikeout:
                [userDefaults setPDFListViewColor:color forKey:CStrikeOutNoteColorKey];
                break;
            case CPDFViewAnnotationModeSquiggly:
                [userDefaults setPDFListViewColor:color forKey:CSquigglyNoteColorKey];
                break;
            case CPDFViewAnnotationModeLine:
                [userDefaults setPDFListViewColor:color forKey:CLineNoteColorKey];
                break;
            case CPDFViewAnnotationModeArrow:
                [userDefaults setPDFListViewColor:color forKey:CArrowNoteColorKey];
                break;
            case CPDFViewAnnotationModeInk:
                [[CPDFKitConfig sharedInstance] setFreehandAnnotationColor:color];
                [userDefaults setPDFListViewColor:color forKey:CInkNoteColorKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

- (CGFloat)opacity {
    CGFloat opacity = 0;
    if (self.isSelectAnnot) {
        opacity = self.annotation.opacity;
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                opacity = [userDefaults floatForKey:CFreeTextNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeNote:
                opacity = [userDefaults floatForKey:CAnchoredNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeCircle:
                opacity = [userDefaults floatForKey:CCircleNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeSquare:
                opacity = [userDefaults floatForKey:CSquareNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeHighlight:
                opacity = [userDefaults floatForKey:CHighlightNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeUnderline:
                opacity = [userDefaults floatForKey:CUnderlineNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeStrikeout:
                opacity = [userDefaults floatForKey:CStrikeOutNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeSquiggly:
                opacity = [userDefaults floatForKey:CSquigglyNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeLine:
                opacity = [userDefaults floatForKey:CLineNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeArrow:
                opacity = [userDefaults floatForKey:CArrowNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeInk:
                opacity = [CPDFKitConfig sharedInstance].freehandAnnotationOpacity;
                opacity/=100;
                break;
            default:
                break;
        }
    }
    return opacity;
}

- (void)setOpacity:(CGFloat)opacity {
    if (self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            [annotation setOpacity:opacity];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                [userDefaults setFloat:opacity forKey:CFreeTextNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeNote:
                [userDefaults setFloat:opacity forKey:CAnchoredNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeCircle:
                [userDefaults setFloat:opacity forKey:CCircleNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeSquare:
                [userDefaults setFloat:opacity forKey:CSquareNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeHighlight:
                [userDefaults setFloat:opacity forKey:CHighlightNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeUnderline:
                [userDefaults setFloat:opacity forKey:CUnderlineNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeStrikeout:
                [userDefaults setFloat:opacity forKey:CStrikeOutNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeSquiggly:
                [userDefaults setFloat:opacity forKey:CSquigglyNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeLine:
                [userDefaults setFloat:opacity forKey:CLineNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeArrow:
                [userDefaults setFloat:opacity forKey:CArrowNoteOpacityKey];
                break;
            case CPDFViewAnnotationModeInk:
                [[CPDFKitConfig sharedInstance] setFreehandAnnotationOpacity:opacity * 100];

                [userDefaults setFloat:opacity forKey:CInkNoteOpacityKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

- (CPDFBorderStyle)style {
    CPDFBorderStyle style = CPDFBorderStyleSolid;
    if (self.isSelectAnnot) {
        style = self.annotation.borderStyle;
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                style = [userDefaults integerForKey:CFreeTextNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeCircle:
                style = [userDefaults integerForKey:CCircleNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeSquare:
                style = [userDefaults integerForKey:CSquareNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeLine:
                style = [userDefaults integerForKey:CLineNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeArrow:
                style = [userDefaults integerForKey:CArrowNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeInk:
                style = [userDefaults integerForKey:CInkNoteLineStyleyKey];
                break;
            default:
                break;
        }
    }
    return style;
}

- (void)setStyle:(CPDFBorderStyle)style {
    if (self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            [annotation setBorderStyle:style];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                [userDefaults setInteger:style forKey:CFreeTextNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeCircle:
                [userDefaults setInteger:style forKey:CCircleNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeSquare:
                [userDefaults setInteger:style forKey:CSquareNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeLine:
                [userDefaults setInteger:style forKey:CLineNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeArrow:
                [userDefaults setInteger:style forKey:CArrowNoteLineStyleKey];
                break;
            case CPDFViewAnnotationModeInk:
                [userDefaults setInteger:style forKey:CInkNoteLineStyleyKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

- (NSArray *)dashPattern {
    if (self.isSelectAnnot) {
        if(CPDFBorderStyleDashed == self.annotation.border.style) {
            return self.annotation.dashPattern;
        } else {
            return 0;
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger dashPattern = 0;
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                dashPattern = [userDefaults integerForKey:CFreeTextNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeCircle:
                dashPattern = [userDefaults integerForKey:CCircleNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeSquare:
                dashPattern = [userDefaults integerForKey:CSquareNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeLine:
                dashPattern = [userDefaults integerForKey:CLineNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeArrow:
                dashPattern = [userDefaults integerForKey:CArrowNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeInk:
                dashPattern = [userDefaults integerForKey:CInkNoteDashPatternKey];
                break;
            default:
                break;
        }
        if(CPDFBorderStyleDashed != self.style) {
            dashPattern=  0;
        }
        return @[@(dashPattern)];
    }
}
- (void)setDashPattern:(NSArray *)dashPatterns {
    if (self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            [annotation setDashPattern:dashPatterns];
        }
    } else {
        NSInteger dashPattern = [dashPatterns.firstObject integerValue];

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                [userDefaults setInteger:dashPattern forKey:CFreeTextNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeCircle:
                [userDefaults setInteger:dashPattern forKey:CCircleNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeSquare:
                [userDefaults setInteger:dashPattern forKey:CSquareNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeLine:
                [userDefaults setInteger:dashPattern forKey:CLineNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeArrow:
                [userDefaults setInteger:dashPattern forKey:CArrowNoteDashPatternKey];
                break;
            case CPDFViewAnnotationModeInk:
                [userDefaults setInteger:dashPattern forKey:CInkNoteDashPatternKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

- (CGFloat)lineWidth {
    CGFloat lineWidth = 0;
    if (self.isSelectAnnot) {
        lineWidth = self.annotation.lineWidth;
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeCircle:
                lineWidth = [userDefaults floatForKey:CCircleNoteLineWidthKey];
                break;
            case CPDFViewAnnotationModeSquare:
                lineWidth = [userDefaults floatForKey:CSquareNoteLineWidthKey];
                break;
            case CPDFViewAnnotationModeLine:
                lineWidth = [userDefaults floatForKey:CLineNoteLineWidthKey];
                break;
            case CPDFViewAnnotationModeArrow:
                lineWidth = [userDefaults floatForKey:CArrowNoteLineWidthKey];
                break;
            case CPDFViewAnnotationModeInk:
                lineWidth = [CPDFKitConfig sharedInstance].freehandAnnotationBorderWidth;
                break;
            default:
                break;
        }
    }
    return lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    if (self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            [annotation setBorderWidth:lineWidth];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeCircle:
                [userDefaults setFloat:lineWidth forKey:CCircleNoteLineWidthKey];
                break;
            case CPDFViewAnnotationModeSquare:
                [userDefaults setFloat:lineWidth forKey:CSquareNoteLineWidthKey];
                break;
            case CPDFViewAnnotationModeLine:
                [userDefaults setFloat:lineWidth forKey:CLineNoteLineWidthKey];
                break;
            case CPDFViewAnnotationModeArrow:
                [userDefaults setFloat:lineWidth forKey:CArrowNoteLineWidthKey];
                break;
            case CPDFViewAnnotationModeInk:
                [[CPDFKitConfig sharedInstance] setFreehandAnnotationBorderWidth:lineWidth];

                [userDefaults setFloat:lineWidth forKey:CInkNoteLineWidthKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}


- (CPDFLineStyle)startLineStyle {
    CPDFLineStyle startLineStyle = CPDFLineStyleNone;
    if (self.isSelectAnnot) {
        if ([self.annotation isKindOfClass:[CPDFLineAnnotation class]]) {
            startLineStyle = [(CPDFLineAnnotation *)self.annotation startLineStyle];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeArrow:
                startLineStyle = [userDefaults integerForKey:CArrowNoteStartStyleKey];
                break;
            case CPDFViewAnnotationModeLine:
                startLineStyle = [userDefaults integerForKey:CLineNoteStartStyleKey];
                break;
            default:
                break;
        }
    }
    return startLineStyle;
}

- (void)setStartLineStyle:(CPDFLineStyle)startLineStyle {
    if(self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            if([annotation isKindOfClass:[CPDFLineAnnotation class]]){
                [(CPDFLineAnnotation*)annotation setStartLineStyle:startLineStyle];
            }
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeArrow:
                [userDefaults setInteger:startLineStyle forKey:CArrowNoteStartStyleKey];
                break;
            case CPDFViewAnnotationModeLine:
                [userDefaults setInteger:startLineStyle forKey:CLineNoteStartStyleKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

- (CPDFLineStyle)endLineStyle {
    CPDFLineStyle endLineStyle = CPDFLineStyleNone;
    if(self.isSelectAnnot) {
        if ([self.annotation isKindOfClass:[CPDFLineAnnotation class]]) {
            endLineStyle = [(CPDFLineAnnotation *)self.annotation endLineStyle];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeArrow:
                endLineStyle = [userDefaults integerForKey:CArrowNoteEndStyleKey];
                break;
            case CPDFViewAnnotationModeLine:
                endLineStyle = [userDefaults integerForKey:CLineNoteEndStyleKey];
                break;
            default:
                break;
        }
    }
    return endLineStyle;
}

-(void)setEndLineStyle:(CPDFLineStyle)endLineStyle {
    if(self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            if([annotation isKindOfClass:[CPDFLineAnnotation class]]){
                [(CPDFLineAnnotation*)annotation setEndLineStyle:endLineStyle];
            }
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeArrow:
                [userDefaults setInteger:endLineStyle forKey:CArrowNoteEndStyleKey];
                break;
            case CPDFViewAnnotationModeLine:
                [userDefaults setInteger:endLineStyle forKey:CLineNoteEndStyleKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

#pragma mark - FreeText

- (UIColor *)fontColor {
    UIColor  *color = nil;
    if (self.isSelectAnnot) {
        if([self.annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
            color = [(CPDFFreeTextAnnotation *)self.annotation fontColor];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                color = [userDefaults PDFListViewColorForKey:CFreeTextNoteFontColorKey];
                break;
            default:
                break;
        }
    }
    return color;
}

- (void)setFontColor:(UIColor *)fontColor {
    if (self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            if ([annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
                CGFloat red,green,blue,alpha;
                [fontColor getRed:&red green:&green blue:&blue alpha:&alpha];
                [(CPDFFreeTextAnnotation *)annotation setFontColor:[UIColor colorWithRed:red green:green blue:blue alpha:self.opacity]];
            }
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                [userDefaults setPDFListViewColor:fontColor forKey:CFreeTextNoteFontColorKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

- (CGFloat)fontSize {
    CGFloat fontSize = 11;
    if (self.isSelectAnnot) {
        if ([self.annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
            fontSize = [(CPDFFreeTextAnnotation *)self.annotation font].pointSize;
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                fontSize = [userDefaults floatForKey:CFreeTextNoteFontSizeKey];
                break;
            default:
                break;
        }
    }
    return fontSize;
}

- (void)setFontSize:(CGFloat)fontSize {
    if (self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            if ([annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
                CPDFFreeTextAnnotation *freeText = (CPDFFreeTextAnnotation *)annotation;

                UIFont  *font = [(CPDFFreeTextAnnotation *)annotation font];
                [(CPDFFreeTextAnnotation *)annotation setFont:[UIFont fontWithName:font.fontName size:fontSize]];
                
                NSDictionary *attributes = @{NSFontAttributeName : freeText.font};
                CGRect bounds = annotation.bounds;

                CGRect rect = [freeText.contents boundingRectWithSize:CGSizeMake(bounds.size.width, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:attributes
                                                              context:nil];
                rect.size.height += 6;
                bounds.origin.y = CGRectGetMaxY(bounds) - rect.size.height;
                bounds.size.height = rect.size.height;
//
                annotation.bounds = bounds;
            }
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                [userDefaults setFloat:fontSize forKey:CFreeTextNoteFontSizeKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }

}

- (NSString *)fontName {
    NSString  *fontName = nil;
    if (self.isSelectAnnot) {
        if ([self.annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
            fontName = [(CPDFFreeTextAnnotation *)self.annotation font].fontName;
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                fontName = [userDefaults objectForKey:CFreeTextNoteFontNameKey];
                break;
            default:
                break;
        }
    }
    return fontName;
}

- (void)setFontName:(NSString *)fontName {
    if (self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            if ([annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
                UIFont  *font = [(CPDFFreeTextAnnotation *)annotation font];
                [(CPDFFreeTextAnnotation *)annotation setFont:[UIFont fontWithName:fontName size:font.pointSize]];
            }
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                [userDefaults setObject:fontName forKey:CFreeTextNoteFontNameKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

- (NSTextAlignment)alignment {
    NSTextAlignment alignment = NSTextAlignmentLeft;
    if (self.isSelectAnnot) {
        if ([self.annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
            alignment = [(CPDFFreeTextAnnotation *)self.annotation alignment];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                alignment = [userDefaults integerForKey:CFreeTextNoteAlignmentKey];
                break;
            default:
                break;
        }
    }
    return alignment;
}

- (void)setAlignment:(NSTextAlignment)alignment {
    if (self.isSelectAnnot){
        for (CPDFAnnotation *annotation in self.annotations) {
        if ([annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
                [(CPDFFreeTextAnnotation *)annotation setAlignment:alignment];
            }
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeFreeText:
                [userDefaults setInteger:alignment forKey:CFreeTextNoteAlignmentKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

#pragma mark - Circle&Square

- (UIColor *)interiorColor {
    UIColor  *interiorColor = nil;
    if (self.isSelectAnnot) {
        if([self.annotation isKindOfClass:[CPDFCircleAnnotation class]] ||
            [self.annotation isKindOfClass:[CPDFSquareAnnotation class]]) {
            interiorColor = [(CPDFCircleAnnotation *)self.annotation interiorColor];
        } else if ([self.annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
            interiorColor = [(CPDFFreeTextAnnotation *)self.annotation color];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeCircle:
                interiorColor = [userDefaults PDFListViewColorForKey:CCircleNoteInteriorColorKey];
                break;
            case CPDFViewAnnotationModeSquare:
                interiorColor = [userDefaults PDFListViewColorForKey:CSquareNoteInteriorColorKey];
                break;
            default:
                break;
        }
    }

    return interiorColor;
}

- (void)setInteriorColor:(UIColor *)interiorColor {
    if (self.isSelectAnnot){
        for (CPDFAnnotation *annotation in self.annotations) {
            if ([annotation isKindOfClass:[CPDFCircleAnnotation class]] ||
                [annotation isKindOfClass:[CPDFSquareAnnotation class]]) {
                [(CPDFCircleAnnotation *)annotation setInteriorColor:interiorColor];
            } else if ([annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
                [(CPDFFreeTextAnnotation *)annotation setColor:interiorColor];
            }
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeCircle:
                [userDefaults setPDFListViewColor:interiorColor forKey:CCircleNoteInteriorColorKey];
                break;
            case CPDFViewAnnotationModeSquare:
                [userDefaults setPDFListViewColor:interiorColor forKey:CSquareNoteInteriorColorKey];
                break;
            default:
                break;
        }
    }
}

- (CGFloat)interiorOpacity {
    CGFloat opacity = 0;
    if (self.isSelectAnnot) {
        if([self.annotation isKindOfClass:[CPDFCircleAnnotation class]] ||
           [self.annotation isKindOfClass:[CPDFSquareAnnotation class]]) {
            opacity = [(CPDFCircleAnnotation *)self.annotation interiorOpacity];
        } else {
            opacity = [self.annotation opacity];
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeCircle:
                opacity = [userDefaults floatForKey:CCircleNoteInteriorOpacityKey];
                break;
            case CPDFViewAnnotationModeSquare:
                opacity = [userDefaults floatForKey:CSquareNoteInteriorOpacityKey];
                break;
            default:
                break;
        }
    }
    return opacity;
}

- (void)setInteriorOpacity:(CGFloat)interiorOpacity {
    if (self.isSelectAnnot) {
        for (CPDFAnnotation *annotation in self.annotations) {
            if ([annotation isKindOfClass:[CPDFCircleAnnotation class]] ||
                [annotation isKindOfClass:[CPDFSquareAnnotation class]]) {
                [(CPDFCircleAnnotation *)annotation setInteriorOpacity:interiorOpacity];
            } else {
                [(CPDFCircleAnnotation *)annotation setOpacity:interiorOpacity];
            }
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch (self.annotMode) {
            case CPDFViewAnnotationModeCircle:
                [userDefaults setFloat:interiorOpacity forKey:CCircleNoteInteriorOpacityKey];
                break;
            case CPDFViewAnnotationModeSquare:
                [userDefaults setFloat:interiorOpacity forKey:CSquareNoteInteriorOpacityKey];
                break;
            default:
                break;
        }
        [userDefaults synchronize];
    }
}

@end
