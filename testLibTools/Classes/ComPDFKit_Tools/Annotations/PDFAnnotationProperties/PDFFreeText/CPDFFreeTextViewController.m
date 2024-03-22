//
//  CPDFFreeTextViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFreeTextViewController.h"
#import "CPDFAnnotationBaseViewController_Header.h"
#import "CPDFThicknessSliderView.h"
#import "CPDFFontStyleTableView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CPDFFreeTextViewController () <UIColorPickerViewControllerDelegate, CPDFThicknessSliderViewDelegate, CPDFFontStyleTableViewDelegate, CPDFColorPickerViewDelegate>

@property (nonatomic, strong) UIButton *boldBtn;

@property (nonatomic, strong) UIButton *italicBtn;

@property (nonatomic, strong) UILabel *alignmentLabel;

@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, strong) UIButton *centerBtn;

@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) CPDFThicknessSliderView *fontsizeSliderView;

@property (nonatomic, assign) BOOL isBold;

@property (nonatomic, assign) BOOL isItalic;

@property (nonatomic, assign) NSString *baseName;

@property (nonatomic, strong) CPDFFontStyleTableView *fontStyleTableView;

@property (nonatomic, strong) UIView * dropMenuView;

@property (nonatomic, strong) UIView * splitView;

@property (nonatomic, strong) UIButton * fontSelectBtn;

@property (nonatomic, strong) UIImageView *dropDownIcon;

@property (nonatomic, strong) UILabel * fontNameLabel;

@property (nonatomic, strong) UILabel * fontNameSelectLabel;

@end

@implementation CPDFFreeTextViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fontNameLabel = [[UILabel alloc] init];
    self.fontNameLabel.text =  NSLocalizedString(@"Font", nil);
    self.fontNameLabel.font = [UIFont systemFontOfSize:14];
    self.fontNameLabel.textColor = [UIColor colorWithRed:153./255 green:153./255 blue:153./255 alpha:1.];
    [self.scrcollView addSubview:self.fontNameLabel];
    
    self.dropMenuView = [[UIView alloc] init];
    [self.scrcollView addSubview:self.dropMenuView];
    
    self.splitView = [[UIView alloc] init];
    self.splitView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    [self.dropMenuView addSubview:self.splitView];
    
    self.dropDownIcon = [[UIImageView alloc] init];
    self.dropDownIcon.image = [UIImage imageNamed:@"CPDFEditArrow" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    [self.dropMenuView addSubview:self.dropDownIcon];
    
    self.fontNameSelectLabel = [[UILabel alloc] init];
    self.fontNameSelectLabel.font = [UIFont systemFontOfSize:14];
    self.fontNameSelectLabel.textColor = [UIColor blackColor];
    [self.dropMenuView addSubview:self.fontNameSelectLabel];
    
    self.fontSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fontSelectBtn.backgroundColor = [UIColor clearColor];
    [self.fontSelectBtn addTarget:self action:@selector(buttonItemClicked_FontStyle:) forControlEvents:UIControlEventTouchUpInside];
    [self.dropMenuView addSubview:self.fontSelectBtn];
    
    self.boldBtn = [[UIButton alloc] init];
    [self.boldBtn setImage:[UIImage imageNamed:@"CPDFFreeTextImageBold" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.boldBtn setImage:[UIImage imageNamed:@"CPDFFreeTextImageBoldHighLinght" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [self.boldBtn addTarget:self action:@selector(buttonItemClicked_Bold:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrcollView addSubview:self.boldBtn];
    
    self.italicBtn = [[UIButton alloc] init];
    [self.italicBtn setImage:[UIImage imageNamed:@"CPDFFreeTextImageUnderline" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.italicBtn setImage:[UIImage imageNamed:@"CPDFFreeTextImageItailcHighLight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [self.italicBtn addTarget:self action:@selector(buttonItemClicked_Italic:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrcollView addSubview:self.italicBtn];
    
    self.alignmentLabel = [[UILabel alloc] init];
    self.alignmentLabel.text = NSLocalizedString(@"Alignment", nil);
    self.alignmentLabel.textColor = [UIColor grayColor];
    self.alignmentLabel.font = [UIFont systemFontOfSize:12.0];
    [self.scrcollView addSubview:self.alignmentLabel];
    
    self.leftBtn = [[UIButton alloc] init];
    [self.leftBtn setImage:[UIImage imageNamed:@"CPDFFreeTextImageLeft" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.leftBtn addTarget:self action:@selector(buttonItemClicked_Left:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrcollView addSubview:self.leftBtn];
    
    self.centerBtn = [[UIButton alloc] init];
    [self.centerBtn setImage:[UIImage imageNamed:@"CPDFFreeTextImageCenter" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.centerBtn addTarget:self action:@selector(buttonItemClicked_Center:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrcollView addSubview:self.centerBtn];
    
    self.rightBtn = [[UIButton alloc] init];
    [self.rightBtn setImage:[UIImage imageNamed:@"CPDFFreeTextImageRight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.rightBtn addTarget:self action:@selector(buttonItemClicked_Right:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrcollView addSubview:self.rightBtn];
    
    self.fontsizeSliderView = [[CPDFThicknessSliderView alloc] init];
    self.fontsizeSliderView.thicknessSlider.value = 20;
    self.fontsizeSliderView.thicknessSlider.minimumValue = 1;
    self.fontsizeSliderView.thicknessSlider.maximumValue = 100;
    self.fontsizeSliderView.titleLabel.text = NSLocalizedString(@"Font Size", nil);
    self.fontsizeSliderView.startLabel.text = @"1";
    self.fontsizeSliderView.delegate = self;
    self.fontsizeSliderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrcollView addSubview:self.fontsizeSliderView];
    
    self.baseName = @"Helvetica";
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrcollView.frame = CGRectMake(0, 170, self.view.frame.size.width, self.view.frame.size.height-170);
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 470);
    
    if (@available(iOS 11.0, *)) {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 50);
        self.fontNameLabel.frame = CGRectMake(self.view.safeAreaInsets.left+20, 195, 30, 30);
        self.dropMenuView.frame = CGRectMake(self.view.safeAreaInsets.left+60, 195, self.view.frame.size.width - 150 - self.view.safeAreaInsets.right-self.view.safeAreaInsets.left, 30);
        self.dropDownIcon.frame = CGRectMake(self.dropMenuView.bounds.size.width - 24 - 5, 3, 24, 24);
        self.fontNameSelectLabel.frame = CGRectMake(10, 0, self.dropMenuView.bounds.size.width - 40, 29);
        self.fontSelectBtn.frame = self.dropMenuView.bounds;
        self.splitView.frame = CGRectMake(0, 29, self.dropMenuView.bounds.size.width, 1);
        
        self.boldBtn.frame = CGRectMake(self.view.frame.size.width - 80 - self.view.safeAreaInsets.right, 195, 30, 30);
        self.italicBtn.frame = CGRectMake(self.view.frame.size.width - 50 - self.view.safeAreaInsets.right, 195, 30, 30);
        self.alignmentLabel.frame = CGRectMake(self.view.safeAreaInsets.left+20, 225, 120, 45);
        self.leftBtn.frame = CGRectMake(self.view.frame.size.width - 130 - self.view.safeAreaInsets.right, 240, 30, 30);
        self.centerBtn.frame = CGRectMake(self.view.frame.size.width - 90 - self.view.safeAreaInsets.right, 240, 30, 30);
        self.rightBtn.frame = CGRectMake(self.view.frame.size.width - 50, 240, 30, 30);
        self.fontsizeSliderView.frame = CGRectMake(self.view.safeAreaInsets.left, 280, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
    } else {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
        self.boldBtn.frame = CGRectMake(self.view.frame.size.width - 80, 195, 30, 30);
        self.italicBtn.frame = CGRectMake(self.view.frame.size.width - 50, 195, 30, 30);
        self.alignmentLabel.frame = CGRectMake(20, 225, 120, 45);
        self.leftBtn.frame = CGRectMake(self.view.frame.size.width - 110, 240, 30, 30);
        self.centerBtn.frame = CGRectMake(self.view.frame.size.width - 80, 240, 30, 30);
        self.rightBtn.frame = CGRectMake(self.view.frame.size.width - 50, 240, 30, 30);
        self.fontsizeSliderView.frame = CGRectMake(0, 280, self.view.frame.size.width, 90);
        
        self.fontNameLabel.frame = CGRectMake(20, 195, 30, 30);
        self.dropMenuView.frame = CGRectMake(60, 195, self.view.frame.size.width - 140, 30);
        self.dropDownIcon.frame = CGRectMake(self.dropMenuView.bounds.size.width - 24 - 5, 3, 24, 24);
        self.fontNameSelectLabel.frame = CGRectMake(10, 0, self.dropMenuView.bounds.size.width-40, 29);
        self.fontSelectBtn.frame = self.dropMenuView.bounds;
        self.splitView.frame = CGRectMake(0, 29, self.dropMenuView.bounds.size.width, 1);
    }
}

#pragma mark - Protect Mehtods

- (void)commomInitTitle {
    self.titleLabel.text = NSLocalizedString(@"FreeText", nil);
    self.colorView.colorLabel.text = NSLocalizedString(@"Font Color", nil);
    self.colorView.selectedColor = self.annotStyle.fontColor;
    
    self.sampleView.selecIndex = CPDFSamplesFreeText;
    self.sampleView.color = [UIColor blueColor];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 600);
}

- (void)commomInitFromAnnotStyle {
    self.opacitySliderView.opacitySlider.value = self.annotStyle.opacity;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
    self.fontsizeSliderView.thicknessSlider.value = self.annotStyle.fontSize;
    self.fontsizeSliderView.startLabel.text = [NSString stringWithFormat:@"%d",(int)self.annotStyle.fontSize];
    self.fontNameSelectLabel.text = self.annotStyle.fontName;
    [self analyzeFont:self.annotStyle.fontName];
    [self analyzeAlignment:self.annotStyle.alignment];

    self.sampleView.color = self.annotStyle.fontColor;
    self.sampleView.opcity = self.annotStyle.opacity;
    self.sampleView.thickness = self.annotStyle.fontSize;
    self.sampleView.fontName = self.annotStyle.fontName;
    self.sampleView.textAlignment = self.annotStyle.alignment;
    [self.sampleView setNeedsDisplay];
}

#pragma mark - Private

- (void)analyzeFont:(NSString *)fontName {
    if ([fontName rangeOfString:@"Bold"].location != NSNotFound) {
        self.isBold = YES;
        self.sampleView.isBold = self.isBold;
        self.boldBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        [self.sampleView setNeedsDisplay];
    } else {
        self.isBold = NO;
        self.sampleView.isBold = self.isBold;
        self.boldBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        [self.sampleView setNeedsDisplay];
    }
    if (([fontName rangeOfString:@"Italic"].location != NSNotFound) || ([fontName rangeOfString:@"Oblique"].location != NSNotFound)) {
        self.isItalic = YES;
        self.sampleView.isItalic = self.isItalic;
        self.italicBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        [self.sampleView setNeedsDisplay];
    } else {
        self.isItalic = NO;
        self.sampleView.isItalic = self.isBold;
        self.italicBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        [self.sampleView setNeedsDisplay];
    }
    if ([fontName rangeOfString:@"Helvetica"].location != NSNotFound)
    {
        self.baseName = @"Helvetica";
        self.sampleView.fontName = self.baseName;
        return ;
    }
    if ([fontName rangeOfString:@"Courier"].location != NSNotFound)
    {
        self.baseName = @"Courier";
        self.sampleView.fontName = self.baseName;
        return ;
    }
    if ([fontName rangeOfString:@"Times"].location != NSNotFound)
    {
        self.baseName = @"Times-Roman";
        self.sampleView.fontName = self.baseName;
    }
}

- (void)analyzeAlignment:(NSTextAlignment)aligment {
    switch (aligment) {
        case NSTextAlignmentLeft:
        {
            self.leftBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        }
            break;
        case NSTextAlignmentCenter:
        {
            self.centerBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        }
            break;
        case NSTextAlignmentRight:
        {
            self.rightBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        }
            break;
            
        default:
            break;
    }
}

- (NSString *)constructionFontname:(NSString *)baseName isBold:(BOOL)isBold isItalic:(BOOL)isItalic {
    NSString *result;
    if ([baseName rangeOfString:@"Times"].location != NSNotFound) {
       if (isBold || isItalic) {
           if (isBold && isItalic) return @"Times-BoldItalic";
           if (isBold) return @"Times-Bold";
           if (isItalic) return @"Times-Italic";
       }
       else
           return @"Times-Roman";
    }
    if (isBold || isItalic) {
       result = [NSString stringWithFormat:@"%@-",baseName];
       if (isBold) result = [NSString stringWithFormat:@"%@Bold",result];
       if (isItalic) result = [NSString stringWithFormat:@"%@Oblique",result];
    }
    else return baseName;
    return result;
}

#pragma mark - Action

- (void)buttonItemClicked_Bold:(id)sender {
    self.isBold = !(self.isBold);
    if (self.isBold) {
        self.boldBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    } else {
        self.boldBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }

    self.sampleView.fontName = [self constructionFontname:self.baseName isBold:self.isBold isItalic:self.isItalic];
    [self.sampleView setNeedsDisplay];
    self.annotStyle.fontName = [self constructionFontname:self.baseName isBold:self.isBold isItalic:self.isItalic];
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
}

- (void)buttonItemClicked_Italic:(id)sender {
    self.isItalic = !(self.isItalic);
    if (self.isItalic) {
        self.italicBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    } else {
        self.italicBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    }
    
    self.annotStyle.fontName = [self constructionFontname:self.baseName isBold:self.isBold isItalic:self.isItalic];
    self.sampleView.fontName = [self constructionFontname:self.baseName isBold:self.isBold isItalic:self.isItalic];
    [self.sampleView setNeedsDisplay];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
}

- (void)buttonItemClicked_FontStyle:(id)sender {
    self.fontStyleTableView = [[CPDFFontStyleTableView alloc] initWithFrame:self.view.bounds];
    self.fontStyleTableView.delegate = self;
    self.fontStyleTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.fontStyleTableView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.fontStyleTableView];
}

- (void)buttonItemClicked_Left:(id)sender {
    self.leftBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    self.centerBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    self.rightBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    
    self.leftBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    self.annotStyle.alignment = NSTextAlignmentLeft;
    self.sampleView.textAlignment = NSTextAlignmentLeft;
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

- (void)buttonItemClicked_Center:(id)sender {
    self.leftBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    self.centerBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    self.rightBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    
    self.centerBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    self.annotStyle.alignment = NSTextAlignmentCenter;
    self.sampleView.textAlignment = NSTextAlignmentCenter;
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

- (void)buttonItemClicked_Right:(id)sender {
    self.leftBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    self.centerBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    self.rightBtn.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    
    self.rightBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    self.annotStyle.alignment = NSTextAlignmentRight;
    self.sampleView.textAlignment = NSTextAlignmentRight;
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFOpacitySliderViewDelegate

- (void)opacitySliderView:(CPDFOpacitySliderView *)opacitySliderView opacity:(CGFloat)opacity {
    self.sampleView.opcity = opacity;
    self.annotStyle.opacity = opacity;
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFThicknessSliderViewDelegate

- (void)thicknessSliderView:(CPDFThicknessSliderView *)thicknessSliderView thickness:(CGFloat)thickness {
    self.sampleView.thickness = thickness;
    self.annotStyle.fontSize = self.fontsizeSliderView.thicknessSlider.value;
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFFontStyleTableViewDelegate

- (void)fontStyleTableView:(CPDFFontStyleTableView *)fontStyleTableView fontName:(NSString *)fontName {
    self.sampleView.fontName = fontName;
    self.baseName = fontName;
    self.annotStyle.fontName = [self constructionFontname:self.baseName isBold:self.isBold isItalic:self.isItalic];
    self.fontNameSelectLabel.text = fontName;
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

#pragma mark - CPDFColorSelectViewDelegate

- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    self.sampleView.color = color;
    self.annotStyle.fontColor = color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
}

- (void)selectColorView:(CPDFColorSelectView *)select {
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        self.colorPicker = [[CPDFColorPickerView alloc] initWithFrame:self.view.frame];
        self.colorPicker.delegate = self;
        self.colorPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.colorPicker.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        [self.view addSubview:self.colorPicker];
    }
}

#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    self.sampleView.color = color;
    self.annotStyle.fontColor = color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
    
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    self.opacitySliderView.opacitySlider.value = alpha;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    self.sampleView.color = viewController.selectedColor;
    self.annotStyle.fontColor = self.sampleView.color;
    if (self.delegate && [self.delegate respondsToSelector:@selector(freeTextViewController:annotStyle:)]) {
        [self.delegate freeTextViewController:self annotStyle:self.annotStyle];
    }
    [self.sampleView setNeedsDisplay];
    
    CGFloat red, green, blue, alpha;
    [viewController.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    self.opacitySliderView.opacitySlider.value = alpha;
    self.opacitySliderView.startLabel.text = [NSString stringWithFormat:@"%d%%", (int)((self.opacitySliderView.opacitySlider.value/1)*100)];
}

@end
