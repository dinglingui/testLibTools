//
//  CInputTextField.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CInputTextField.h"
#import "CPDFColorUtils.h"

@interface CInputTextField () <UITextFieldDelegate>

@end

@implementation CInputTextField

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor grayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.titleLabel];
        
        self.inputTextField = [[UITextField alloc] init];
        self.inputTextField.backgroundColor = [UIColor clearColor];
        self.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
        self.inputTextField.font = [UIFont systemFontOfSize:13];
        self.inputTextField.delegate = self;
        [self.inputTextField addTarget:self action:@selector(textField_change:) forControlEvents:UIControlEventEditingChanged];
        self.inputTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.inputTextField];
        
        self.leftMargin = self.rightMargin = self.rightTitleMargin = 0;
        
        self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(self.rightTitleMargin, 0, self.frame.size.width, self.frame.size.height/2);
    self.inputTextField.frame = CGRectMake(self.leftMargin, self.frame.size.height/2, self.frame.size.width + self.leftMargin + self.rightMargin, self.frame.size.height/2);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setCInputTextFieldClear:)]) {
        [self.delegate setCInputTextFieldClear:self];
    }
    return YES;
}

- (void)textField_change:(UITextField *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setCInputTextFieldChange:text:)]) {
        [self.delegate setCInputTextFieldChange:self text:sender.text];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.delegate && [self.delegate respondsToSelector:@selector(setCInputTextFieldBegin:)]) {
        [self.delegate setCInputTextFieldBegin:self];
    }
    return YES;
}

@end
