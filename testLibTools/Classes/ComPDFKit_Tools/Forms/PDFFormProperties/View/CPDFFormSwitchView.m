//
//  CPDFFormSwitchView.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormSwitchView.h"

@implementation CPDFFormSwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = NSLocalizedString(@"Field Name", nil);
        self.titleLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1.];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [self addSubview:self.titleLabel];
        
        self.switcher = [[UISwitch alloc] init];
        [self addSubview:self.switcher];
        [self.switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(20, 12, self.bounds.size.width - 40, 20);
    self.switcher.frame = CGRectMake(self.bounds.size.width - 70,7, 70, 30);
}

- (void)switchAction:(UISwitch*)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(SwitchActionInView:switcher:)]) {
        [self.delegate SwitchActionInView:self switcher:sender];
    }
}

@end
