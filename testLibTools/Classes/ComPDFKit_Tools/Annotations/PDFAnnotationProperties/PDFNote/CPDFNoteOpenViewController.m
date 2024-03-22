//
//  CPDFNoteOpenViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFNoteOpenViewController.h"

#import <ComPDFKit/ComPDFKit.h>
#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
#pragma mark - UIPopBackgroundView

@interface UIPopBackgroundView : UIPopoverBackgroundView

@property (nonatomic, assign) CGFloat fArrowOffset;
@property (nonatomic, assign) UIPopoverArrowDirection direction;

@end


@implementation UIPopBackgroundView

+ (BOOL)wantsDefaultContentAppearance {
    return NO;
}

+ (CGFloat)arrowBase{
    return 0;
}

+ (UIEdgeInsets)contentViewInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

+ (CGFloat)arrowHeight{
    return 0;
}

- (UIPopoverArrowDirection)arrowDirection {
    return self.direction;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection {
    self.direction = arrowDirection;
}
- (void)setArrowOffset:(CGFloat)arrowOffset {
    self.fArrowOffset = arrowOffset;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 3.0f;
        
        UIView *shadowView = [[UIView alloc] initWithFrame:frame];
        shadowView.backgroundColor = self.backgroundColor;
        [self addSubview:shadowView];
        shadowView.layer.shadowColor = [UIColor colorWithRed:163.0/255.0 green:163.0/255.0 blue:163.0/255.0 alpha:0.5].CGColor;
        shadowView.layer.shadowOpacity = 1.0f;
        shadowView.layer.shadowRadius = 1.0;
        shadowView.layer.shadowOffset = CGSizeMake(2, 1);
        shadowView.layer.cornerRadius = 3.0f;
        
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = shadowView.layer.bounds;
        maskLayer.masksToBounds = YES;
        [shadowView.layer addSublayer:maskLayer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end

#pragma mark - CPDFNoteOpenViewController

@interface CPDFNoteOpenViewController () <UIPopoverPresentationControllerDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITextView *noteTextView;

@property (nonatomic, strong) NSString *textViewContent;

@property (nonatomic, strong) CPDFAnnotation * annotation;

@property (nonatomic, strong) UIView *contentView;

@end

@implementation CPDFNoteOpenViewController

- (instancetype)initWithAnnotation:(id)annotation {
    if(self = [super init]) {
        self.annotation = annotation;
    }
    return self;
}

#pragma mark - UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [CPDFColorUtils CNoteOpenBackgooundColor];
    
    _noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, self.view.bounds.size.height-45)];
    _noteTextView.delegate = self;
    _noteTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [_noteTextView setBackgroundColor:[UIColor clearColor]];
    [_noteTextView setFont:[UIFont systemFontOfSize:14]];
    [_noteTextView setTextAlignment:NSTextAlignmentLeft];
    [_noteTextView setTextColor:[UIColor blackColor]];
    [self.view addSubview:_noteTextView];
    _noteTextView.text = self.textViewContent;
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:[UIImage imageNamed:@"CPDFNoteContentImageNameDelete"
                                      inBundle:[NSBundle bundleForClass:self.class]
                 compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [deleteButton sizeToFit];
    CGRect frame = deleteButton.frame;
    frame.origin.x = 10;
    frame.origin.y = self.view.bounds.size.height-deleteButton.bounds.size.height-10;
    deleteButton.frame = frame;
    deleteButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [deleteButton addTarget:self action:@selector(buttonItemClicked_Delete:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveButton setImage:[UIImage imageNamed:@"CPDFNoteContentImageNameSave"
                                    inBundle:[NSBundle bundleForClass:self.class]
               compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [saveButton sizeToFit];
    frame = saveButton.frame;
    frame.origin.x = self.view.bounds.size.width-saveButton.bounds.size.width-10;
    frame.origin.y = self.view.bounds.size.height-saveButton.bounds.size.height-10;
    saveButton.frame = frame;
    saveButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [saveButton addTarget:self action:@selector(buttonItemClicked_Save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
    
    self.noteTextView.text = self.annotation.contents?:@"";
}

- (void)viewDidAppear:(BOOL)animation {
    [super viewDidAppear:animation];
    
    [_noteTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animation {
    [super viewWillDisappear:animation];
    
    if ([_noteTextView isFirstResponder]) {
        [_noteTextView resignFirstResponder];
    }
}

- (void)showViewController:(UIViewController *)viewController inRect:(CGRect)rect {
    self.preferredContentSize = CGSizeMake(280, 305);
    self.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popVC = self.popoverPresentationController;
    popVC.delegate = self;
    popVC.sourceRect = rect;
    popVC.sourceView = viewController.view;
    popVC.canOverlapSourceViewRect = YES;
    popVC.popoverBackgroundViewClass = [UIPopBackgroundView class];
    [viewController presentViewController:self animated:YES completion:nil];
}

#pragma mark - Button Event Action

- (void)buttonItemClicked_Delete:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(getNoteOpenViewController:content:isDelete:)]) {
            [self.delegate getNoteOpenViewController:self content:self.noteTextView.text isDelete:YES];
        }
    }];
}

- (void)buttonItemClicked_Save:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(getNoteOpenViewController:content:isDelete:)]) {
            [self.delegate getNoteOpenViewController:self content:self.noteTextView.text isDelete:NO];
        }
    }];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(getNoteOpenViewController:content:isDelete:)]) {
        [self.delegate getNoteOpenViewController:self content:self.noteTextView.text isDelete:NO];
    }
}

@end
