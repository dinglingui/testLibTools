//
//  CPDFAnnotationListCell.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import <UIKit/UIKit.h>

@class CPDFAnnotation;

NS_ASSUME_NONNULL_BEGIN

@interface CPDFAnnotationListCell : UITableViewCell

@property(nonatomic, strong) UIImageView *typeImageView;

@property(nonatomic, strong) UILabel *dateLabel;

@property(nonatomic, strong) UILabel *contentLabel;

@property(nonatomic, readonly)CPDFAnnotation *annot;

@property(nonatomic, assign)NSInteger pageNumber;

- (void)updateCellWithAnnotation:(CPDFAnnotation *)annotation;

@end

NS_ASSUME_NONNULL_END
