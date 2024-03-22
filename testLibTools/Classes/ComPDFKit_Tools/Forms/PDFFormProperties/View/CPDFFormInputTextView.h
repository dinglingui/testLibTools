//
//  CPDFFormInputTextView.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

@class CPDFFormInputTextView;

@protocol CPDFFormInputTextViewDelegate <NSObject>

@optional

- (void)SetCPDFFormInputTextView:(CPDFFormInputTextView *)view text:(NSString*)completedText;

@end


@interface CPDFFormInputTextView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, weak) id <CPDFFormInputTextViewDelegate> delegate;

@property (nonatomic, strong) UITextView * contentField;


@end
