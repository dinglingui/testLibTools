//
//  CPDFFormToolBar.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormToolBar.h"
#import "CPDFColorUtils.h"
#import "CPDFAnnotationBarButton.h"
#import "AAPLCustomPresentationController.h"

#import "CPDFFormTextViewController.h"
#import "CPDFFormCheckBoxViewController.h"
#import "CPDFFormRadioButtonViewController.h"
#import "CPDFFormComboxViewController.h"
#import "CPDFFormListViewController.h"
#import "CPDFFormButtonViewController.h"
#import "CPDFSignatureViewController.h"
#import "CAnnotStyle.h"
#import "CPDFListView.h"
#import "CPDFListView+UndoManager.h"
#import "CPDFListView+Private.h"
#import "CPDFFormLinkViewController.h"

@interface CPDFFormToolBar()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *formBtns;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) UIView *propertiesBar;

@property (nonatomic, strong) UIButton *propertiesBtn;

@property (nonatomic, strong) UIButton *undoBtn;

@property (nonatomic, strong) UIButton *redoBtn;

@property (nonatomic, strong) CPDFListView *pdfListView;

@property (nonatomic, strong) CAnnotationManage *annotManage;


@end

@implementation CPDFFormToolBar

#pragma mark - Initializers

- (instancetype)initAnnotationManage:(CAnnotationManage *)annotationManage {
    if (self = [super init]) {
        self.annotManage = annotationManage;
        
        self.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        line.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:line];
        
        self.pdfListView = annotationManage.pdfListView;
        
        self.selectedIndex = 0;
        [self initSubview];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationChangedNotification:) name:CPDFListViewActiveAnnotationsChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(annotationsOperationChangeNotification:) name:CPDFListViewAnnotationsOperationChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CPDFListViewAnnotationsOperationChangeNotification object:annotationManage.pdfListView];


    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width-self.propertiesBar.frame.size.width, self.frame.size.height);
}

#pragma mark - NSNotification

- (void)annotationsOperationChangeNotification:(NSNotification *)notification {
    CPDFListView *pdfListView = notification.object;
    if(pdfListView == self.annotManage.pdfListView) {
        if([pdfListView canUndo])
            self.undoBtn.enabled = YES;
         else
            self.undoBtn.enabled = NO;
        
        if([pdfListView canRedo])
            self.redoBtn.enabled = YES;
         else
            self.redoBtn.enabled = NO;
    }
}

- (void)annotationChangedNotification:(NSNotification *)notification {
    if (self.pdfListView.activeAnnotations.firstObject) {
        [self.annotManage setAnnotStyleFromAnnotations:self.pdfListView.activeAnnotations];
    } else {
        [self.annotManage setAnnotStyleFromMode:self.pdfListView.annotationMode];

    }
    [self updatePropertiesButtonState];
}



#pragma mark - Public Methods

- (void)reloadData {
    if(CPDFViewAnnotationModeNone == self.pdfListView.annotationMode) {
        if (self.selectedIndex >0 &&
            self.selectedIndex <= self.formBtns.count) {
            for (NSInteger i = 0; i< self.formBtns.count; i++) {
                UIButton *button = [self.formBtns objectAtIndex:i];
                if(button.tag == self.selectedIndex) {
                    button.backgroundColor = [UIColor clearColor];
                    self.selectedIndex = 0;
                    break;
                }
            }
        }
    } else {
        for (NSInteger i = 0; i< self.formBtns.count; i++) {
            UIButton *button = [self.formBtns objectAtIndex:i];
            if(button.tag == self.pdfListView.annotationMode) {
                button.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
                self.selectedIndex = button.tag;
            } else {
                button.backgroundColor = [UIColor clearColor];
            }
        }
    }
    
    [self.pdfListView reloadInputViews];
}

#pragma mark - Private Methods

- (void)initSubview {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    CGFloat offsetX = 10.0;
    CGFloat buttonOffset = 25;
    CGFloat buttonSize = 30;
    
    CGFloat topOffset = (44 - buttonSize)/2;
    
    NSMutableArray *images = [NSMutableArray arrayWithArray:@[@"CPDFFormTextField",
                                                              @"CPDFFormCheckbox",
                                                              @"CPDFFormRadiobutton",
                                                              @"CPDFFormListbox",
                                                              @"CPDFFormPullDownMenu",
                                                              @"CPDFFormButton",
                                                              @"CPDFFormSign"]];
    

    NSMutableArray *types = [NSMutableArray arrayWithArray:@[@(CPDFViewFormModeText),
                                                             @(CPDFViewFormModeCheckBox),
                                                             @(CPDFViewFormModeRadioButton),
                                                             @(CPDFViewFormModeList),
                                                             @(CPDFViewFormModeCombox),
                                                             @(CPDFViewFormModeButton),
                                                             @(CPDFViewFormModeSign)]];
    NSMutableArray *annotationBtns = [NSMutableArray array];
    for (int i = 0; i < types.count; i++) {
        CPDFViewAnnotationMode annotationMode = (CPDFViewAnnotationMode)[types[i] integerValue];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(offsetX, topOffset, buttonSize, buttonSize);
        [button setImage:[UIImage imageNamed:images[i] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        button.layer.cornerRadius = 5.0;
        button.tag = annotationMode;
        [button addTarget:self action:@selector(buttonItemClicked_Switch:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];
        [annotationBtns addObject:button];
        if(i != types.count -1)
            offsetX += button.bounds.size.width + buttonOffset;
        else
          offsetX += button.bounds.size.width + 10;

    }
    self.formBtns = annotationBtns;
    
    _scrollView.contentSize = CGSizeMake(offsetX, _scrollView.bounds.size.height);
    [self.scrollView bringSubviewToFront:self.propertiesBar];
    
    CGFloat offset = 10;

    CGFloat prWidth = buttonSize * 2 + offset;
    _propertiesBar = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width - prWidth, 0, prWidth, 44)];
    _propertiesBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:self.propertiesBar];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(offset - 5, 12, 1, 20)];
    if (@available(iOS 13.0, *)){
        if([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark) {
            lineView.backgroundColor = [UIColor whiteColor];
        }else{
            lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        }

    }else {
        lineView.backgroundColor = [UIColor blackColor];
    }

    [self.propertiesBar addSubview:lineView];
    offset += lineView.frame.size.width;

    _undoBtn = [[UIButton alloc] initWithFrame:CGRectMake(offset, topOffset, buttonSize, buttonSize)];
    [_undoBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBarImageUndo" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_undoBtn addTarget:self action:@selector(buttonItemClicked_undo:) forControlEvents:UIControlEventTouchUpInside];
    [self.propertiesBar addSubview:self.undoBtn];
    offset += self.undoBtn.frame.size.width;

    _redoBtn = [[UIButton alloc] initWithFrame:CGRectMake(offset, topOffset, buttonSize, buttonSize)];
    [_redoBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBarImageRedo" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_redoBtn addTarget:self action:@selector(buttonItemClicked_redo:) forControlEvents:UIControlEventTouchUpInside];
    [self.propertiesBar addSubview:self.redoBtn];
    
    [self updatePropertiesButtonState];
}

- (void)updatePropertiesButtonState {
    if(CPDFViewAnnotationModeNone != self.pdfListView.annotationMode || self.annotManage.pdfListView.activeAnnotations.count > 0) {
        CPDFAnnotation *annotation = self.annotManage.pdfListView.activeAnnotations.firstObject;
        if([annotation isKindOfClass:[CPDFSignatureAnnotation class]]) {
            self.propertiesBtn.enabled = NO;
        } else {
            self.propertiesBtn.enabled = YES;
        }
    } else {
        self.propertiesBtn.enabled = NO;
    }
    self.propertiesBtn.enabled = NO;
}


- (void)buttonItemClicked_Switch:(UIButton *)button {
    self.selectedIndex = button.tag;
    BOOL isSelect = YES;
    if (self.pdfListView.annotationMode != self.selectedIndex) {
        self.propertiesBtn.enabled = YES;
        button.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        self.pdfListView.annotationMode = self.selectedIndex;
        [self.annotManage setAnnotStyleFromMode:self.selectedIndex];
        isSelect = YES;

    } else {
        self.propertiesBtn.enabled = NO;
        self.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
        self.selectedIndex = 0;
        button.backgroundColor = [UIColor clearColor];
        isSelect = NO;
    }
    
    [self updatePropertiesButtonState];
    
    [self reloadData];
}

- (void)updateStatus {
    self.selectedIndex = 0;
    self.pdfListView.annotationMode = self.selectedIndex;
    [self.annotManage setAnnotStyleFromMode:self.selectedIndex];
    [self reloadData];
}

- (void)initUndoRedo {
    self.undoBtn.enabled = NO;
    self.redoBtn.enabled = NO;
    [self.pdfListView registerAsObserver];
}


- (void)buttonItemClicked_open:(UIButton *)button {
    CAnnotStyle *annotStytle = self.annotManage.annotStyle;
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    switch (annotStytle.annotMode) {
        case CPDFViewFormModeText:
        {
            CPDFFormTextViewController *textVC = [[CPDFFormTextViewController alloc] initWithManage:self.annotManage];
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:textVC presentingViewController:self.parentVC];
            textVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:textVC animated:YES completion:nil];
            
        }
            break;
        case CPDFViewFormModeCheckBox:
        {
            CPDFFormCheckBoxViewController * checkBoxVc = [[CPDFFormCheckBoxViewController alloc] initWithManage:self.annotManage];
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:checkBoxVc presentingViewController:self.parentVC];
            checkBoxVc.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:checkBoxVc animated:YES completion:nil];
        }
            break;
        case CPDFViewFormModeRadioButton:
        {
            CPDFFormRadioButtonViewController * radioButtonVc = [[CPDFFormRadioButtonViewController alloc] initWithManage:self.annotManage];
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:radioButtonVc presentingViewController:self.parentVC];
            radioButtonVc.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:radioButtonVc animated:YES completion:nil];
            
        }
            break;
        case CPDFViewFormModeList:
        {
            CPDFFormListViewController * listVC = [[CPDFFormListViewController alloc] initWithManage:self.annotManage];
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:listVC presentingViewController:self.parentVC];
            listVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:listVC animated:YES completion:nil];
        }
            break;
        case CPDFViewFormModeCombox:
        {
            CPDFFormComboxViewController * comboVC = [[CPDFFormComboxViewController alloc] initWithManage:self.annotManage];
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:comboVC presentingViewController:self.parentVC];
            comboVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:comboVC animated:YES completion:nil];

        }
            break;
        case CPDFViewFormModeButton:
        {
            CPDFFormButtonViewController * buttonVC = [[CPDFFormButtonViewController alloc] initWithManage:self.annotManage];
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:buttonVC presentingViewController:self.parentVC];
            buttonVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:buttonVC animated:YES completion:nil];
            
        }
            break;
        case CPDFViewFormModeSign:
        {
            //pusTosign
            CPDFSignatureViewController *signatureVC = [[CPDFSignatureViewController alloc] initWithStyle:nil];
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:signatureVC presentingViewController:self.parentVC];
            signatureVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:signatureVC animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

- (void)buttonItemClicked_openOption:(CPDFWidgetAnnotation *)annotation {
    CAnnotStyle *annotStytle = self.annotManage.annotStyle;
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    if([annotation isKindOfClass:[CPDFButtonWidgetAnnotation class]]) {
        CPDFFormLinkViewController *linkVC = [[CPDFFormLinkViewController alloc] initWithStyle:annotStytle];
        linkVC.pageCount = self.annotManage.pdfListView.document.pageCount;
        presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:linkVC presentingViewController:self.parentVC];
        linkVC.transitioningDelegate = presentationController;
        [self.parentVC presentViewController:linkVC animated:YES completion:nil];
    }else{
        CPDFFormListOptionVC * listVc = [[CPDFFormListOptionVC alloc] initWithPDFView:self.pdfListView andAnnotation:annotation];

        presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:listVc presentingViewController:self.parentVC];
        listVc.transitioningDelegate = presentationController;

        [self.parentVC presentViewController:listVc animated:YES completion:nil];
    }
}

- (void)buttonItemClicked_undo:(UIButton *)button {
    if(self.annotManage.pdfListView.undoPDFManager && [self.annotManage.pdfListView canUndo]) {
        [self.annotManage.pdfListView.undoPDFManager undo];
    }
}

- (void)buttonItemClicked_redo:(UIButton *)button {
    if(self.annotManage.pdfListView.undoPDFManager && [self.annotManage.pdfListView canRedo]) {
        [self.annotManage.pdfListView.undoPDFManager redo];
    }
}


@end
