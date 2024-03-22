//
//  CStampShapView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CStampShapView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/CPDFColorUtils.h>
#else
#import "CPDFColorUtils.h"
#endif
@interface CStampShapView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *centerButton;

@property (nonatomic, strong) UIButton *leftButton;

@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UIButton *noneButton;

@property (nonatomic, strong) UIView *shapeView;

@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation CStampShapView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = NSLocalizedString(@"Style", nil);
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.titleLabel.textColor = [UIColor grayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.titleLabel];
        
        self.shapeView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, self.bounds.size.width, 60)];
        [self addSubview:self.shapeView];
        
        self.buttonArray = [NSMutableArray array];
    
        self.centerButton = [[UIButton alloc] init];
        [self.centerButton setImage:[UIImage imageNamed:@"CPDFStampTextImageCenter" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.centerButton addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
        self.centerButton.tag = 0;
        self.centerButton.layer.cornerRadius = 5.0;
        self.centerButton.layer.masksToBounds = YES;
        [self.shapeView addSubview:self.centerButton];
        [self.buttonArray addObject:self.centerButton];
        
        self.centerButton.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        
        self.leftButton = [[UIButton alloc] init];
        [self.leftButton setImage:[UIImage imageNamed:@"CPDFStampTextImageLeft" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
        self.leftButton.tag = 1;
        self.leftButton.layer.cornerRadius = 5.0;
        self.leftButton.layer.masksToBounds = YES;
        [self.shapeView addSubview:self.leftButton];
        [self.buttonArray addObject:self.leftButton];
        
        self.rightButton = [[UIButton alloc] init];
        [self.rightButton setImage:[UIImage imageNamed:@"CPDFStampTextImageRight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
        self.rightButton.tag = 2;
        self.rightButton.layer.cornerRadius = 5.0;
        self.rightButton.layer.masksToBounds = YES;
        [self.shapeView addSubview:self.rightButton];
        [self.buttonArray addObject:self.rightButton];
        
        self.noneButton = [[UIButton alloc] init];
        [self.noneButton setImage:[UIImage imageNamed:@"CPDFStampTextImageNone" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.noneButton addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
        self.noneButton.tag = 3;
        self.noneButton.layer.cornerRadius = 5.0;
        self.noneButton.layer.masksToBounds = YES;
        [self.shapeView addSubview:self.noneButton];
        [self.buttonArray addObject:self.noneButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(20, 0, 50, self.bounds.size.height/3);
    self.shapeView.frame = CGRectMake(0, self.bounds.size.height/3, self.bounds.size.width, (self.bounds.size.height/3)*2);
    self.centerButton.frame = CGRectMake((self.shapeView.bounds.size.width - (44*4))/5, (self.shapeView.bounds.size.height-44)/2, 44, 44);
    self.leftButton.frame = CGRectMake(((self.shapeView.bounds.size.width - (44*4))/5)*2 + 44, (self.shapeView.bounds.size.height-44)/2, 44, 44);
    self.rightButton.frame = CGRectMake(((self.shapeView.bounds.size.width - (44*4))/5)*3 + 44*2, (self.shapeView.bounds.size.height-44)/2, 44, 44);
    self.noneButton.frame = CGRectMake(((self.shapeView.bounds.size.width - (44*4))/5)*4 + 44*3, (self.shapeView.bounds.size.height-44)/2, 44, 44);
}

#pragma mark - Action

- (void)buttonItemClicked_select:(UIButton *)button {
    for (int j = 0; j < self.buttonArray.count; j++) {
        ((UIButton *)self.buttonArray[j]).backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }
    ((UIButton *)self.buttonArray[button.tag]).backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stampShapView:tag:)]) {
        [self.delegate stampShapView:self tag:button.tag];
    }
}

@end
