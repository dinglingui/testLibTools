//
//  CPDFTextPropertyCell.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CPDFTextActionType) {
    CPDFTextActionColorSelect,
    CPDFTextActionFontNameSelect
};

typedef NS_ENUM(NSUInteger, CPDFTextAlignment) {
    CPDFTextAlignmentLeft,
    CPDFTextAlignmentCenter,
    CPDFTextAlignmentRight,
    CPDFTextAlignmentJustified,
    CPDFTextAlignmentNatural
};

NS_ASSUME_NONNULL_BEGIN

@class CPDFView;
@class CPDFColorSelectView;

@interface CPDFTextPropertyCell : UITableViewCell

@property (nonatomic, strong) void(^actionBlock)(CPDFTextActionType actionType);

@property (nonatomic, strong) void(^colorBlock)(UIColor * selectColor);

@property (nonatomic, strong) void(^boldBlock)(BOOL  isBold);

@property (nonatomic, strong) void(^italicBlock)(BOOL  isItalic);

@property (nonatomic, strong) void(^opacityBlock)(CGFloat opacity);

@property (nonatomic, strong) void(^alignmentBlock)(CPDFTextAlignment alignment);

@property (nonatomic, strong) void(^fontSizeBlock)(CGFloat fontSize);

@property (nonatomic, strong) NSString * currentSelectFontName;

@property (nonatomic, strong) CPDFView * pdfView;

@property (nonatomic, readonly) UIButton * boldBtn;
@property (nonatomic, readonly) UIButton * italicBtn;


@end

NS_ASSUME_NONNULL_END
