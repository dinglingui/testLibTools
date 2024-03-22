//
//  CPDFEditTextSampleView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import "CPDFEditTextSampleView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CPDFEditTextSampleView()

@property (nonatomic, strong) UILabel * sampleLabel;

@end

@implementation CPDFEditTextSampleView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.sampleLabel = [[UILabel alloc] init];
        self.sampleLabel.text = @"Sample";
        self.sampleLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        self.sampleLabel.font = [UIFont systemFontOfSize:20];
        self.sampleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.sampleLabel];
        
        self.backgroundColor = [CPDFColorUtils CAnnotationSampleDrawBackgoundColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.sampleLabel.frame = self.bounds;
}

#pragma mark - setter
- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.sampleLabel.textColor = textColor;
}


- (void)setTextOpacity:(CGFloat)textOpacity {
    _textOpacity = textOpacity;
    self.sampleLabel.alpha = textOpacity;
}

- (void)setIsBold:(BOOL)isBold {
    _isBold = isBold;
    
    if(isBold) {
        if(self.isItalic){
            UIFontDescriptor * fontD = [self.sampleLabel.font.fontDescriptor
                        fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic
                                      ];
            self.sampleLabel.font = [UIFont fontWithDescriptor:fontD size:0];
        }else{
            UIFontDescriptor * fontD = [self.sampleLabel.font.fontDescriptor
                        fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold
                                      ];
            self.sampleLabel.font = [UIFont fontWithDescriptor:fontD size:0];
        }
    }else{
        if(self.isItalic){
            UIFontDescriptor * fontD = [self.sampleLabel.font.fontDescriptor
                        fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic
                                      ];
            self.sampleLabel.font = [UIFont fontWithDescriptor:fontD size:0];
        }else{
            if(self.fontName) {
                self.sampleLabel.font = [UIFont fontWithName:self.fontName size:self.fontSize?self.fontSize:20];
            }else{
                self.sampleLabel.font = [UIFont systemFontOfSize:self.fontSize?self.fontSize:20];
            }

        }

    }

}

- (void)setIsItalic:(BOOL)isItalic {
    _isItalic = isItalic;
    
    if(isItalic) {
        if(self.isBold) {
            UIFontDescriptor * fontD = [self.sampleLabel.font.fontDescriptor
                        fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic|UIFontDescriptorTraitBold];
            self.sampleLabel.font = [UIFont fontWithDescriptor:fontD size:0];
        }else {
            UIFontDescriptor * fontD = [self.sampleLabel.font.fontDescriptor
                        fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
            self.sampleLabel.font = [UIFont fontWithDescriptor:fontD size:0];
        }

       
    }else {
        if(self.isBold) {
            UIFontDescriptor * fontD = [self.sampleLabel.font.fontDescriptor
                        fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
            self.sampleLabel.font = [UIFont fontWithDescriptor:fontD size:0];
        }else{
            if(self.fontName) {
                self.sampleLabel.font = [UIFont fontWithName:self.fontName size:self.fontSize?self.fontSize:20];
            }else{
                self.sampleLabel.font = [UIFont systemFontOfSize:self.fontSize?self.fontSize:20];
            }
        }

    }

}

- (void)setTextAlignmnet:(NSTextAlignment)textAlignmnet {
    _textAlignmnet = textAlignmnet;
    self.sampleLabel.textAlignment = textAlignmnet;
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    if(self.fontName){
        self.sampleLabel.font = [UIFont fontWithName:self.fontName size:fontSize];
    }else{
        self.sampleLabel.font = [UIFont systemFontOfSize:fontSize];
    }

}

- (void)setFontName:(NSString *)fontName {
    _fontName = fontName;
    self.sampleLabel.font = [UIFont fontWithName:fontName size:self.fontSize?self.fontSize:20];
    self.sampleLabel.textColor = self.textColor;
}
@end
