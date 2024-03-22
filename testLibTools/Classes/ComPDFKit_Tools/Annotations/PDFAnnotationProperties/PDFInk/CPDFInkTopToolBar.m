//
//  CPDFFreehandView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFInkTopToolBar.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface CPDFInkTopToolBar ()

@end

@implementation CPDFInkTopToolBar

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0  blue:170.0/255.0  alpha:1.0].CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.cornerRadius = 5.0;
        
        CGFloat width = self.bounds.size.width/6;
        CGFloat height = self.bounds.size.height;
        
        self.buttonArray = [NSMutableArray array];
        
        UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        settingButton.tag = CPDFInkTopToolBarSetting;
        settingButton.frame = CGRectMake(0, 0, width, height);
        [settingButton setImage:[UIImage imageNamed:@"CPDFInkImageSetting" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [settingButton addTarget:self action:@selector(buttonItemClicked_Switch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:settingButton];
        [self.buttonArray addObject:settingButton];
        
        UIButton *eraseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        eraseButton.tag = CPDFInkTopToolBarErase;
        eraseButton.frame = CGRectMake(width, 0, width, height);
        [eraseButton setImage:[UIImage imageNamed:@"CPDFInkImageEraer" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [eraseButton addTarget:self action:@selector(buttonItemClicked_Switch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:eraseButton];
        [self.buttonArray addObject:eraseButton];
        
        UIButton *undoButton = [[UIButton alloc] init];
        undoButton.tag = CPDFInkTopToolBarUndo;
        undoButton.frame = CGRectMake(width*2, 0, width, height);
        [undoButton setImage:[UIImage imageNamed:@"CPDFInkImageUndo" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [undoButton addTarget:self action:@selector(buttonItemClicked_Switch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:undoButton];
        [self.buttonArray addObject:undoButton];
        
        UIButton *redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        redoButton.tag = CPDFInkTopToolBarRedo;
        redoButton.frame = CGRectMake(width*3, 0, width, height);
        [redoButton setImage:[UIImage imageNamed:@"CPDFInkImageRedo" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [redoButton addTarget:self action:@selector(buttonItemClicked_Switch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:redoButton];
        [self.buttonArray addObject:redoButton];
        
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
        clearButton.tag = CPDFInkTopToolBarClear;
        clearButton.frame = CGRectMake(4*width, 0, width, height);
        [clearButton setTitle:NSLocalizedString(@"Clear", nil) forState:UIControlStateNormal];
        [clearButton setTitleColor:[CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        clearButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [clearButton addTarget:self action:@selector(buttonItemClicked_Switch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearButton];
        [self.buttonArray addObject:clearButton];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(4*width, 10, 1, height-20)];
        view.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.1];
        [self addSubview:view];
        
        UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
        saveButton.tag = CPDFInkTopToolBarSave;
        saveButton.frame = CGRectMake(5*width, 0, width, height);
        [saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        saveButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [saveButton addTarget:self action:@selector(buttonItemClicked_Switch:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveButton];
        [self.buttonArray addObject:saveButton];
        
        self.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }
    return self;
 }

#pragma mark - Action

- (void)buttonItemClicked_Switch:(UIButton *)button {
    for (int j = 0; j < self.buttonArray.count; j++) {
        ((UIButton *)self.buttonArray[j]).backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }
    ((UIButton *)self.buttonArray[button.tag]).backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    
    switch (button.tag) {
        case CPDFInkTopToolBarSetting: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(inkTopToolBar:tag:isSelect:)]) {
                [self.delegate inkTopToolBar:self tag:(CPDFInkTopToolBarSelect)button.tag isSelect:button.isSelected];
            }
        }
            break;
        case CPDFInkTopToolBarErase: {
            button.selected = !button.isSelected;
            if (!button.selected) {
                button.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(inkTopToolBar:tag:isSelect:)]) {
                [self.delegate inkTopToolBar:self tag:(CPDFInkTopToolBarSelect)button.tag isSelect:button.isSelected];
            }
        }
            break;
        case CPDFInkTopToolBarUndo: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(inkTopToolBar:tag:isSelect:)]) {
                [self.delegate inkTopToolBar:self tag:(CPDFInkTopToolBarSelect)button.tag isSelect:button.isSelected];
            }
            ((UIButton *)self.buttonArray[button.tag]).backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        }
            break;
        case CPDFInkTopToolBarRedo: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(inkTopToolBar:tag:isSelect:)]) {
                [self.delegate inkTopToolBar:self tag:(CPDFInkTopToolBarSelect)button.tag isSelect:button.isSelected];
            }
            ((UIButton *)self.buttonArray[button.tag]).backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        }
            break;
        case CPDFInkTopToolBarClear: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(inkTopToolBar:tag:isSelect:)]) {
                [self.delegate inkTopToolBar:self tag:(CPDFInkTopToolBarSelect)button.tag isSelect:button.isSelected];
            }
            [self removeFromSuperview];
        }
            break;
            
        case CPDFInkTopToolBarSave:{
            if (self.delegate && [self.delegate respondsToSelector:@selector(inkTopToolBar:tag:isSelect:)]) {
                [self.delegate inkTopToolBar:self tag:(CPDFInkTopToolBarSelect)button.tag isSelect:button.isSelected];
            }
            [self removeFromSuperview];
        }
            break;
    }
}

@end
