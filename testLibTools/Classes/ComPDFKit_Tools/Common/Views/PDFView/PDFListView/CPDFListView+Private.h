//
//  Private.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFListView.h"

typedef NS_ENUM(NSInteger, CPDFAnnotationDraggingType) {
    CPDFAnnotationDraggingNone = 0,
    CPDFAnnotationDraggingCenter,
    CPDFAnnotationDraggingTopLeft,
    CPDFAnnotationDraggingTopRight,
    CPDFAnnotationDraggingBottomLeft,
    CPDFAnnotationDraggingBottomRight,
    CPDFAnnotationDraggingStart,
    CPDFAnnotationDraggingEnd
};

@interface CPDFListView ()

@property (nonatomic, assign) CPDFAnnotationDraggingType draggingType;

@property (nonatomic, assign) CGRect topLeftRect;

@property (nonatomic, assign) CGRect bottomLeftRect;

@property (nonatomic, assign) CGRect topRightRect;

@property (nonatomic, assign) CGRect bottomRightRect;

@property (nonatomic, assign) CGRect startPointRect;

@property (nonatomic, assign) CGRect endPointRect;

@property (nonatomic, assign) CGPoint addAnnotationPoint;

@property (nonatomic, assign) CGRect addAnnotationRect;

@property (nonatomic, assign) CGPoint draggingPoint;

@property (nonatomic, assign) CGPoint menuPoint;

@property (nonatomic, assign) CPDFPage *menuPage;

@property (nonatomic, strong) CPDFAnnotation *menuAnnotation;

@property (nonatomic, strong) NSMutableArray <CPDFAnnotation *>*activeAnnotations;

@property (nonatomic, readonly) CPDFAnnotation *activeAnnotation;

@property (nonatomic, strong) NSMutableArray *notes;

@property (nonatomic, strong) NSMapTable *undoGroupOldPropertiesPerNote;

@property (nonatomic, assign) BOOL undoMove;

@property (nonatomic,retain) CPDFAnnotation *addAnnotation;

@property (nonatomic,retain) CPDFPage *mediaSelectionPage;

@property (nonatomic,assign) CGRect mediaSelectionRect;

- (NSString *)annotationUserName;

@end
