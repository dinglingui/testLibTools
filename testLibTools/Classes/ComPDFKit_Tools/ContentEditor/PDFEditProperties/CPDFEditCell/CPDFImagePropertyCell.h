//
//  CPDFImagePropertyCell.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CPDFImageRotateType) {
    CPDFImageRotateTypeLeft = -1,
    CPDFImageRotateTypeRight = 1
};

typedef NS_ENUM(NSUInteger, CPDFImageTransFormType) {
    CPDFImageTransFormTypeHorizontal,
    CPDFImageTransFormTypeVertical
};


NS_ASSUME_NONNULL_BEGIN

@class CPDFView;

@interface CPDFImagePropertyCell : UITableViewCell

+(instancetype)CPDFImagePropertyCell;

@property (nonatomic, strong) void(^rotateBlock)(CPDFImageRotateType rotateType,BOOL isRotated);

@property (nonatomic, strong) void(^transFormBlock)(CPDFImageTransFormType transformType,BOOL isTransformed);

@property (nonatomic, strong) void(^transparencyBlock)(CGFloat transparency);

@property (nonatomic, strong) void(^replaceImageBlock)(void);

@property (nonatomic, strong) void(^exportImageBlock)(void);

@property (nonatomic, strong) void(^cropImageBlock)(void);

@property (nonatomic, strong) CPDFView * pdfView;

@end

NS_ASSUME_NONNULL_END
