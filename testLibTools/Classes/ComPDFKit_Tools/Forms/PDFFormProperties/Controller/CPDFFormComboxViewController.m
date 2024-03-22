//
//  CPDFFormComboxViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormComboxViewController.h"

#import "CPDFColorSelectView.h"
#import "CPDFThicknessSliderView.h"
#import "CPDFFormTextFieldView.h"
#import "CPDFFormSwitchView.h"
#import "CPDFFontSettingView.h"
#import "CPDFFontAlignView.h"
#import "CPDFFormInputTextView.h"

#import <ComPDFKit/ComPDFKit.h>
#import "CAnnotationManage.h"
#import "CAnnotStyle.h"
#import "CPDFColorPickerView.h"
#import "CPDFColorUtils.h"
#import "CPDFColorPickerView.h"
#import "CPDFFontStyleTableView.h"

@interface CPDFFormComboxViewController ()<CPDFFormTextFiledViewDelegate,CPDFColorSelectViewDelegate,CPDFThicknessSliderViewDelegate,CPDFFormSwitchViewDelegate,UIColorPickerViewControllerDelegate,CPDFColorPickerViewDelegate,CPDFFontSettingViewDelegate,CPDFFontStyleTableViewDelegate>

@property (nonatomic, strong) CPDFColorSelectView * borderColorView;
@property (nonatomic, strong) CPDFColorSelectView * backGroundColorView;
@property (nonatomic, strong) CPDFColorSelectView * textColorView;
@property (nonatomic, strong) CPDFThicknessSliderView * sizeThickNessView;
@property (nonatomic, strong) CPDFFormTextFieldView * textFiledView;
@property (nonatomic, strong) CPDFFormSwitchView * hideFormView;
@property (nonatomic, strong) CPDFFontSettingView * fontSettingView;
@property (nonatomic, strong) CAnnotationManage * annotManage;
@property (nonatomic, strong) CPDFChoiceWidgetAnnotation * comboxChoiceWidget;
@property (nonatomic, strong) CPDFColorPickerView * colorPicker;
@property (nonatomic, strong) CPDFColorSelectView * currentSelectColorView;
@property (nonatomic, strong) CPDFFontStyleTableView *fontStyleTableView;

@property (nonatomic,   copy) NSString * baseName;
@property (nonatomic, assign) BOOL isBold;
@property (nonatomic, assign) BOOL isItalic;
@property (nonatomic, assign) CGFloat fontSize;

@end

@implementation CPDFFormComboxViewController

- (instancetype)initWithManage:(CAnnotationManage *)annotManage {
    if (self = [super init]) {
        self.annotManage = annotManage;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.borderColorView = [[CPDFColorSelectView alloc] init];
    self.borderColorView.delegate = self;
    self.borderColorView.colorLabel.text = NSLocalizedString(@"Stroke Color", nil);
    self.borderColorView.colorLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.borderColorView.colorLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.borderColorView.colorPickerView.showsHorizontalScrollIndicator = NO;
    
    
    self.backGroundColorView = [[CPDFColorSelectView alloc] init];
    self.backGroundColorView.colorLabel.text = NSLocalizedString(@"Background Color", nil);
    self.backGroundColorView.colorLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.backGroundColorView.colorLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.backGroundColorView.colorPickerView.showsHorizontalScrollIndicator = NO;
    self.backGroundColorView.delegate = self;
    
    self.textColorView = [[CPDFColorSelectView alloc] init];
    self.textColorView.colorLabel.text = NSLocalizedString(@"Font Color", nil);
    self.textColorView.colorLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.textColorView.colorLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.textColorView.colorPickerView.showsHorizontalScrollIndicator = NO;
    self.textColorView.delegate = self;
    
    [self.scrcollView addSubview:self.borderColorView];
    [self.scrcollView addSubview:self.backGroundColorView];
    [self.scrcollView addSubview:self.textColorView];
    
    self.sizeThickNessView = [[CPDFThicknessSliderView alloc] init];
    self.sizeThickNessView.titleLabel.text = NSLocalizedString(@"Font Size", nil);
    self.sizeThickNessView.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.sizeThickNessView.titleLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    [self.scrcollView addSubview:self.sizeThickNessView];
    self.sizeThickNessView.thick = 10.;
    self.sizeThickNessView.delegate = self;
    
    self.textFiledView = [[CPDFFormTextFieldView alloc] init];
    self.textFiledView.delegate = self;
    [self.scrcollView addSubview:self.textFiledView];
    
    self.fontSettingView = [[CPDFFontSettingView alloc] init];
    self.fontSettingView.fontNameLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.fontSettingView.fontNameLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.fontSettingView.fontNameLabel.text = NSLocalizedString(@"Font", nil);
    self.fontSettingView.delegate = self;
    [self.scrcollView addSubview:self.fontSettingView];
    
    self.baseName = @"Helvetica";
    self.fontSettingView.fontNameSelectLabel.text = self.baseName;
    
    self.comboxChoiceWidget = (CPDFChoiceWidgetAnnotation*)self.annotManage.annotStyle.annotations.firstObject;
    
}

#pragma mark - Setter
- (void)setComboxChoiceWidget:(CPDFChoiceWidgetAnnotation *)comboxChoiceWidget {
    _comboxChoiceWidget = comboxChoiceWidget;
    
    
    //field Name
    self.textFiledView.contentField.text = self.comboxChoiceWidget.fieldName;
    //border color
    if(self.comboxChoiceWidget.borderColor == nil) {
        [self refreshUI];
    }else{
        self.borderColorView.selectedColor = self.comboxChoiceWidget.borderColor;
    }
    
    if(self.comboxChoiceWidget.backgroundColor == nil) {
        [self refreshUI];
    }else {
        //back groundColor
        self.backGroundColorView.selectedColor = self.comboxChoiceWidget.backgroundColor;
    }
    
    if(self.comboxChoiceWidget.fontColor == nil) {
        self.textColorView.selectedColor = [UIColor blackColor];
        self.comboxChoiceWidget.fontColor = self.textColorView.selectedColor;
        [self refreshUI];
    }else {
        //Text color
        self.textColorView.selectedColor = self.comboxChoiceWidget.fontColor;
    }

    //Text content
    [self analyzeFont:self.comboxChoiceWidget.font.fontName];
    
    if(self.comboxChoiceWidget.font.pointSize == 0) {
        self.fontSize = 14;
        self.sizeThickNessView.defaultValue = 0.14;
        [self refreshUI];
    }else{
        self.sizeThickNessView.defaultValue = self.comboxChoiceWidget.font.pointSize/100.;
    }
    
    self.fontSize = self.comboxChoiceWidget.font.pointSize?self.comboxChoiceWidget.font.pointSize:14;
    
    //hide form
    self.hideFormView.switcher.on = self.comboxChoiceWidget.isHidden;
    
}

#pragma mark - Private


- (void)analyzeFont:(NSString *)fontName {
    if(fontName == nil) {
        self.fontSettingView.isBold = NO;
        self.fontSettingView.isItalic = NO;
        return;
    }
    
    if ([fontName rangeOfString:@"Bold"].location != NSNotFound) {
       //isBold
        self.fontSettingView.isBold = YES;
        self.isBold = YES;
    } else {
        //is not bold
        self.fontSettingView.isBold = NO;
        self.isBold = NO;
    }
    if ([fontName rangeOfString:@"Italic"].location != NSNotFound || [fontName rangeOfString:@"Oblique"].location != NSNotFound) {
        //is Italic
        self.fontSettingView.isItalic = YES;
        self.isItalic = YES;
    } else {
        //is Not Italic
        self.fontSettingView.isItalic = NO;
        self.isItalic = NO;
        
    }
    if ([fontName rangeOfString:@"Helvetica"].location != NSNotFound)
    {
        self.baseName = @"Helvetica";
        self.fontSettingView.fontNameSelectLabel.text = self.baseName;
        return ;
    }
    if ([fontName rangeOfString:@"Courier"].location != NSNotFound)
    {
        self.baseName = @"Courier";
        self.fontSettingView.fontNameSelectLabel.text = self.baseName;
        return ;
    }
    if ([fontName rangeOfString:@"Times"].location != NSNotFound)
    {
        self.baseName = @"Times-Roman";
        self.fontSettingView.fontNameSelectLabel.text = self.baseName;
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

#pragma mark - Protect Mehtods

- (void)buttonItemClicked_back:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)commomInitTitle {
    self.titleLabel.text = NSLocalizedString(@"Combo Box", nil);
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    if ([self.colorPicker superview]) {
        UIDevice *currentDevice = [UIDevice currentDevice];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // This is an iPad
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 520);
        } else {
            // This is an iPhone or iPod touch
            self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 320);
        }
    } else {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 600);
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrcollView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60);
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 550);
    self.scrcollView.showsVerticalScrollIndicator = NO;
    
    
    if (@available(iOS 11.0, *)) {
        self.textFiledView.frame = CGRectMake(self.view.safeAreaInsets.left, 8, self.view.frame.size.width - self.view.safeAreaInsets.left, 65);
        self.borderColorView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.textFiledView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 74);
        self.backGroundColorView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.borderColorView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 74);
        self.textColorView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.backGroundColorView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 74);
        self.fontSettingView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.textColorView.frame)+8, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 30);
    
        self.sizeThickNessView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.fontSettingView.frame),self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 82);
        
    } else {
        self.textFiledView.frame = CGRectMake(0, 8, self.view.bounds.size.width, 60);
        self.borderColorView.frame = CGRectMake(0,CGRectGetMaxY(self.textFiledView.frame)+8, self.view.frame.size.width, 74);
        self.backGroundColorView.frame = CGRectMake(0,CGRectGetMaxY(self.borderColorView.frame)+8, self.view.frame.size.width, 74);
        self.textColorView.frame = CGRectMake(0, CGRectGetMaxY(self.backGroundColorView.frame)+8, self.view.frame.size.width, 74);
        self.fontSettingView.frame = CGRectMake(0, CGRectGetMaxY(self.textColorView.frame)+8, self.view.frame.size.width, 30);
        
        self.sizeThickNessView.frame = CGRectMake(0, CGRectGetMaxY(self.fontSettingView.frame), self.view.frame.size.width, 82);
    }
    
    self.textFiledView.contentField.text = self.comboxChoiceWidget.fieldName;
}




#pragma mark - CPDFFormTextFiledViewDelegate

- (void)SetCPDFFormTextFiledView:(CPDFFormTextFieldView *)view text:(NSString *)completedText {
    self.comboxChoiceWidget.fieldName = completedText;
    [self refreshUI];
}


#pragma mark - CPDFColorSelectViewDelegate
- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    self.currentSelectColorView = select;
    if(select == self.borderColorView) {
        self.comboxChoiceWidget.borderColor = color;
    }else if(select == self.backGroundColorView) {
        self.comboxChoiceWidget.backgroundColor = color;
    }else if(select == self.textColorView) {
        self.comboxChoiceWidget.fontColor = color;
    }
    [self refreshUI];
}

- (void)selectColorView:(CPDFColorSelectView *)select {
    self.currentSelectColorView = select;
    if (@available(iOS 14.0, *)) {
        UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIDevice *currentDevice = [UIDevice currentDevice];
        if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // This is an iPad
            _colorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 520)];
        } else {
            // This is an iPhone or iPod touch
            _colorPicker = [[CPDFColorPickerView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 320)];
        }
        self.colorPicker.delegate = self;
        self.colorPicker.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        [self.view addSubview:self.colorPicker];
        [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    }
    [self refreshUI];
}


#pragma mark - CPDFColorPickerViewDelegate

- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    if(self.currentSelectColorView == self.borderColorView) {
        self.comboxChoiceWidget.borderColor = color;
    }else if(self.currentSelectColorView == self.backGroundColorView) {
        self.comboxChoiceWidget.backgroundColor = color;
    }else if(self.currentSelectColorView == self.textColorView) {
        self.comboxChoiceWidget.fontColor = color;
    }
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    [self refreshUI];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    if(self.currentSelectColorView == self.borderColorView) {
        self.comboxChoiceWidget.borderWidth = 2;
        self.comboxChoiceWidget.borderColor = viewController.selectedColor;
    }else if(self.currentSelectColorView == self.backGroundColorView) {
        CGFloat red, green, blue, alpha;
        [viewController.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
        self.comboxChoiceWidget.backgroundOpacity = alpha;
        self.comboxChoiceWidget.backgroundColor = viewController.selectedColor;
    }else if(self.currentSelectColorView == self.textColorView) {
        self.comboxChoiceWidget.fontColor = viewController.selectedColor;
    }
    [self refreshUI];
}

#pragma mark - CPDFFormSwitchViewDelegate
- (void)SwitchActionInView:(CPDFFormSwitchView *)view switcher:(UISwitch *)switcher {
    if(switcher.on) {
        if([self.annotManage.pdfListView.activeAnnotations containsObject:self.annotManage.annotStyle.annotations.firstObject]) {
            [self.annotManage.pdfListView updateActiveAnnotations:@[]];
        }
    }
    [self.comboxChoiceWidget setHidden:switcher.on];
    [self refreshUI];
}

#pragma mark - CPDFThicknessSliderViewDelegate
- (void)thicknessSliderView:(CPDFThicknessSliderView *)thicknessSliderView thickness:(CGFloat)thickness {
    self.fontSize = thickness * 10;
    [self refreshUI];
}


#pragma mark - CPDFFontSettingViewDelegate
- (void)CPDFFontSettingView:(CPDFFontSettingView *)view isBold:(BOOL)isBold {
    self.isBold = isBold;
    [self refreshUI];
}

- (void)CPDFFontSettingView:(CPDFFontSettingView *)view isItalic:(BOOL)isItalic {
    self.isItalic = isItalic;
    [self refreshUI];
}

- (void)CPDFFontSettingView:(CPDFFontSettingView *)view text:(NSString *)text {
}


#pragma mark - CPDFFontSettingViewDelegate
- (void)CPDFFontSettingViewFontSelect:(CPDFFontSettingView *)view {
    self.fontStyleTableView = [[CPDFFontStyleTableView alloc] initWithFrame:self.view.bounds];
    self.fontStyleTableView.delegate = self;
    self.fontStyleTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.fontStyleTableView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    
    [self.view addSubview:self.fontStyleTableView];
    
}

#pragma mark - CPDFFontStyleTableViewDelegate
- (void)fontStyleTableView:(CPDFFontStyleTableView *)fontStyleTableView fontName:(NSString *)fontName {
    self.baseName = fontName;
    self.fontSettingView.fontNameSelectLabel.text = fontName;
    [self refreshUI];
}

- (void)refreshUI {
    NSString * fontName = [self constructionFontname:self.baseName isBold:self.isBold isItalic:self.isItalic];
    self.comboxChoiceWidget.font = [UIFont fontWithName:fontName size:self.fontSize];
    [self.comboxChoiceWidget updateAppearanceStream];
    CPDFPage *page = self.comboxChoiceWidget.page;
    [self.annotManage.pdfListView setNeedsDisplayForPage:page];
}

@end
