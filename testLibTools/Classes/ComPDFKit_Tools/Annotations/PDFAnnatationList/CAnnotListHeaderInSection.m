//
//  CAnnotListHeaderInSection.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import "CAnnotListHeaderInSection.h"

#import "CPDFColorUtils.h"

@interface CAnnotListHeaderInSection()

@property (nonatomic, strong) UIView* shadowView;

@property (nonatomic, strong) UILabel* pagenumber;

@property (nonatomic, strong) UILabel* annotscount;

@property (nonatomic, strong) UIView* mainView;

@property (nonatomic, assign) CGFloat mainViewHeight;

@end

@implementation CAnnotListHeaderInSection

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _mainViewHeight = frame.size.height;
        self.contentView.backgroundColor = [CPDFColorUtils CViewBackgroundColor];
        _mainView = [[UIView alloc] init];
        _mainView.layer.cornerRadius = 2;
        _mainView.layer.masksToBounds = YES;
        [self.contentView addSubview:_mainView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
       ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight))  {
        if (@available(iOS 11.0, *)) {
            width = [UIScreen mainScreen].bounds.size.width - self.window.safeAreaInsets.left;
        } else {
            // Fallback on earlier versions
            width = [UIScreen mainScreen].bounds.size.width;
        }
    }
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        width = self.frame.size.width;
    }
    
    _mainView.frame = CGRectMake(0, 0, width - 21, _mainViewHeight);
    _shadowView.center = _annotscount.center;
}

- (void)setPageNumber:(NSInteger)number {
    if (!_pagenumber) {
        _pagenumber = [[UILabel alloc] init];
        _pagenumber.backgroundColor = [UIColor clearColor];
        if (@available(iOS 13.0, *)) {
            _pagenumber.textColor = [UIColor labelColor];
        } else {
            _pagenumber.textColor = [UIColor blackColor];
        }
        [_pagenumber setFont:[UIFont systemFontOfSize:13.0f]];
        [_mainView addSubview:_pagenumber];
    }
    
    _pagenumber.text = [NSString stringWithFormat:NSLocalizedString(@"Page %ld",nil), (long)number];
    [_pagenumber sizeToFit];
    
    CGRect rect = [_pagenumber frame];
    rect.origin = CGPointMake(16, (self.contentView.frame.size.height-rect.size.height)/2.0);
    _pagenumber.frame = rect;
}

- (void)setAnnotsCount:(NSInteger)count {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(0,1.0);
        _shadowView.layer.shadowOpacity = 0.3;
        [_mainView addSubview:_shadowView];
    }
    
    if (!_annotscount) {
        _annotscount = [[UILabel alloc] init];
        if (@available(iOS 13.0, *)) {
            _annotscount.textColor = [UIColor labelColor];
        } else {
            _annotscount.textColor = [UIColor blackColor];
        }
        [_annotscount setFont:[UIFont boldSystemFontOfSize:13.0f]];
        _annotscount.textAlignment = NSTextAlignmentCenter;
        _annotscount.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _annotscount.layer.cornerRadius = 2;
        _annotscount.layer.masksToBounds = YES;
        [_mainView addSubview:_annotscount];
    }
    
    _annotscount.text = [NSString stringWithFormat:@"%ld", (long)count];
    [_annotscount sizeToFit];
    CGRect rect = [_annotscount frame];
    rect.size.width = rect.size.width < 8 ? 16 : rect.size.width + 8;
    rect.size.height = 16;
    rect.origin = CGPointMake(_mainView.frame.size.width - rect.size.width - 5, (self.contentView.frame.size.height-rect.size.height)/2.0);
    _annotscount.frame = rect;
    _shadowView.frame = rect;
}

@end
