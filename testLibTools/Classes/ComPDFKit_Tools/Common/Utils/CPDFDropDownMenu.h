//
//  CPDFDropDownMenu.h
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

@class CPDFDropDownMenu;

@protocol CPDFDropDownMenuDelegate <NSObject>

- (void)dropDownMenu:(CPDFDropDownMenu*)menu didEditWithText:(NSString*)text;
- (void)dropDownMenu:(CPDFDropDownMenu*)menu didSelectWithIndex:(NSInteger)index;

@end


NS_ASSUME_NONNULL_BEGIN

@interface CPDFDropDownMenu : UIView

@property (nonatomic, assign) id<CPDFDropDownMenuDelegate> delegate;

@property (nonatomic, strong) NSMutableArray * options;

@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, assign) CGFloat menuHeight;

@property (nonatomic, assign) BOOL editable;

@property (nonatomic, strong) UIImage * buttonImage;

@property (nonatomic, copy)   NSString * placeHolder;

@property (nonatomic, copy)   NSString * defaultValue;

@property (nonatomic, strong) UIColor * textColor;

@property (nonatomic, strong) UIFont  * font;

@property (nonatomic, assign) BOOL  showBorder;



@end

NS_ASSUME_NONNULL_END
