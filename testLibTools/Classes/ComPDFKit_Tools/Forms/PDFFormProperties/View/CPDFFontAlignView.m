//
//  CPDFFontAlignView.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFontAlignView.h"

@interface CPDFFontAlignView()


@property (nonatomic, strong) UIButton *leftAlignBtn;
@property (nonatomic, strong) UIButton *centerAlignBtn;
@property (nonatomic, strong) UIButton *rightAlignBtn;

@property (nonatomic, strong) UIView * alignmnetCoverView;

@property (nonatomic, strong) UIButton * lastSelectAlignBtn;

@end

@implementation CPDFFontAlignView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.alignmentLabel = [[UILabel alloc] init];
        self.alignmentLabel.text =  NSLocalizedString(@"Alignmnet", nil);
        self.alignmentLabel.font = [UIFont systemFontOfSize:14];
        self.alignmentLabel.textColor = [UIColor colorWithRed:153./255 green:153./255 blue:153./255 alpha:1.];
        [self addSubview:self.alignmentLabel];
        
        self.alignmnetCoverView = [[UIView alloc] init];
        self.alignmnetCoverView.layer.borderColor = [UIColor colorWithRed:0.886 green:0.89 blue:0.902 alpha:1.].CGColor;
        self.alignmnetCoverView.layer.borderWidth = 1.;
        [self addSubview:self.alignmnetCoverView];
        
        self.leftAlignBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftAlignBtn setImage:[UIImage imageNamed:@"CPDFEditAlignmentLeft" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]  forState:UIControlStateNormal];
        [self.leftAlignBtn addTarget:self action:@selector(fontAlignmentAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.rightAlignBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightAlignBtn setImage:[UIImage imageNamed:@"CPDFEditAlignmentRight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]  forState:UIControlStateNormal];
        [self.rightAlignBtn addTarget:self action:@selector(fontAlignmentAction:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        self.centerAlignBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.centerAlignBtn setImage:[UIImage imageNamed:@"CPDFEditAligmentCenter" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]  forState:UIControlStateNormal];
        [self.centerAlignBtn addTarget:self action:@selector(fontAlignmentAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.alignmnetCoverView addSubview:self.leftAlignBtn];
        [self.alignmnetCoverView addSubview:self.centerAlignBtn];
        [self.alignmnetCoverView addSubview:self.rightAlignBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.alignmentLabel.frame = CGRectMake(20, 9, 100, 30);
    
    self.leftAlignBtn.frame = CGRectMake(0, 0, 50, 30);
    self.centerAlignBtn.frame = CGRectMake(50, 0, 50, 30);
    self.rightAlignBtn.frame = CGRectMake(100, 0, 50, 30);
    self.alignmnetCoverView.frame = CGRectMake(self.frame.size.width - 170, 9, 150, 30);
}


#pragma mark - Font Alignment
- (IBAction)fontAlignmentAction:(UIButton *)sender {
    
    if(sender == self.lastSelectAlignBtn) {
        return;
    }
    
    sender.selected = !sender.selected;
    
    if(sender.selected == YES) {
        [sender setBackgroundColor:[UIColor colorWithRed:73/255. green:130./255. blue:230/255. alpha:0.16]];
    }
    
    if(sender == self.leftAlignBtn && sender.isSelected){
        [self.centerAlignBtn setSelected:NO];
        [self.rightAlignBtn setSelected:NO];
        
        [self.centerAlignBtn setBackgroundColor:[UIColor clearColor]];
        [self.rightAlignBtn setBackgroundColor:[UIColor clearColor]];
        
//        if(self.alignmentBlock){
//            self.alignmentBlock(CPDFTextAlignmentLeft);
//        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFFontAlignView:algnment:)]) {
            [self.delegate CPDFFontAlignView:self algnment:NSTextAlignmentLeft];
        }
        self.lastSelectAlignBtn = self.leftAlignBtn;
    }else if(sender == self.centerAlignBtn && sender.isSelected){
        [self.rightAlignBtn setSelected:NO];
        [self.leftAlignBtn setSelected:NO];
        
        [self.leftAlignBtn setBackgroundColor:[UIColor clearColor]];
        [self.rightAlignBtn setBackgroundColor:[UIColor clearColor]];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFFontAlignView:algnment:)]) {
            [self.delegate CPDFFontAlignView:self algnment:NSTextAlignmentCenter];
        }
        
        self.lastSelectAlignBtn = self.centerAlignBtn;
    }else if(sender == self.rightAlignBtn && sender.isSelected){
        [self.leftAlignBtn setSelected:NO];
        [self.centerAlignBtn setSelected:NO];
        
        [self.centerAlignBtn setBackgroundColor:[UIColor clearColor]];
        [self.leftAlignBtn setBackgroundColor:[UIColor clearColor]];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFFontAlignView:algnment:)]) {
            [self.delegate CPDFFontAlignView:self algnment:NSTextAlignmentRight];
        }
        self.lastSelectAlignBtn = self.rightAlignBtn;
    }else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFFontAlignView:algnment:)]) {
            [self.delegate CPDFFontAlignView:self algnment:NSTextAlignmentNatural];
        }
    }
}

#pragma mark - Setter
- (void)setAlignment:(NSTextAlignment)alignment {
    _alignment = alignment;
    
    if(alignment == NSTextAlignmentLeft){
        [self.leftAlignBtn setSelected:YES];
        [self.centerAlignBtn setSelected:NO];
        [self.rightAlignBtn setSelected:NO];
        [self.leftAlignBtn setBackgroundColor:[UIColor colorWithRed:73/255. green:130./255. blue:230/255. alpha:0.16]];
        [self.centerAlignBtn setBackgroundColor:[UIColor clearColor]];
        [self.rightAlignBtn setBackgroundColor:[UIColor clearColor]];
    }else if(alignment == NSTextAlignmentCenter) {
        [self.centerAlignBtn setSelected:YES];
        [self.rightAlignBtn setSelected:NO];
        [self.leftAlignBtn setSelected:NO];
        [self.centerAlignBtn setBackgroundColor:[UIColor colorWithRed:73/255. green:130./255. blue:230/255. alpha:0.16]];
        [self.leftAlignBtn setBackgroundColor:[UIColor clearColor]];
        [self.rightAlignBtn setBackgroundColor:[UIColor clearColor]];
    }else if(alignment == NSTextAlignmentRight) {
        [self.rightAlignBtn setSelected:YES];
        [self.leftAlignBtn setSelected:NO];
        [self.centerAlignBtn setSelected:NO];
        [self.rightAlignBtn setBackgroundColor:[UIColor colorWithRed:73/255. green:130./255. blue:230/255. alpha:0.16]];
        [self.centerAlignBtn setBackgroundColor:[UIColor clearColor]];
        [self.leftAlignBtn setBackgroundColor:[UIColor clearColor]];
    }
}


@end
