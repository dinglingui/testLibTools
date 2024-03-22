//
//  CShapeSelectView.h
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CShapeSelectType) {
    CShapeSelectTypeSquare = 0,
    CShapeSelectTypeCircle,
    CShapeSelectTypeArrow,
    CShapeSelectTypeLine
};

@class CShapeSelectView;

@protocol CShapeSelectViewDelegate <NSObject>

@optional

- (void)shapeSelectView:(CShapeSelectView *)shapeSelectView tag:(NSInteger)tag;

@end

@interface CShapeSelectView : UIView

@property (nonatomic, weak) id<CShapeSelectViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
