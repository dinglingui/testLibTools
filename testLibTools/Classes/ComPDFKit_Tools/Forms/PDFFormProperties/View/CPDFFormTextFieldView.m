//
//  CPDFFormTextFiledView.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormTextFieldView.h"
#import "CPDFColorUtils.h"

@interface CPDFFormTextFieldView()<UITextFieldDelegate>

@end

@implementation CPDFFormTextFieldView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = NSLocalizedString(@"Name", nil);
        self.titleLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1.];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [self addSubview:self.titleLabel];
        
        self.contentField = [[UITextField alloc] init];
        self.contentField.layer.cornerRadius = 1;
        self.contentField.layer.borderWidth = 1;
        self.contentField.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.contentField.delegate = self;
        [self addSubview:self.contentField];
    
        self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(20, 0, self.bounds.size.width - 40, 20);
    self.contentField.frame = CGRectMake(20, CGRectGetMaxY(self.titleLabel.frame) + 8, self.bounds.size.width - 40, 35);
}


#pragma mark - UITextfieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if(self.delegate && [self.delegate respondsToSelector:@selector(SetCPDFFormTextFiledView:text:)]){
        [self.delegate SetCPDFFormTextFiledView:self text:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}


@end
