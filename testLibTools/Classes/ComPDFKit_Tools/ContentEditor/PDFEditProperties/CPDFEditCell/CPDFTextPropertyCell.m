//
//  CPDFTextPropertyCell.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//


#import "CPDFTextPropertyCell.h"
#import "CPDFColorSelectView.h"
#import "CPDFOpacitySliderView.h"
#import "CPDFColorPickerView.h"
#import "CPDFThicknessSliderView.h"
#import "CPDFDropDownMenu.h"
#import <ComPDFKit/ComPDFKit.h>
#import "CPDFColorUtils.h"
#import "CPDFSampleView.h"
#import "CPDFEditTextSampleView.h"
#import "CPDFColorUtils.h"
#import "CPDFTextProperty.h"

@interface CPDFTextPropertyCell()<CPDFColorSelectViewDelegate,CPDFOpacitySliderViewDelegate,CPDFThicknessSliderViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *colorAreaView;
@property (weak, nonatomic) IBOutlet UIView *sliderArea;

@property (nonatomic, strong) CPDFColorSelectView * colorView;
@property (nonatomic, strong) CPDFOpacitySliderView * opacityView;
@property (nonatomic, strong) CPDFColorPickerView * colorPickerView;
@property (nonatomic, strong) CPDFThicknessSliderView * thickSliderView;

@property (nonatomic, strong) UIView * fontView;
@property (nonatomic, strong) UIView * alignmentView;
@property (nonatomic, strong) UIView * alignmnetCoverView;
@property (nonatomic, strong) UIView * styleView;
@property (nonatomic, strong) UIView * dropMenuView;
@property (nonatomic, strong) UIView * splitView;
@property (nonatomic, strong) CPDFDropDownMenu * menu;

@property (nonatomic, strong) UIImageView *dropDownIcon;

@property (nonatomic, strong) UILabel * fontNameLabel;
@property (nonatomic, strong) UILabel * alignmentLabel;
@property (nonatomic, strong) UILabel * fontNameSelectLabel;

@property (nonatomic, strong) UIButton *leftAlignBtn;
@property (nonatomic, strong) UIButton *centerAlignBtn;
@property (nonatomic, strong) UIButton *rightAlignBtn;

@property (nonatomic, strong) UIButton * boldBtn;
@property (nonatomic, strong) UIButton * italicBtn;
@property (nonatomic, strong) UIButton * fontSelectBtn;

@property (nonatomic, strong) UIButton * lastSelectAlignBtn;

@end

@implementation CPDFTextPropertyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.colorView  = [[CPDFColorSelectView alloc] init];
        self.colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.colorView.colorLabel.text = NSLocalizedString(@"Font Color", nil);
        self.colorView.delegate = self;
        [self.contentView addSubview:self.colorView];
        
        self.opacityView = [[CPDFOpacitySliderView alloc] init];
        self.opacityView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.opacityView.titleLabel.text = NSLocalizedString(@"Opacity", nil);
        self.opacityView.startLabel.text = @"0";
        self.opacityView.titleLabel.font = [UIFont systemFontOfSize:14];
        self.opacityView.titleLabel.textColor = [UIColor colorWithRed:153./255 green:153./255 blue:153./255 alpha:1.];
        self.opacityView.delegate = self;
        self.opacityView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        [self.contentView addSubview:self.opacityView];
        
        self.fontView = [[UIView alloc] init];
        self.fontView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.fontView];
        
        self.fontNameLabel = [[UILabel alloc] init];
        self.fontNameLabel.text =  NSLocalizedString(@"Font", nil);
        self.fontNameLabel.font = [UIFont systemFontOfSize:14];
        self.fontNameLabel.textColor = [UIColor colorWithRed:153./255 green:153./255 blue:153./255 alpha:1.];
        [self.fontView addSubview:self.fontNameLabel];
        
        self.alignmentView = [[UIView alloc] init];
        self.alignmentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.alignmentView];
        
        self.alignmentLabel = [[UILabel alloc] init];
        self.alignmentLabel.text =  NSLocalizedString(@"Alignmnet", nil);
        self.alignmentLabel.font = [UIFont systemFontOfSize:14];
        self.alignmentLabel.textColor = [UIColor colorWithRed:153./255 green:153./255 blue:153./255 alpha:1.];
        [self.alignmentView addSubview:self.alignmentLabel];
        
        self.alignmnetCoverView = [[UIView alloc] init];
        self.alignmnetCoverView.layer.borderColor = [UIColor colorWithRed:0.886 green:0.89 blue:0.902 alpha:1.].CGColor;
        self.alignmnetCoverView.layer.borderWidth = 1.;
        [self.alignmentView addSubview:self.alignmnetCoverView];
        
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
        
        
        self.thickSliderView = [[CPDFThicknessSliderView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.fontView.frame) + 10, self.frame.size.width-20, 90)];
        self.thickSliderView.titleLabel.text = NSLocalizedString(@"Font Size", nil);
        self.thickSliderView.titleLabel.font = [UIFont systemFontOfSize:14];
        self.thickSliderView.titleLabel.textColor = [UIColor colorWithRed:153./255 green:153./255 blue:153./255 alpha:1.];
        self.thickSliderView.thick = 10;
        self.thickSliderView.delegate = self;
        [self.contentView addSubview:self.thickSliderView];
        
        self.backgroundColor = [UIColor colorWithRed:250./255 green:252./255 blue:255./255 alpha:1.];
        
        self.italicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.italicBtn setImage:[UIImage imageNamed:@"CPDFEditItalicNormal" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.italicBtn setImage:[UIImage imageNamed:@"CPDFEditItalicHighlight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [self.italicBtn addTarget:self action:@selector(fontItalicAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.boldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.boldBtn setImage:[UIImage imageNamed:@"CPDFEditBoldNormal" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.boldBtn setImage:[UIImage imageNamed:@"CPDFEditBoldHighlight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [self.boldBtn addTarget:self action:@selector(fontBoldAction:) forControlEvents:UIControlEventTouchUpInside];
    
        
        self.styleView = [[UIView alloc] init];
        self.styleView.layer.cornerRadius = 4;
        [self.fontView addSubview:self.styleView];
        [self.styleView addSubview:self.italicBtn];
        [self.styleView addSubview:self.boldBtn];
        
        self.dropMenuView = [[UIView alloc] init];
        [self.fontView addSubview:self.dropMenuView];
        
        self.splitView = [[UIView alloc] init];
        self.splitView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [self.dropMenuView addSubview:self.splitView];
        
        self.dropDownIcon = [[UIImageView alloc] init];
        self.dropDownIcon.image = [UIImage imageNamed:@"CPDFEditArrow" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        [self.dropMenuView addSubview:self.dropDownIcon];
        
        self.fontNameSelectLabel = [[UILabel alloc] init];
        self.fontNameSelectLabel.adjustsFontSizeToFitWidth = YES;
        self.fontNameSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
        [self.dropMenuView addSubview:self.fontNameSelectLabel];
        
        self.fontSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.fontSelectBtn.backgroundColor = [UIColor clearColor];
        [self.fontSelectBtn addTarget:self action:@selector(showFontNameAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.dropMenuView addSubview:self.fontSelectBtn];
        
        self.styleView.backgroundColor = [UIColor colorWithRed:73/255. green:130/255. blue:230/255. alpha:0.08];
        self.opacityView.rightMargin = 10;
        self.opacityView.leftMargin = 5;
        self.opacityView.rightTitleMargin = 10;
        
        self.thickSliderView.rightMargin = 20;
        self.thickSliderView.leftMargin = 5;
        self.thickSliderView.leftTitleMargin = 10;
        
        self.fontNameSelectLabel.text = @"Helvetica";
    
        
        self.contentView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
//    self.sampleSuperView .frame = CGRectMake(0, 0, self.frame.size.width, 120);
//    self.textSampleView.frame  = CGRectMake((self.frame.size.width - 300)/2, 15, 300, self.sampleSuperView.bounds.size.height - 30);
    self.colorView.frame = CGRectMake(0, 0, self.frame.size.width, 90);
    self.opacityView.frame = CGRectMake(10, CGRectGetMaxY(self.colorView.frame), self.frame.size.width-10, 90);
    self.fontView.frame = CGRectMake(10, CGRectGetMaxY(self.opacityView.frame)+ 20, self.frame.size.width-20, 30);
    self.alignmentView.frame = CGRectMake(10, CGRectGetMaxY(self.fontView.frame) + 20, self.frame.size.width-20, 30);
    self.thickSliderView.frame = CGRectMake(10, CGRectGetMaxY(self.alignmentView.frame), self.frame.size.width-20, 90);
    self.styleView.frame  = CGRectMake(self.frame.size.width - 100, 0, 80, 30);
    
    self.alignmnetCoverView.frame = CGRectMake(self.frame.size.width - 170, 0, 150, 30);
    
    self.fontNameLabel.frame = CGRectMake(10, 0, 30, 30);
    self.alignmentLabel.frame = CGRectMake(10, 0, 100, 30);
    
    self.leftAlignBtn.frame = CGRectMake(0, 0, 50, 30);
    self.centerAlignBtn.frame = CGRectMake(50, 0, 50, 30);
    self.rightAlignBtn.frame = CGRectMake(100, 0, 50, 30);
    self.boldBtn.frame = CGRectMake(0, 0, 40, 30);
    self.italicBtn.frame = CGRectMake(40, 0, 40, 30);
    
    self.dropMenuView.frame = CGRectMake(CGRectGetMaxX(self.fontNameLabel.frame) + 20, 0, self.frame.size.width - CGRectGetMaxX(self.fontNameLabel.frame) - 20 -  20 - 80 - 20, 30);
    self.splitView.frame = CGRectMake(0, 29, self.dropMenuView.bounds.size.width, 1);
    
    self.dropDownIcon.frame = CGRectMake(self.dropMenuView.bounds.size.width - 24 - 5, 3, 24, 24);
    self.fontNameSelectLabel.frame = CGRectMake(10, 0, self.dropMenuView.bounds.size.width - 40, 29);
    
    self.fontSelectBtn.frame = self.dropMenuView.bounds;
}

- (void)setPdfView:(CPDFView *)pdfView {
    _pdfView = pdfView;
    if(pdfView.editingArea) {
        self.opacityView.defaultValue = [pdfView getCurrentOpacity];
        if(pdfView.isItalicCurrentSelection) {
            [self.italicBtn setSelected:YES];
        }
        
        if(pdfView.isBoldCurrentSelection) {
            [self.boldBtn setSelected:YES];
        }
        
        if(pdfView.editingSelectionAlignment == NSTextAlignmentLeft) {
            [self.leftAlignBtn setSelected:NO];
            [self fontAlignmentAction:self.leftAlignBtn];
        }else if(pdfView.editingSelectionAlignment == NSTextAlignmentCenter) {
            [self.centerAlignBtn setSelected:NO];
            [self fontAlignmentAction:self.centerAlignBtn];
        }else if(pdfView.editingSelectionAlignment == NSTextAlignmentRight) {
            [self.rightAlignBtn setSelected:NO];
            [self fontAlignmentAction:self.rightAlignBtn];
        }
        
        self.colorView.selectedColor = pdfView.editingSelectionFontColor;
        
        self.thickSliderView.defaultValue = pdfView.editingSelectionFontSize / 100.;
    } else {
        self.opacityView.defaultValue = [CPDFTextProperty sharedManager].textOpacity;
        if([CPDFTextProperty sharedManager].isItalic) {
            [self.italicBtn setSelected:NO];
            [self fontItalicAction:self.italicBtn];
        }
        
        if([CPDFTextProperty sharedManager].isBold) {
            [self.boldBtn setSelected:NO];
            [self fontBoldAction:self.boldBtn];
        }
        
        if([CPDFTextProperty sharedManager].textAlignment == NSTextAlignmentLeft) {
            [self.leftAlignBtn setSelected:NO];
            [self fontAlignmentAction:self.leftAlignBtn];
        }else if([CPDFTextProperty sharedManager].textAlignment == NSTextAlignmentCenter) {
            [self.centerAlignBtn setSelected:NO];
            [self fontAlignmentAction:self.centerAlignBtn];
        }else if([CPDFTextProperty sharedManager].textAlignment == NSTextAlignmentRight) {
            [self.rightAlignBtn setSelected:NO];
            [self fontAlignmentAction:self.rightAlignBtn];
        }
        
        self.colorView.selectedColor = [CPDFTextProperty sharedManager].fontColor;
        
        self.thickSliderView.defaultValue = [CPDFTextProperty sharedManager].fontSize/100;
    }
    
}

- (void)setCurrentSelectFontName:(NSString *)currentSelectFontName {
    _currentSelectFontName = currentSelectFontName;
    self.fontNameSelectLabel.text = currentSelectFontName;
}
#pragma mark - CPDFDropDownMenuDelegate

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - CPDFColorSelectViewDelegate
- (void)selectColorView:(CPDFColorSelectView *)select {
    if(self.actionBlock){
        self.actionBlock(CPDFTextActionColorSelect);
    }
}

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    if(self.colorBlock){
        self.colorBlock(color);
    }
}

#pragma mark - OPacitySliderView

- (void)thicknessSliderView:(CPDFThicknessSliderView *)thicknessSliderView thickness:(CGFloat)thickness {
    if(self.fontSizeBlock){
        self.fontSizeBlock(thickness);
    }
}

- (void)opacitySliderView:(CPDFOpacitySliderView *)opacitySliderView opacity:(CGFloat)opacity {
    
    if(self.opacityBlock) {
        self.opacityBlock(opacity);
    }
}

#pragma mark - Action

- (IBAction)fontBoldAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(self.boldBlock){
        self.boldBlock(sender.selected);
    }
}

- (IBAction)fontItalicAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(self.italicBlock){
        self.italicBlock(sender.selected);
    }
    
}

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
        
        if(self.alignmentBlock){
            self.alignmentBlock(CPDFTextAlignmentLeft);
        }
        self.lastSelectAlignBtn = self.leftAlignBtn;
    }else if(sender == self.centerAlignBtn && sender.isSelected){
        [self.rightAlignBtn setSelected:NO];
        [self.leftAlignBtn setSelected:NO];
        
        [self.leftAlignBtn setBackgroundColor:[UIColor clearColor]];
        [self.rightAlignBtn setBackgroundColor:[UIColor clearColor]];
        
        if(self.alignmentBlock){
            self.alignmentBlock(CPDFTextAlignmentCenter);
        }
        self.lastSelectAlignBtn = self.centerAlignBtn;
    }else if(sender == self.rightAlignBtn && sender.isSelected){
        [self.leftAlignBtn setSelected:NO];
        [self.centerAlignBtn setSelected:NO];
        
        [self.centerAlignBtn setBackgroundColor:[UIColor clearColor]];
        [self.leftAlignBtn setBackgroundColor:[UIColor clearColor]];
        
        if(self.alignmentBlock){
            self.alignmentBlock(CPDFTextAlignmentRight);
        }
        
        self.lastSelectAlignBtn = self.rightAlignBtn;
    }else{
        if(self.alignmentBlock){
            self.alignmentBlock(CPDFTextAlignmentNatural);
        }
    }
}

- (IBAction)showFontNameAction:(UIButton *)sender {
    if(self.actionBlock){
        self.actionBlock(CPDFTextActionFontNameSelect);
    }
}



@end
