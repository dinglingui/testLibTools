//
//  CShapeSelectView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CShapeSelectView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CShapeSelectView ()

@property (nonatomic, strong) NSMutableArray *buttonArray;

@end

@implementation CShapeSelectView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.buttonArray = [NSMutableArray array];
        
        UIButton *squareButton = [[UIButton alloc] init];
        [squareButton setImage:[UIImage imageNamed:@"CPDFShapeArrowImageSquare" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [squareButton addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
        squareButton.tag = CShapeSelectTypeSquare;
        [self addSubview:squareButton];
        [self.buttonArray addObject:squareButton];
        
        UIButton *circleButton = [[UIButton alloc] init];
        [circleButton setImage:[UIImage imageNamed:@"CPDFShapeArrowImageCircle" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [circleButton addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
        circleButton.tag = CShapeSelectTypeCircle;
        [self addSubview:circleButton];
        [self.buttonArray addObject:circleButton];
        
        UIButton *arrowButton = [[UIButton alloc] init];
        [arrowButton setImage:[UIImage imageNamed:@"CPDFShapeArrowImageArrow" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [arrowButton addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
        arrowButton.tag = CShapeSelectTypeArrow;
        [self addSubview:arrowButton];
        [self.buttonArray addObject:arrowButton];
        
        UIButton *lineButton = [[UIButton alloc] init];
        [lineButton setImage:[UIImage imageNamed:@"CPDFShapeArrowImageLine" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [lineButton addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
        lineButton.tag = CShapeSelectTypeLine;
        [self addSubview:lineButton];
        [self.buttonArray addObject:lineButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (int i = 0; i < self.buttonArray.count; i++) {
        ((UIButton *)self.buttonArray[i]).frame = CGRectMake((self.bounds.size.width - (self.bounds.size.height*4))/5*(i+1) + self.bounds.size.height*i, 0, self.bounds.size.height, self.bounds.size.height);
        
    }
}

#pragma mark - Action

- (void)buttonItemClicked_select:(UIButton *)button {
    for (int j = 0; j < self.buttonArray.count; j++) {
        ((UIButton *)self.buttonArray[j]).backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }
    ((UIButton *)self.buttonArray[button.tag]).backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(shapeSelectView:tag:)]) {
        [self.delegate shapeSelectView:self tag:button.tag];
    }
}

@end
