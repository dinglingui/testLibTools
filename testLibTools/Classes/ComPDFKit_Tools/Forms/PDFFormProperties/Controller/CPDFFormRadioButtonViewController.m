//
//  CPDFFormRadioButtonViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormRadioButtonViewController.h"

#import "CPDFFormTextFieldView.h"
#import "CPDFColorSelectView.h"
#import "CPDFFormSwitchView.h"
#import "CPDFFormArrowStyleView.h"

#import <ComPDFKit/ComPDFKit.h>
#import "CAnnotationManage.h"
#import "CAnnotStyle.h"
#import "CPDFColorPickerView.h"
#import "CPDFColorUtils.h"
#import "CPDFColorPickerView.h"
#import "CPDFArrowStyleTableView.h"

@interface CPDFFormRadioButtonViewController ()<CPDFFormTextFiledViewDelegate,CPDFColorSelectViewDelegate,CPDFFormSwitchViewDelegate,UIColorPickerViewControllerDelegate,CPDFColorPickerViewDelegate,CPDFFormSwitchViewDelegate,CPDFArrowStyleTableViewDelegate,CPDFFormArrowStyleViewDelegate>

@property (nonatomic, strong)CPDFFormTextFieldView * formTextFiledView;

@property (nonatomic, strong) CPDFColorSelectView * borderColorView;
@property (nonatomic, strong) CPDFColorSelectView * backGroundColorView;
@property (nonatomic, strong) CPDFColorSelectView * colorSelectView;
@property (nonatomic, strong) CPDFFormSwitchView * selectDefaultSwitchView;
@property (nonatomic, strong) CPDFFormSwitchView * hideFormSwitchView;
@property (nonatomic, strong) CPDFFormArrowStyleView * arrowStyleView;

@property (nonatomic, strong) CAnnotationManage * annotManage;

@property (nonatomic, strong) CPDFButtonWidgetAnnotation * buttonWidget;

@property (nonatomic, strong) CPDFColorPickerView * colorPicker;
@property (nonatomic, strong) CPDFColorSelectView * currentSelectColorView;

@property (nonatomic, strong) CPDFArrowStyleTableView *arrowStyleTableView;

@end

@implementation CPDFFormRadioButtonViewController

- (instancetype)initWithManage:(CAnnotationManage *)annotManage {
    if (self = [super init]) {
        self.annotManage = annotManage;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.formTextFiledView = [[CPDFFormTextFieldView alloc] init];
    self.formTextFiledView.delegate = self;
    [self.scrcollView addSubview:self.formTextFiledView];
    
    self.borderColorView = [[CPDFColorSelectView alloc] init];
    self.borderColorView.delegate = self;
    self.borderColorView.colorLabel.text = NSLocalizedString(@"Stroke Color", nil);
    self.borderColorView.colorLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.borderColorView.colorLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.borderColorView.colorPickerView.showsHorizontalScrollIndicator = NO;
    
    self.backGroundColorView = [[CPDFColorSelectView alloc] init];
    self.backGroundColorView.colorLabel.text = NSLocalizedString(@"Background Color", nil);
    self.backGroundColorView.delegate = self;
    self.backGroundColorView.colorLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.backGroundColorView.colorLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.backGroundColorView.colorPickerView.showsHorizontalScrollIndicator = NO;
    
    self.colorSelectView = [[CPDFColorSelectView alloc] init];
    [self.scrcollView addSubview:self.colorSelectView];
    [self.scrcollView addSubview:self.borderColorView];
    [self.scrcollView addSubview:self.backGroundColorView];
    
    self.colorSelectView.colorLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.colorSelectView.colorLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.colorSelectView.colorLabel.text = NSLocalizedString(@"Checkmark Color", nil);
    self.colorSelectView.delegate = self;
    self.colorSelectView.colorPickerView.showsHorizontalScrollIndicator = NO;
    
    self.selectDefaultSwitchView = [[CPDFFormSwitchView alloc] init];
    [self.scrcollView addSubview:self.selectDefaultSwitchView];
    self.selectDefaultSwitchView.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.selectDefaultSwitchView.titleLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.selectDefaultSwitchView.titleLabel.text = NSLocalizedString(@"Button is checked by default", nil);
    self.selectDefaultSwitchView.delegate = self;
    
    self.arrowStyleView = [[CPDFFormArrowStyleView alloc] init];
    [self.scrcollView addSubview:self.arrowStyleView];
    
    self.arrowStyleView.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    self.arrowStyleView.titleLabel.textColor = [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1];
    self.arrowStyleView.delegate  = self;
    self.arrowStyleView.titleLabel.text = NSLocalizedString(@"Button Style", nil);
    
    self.buttonWidget = (CPDFButtonWidgetAnnotation*)self.annotManage.annotStyle.annotations.firstObject;
}

#pragma mark - Setter
- (void)setButtonWidget:(CPDFButtonWidgetAnnotation *)buttonWidget {
    _buttonWidget = buttonWidget;
    
    self.formTextFiledView.contentField.text = self.buttonWidget.fieldName;
    
    if(self.buttonWidget.borderColor == nil){
        self.borderColorView.selectedColor = [UIColor blackColor];
        self.buttonWidget.borderColor = self.borderColorView.selectedColor;
        [self refreshUI];
    }else{
        self.borderColorView.selectedColor = self.buttonWidget.borderColor;
    }
    
    if(self.buttonWidget.backgroundColor == nil) {
        [self refreshUI];
    }else{
        self.backGroundColorView.selectedColor = self.buttonWidget.backgroundColor;
    }
    
    
    if(self.buttonWidget.fontColor == nil) {
        self.colorSelectView.selectedColor = [UIColor blackColor];
        self.buttonWidget.fontColor = self.colorSelectView.selectedColor;
        [self refreshUI];
    }else{
        self.colorSelectView.selectedColor = self.buttonWidget.fontColor;
    }
    
    self.hideFormSwitchView.switcher.on = self.buttonWidget.isHidden;
    
    if(self.buttonWidget.state == 1)  {
        self.selectDefaultSwitchView.switcher.on = YES;
    }
    
    if(self.buttonWidget.state == 0) {
        self.selectDefaultSwitchView.switcher.on = NO;
    }
    
    switch (buttonWidget.widgetCheckStyle) {
        case CPDFWidgetButtonStyleCheck:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormCheck" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleCircle:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormCircle" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleCross:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormCross" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleDiamond:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormDiamond" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleSquare:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormSquare" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleStar:{
            self.arrowStyleView.arrowImageView.image =  [UIImage imageNamed:@"CPDFFormStar" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)commomInitTitle {
    self.titleLabel.text = NSLocalizedString(@"Raido Button", nil);
}

- (void)buttonItemClicked_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 500);
    self.scrcollView.showsVerticalScrollIndicator = NO;;
    
    
    if (@available(iOS 11.0, *)) {
        self.formTextFiledView.frame = CGRectMake(self.view.safeAreaInsets.left, 8, self.view.frame.size.width - self.view.safeAreaInsets.left, 65);
        self.borderColorView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.formTextFiledView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 74);
        self.backGroundColorView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.borderColorView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 74);
        self.colorSelectView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.backGroundColorView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 74);
        self.arrowStyleView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.colorSelectView.frame)+8,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 44);
        self.selectDefaultSwitchView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.arrowStyleView.frame)+8, self.view.frame.size.width - self.view.safeAreaInsets.left, 44);
//        self.hideFormSwitchView.frame = CGRectMake(self.view.safeAreaInsets.left, CGRectGetMaxY(self.selectDefaultSwitchView.frame)+8, self.view.frame.size.width - self.view.safeAreaInsets.left, 44);
    } else {
        self.formTextFiledView.frame = CGRectMake(0, 8, self.view.bounds.size.width, 60);
        self.borderColorView.frame = CGRectMake(0,CGRectGetMaxY(self.formTextFiledView.frame)+8, self.view.frame.size.width, 74);
        self.backGroundColorView.frame = CGRectMake(0,CGRectGetMaxY(self.borderColorView.frame)+8, self.view.frame.size.width, 74);
        self.colorSelectView.frame = CGRectMake(0,CGRectGetMaxY(self.backGroundColorView.frame)+8, self.view.frame.size.width, 74);
        self.arrowStyleView.frame = CGRectMake(0,CGRectGetMaxY(self.colorSelectView.frame)+8, self.view.frame.size.width, 44);
        self.selectDefaultSwitchView.frame = CGRectMake(0, CGRectGetMaxY(self.arrowStyleView.frame)+8, self.view.frame.size.width, 44);
//        self.hideFormSwitchView.frame = CGRectMake(0,  CGRectGetMaxY(self.selectDefaultSwitchView.frame)+8,self.view.frame.size.width , 44);
    }
}


#pragma mark - CPDFFormTextFiledViewDelegate

- (void)SetCPDFFormTextFiledView:(CPDFFormTextFieldView *)view text:(NSString *)completedText {
    self.buttonWidget.fieldName = completedText;
    [self refreshUI];
}


#pragma mark - CPDFColorSelectViewDelegate
- (void)selectColorView:(CPDFColorSelectView *)select color:(UIColor *)color {
    self.currentSelectColorView = select;
    if(select == self.borderColorView) {
        self.buttonWidget.borderColor = color;
    }else if(select == self.backGroundColorView) {
        self.buttonWidget.backgroundColor = color;
    }else if(select == self.colorSelectView) {
        self.buttonWidget.fontColor = color;
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
        self.buttonWidget.borderColor = color;
    }else if(self.currentSelectColorView == self.backGroundColorView) {
        self.buttonWidget.backgroundColor = color;
    }else if(self.currentSelectColorView == self.colorSelectView) {
        self.buttonWidget.fontColor = color;
    }
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    [self refreshUI];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    if(self.currentSelectColorView == self.borderColorView) {
        self.buttonWidget.borderColor = viewController.selectedColor;
    }else if(self.currentSelectColorView == self.backGroundColorView) {
        self.buttonWidget.backgroundColor = viewController.selectedColor;
    }else if(self.currentSelectColorView == self.colorSelectView) {
        self.buttonWidget.fontColor = viewController.selectedColor;
    }
    [self refreshUI];
}

#pragma mark - CPDFFormSwitchViewDelegate
- (void)SwitchActionInView:(CPDFFormSwitchView *)view switcher:(UISwitch *)switcher {
    if(view == self.selectDefaultSwitchView) {
       //
        if(switcher.on){
            [self.buttonWidget setState:1];
        }else{
            [self.buttonWidget setState:0];
        }
    }else if(view == self.hideFormSwitchView) {
        if(switcher.on) {
            if([self.annotManage.pdfListView.activeAnnotations containsObject:self.annotManage.annotStyle.annotations.firstObject]) {
                [self.annotManage.pdfListView updateActiveAnnotations:@[]];
            }
        }
        [self.buttonWidget setHidden:switcher.on];
    }
    
    [self refreshUI];
}

#pragma mark - CPDFFormArrowStyleViewDelegate
- (void)CPDFFormArrowStyleViewClicked:(CPDFFormArrowStyleView *)view {
    self.arrowStyleTableView = [[CPDFArrowStyleTableView alloc] initWithFrame:self.view.bounds];
    self.arrowStyleTableView.delegate = self;
    self.arrowStyleTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.arrowStyleTableView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    self.arrowStyleTableView.style = self.buttonWidget.widgetCheckStyle;
    [self.view addSubview:self.arrowStyleTableView];
}

#pragma mark - CPDFArrowStyleTableViewDelegate
- (void)CPDFArrowStyleTableView:(CPDFArrowStyleTableView *)arrowStyleTableView style:(CPDFWidgetButtonStyle)widgetButtonStyle {
    [self.buttonWidget setWidgetCheckStyle:widgetButtonStyle];
    
    switch (widgetButtonStyle) {
        case CPDFWidgetButtonStyleCheck:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormCheck" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleCircle:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormCircle" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleCross:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormCross" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleDiamond:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormDiamond" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleSquare:{
            self.arrowStyleView.arrowImageView.image = [UIImage imageNamed:@"CPDFFormSquare" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        }
            break;
            
        case CPDFWidgetButtonStyleStar:{
            self.arrowStyleView.arrowImageView.image =  [UIImage imageNamed:@"CPDFFormStar" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
            
        }
            break;
            
        default:
            break;
    }
    
    [self refreshUI];
}

- (void)refreshUI {
    [self.buttonWidget updateAppearanceStream];
    CPDFPage *page = self.buttonWidget.page;
    [self.annotManage.pdfListView setNeedsDisplayForPage:page];
}

@end
