//
//  CPDFDrawPencilKitFuncView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFDrawPencilKitFuncView.h"
#import "CPDFColorUtils.h"

@interface CPDFDrawPencilKitFuncView ()

@property (nonatomic,strong) UIButton *eraseButton;

@end

@implementation CPDFDrawPencilKitFuncView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.cornerRadius = 5.0;
        [self initSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float tWidth  = 182.0;
    float tHeight = 54.0;
    
    self.transform = CGAffineTransformIdentity;
    self.frame = CGRectMake(0, 0, tWidth, tHeight);
    
    CGFloat width = self.superview.bounds.size.width-30;
    CGFloat scale = width/self.bounds.size.width;
    if (self.frame.size.width > width) {
        self.transform = CGAffineTransformMakeScale(scale,scale);
        
        self.center = CGPointMake(self.superview.frame.size.width/2.0,
                                  self.frame.size.height/2.0 + 22);

    } else {
        if (@available(iOS 11.0, *)) {
            if (self.window.safeAreaInsets.bottom > 0) {
                self.center = CGPointMake(self.superview.frame.size.width - self.frame.size.width/2.0 - 40,
                                          self.frame.size.height/2.0 + 42);
                
            } else{
                self.center = CGPointMake(self.superview.frame.size.width - self.frame.size.width/2.0 - 30,
                                          self.frame.size.height/2.0 + 22);
            }
        }
    }
}

- (void)initSubViews {
    float tSpace = 10.0;
    float tOffsetX = tSpace;
    float tOffsetY = 5.0;
    float tWidth = 44.0;
    
    UIButton* eraseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    eraseBtn.tag = CPDFDrawPencilKitFuncType_Eraser;
    eraseBtn.layer.cornerRadius = 2.0;
    eraseBtn.frame = CGRectMake(tOffsetX, tOffsetY, tWidth, self.height - tOffsetY*2.0);
    [eraseBtn setImage:[UIImage imageNamed:@"CImageNamePencilEraserOff" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [eraseBtn setImage:[UIImage imageNamed:@"CImageNamePencilEraserOn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [eraseBtn addTarget:self action:@selector(eraserBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:eraseBtn];
    self.eraseButton = eraseBtn;
    tOffsetX = tOffsetX + eraseBtn.frame.size.width + tSpace;
    
    UIButton* clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.tag = CPDFDrawPencilKitFuncType_Cancel;
    clearBtn.layer.cornerRadius = 2.0;
    clearBtn.frame = CGRectMake(tOffsetX, tOffsetY, tWidth+10, self.height - tOffsetY*2.0);
    if (@available(iOS 13.0, *)) {
        [clearBtn setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    } else {
        [clearBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [clearBtn setTitle:NSLocalizedString(@"Discard", nil) forState:UIControlStateNormal];
    clearBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    clearBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [clearBtn addTarget:self action:@selector(clearBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clearBtn];
    tOffsetX = tOffsetX + clearBtn.frame.size.width + tSpace;
    
    UIButton* saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.tag = CPDFDrawPencilKitFuncType_Done;
    saveBtn.layer.cornerRadius = 2.0;
    saveBtn.frame = CGRectMake(tOffsetX, tOffsetY, tWidth, self.frame.size.height - tOffsetY*2.0);
    if (@available(iOS 13.0, *)) {
        [saveBtn setTitleColor:[UIColor labelColor] forState:UIControlStateNormal];
    } else {
        [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [saveBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [saveBtn addTarget:self action:@selector(saveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saveBtn];
}

- (void)resetAllSubviews {
    for (UIView *tSubview in self.subviews) {
        if ([tSubview isKindOfClass:[UIButton class]]) {
            UIButton *tBtn = (UIButton *)tSubview;
            tBtn.selected = NO;
            tBtn.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)clearBtnClicked:(UIButton *)sender {
    [self resetAllSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(drawPencilFuncView:cancelBtn:)]) {
            [self.delegate drawPencilFuncView:self cancelBtn:(UIButton *)sender];
        }
    });
}

- (void)saveBtnClicked:(UIButton *)sender {
    [self resetAllSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(drawPencilFuncView:saveBtn:)]) {
            [self.delegate drawPencilFuncView:self saveBtn:(UIButton *)sender];
        }
    });
}

- (void)eraserBtnClicked:(UIButton *)sender {
    BOOL isSelected = !sender.selected;
    [self resetAllSubviews];
    sender.selected = isSelected;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(drawPencilFuncView:eraserBtn:)]) {
            [self.delegate drawPencilFuncView:self eraserBtn:(UIButton *)sender];
        }
    });
}

- (CGFloat)width {
   return CGRectGetWidth([self frame]);
}

- (void)setWidth:(CGFloat)width {
   CGRect frame = [self frame];
   frame.size.width = width;
   
   
   [self setFrame:CGRectStandardize(frame)];
}

- (CGFloat)height {
   return CGRectGetHeight([self frame]);
}


- (void)setHeight:(CGFloat)height {
   CGRect frame = [self frame];
   frame.size.height = height;
   [self setFrame:CGRectStandardize(frame)];
}

@end
