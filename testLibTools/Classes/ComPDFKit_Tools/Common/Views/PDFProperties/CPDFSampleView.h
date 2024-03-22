//
//  CPDFSampleView.h
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

typedef NS_ENUM(NSInteger, CPDFSamplesSelectedIndex) {
    CPDFSamplesNote = 0,
    CPDFSamplesHighlight,
    CPDFSamplesUnderline,
    CPDFSamplesStrikeout,
    CPDFSamplesSquiggly,
    CPDFSamplesFreehand,
    CPDFSamplesShapeCircle,
    CPDFSamplesShapeSquare,
    CPDFSamplesShapeArrow,
    CPDFSamplesShapeLine,
    CPDFSamplesFreeText,
    CPDFSamplesSignature,
    CPDFSamplesStamp,
    CPDFSamplesImage,
    CPDFSamplesLink,
    CPDFSamplesSound,
};

typedef NS_ENUM(NSInteger, CPDFArrowStyle) {
    CPDFArrowStyleNone = 0,
    CPDFArrowStyleOpenArrow = 1,
    CPDFArrowStyleClosedArrow = 2,
    CPDFArrowStyleSquare = 3,
    CPDFArrowStyleCircle = 4,
    CPDFArrowStyleDiamond = 5
};

NS_ASSUME_NONNULL_BEGIN

@interface CPDFSampleView : UIView

@property (nonatomic, assign) CPDFSamplesSelectedIndex selecIndex;

@property (nonatomic, assign) CPDFArrowStyle startArrowStyleIndex;

@property (nonatomic, assign) CPDFArrowStyle endArrowStyleIndex;

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) UIColor *interiorColor;

@property (nonatomic, assign) CGFloat opcity;

@property (nonatomic, assign) CGFloat thickness;

@property (nonatomic, assign) CGFloat dotted;

@property (nonatomic, strong) NSString *fontName;

@property (nonatomic, assign) BOOL isBold;

@property (nonatomic, assign) BOOL isItalic;

@property (nonatomic, assign) NSTextAlignment textAlignment;

@end

NS_ASSUME_NONNULL_END
