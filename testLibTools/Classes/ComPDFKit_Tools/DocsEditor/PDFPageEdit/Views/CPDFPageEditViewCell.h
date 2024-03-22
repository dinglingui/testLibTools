//
//  CPDFPageEditViewCell.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFThumbnailViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPDFPageEditViewCell : UICollectionViewCell

- (void)setEdit:(BOOL)editing;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CGSize imageSize;

- (void)setPageRef:(CGPDFPageRef)pageRef;

@end

NS_ASSUME_NONNULL_END
