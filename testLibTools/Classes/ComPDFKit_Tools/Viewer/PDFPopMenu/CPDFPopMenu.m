//
//  CPDFPopMenu.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CPDFPopMenu.h"
#import "UIView+Extension.h"

@interface CPDFPopMenu()

@property (nonatomic, assign) CGRect lastRect;

@end

@implementation CPDFPopMenu


- (instancetype) initWithContentView:(UIView *) contentView {
    if (self = [super init]) {
        self.contentView = contentView;
    }

    return self;
}

+ (instancetype) popMenuWithContentView:(UIView *) contentView {
    return [[self alloc] initWithContentView:contentView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *coverLayer = [UIButton buttonWithType:UIButtonTypeCustom];
        self.coverLayer = coverLayer;
        [self setDimCoverLayer:YES];
        [coverLayer addTarget:self action:@selector(coverLayerClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:coverLayer];

        UIImageView *backgroundContainer = [[UIImageView alloc] init];
        self.backgroundContainer = backgroundContainer;
        backgroundContainer.userInteractionEnabled = YES;
        [self addSubview:backgroundContainer];
    }

    return self;
}

- (void) coverLayerClicked {
    [self hideMenu];
}

#pragma mark - Usage

- (void)showMenuInRect:(CGRect) rect {
    self.lastRect = rect;
    UIView *window = [[UIApplication sharedApplication] keyWindow];
    self.frame = window.bounds;
    [window addSubview:self];

    self.coverLayer.frame = window.bounds;
    self.backgroundContainer.frame = rect;

    if (self.contentView) {
        CGFloat topMargin = 12;
        CGFloat leftMargin = 5;
        CGFloat bottomMargin = 8;
        CGFloat rightMargin = 5;

        self.contentView.x = leftMargin;
        self.contentView.y = topMargin;
        self.contentView.width = self.backgroundContainer.width - leftMargin - rightMargin;
        self.contentView.height = self.backgroundContainer.height - topMargin - bottomMargin;

        [self.backgroundContainer addSubview:self.contentView];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(menuDidClosedIn:isClosed:)]) {
        [self.delegate menuDidClosedIn:self isClosed:NO];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void) hideMenu {

    [self removeFromSuperview];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(menuDidClosedIn:isClosed:)]) {
        [self.delegate menuDidClosedIn:self isClosed:YES];
    }
}

#pragma mark - Property

- (void)setDimCoverLayer:(BOOL)dimCoverLayer {
    if (dimCoverLayer) {
        self.coverLayer.backgroundColor = [UIColor blackColor];
        self.coverLayer.alpha = 0.2;
    } else {
        self.coverLayer.backgroundColor = [UIColor clearColor];
        self.coverLayer.alpha = 1.0;
    }
}

@end
