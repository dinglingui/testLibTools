//
//  CStampPreview.h
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

typedef NS_ENUM(NSInteger, TextStampType) {
    TextStampTypeCenter = 0,
    TextStampTypeLeft,
    TextStampTypeRight,
    TextStampTypeNone
};

typedef NS_ENUM(NSInteger, TextStampColorType) {
    TextStampColorTypeBlack = 0,
    TextStampColorTypeRed,
    TextStampColorTypeGreen,
    TextStampColorTypeBlue
};


@interface CStampPreview : UIView {
    double color[3];
}

@property (nonatomic, assign) NSInteger textStampStyle;

@property (nonatomic, assign) NSInteger textStampColorStyle;

@property (nonatomic, assign) BOOL textStampHaveDate;

@property (nonatomic, assign) BOOL textStampHaveTime;

@property (nonatomic, strong) NSString *textStampText;

@property (nonatomic, strong) NSString *dateTime;

@property (nonatomic, assign) CGRect stampBounds;

@property (nonatomic, assign) float scale;

@property (nonatomic, assign) CGFloat leftMargin;

@property (nonatomic, strong) UIColor *color;

- (UIImage *)renderImage;

@end

NS_ASSUME_NONNULL_END
