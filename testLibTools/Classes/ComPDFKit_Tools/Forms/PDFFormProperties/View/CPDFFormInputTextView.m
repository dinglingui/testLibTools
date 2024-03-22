//
//  CPDFFormInputTextView.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormInputTextView.h"

@interface CPDFFormInputTextView ()<UITextViewDelegate>

@end

@implementation CPDFFormInputTextView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        [self addSubview:self.titleLabel];
        
        self.contentField = [[UITextView alloc] init];
        self.contentField.layer.cornerRadius = 1;
        self.contentField.layer.borderWidth = 1;
        self.contentField.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.contentField.delegate = self;
        self.contentField.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.contentField];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(20, 0, self.frame.size.width - 40, 30);
    self.contentField.frame = CGRectMake(20, CGRectGetMaxY(self.titleLabel.frame)+ 8, self.frame.size.width - 40, 90);

}

#pragma mark - UITextfieldDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(self.delegate && [self.delegate respondsToSelector:@selector(SetCPDFFormInputTextView:text:)]) {
        [self.delegate SetCPDFFormInputTextView:self text:textView.text];
    }
}



@end
