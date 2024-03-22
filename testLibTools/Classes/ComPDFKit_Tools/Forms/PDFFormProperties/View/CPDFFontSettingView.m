//
//  CPDFFontSettingView.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFontSettingView.h"
#import "CPDFColorUtils.h"

@interface CPDFFontSettingView()
@property (nonatomic, strong) UIButton * boldBtn;
@property (nonatomic, strong) UIButton * italicBtn;
@property (nonatomic, strong) UIButton * fontSelectBtn;

@property (nonatomic, strong) UIView * dropMenuView;
@property (nonatomic, strong) UIView * splitView;
@property (nonatomic, strong) UIView * styleView;
@property (nonatomic, strong) UIImageView *dropDownIcon;

@end

@implementation CPDFFontSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.fontNameLabel = [[UILabel alloc] init];
        self.fontNameLabel.text =  NSLocalizedString(@"Font", nil);
        self.fontNameLabel.font = [UIFont systemFontOfSize:14];
        self.fontNameLabel.textColor = [UIColor colorWithRed:153./255 green:153./255 blue:153./255 alpha:1.];
        [self addSubview:self.fontNameLabel];
        
        self.fontNameSelectLabel = [[UILabel alloc] init];
        
        self.italicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.italicBtn setImage:[UIImage imageNamed:@"CPDFEditItalicNormal" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.italicBtn setImage:[UIImage imageNamed:@"CPDFEditItalicHighlight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [self.italicBtn addTarget:self action:@selector(fontItalicAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.boldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.boldBtn setImage:[UIImage imageNamed:@"CPDFEditBoldNormal" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.boldBtn setImage:[UIImage imageNamed:@"CPDFEditBoldHighlight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [self.boldBtn addTarget:self action:@selector(fontBoldAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.dropMenuView = [[UIView alloc] init];
        [self addSubview:self.dropMenuView];
        
        self.splitView = [[UIView alloc] init];
        self.splitView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [self.dropMenuView addSubview:self.splitView];
        
        self.dropDownIcon = [[UIImageView alloc] init];
        self.dropDownIcon.image = [UIImage imageNamed:@"CPDFEditArrow" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        [self.dropMenuView addSubview:self.dropDownIcon];
        
        self.fontNameSelectLabel = [[UILabel alloc] init];
        self.fontNameSelectLabel.adjustsFontSizeToFitWidth = YES;
        [self.dropMenuView addSubview:self.fontNameSelectLabel];
        self.fontNameSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
        
        self.fontSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fontSelectBtn.backgroundColor = [UIColor clearColor];
        [self.fontSelectBtn addTarget:self action:@selector(showFontNameAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.dropMenuView addSubview:self.fontSelectBtn];
        
        self.styleView = [[UIView alloc] init];
        self.styleView.layer.cornerRadius = 4;
        self.styleView.backgroundColor = [UIColor colorWithRed:73/255.0 green:130/255.0 blue:230/255.0 alpha:0.08];
        [self addSubview:self.styleView];
        [self.styleView addSubview:self.italicBtn];
        [self.styleView addSubview:self.boldBtn];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.fontNameLabel.frame = CGRectMake(20, 0, 30, 30);
    self.boldBtn.frame = CGRectMake(0, 0, 40, 30);
    self.italicBtn.frame = CGRectMake(40, 0, 40, 30);
    
    self.dropMenuView.frame = CGRectMake(CGRectGetMaxX(self.fontNameLabel.frame) + 20, 0, self.frame.size.width - CGRectGetMaxX(self.fontNameLabel.frame) - 20 -  20 - 80 - 20, 30);
    self.splitView.frame = CGRectMake(0, 29, self.dropMenuView.bounds.size.width, 1);
    
    self.dropDownIcon.frame = CGRectMake(self.dropMenuView.bounds.size.width - 24 - 5, 3, 24, 24);
    self.fontNameSelectLabel.frame = CGRectMake(10, 0, self.dropMenuView.bounds.size.width - 40, 29);
    
    self.fontSelectBtn.frame = self.dropMenuView.bounds;
    self.styleView.frame  = CGRectMake(self.frame.size.width - 100, 0, 80, 30);
    
    //bold
    UIBezierPath *maskPath=[UIBezierPath bezierPathWithRoundedRect:self.boldBtn.bounds byRoundingCorners:UIRectCornerTopLeft |UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *maskLayer=[[CAShapeLayer alloc]init];
    maskLayer.frame = self.boldBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    self.boldBtn.layer.mask = maskLayer;
    
    UIBezierPath *maskPath1=[UIBezierPath bezierPathWithRoundedRect:self.italicBtn.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
    CAShapeLayer *maskLayer1 =[[CAShapeLayer alloc]init];
    maskLayer1.frame = self.italicBtn.bounds;
    maskLayer1.path = maskPath1.CGPath;
    self.italicBtn.layer.mask = maskLayer1;
}

- (IBAction)fontBoldAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected) {
        [self.boldBtn setBackgroundColor:[UIColor colorWithRed:221/255. green:223/255. blue:255/255. alpha:1.]];
    }else{
        [self.boldBtn setBackgroundColor:[UIColor clearColor]];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFFontSettingView:isBold:)]) {
        [self.delegate CPDFFontSettingView:self isBold:sender.selected];
    }
}

- (IBAction)fontItalicAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(sender.selected) {
        [self.italicBtn setBackgroundColor:[UIColor colorWithRed:221/255. green:223/255. blue:255/255. alpha:1.]];
    }else{
        [self.italicBtn setBackgroundColor:[UIColor clearColor]];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFFontSettingView:isItalic:)]) {
        [self.delegate CPDFFontSettingView:self isItalic:sender.selected];
    }
    
}

- (IBAction)showFontNameAction:(UIButton *)sender {
    //push to font selectView
    if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFFontSettingViewFontSelect:)]){
        [self.delegate CPDFFontSettingViewFontSelect:self];
    }
}

#pragma mark - Setter
- (void)setIsBold:(BOOL)isBold {
    _isBold = isBold;
    if(isBold) {
        [self.boldBtn setBackgroundColor:[UIColor colorWithRed:221/255. green:223/255. blue:255/255. alpha:1.]];
    }else{
        [self.boldBtn setBackgroundColor:[UIColor clearColor]];
    }
    [self.boldBtn setSelected:isBold];
}

-(void)setIsItalic:(BOOL)isItalic {
    _isItalic = isItalic;
    if(isItalic) {
        [self.italicBtn setBackgroundColor:[UIColor colorWithRed:221/255. green:223/255. blue:255/255. alpha:1.]];
    }else{
        [self.italicBtn setBackgroundColor:[UIColor clearColor]];
    }
    
    [self.italicBtn setSelected:isItalic];
}


@end
