//
//  CPDFKeyboardToolbar.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFKeyboardToolbar.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CPDFKeyboardToolbar ()

@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation CPDFKeyboardToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [self.doneButton sizeToFit];
        [self.doneButton addTarget:self action:@selector(buttonItemClick_done:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];
        
        self.backgroundColor = [CPDFColorUtils CPDFKeyboardToolbarColor];
    }
    return self;
}

- (void)layoutSubviews {
    if (@available(iOS 11.0, *)) {
        self.doneButton.frame = CGRectMake(self.frame.size.width-self.superview.safeAreaInsets.right-60, 0, 50, self.frame.size.height);
    } else {
        self.doneButton.frame = CGRectMake(self.frame.size.width-70, 0, 50, self.frame.size.height);
    }
}

- (void)bindToTextView:(UITextView *)textView {
    [textView setInputAccessoryView:self];
}

- (void)bindToTextField:(UITextField *)textField {
    [textField setInputAccessoryView:self];
}

- (void)buttonItemClick_done:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardShouldDissmiss:)]) {
        [self.delegate keyboardShouldDissmiss:self];
    }
}

@end
