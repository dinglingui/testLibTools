//
//  CPDFSignatureEditViewController_Header.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#ifndef CPDFSignatureEditViewController_Header_h
#define CPDFSignatureEditViewController_Header_h

#import "CPDFColorPickerView.h"

@interface CPDFSignatureEditViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

- (void)segmentedControlValueChanged_singature:(id)sender;

- (void)initDrawSignatureViewProperties;

- (void)initTextSignatureViewProperties;

- (void)initImageSignatureViewProperties;

- (void)initSegmentedControl;

@property (nonatomic, strong) CPDFColorPickerView *colorPicker;

@end

#endif /* CPDFSignatureEditViewController_Header_h */
