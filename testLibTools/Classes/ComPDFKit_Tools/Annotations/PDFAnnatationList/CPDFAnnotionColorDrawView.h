//
//  CPDFAnnotionColorDrawView.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CPDFAnnotionMarkUpType) {
    CPDFAnnotionMarkUpTypeHighlight,
    CPDFAnnotionMarkUpTypeUnderline,
    CPDFAnnotionMarkUpTypeStrikeout,
    CPDFAnnotionMarkUpTypeSquiggly,
    CPDFAnnotionMarkUpTypeFreehand
};


NS_ASSUME_NONNULL_BEGIN

@interface CPDFAnnotionColorDrawView : UIView

@property(nonatomic, strong)UIColor * lineColor;

@property(nonatomic, assign)CPDFAnnotionMarkUpType markUpType;

@end

NS_ASSUME_NONNULL_END
