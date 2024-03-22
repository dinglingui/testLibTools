//
//  KMPDFAnnotation+KMExtensions.h
//  PDFReader
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  The PDF Reader Sample applications are licensed with a modified BSD license.
//  Please see License for details. This notice may not be removed from this file.
//

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFAnnotation (Extensions)

- (NSSet *)keysForValuesToObserveForUndo;

@end
