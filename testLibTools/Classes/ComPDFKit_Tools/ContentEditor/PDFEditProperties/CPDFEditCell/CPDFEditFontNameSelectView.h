//
//  CPDFEditFontNameSelectView.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CPDFEditFontNameSelectView;

@protocol CPDFEditFontNameSelectViewDelegate <NSObject>

@optional

- (void)pickerView:(CPDFEditFontNameSelectView *)colorPickerView fontName:(NSString *)fontName;

@end


@interface CPDFEditFontNameSelectView : UIView

@property (nonatomic, strong) NSMutableArray * fontNameArr;

@property (nonatomic, strong) NSString *fontName;

@property (nonatomic, weak) id<CPDFEditFontNameSelectViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
