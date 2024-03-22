//
//  CPDFArrowStyleCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFArrowStyleCell.h"
#import "CPDFDrawArrowView.h"
#import "CPDFColorUtils.h"

@implementation CPDFArrowStyleCell

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contextView = [[CPDFDrawArrowView alloc] initWithFrame:CGRectMake(1, 1, self.bounds.size.width - 2, self.bounds.size.height - 2)];
        self.contextView.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
        self.contentView.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
        [self addSubview:self.contextView];
    }
    return self;
}

@end
