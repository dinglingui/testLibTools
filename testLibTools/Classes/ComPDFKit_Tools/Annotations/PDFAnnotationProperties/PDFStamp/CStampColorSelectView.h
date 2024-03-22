//
//  CStampColorSelectView.h
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

@class CStampColorSelectView;

@protocol CStampColorSelectViewDelegate <NSObject>

@optional

- (void)stampColorSelectView:(CStampColorSelectView *)StampColorSelectView tag:(NSInteger)tag;

@end

@interface CStampColorSelectView : UIView

@property (nonatomic, strong) UILabel *colorLabel;

@property (nonatomic, strong) UIColor * selectedColor;

@property (nonatomic, weak) id<CStampColorSelectViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
