//
//  CStampTextViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CStampTextViewController.h"
#import "CStampPreview.h"
#import "CStampShapView.h"
#import "CPDFColorSelectView.h"
#import "CStampColorSelectView.h"
#import "CPDFColorPickerView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CStampTextViewController () <UITextFieldDelegate, CStampColorSelectViewDelegate, CStampShapViewDelegate>

@property (nonatomic, strong) CStampPreview *preView;

@property (nonatomic, strong) UITextField *stampTextField;

@property (nonatomic, strong) UISwitch *haveDateSwitch;

@property (nonatomic, strong) UISwitch *haveTimeSwitch;

@property (nonatomic, strong) UIButton *doneBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) CStampColorSelectView *colorView;

@property (nonatomic, strong) CStampShapView *stampShapeViw;

@property (nonatomic, assign) NSInteger textStampColorStyle;

@property (nonatomic, assign) NSInteger textStampStyle;

@property (nonatomic, strong) UIScrollView *scrcollView;

@end

@implementation CStampTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.titleLabel.text = NSLocalizedString(@"Create Stamp", nil);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:self.titleLabel];
    
    self.doneBtn = [[UIButton alloc] init];
    self.doneBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.doneBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [self.doneBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(buttonItemClicked_done:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneBtn];
    
    self.scrcollView = [[UIScrollView alloc] init];
    self.scrcollView.scrollEnabled = YES;
    self.scrcollView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self.view addSubview:self.scrcollView];
    
    self.cancelBtn = [[UIButton alloc] init];
    self.cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.cancelBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(buttonItemClicked_cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelBtn];
    
    self.preView = [[CStampPreview alloc] init];
    self.preView.backgroundColor = [UIColor clearColor];
    self.preView.color = [UIColor blackColor];
    self.preView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.preView.layer.borderWidth = 1.0;
    self.preView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.scrcollView addSubview:self.preView];
    
    self.stampTextField = [[UITextField alloc] init];
    self.stampTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.stampTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    self.stampTextField.leftViewMode = UITextFieldViewModeAlways;
    self.stampTextField.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    self.stampTextField.rightViewMode = UITextFieldViewModeAlways;
    self.stampTextField.returnKeyType = UIReturnKeyDone;
    self.stampTextField.clearButtonMode = YES;
    self.stampTextField.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.stampTextField.layer.borderWidth = 1.0;
    self.stampTextField.delegate = self;
    self.stampTextField.borderStyle = UITextBorderStyleNone;
    [self.stampTextField addTarget:self action:@selector(textFieldEditChange:) forControlEvents:UIControlEventEditingChanged];
    self.stampTextField.placeholder = NSLocalizedString(@"Text", nil);
    [self.scrcollView addSubview:self.stampTextField];
    
    self.colorView = [[CStampColorSelectView alloc] init];
    self.colorView.delegate = self;
    self.colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.colorView.selectedColor = [UIColor blackColor];
    [self.scrcollView addSubview:self.colorView];
    
    self.stampShapeViw = [[CStampShapView alloc] init];
    self.stampShapeViw.delegate = self;
    self.stampShapeViw.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.scrcollView addSubview:self.stampShapeViw];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.text = NSLocalizedString(@"Date", nil);
    self.dateLabel.textColor = [UIColor grayColor];
    self.dateLabel.font = [UIFont systemFontOfSize:12.0];
    [self.scrcollView addSubview:self.dateLabel];
    
    self.haveDateSwitch = [[UISwitch alloc] init];
    [self.haveDateSwitch setOn:NO animated:NO];
    self.haveDateSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.haveDateSwitch addTarget:self action:@selector(switchChange_date:) forControlEvents:UIControlEventValueChanged];
    [self.scrcollView addSubview:self.haveDateSwitch];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.text = NSLocalizedString(@"Time", nil);
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.font = [UIFont systemFontOfSize:12.0];
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.scrcollView addSubview:self.timeLabel];
    
    self.haveTimeSwitch = [[UISwitch alloc] init];
    [self.haveTimeSwitch setOn:NO animated:NO];
    self.haveTimeSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.haveTimeSwitch addTarget:self action:@selector(switchChange_time:) forControlEvents:UIControlEventValueChanged];
    [self.scrcollView addSubview:self.haveTimeSwitch];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
    
    self.scrcollView.frame = CGRectMake(0, 50, self.view.frame.size.width, 560);
    self.scrcollView.contentSize = CGSizeMake(self.view.frame.size.width, 700);
    self.preView.frame  = CGRectMake((self.view.frame.size.width - 350)/2, 15, 350, 120);
    self.stampTextField.frame = CGRectMake((self.view.frame.size.width - 350)/2, 150, 350, 30);
    
    if (@available(iOS 11.0, *)) {
        self.doneBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 50);
        self.cancelBtn.frame = CGRectMake(self.view.safeAreaInsets.left + 10, 5, 50, 50);
        self.stampShapeViw.frame = CGRectMake(self.view.safeAreaInsets.left, 180,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 90);
        self.colorView.frame = CGRectMake(self.view.safeAreaInsets.left, 270,self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 60);
        self.dateLabel.frame = CGRectMake(self.view.safeAreaInsets.left+20, 330, 80, 50);
        self.haveDateSwitch.frame = CGRectMake(self.view.frame.size.width - 80- self.view.safeAreaInsets.right, 330, 60, 50);
        self.timeLabel.frame = CGRectMake(self.view.safeAreaInsets.left+20, 380, 100, 45);
        self.haveTimeSwitch.frame = CGRectMake(self.view.frame.size.width - 80- self.view.safeAreaInsets.right, 380, 60, 50);
    } else {
        self.doneBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
        self.colorView.frame = CGRectMake(0, 270, self.view.frame.size.width, 60);
        self.stampShapeViw.frame = CGRectMake(0, 180, self.view.frame.size.width, 90);
        self.dateLabel.frame = CGRectMake(20, 330, 80, 50);
        self.haveDateSwitch.frame = CGRectMake(self.view.frame.size.width - 80, 330, 60, 50);
        self.timeLabel.frame = CGRectMake(20, 380, 100, 45);
        self.haveTimeSwitch.frame = CGRectMake(self.view.frame.size.width - 80, 380, 60, 50);
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

#pragma mark - Private Mthods

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 560);
}

#pragma mark - Action

- (void)buttonItemClicked_done:(id)sender {
    NSMutableDictionary *tStampItem = [[NSMutableDictionary alloc] init];
    if (![self.stampTextField.text isEqualToString:@""] || [self.haveDateSwitch isOn] || [self.haveTimeSwitch isOn]) {
        if (self.stampTextField.text.length > 0) {
            [tStampItem setObject:self.stampTextField.text forKey:@"text"];
            [tStampItem setObject:[NSNumber numberWithInteger:self.textStampColorStyle] forKey:@"colorStyle"];
            [tStampItem setObject:[NSNumber numberWithInteger:self.textStampStyle] forKey:@"style"];
            [tStampItem setObject:[NSNumber numberWithBool:[self.haveDateSwitch isOn]] forKey:@"haveDate"];
            [tStampItem setObject:[NSNumber numberWithBool:[self.haveTimeSwitch isOn]] forKey:@"haveTime"];
        } else {
            [tStampItem setObject:self.preView.dateTime forKey:@"text"];
            [tStampItem setObject:[NSNumber numberWithInteger:self.textStampColorStyle] forKey:@"colorStyle"];
            [tStampItem setObject:[NSNumber numberWithInteger:self.textStampStyle] forKey:@"style"];
            [tStampItem setObject:[NSNumber numberWithBool:NO] forKey:@"haveDate"];
            [tStampItem setObject:[NSNumber numberWithBool:NO] forKey:@"haveTime"];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(stampTextViewController:dictionary:)]) {
            [self.delegate stampTextViewController:self dictionary:tStampItem];
        }
    } else if ([self.stampTextField.text isEqualToString:@""] && ![self.haveDateSwitch isOn] && ![self.haveTimeSwitch isOn]) {
        [tStampItem setObject:@"StampText" forKey:@"text"];
        [tStampItem setObject:[NSNumber numberWithInteger:self.textStampColorStyle] forKey:@"colorStyle"];
        [tStampItem setObject:[NSNumber numberWithInteger:self.textStampStyle] forKey:@"style"];
        [tStampItem setObject:[NSNumber numberWithBool:[self.haveDateSwitch isOn]] forKey:@"haveDate"];
        [tStampItem setObject:[NSNumber numberWithBool:[self.haveTimeSwitch isOn]] forKey:@"haveTime"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(stampTextViewController:dictionary:)]) {
            [self.delegate stampTextViewController:self dictionary:tStampItem];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)buttonItemClicked_cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldEditChange:(id)sender {
    UITextField *textField = (UITextField *)sender;
    
    self.preView.textStampText = textField.text;
    [self.preView setNeedsDisplay];
}

- (void)switchChange_date:(id)sender {
    self.preView.textStampHaveDate = [self.haveDateSwitch isOn];
    [self.preView setNeedsDisplay];
}

- (void)switchChange_time:(id)sender {
    self.preView.textStampHaveTime = [self.haveTimeSwitch isOn];
    [self.preView setNeedsDisplay];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 800);
    } else {

    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 560);
    } else {

    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - CStampShapViewDelegate

- (void)stampShapView:(CStampShapView *)stampShapView tag:(NSInteger)tag {
    switch (tag) {
        case TextStampTypeCenter:
        {
            self.preView.textStampStyle = TextStampTypeCenter;
            self.textStampStyle = TextStampTypeCenter;
            [self.preView setNeedsDisplay];
        }
            break;
        case TextStampTypeLeft:
        {
            self.preView.textStampStyle = TextStampTypeLeft;
            self.textStampStyle = TextStampTypeLeft;
            [self.preView setNeedsDisplay];
        }
            break;
        case TextStampTypeRight:
        {
            self.preView.textStampStyle = TextStampTypeRight;
            self.textStampStyle = TextStampTypeRight;
            [self.preView setNeedsDisplay];
        }
            break;
        case TextStampTypeNone:
        {
            self.preView.textStampStyle = TextStampTypeNone;
            self.textStampStyle = TextStampTypeNone;
            [self.preView setNeedsDisplay];
        }
            break;
    }
}

#pragma mark - CPDFColorSelectViewDelegate

- (void)stampColorSelectView:(CStampColorSelectView *)StampColorSelectView tag:(NSInteger)tag {
    switch (tag) {
        case 0:
        {
            self.preView.textStampColorStyle = TextStampColorTypeBlack;
            self.textStampColorStyle = TextStampColorTypeBlack;
            [self.preView setNeedsDisplay];
        }
            break;
        case 1:
        {
            self.preView.textStampColorStyle = TextStampColorTypeRed;
            self.textStampColorStyle = TextStampColorTypeRed;
            [self.preView setNeedsDisplay];
        }
            
            break;
        case 2:
        {
            self.preView.textStampColorStyle = TextStampColorTypeGreen;
            self.textStampColorStyle = TextStampColorTypeGreen;
            [self.preView setNeedsDisplay];
        }
            
            break;
        case 3:
        {
            self.preView.textStampColorStyle = TextStampColorTypeBlue;
            self.textStampColorStyle = TextStampColorTypeBlue;
            [self.preView setNeedsDisplay];
        }
            
            break;
            
        default:
            break;
    }
}

@end
