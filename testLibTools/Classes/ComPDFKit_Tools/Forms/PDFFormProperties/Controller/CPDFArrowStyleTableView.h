//
//  CPDFArrowStyleTableView.h
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
#import <ComPDFKit/ComPDFKit.h>

@class CPDFArrowStyleTableView;

@protocol CPDFArrowStyleTableViewDelegate <NSObject>

@optional

- (void)CPDFArrowStyleTableView:(CPDFArrowStyleTableView *)arrowStyleTableView style:(CPDFWidgetButtonStyle ) widgetButtonStyle;

@end

@interface CPDFArrowStyleTableView : UIView

@property (nonatomic, weak) id<CPDFArrowStyleTableViewDelegate> delegate;

@property (nonatomic, assign) CPDFWidgetButtonStyle style;

@end

