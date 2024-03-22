//
//  CPDFImagePropertyCell.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import "CPDFImagePropertyCell.h"
#import "CPDFDropDownMenu.h"
#import "CPDFOpacitySliderView.h"
#import "CPDFColorUtils.h"

#import <ComPDFKit/ComPDFKit.h>


@interface CPDFImagePropertyCell()<CPDFDropDownMenuDelegate,CPDFOpacitySliderViewDelegate>

@property (nonatomic, strong) CPDFDropDownMenu * menu;
@property (weak, nonatomic) IBOutlet UISlider *transparencySlider;

@property (nonatomic, strong) UILabel *rotateLabel;
@property (nonatomic, strong) UILabel *transformLabel;
@property (nonatomic, strong) UILabel *toolsLabel;

@property (nonatomic, strong) UIButton * leftRotateBtn;

@property (nonatomic, strong) UIButton * rightRotateBtn;

@property (nonatomic, strong) UIView * transformView;

@property (nonatomic, strong) UIButton * hBtn;
@property (nonatomic, strong) UIButton * vBtn;

@property (nonatomic, strong) CPDFOpacitySliderView * opacityView;

@property (nonatomic, strong) UIButton * replaceBtn;

@property (nonatomic, strong) UIButton * exportBtn;

@property (nonatomic, strong) UIButton * cropBtn;

@property (nonatomic, strong) UIView *transformSplitView;


@end

@implementation CPDFImagePropertyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.rotateLabel = [[UILabel alloc] init];
        self.rotateLabel.font = [UIFont systemFontOfSize:13];
        self.rotateLabel.text =  NSLocalizedString(@"Rotate", nil);
        self.rotateLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
        [self.contentView addSubview:self.rotateLabel];
        
        
        self.leftRotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftRotateBtn addTarget:self action:@selector(leftRotateAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.leftRotateBtn setImage:[UIImage imageNamed:@"CPDFEditIRotate" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        NSString * leftTitle = [NSString stringWithFormat:@" %@",NSLocalizedString(@"Rotate Left", nil)];
        [self.leftRotateBtn setTitle:leftTitle forState:UIControlStateNormal];
        [self.leftRotateBtn setTitleColor:[CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        self.leftRotateBtn.titleLabel.font = [UIFont systemFontOfSize:14.];
        self.leftRotateBtn.layer.borderWidth = 1.;
        self.leftRotateBtn.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.leftRotateBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];;
        [self addSubview:self.leftRotateBtn];
        
        self.rightRotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightRotateBtn addTarget:self action:@selector(rightRotateAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightRotateBtn setImage:[UIImage imageNamed:@"CPDFEditRRotate" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        NSString * rightTitle = [NSString stringWithFormat:@" %@",NSLocalizedString(@"Rotate Right", nil)];
        [self.rightRotateBtn setTitle:rightTitle forState:UIControlStateNormal];
        [self.rightRotateBtn setTitleColor:[CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        self.rightRotateBtn.titleLabel.font = [UIFont systemFontOfSize:14.];
        self.rightRotateBtn.layer.borderWidth = 1.;
        self.rightRotateBtn.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.rightRotateBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];;
        [self addSubview:self.rightRotateBtn];
        
        
        self.transformLabel = [[UILabel alloc] init];
        self.transformLabel.font = [UIFont systemFontOfSize:13];
        self.transformLabel.text =  NSLocalizedString(@"Flip", nil);
        self.transformLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
        [self.contentView addSubview:self.transformLabel];
        
        self.transformView = [[UIView alloc] init];
        self.transformView.layer.borderWidth = 1;
        self.transformView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
        [self.contentView addSubview:self.transformView];
        
        
        self.vBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.vBtn setImage:[UIImage imageNamed:@"CPDFEditVerticalFlip" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.vBtn addTarget:self action:@selector(verticalAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.hBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.hBtn setImage:[UIImage imageNamed:@"CPDFEditHorizontalFlip" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.hBtn addTarget:self action:@selector(horizontalAction:) forControlEvents:UIControlEventTouchUpInside];

        
        [self.transformView addSubview:self.hBtn];
        [self.transformView addSubview:self.vBtn];
        
        self.opacityView = [[CPDFOpacitySliderView alloc] init];
        self.opacityView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.opacityView.titleLabel.text = NSLocalizedString(@"Opacity", nil);
        self.opacityView.titleLabel.font = [UIFont systemFontOfSize:13];
        self.opacityView.titleLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
        self.opacityView.startLabel.text = @"0";
        self.opacityView.defaultValue = 1;
        self.opacityView.bgColor = [UIColor clearColor];
        self.opacityView.delegate = self;
        [self.contentView addSubview:self.opacityView];
        
        self.toolsLabel = [[UILabel alloc] init];
        self.toolsLabel.font = [UIFont systemFontOfSize:13];
        self.toolsLabel.text =  NSLocalizedString(@"Tools", nil);
        self.toolsLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
        [self.contentView addSubview:self.toolsLabel];
        
        
        self.replaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.replaceBtn addTarget:self action:@selector(replaceImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.replaceBtn setImage:[UIImage imageNamed:@"CPDFEditReplace" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        NSString * replaceTitle = [NSString stringWithFormat:@" %@",NSLocalizedString(@"Replace", nil)];
        [self.replaceBtn setTitle:replaceTitle forState:UIControlStateNormal];
        [self.replaceBtn setTitleColor: [CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        self.replaceBtn.titleLabel.font  = [UIFont systemFontOfSize:14.f];
        self.replaceBtn.layer.borderWidth = 1;
        self.replaceBtn.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        [self addSubview:self.replaceBtn];
        self.replaceBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];;
    
        
        self.exportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.exportBtn addTarget:self action:@selector(exportImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.exportBtn setImage:[UIImage imageNamed:@"CPDFEditExport" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        NSString * exportTitle = [NSString stringWithFormat:@" %@",NSLocalizedString(@"Export", nil)];
        [self.exportBtn setTitle:exportTitle forState:UIControlStateNormal];
        [self.exportBtn setTitleColor: [CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        self.exportBtn.titleLabel.font  = [UIFont systemFontOfSize:14.f];
        self.exportBtn.layer.borderWidth = 1;
        self.exportBtn.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        [self addSubview:self.exportBtn];
        self.exportBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        
        
        self.cropBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cropBtn addTarget:self action:@selector(cropImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.cropBtn setImage:[UIImage imageNamed:@"CPDFEditCrop" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        NSString * cropTitle = [NSString stringWithFormat:@" %@",NSLocalizedString(@"Crop", nil)];
        [self.cropBtn setTitle:cropTitle forState:UIControlStateNormal];
        [self.cropBtn setTitleColor: [CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        self.cropBtn.titleLabel.font  = [UIFont systemFontOfSize:14.f];
        self.cropBtn.layer.borderWidth = 1;
        self.cropBtn.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        [self addSubview:self.cropBtn];
        self.cropBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];;
        
        self.transformSplitView = [[UIView alloc] init];
        self.transformSplitView.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        [self.transformView addSubview:self.transformSplitView];
        
        self.opacityView.rightMargin = 10;
        self.opacityView.leftMargin = 5;
        self.opacityView.rightTitleMargin = 10;
        
        self.contentView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.rotateLabel.frame = CGRectMake(16, 0, self.bounds.size.width, 20);
    
    
    self.leftRotateBtn.frame = CGRectMake(16, CGRectGetMaxY(self.rotateLabel.frame) + 12, (self.bounds.size.width - 16*2 - 8)/2, 32);
    
    
    self.rightRotateBtn.frame = CGRectMake(CGRectGetMaxX(self.leftRotateBtn.frame) + 4, CGRectGetMaxY(self.rotateLabel.frame) + 12, (self.bounds.size.width - 16*2 -8)/2, 32);
    
    self.transformLabel.frame = CGRectMake(16, CGRectGetMaxY(self.leftRotateBtn.frame) + 16, self.bounds.size.width, 20);
    
    self.transformView.frame = CGRectMake(16, CGRectGetMaxY(self.transformLabel.frame) + 16, 101, 32);
    self.hBtn.frame =  CGRectMake(0, 0, 50, 32);
    self.transformSplitView.frame = CGRectMake(50, 0, 1, 32);
    self.vBtn.frame = CGRectMake(51, 0, 50, 32);
    
    self.opacityView.frame = CGRectMake(6, CGRectGetMaxY(self.transformView.frame)+ 10, self.frame.size.width - 12, 90);
    
    self.toolsLabel.frame = CGRectMake(16, CGRectGetMaxY(self.opacityView.frame) + 16, self.bounds.size.width, 20);
    
    self.replaceBtn.frame = CGRectMake(16, CGRectGetMaxY(self.toolsLabel.frame) + 16,(self.bounds.size.width - 16 * 2 - 8*2)/3, 32);

    
    self.exportBtn.frame = CGRectMake(CGRectGetMaxX(self.replaceBtn.frame) + 8, CGRectGetMaxY(self.toolsLabel.frame) + 16,(self.bounds.size.width - 16 * 2 - 8*2)/3, 32);
    
    self.cropBtn.frame = CGRectMake(CGRectGetMaxX(self.exportBtn.frame) + 8, CGRectGetMaxY(self.toolsLabel.frame) + 16,(self.bounds.size.width - 16 * 2 - 8*2)/3, 32);

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Action
- (IBAction)leftRotateAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(self.rotateBlock){
        self.rotateBlock(CPDFImageRotateTypeLeft, sender.selected);
    }
}

- (IBAction)rightRotateAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if(self.rotateBlock){
        self.rotateBlock(CPDFImageRotateTypeRight, sender.selected);
    }
}


- (IBAction)horizontalAction:(UIButton *)sender {
    if (sender.selected) {
        sender.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    } else {
        sender.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }
    sender.selected = !sender.selected;
    if(self.transFormBlock){
        self.transFormBlock(CPDFImageTransFormTypeHorizontal, sender.selected);
    }
}

- (IBAction)verticalAction:(UIButton *)sender{
    if (sender.selected) {
        sender.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    } else {
        sender.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }
    sender.selected = !sender.selected;
    if(self.transFormBlock){
        self.transFormBlock(CPDFImageTransFormTypeVertical, sender.selected);
    }
}

- (IBAction)replaceImageAction:(UIButton *)sender {
    if(self.replaceImageBlock){
        self.replaceImageBlock();
    }
}

- (IBAction)exportImageAction:(UIButton *)sender {
    if(self.exportImageBlock){
        self.exportImageBlock();
    }
}

- (IBAction)cropImageAction:(UIButton *)sender {
    if(self.cropImageBlock){
        self.cropImageBlock();
    }
}

- (IBAction)sliderAction:(UISlider *)sender {
    self.menu.defaultValue = [NSString stringWithFormat:@"%.2f",sender.value];
    if(self.transparencyBlock){
        self.transparencyBlock(sender.value);
    }
}

#pragma mark - CPDFDropDownMenuDelegate
- (void)dropDownMenu:(CPDFDropDownMenu *)menu didEditWithText:(NSString *)text{
    if([text floatValue] >= 0 && [text floatValue] <= 1){
        self.transparencySlider.value = [text floatValue];
        
        if(self.transparencyBlock){
            self.transparencyBlock([text floatValue]);
        }
    }
}

- (void)dropDownMenu:(CPDFDropDownMenu *)menu didSelectWithIndex:(NSInteger)index{
    float value = [self.menu.options[index] floatValue];
    self.transparencySlider.value = value;
    
    if(self.transparencyBlock){
        self.transparencyBlock(value);
    }
}

- (void)opacitySliderView:(CPDFOpacitySliderView *)opacitySliderView opacity:(CGFloat)opacity {
    if(self.transparencyBlock){
        self.transparencyBlock(opacity);
    }
}

- (void)setPdfView:(CPDFView *)pdfView {
    _pdfView = pdfView;
    self.opacityView.defaultValue = [pdfView getCurrentOpacity];
}

@end
