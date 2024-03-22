//
//  CPDFFontSettingView.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

@class CPDFFontSettingView;

@protocol CPDFFontSettingViewDelegate <NSObject>

@optional

- (void)CPDFFontSettingView:(CPDFFontSettingView *)view isBold:(BOOL)isBold;
- (void)CPDFFontSettingView:(CPDFFontSettingView *)view isItalic:(BOOL)isItalic;
- (void)CPDFFontSettingView:(CPDFFontSettingView *)view text:(NSString*)text;
- (void)CPDFFontSettingViewFontSelect:(CPDFFontSettingView *)view;

@end


@interface CPDFFontSettingView : UIView

@property (nonatomic, strong) UILabel * fontNameLabel;
@property (nonatomic, strong) UILabel * fontNameSelectLabel;

@property (nonatomic, weak) id<CPDFFontSettingViewDelegate> delegate;

@property (nonatomic, assign) BOOL isBold;
@property (nonatomic, assign) BOOL isItalic;

@end
