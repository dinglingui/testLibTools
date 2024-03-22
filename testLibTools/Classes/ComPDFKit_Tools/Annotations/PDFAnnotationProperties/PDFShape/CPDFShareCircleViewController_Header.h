//
//  CPDFShareCircleViewController_Header.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#ifndef CPDFShareCircleViewController_Header_h
#define CPDFShareCircleViewController_Header_h

#import "CPDFAnnotationBaseViewController_Header.h"
#import "CPDFThicknessSliderView.h"

@interface CPDFShapeCircleViewController ()

@property (nonatomic, strong) CPDFColorSelectView *fillColorSelectView;

@property (nonatomic, strong) CPDFThicknessSliderView *thicknessView;

@property (nonatomic, strong) CPDFThicknessSliderView *dottedView;

@property (nonatomic, strong) CPDFColorPickerView *fillColorPicker;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) NSString *titles;

@end

#endif /* CPDFShareCircleViewController_Header_h */
