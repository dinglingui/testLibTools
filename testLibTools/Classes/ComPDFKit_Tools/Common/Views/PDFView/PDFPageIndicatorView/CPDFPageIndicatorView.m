//
//  CPDFPageIndicatorView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFPageIndicatorView.h"
#import "CPDFColorUtils.h"

@interface CPDFPageIndicatorView()

@property(nonatomic, strong) UIButton *pageNumButton;

@property(nonatomic, assign) CPDFPageIndicatorViewPosition atPosition;

@end

@implementation CPDFPageIndicatorView

#pragma mark - Initializers

- (instancetype)init {
    if(self = [super init]) {
        self.pageNumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.userInteractionEnabled = YES;
        [self.pageNumButton addTarget:self action:@selector(buttonItemClick_PageNum:) forControlEvents:UIControlEventTouchUpInside];
        [self.pageNumButton setTitle:[NSString stringWithFormat:@" %d/%d ",0,0] forState:UIControlStateNormal];
        [self addSubview:self.pageNumButton];
        [self.pageNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.indicatorCornerRadius = 5;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark - Public method

- (void)showInView:(UIView *)subView position:(CPDFPageIndicatorViewPosition)position {

    self.atPosition = position;
    [subView addSubview:self];
    [self setNeedsLayout];
    
}

- (void)updatePageCount:(NSUInteger)pageCount currentPageIndex:(NSUInteger)currentPageIndex {
    [self.pageNumButton setTitle:[NSString stringWithFormat:@" %ld/%ld ",currentPageIndex,pageCount] forState:UIControlStateNormal];
    self.pageNumButton.titleLabel.font = [UIFont systemFontOfSize:12.f];
    [self.pageNumButton sizeToFit];
    self.pageNumButton.frame = CGRectMake(self.pageNumButton.frame.origin.x, self.pageNumButton.frame.origin.y, self.pageNumButton.frame.size.width + 10, self.pageNumButton.frame.size.height);

    self.pageNumButton.backgroundColor = self.indicatorBackgroudColor;
    self.layer.cornerRadius = self.indicatorCornerRadius;
    self.pageNumButton.layer.cornerRadius = self.indicatorCornerRadius;

    CGFloat offset = [self pageOffset];

    CGFloat offsetX = offset;
    CGFloat offsetY = offset;

    switch (self.atPosition) {
        case CPDFPageIndicatorViewPositionLeftBottom:
            offsetY = self.superview.frame.size.height - self.pageNumButton.frame.size.height;
            break;
            
        case CPDFPageIndicatorViewPositionCenterBottom:
            offsetY = self.superview.frame.size.height - self.pageNumButton.frame.size.height;
            offsetX = (self.superview.frame.size.width - self.pageNumButton.frame.size.width)/2;
            
        default:
            break;
    }
    
    self.frame = CGRectMake(offsetX, offsetY - offset, self.pageNumButton.frame.size.width, self.pageNumButton.frame.size.height);
    
    [self showPageNumIndicator];
    [self performSelector:@selector(hidePageNumIndicator) withObject:nil afterDelay:3.0];
}

#pragma mark - Action

- (IBAction)buttonItemClick_PageNum:(id)sender {
    if(self.touchCallBack) {
        self.touchCallBack();
    }
}

#pragma mark - Private method

- (CGFloat)pageOffset {
    return 20;
}

- (void)hidePageNumIndicator {
    if (self.hidden)
        return;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    }completion:^(BOOL finished){
        self.hidden = YES;
    }];
}

- (void)showPageNumIndicator {
    if (self.hidden) {
        self.alpha = 1.0;
        self.hidden = NO;
    }
}


@end
