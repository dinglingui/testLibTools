//
//  CPDFFormTextFiledView.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

@class CPDFFormTextFieldView;

@protocol CPDFFormTextFiledViewDelegate <NSObject>

@optional

- (void)SetCPDFFormTextFiledView:(CPDFFormTextFieldView *)view text:(NSString*)completedText;

@end

@interface CPDFFormTextFieldView : UIView

@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) UITextField * contentField;

@property (nonatomic, weak) id<CPDFFormTextFiledViewDelegate> delegate;

@end

