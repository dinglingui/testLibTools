//
//  CPDFSigntureCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSigntureCell.h"

@implementation CPDFSigntureCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.arrowButton setImage:[UIImage imageNamed:@"ImageNameSignCloseFolder"
                                           inBundle:[NSBundle bundleForClass:self.class]
                      compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    [self.arrowButton setImage:[UIImage imageNamed:@"ImageNameSignOpenFolder"
                                           inBundle:[NSBundle bundleForClass:self.class]
                      compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
}

- (void)setIndentationLevel:(NSInteger)indentationLevel {
    [super setIndentationLevel:indentationLevel];
    
    self.contentOffsetX.constant = indentationLevel*15+10;
}

- (void)setIsShow:(BOOL)isShow {
    _isShow = isShow;
    
    self.model.isShow = self.isShow;
    
    if (self.model.count > 0) {
        if (self.model.isShow) {
            self.arrowButton.selected = YES;
        } else {
            self.arrowButton.selected = NO;
        }
    }
}

- (IBAction)arrowButtonAction:(id)sender {
    if (self.callback) {
        self.callback();
    }
}

@end
