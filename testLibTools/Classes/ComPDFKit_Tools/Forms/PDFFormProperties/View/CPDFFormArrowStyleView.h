//
//  CPDFFormArrowStyleView.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

@class CPDFFormArrowStyleView;

@protocol CPDFFormArrowStyleViewDelegate <NSObject>

@optional
- (void)CPDFFormArrowStyleViewClicked:(CPDFFormArrowStyleView *)view;
@end


@interface CPDFFormArrowStyleView : UIView

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * arrowImageView;

@property (nonatomic, weak) id<CPDFFormArrowStyleViewDelegate> delegate;

@end

