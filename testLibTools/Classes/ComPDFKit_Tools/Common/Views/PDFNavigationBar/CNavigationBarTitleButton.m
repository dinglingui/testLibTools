//
//  CNavigationBarTitleButton.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CNavigationBarTitleButton.h"

@implementation CNavigationBarTitleButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:17.];
        
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [self.titleLabel setTextAlignment:NSTextAlignmentRight];
        
        self.titleLabel.numberOfLines = 0;
        
        [self setAdjustsImageWhenDisabled:NO];
        
        [self.imageView setContentMode:UIViewContentModeCenter];

    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat height = contentRect.size.height;
    CGFloat width = height;
    CGFloat x = self.frame.size.width - width;
    CGFloat y = 0;
    return CGRectMake(x, y, width, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGFloat height = contentRect.size.height;
    CGFloat width = self.frame.size.width - height;
    CGFloat x = 0;
    CGFloat y = 0;
    return CGRectMake(x, y, width, height);
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    
    NSDictionary *param = @{NSFontAttributeName:self.titleLabel.font};
    CGFloat titleWidth = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:param context:nil].size.width;
    
    CGRect frame = self.frame;
    frame.size.width = titleWidth + self.frame.size.height + 10;
    self.frame = frame;
}

@end
