//
//  CPDFAnnotationToolBar.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFAnnotationToolBar.h"
#import "CPDFAnnotationBarButton.h"
#import "CPDFNoteViewController.h"
#import "CPDFHighlightViewController.h"
#import "CPDFStrikeoutViewController.h"
#import "CPDFSquigglyViewController.h"
#import "CPDFInkViewController.h"
#import "CPDFShapeCircleViewController.h"
#import "CPDFShapeArrowViewController.h"
#import "CPDFFreeTextViewController.h"
#import "CPDFSignatureViewController.h"
#import "CPDFLinkViewController.h"
#import "CPDFInkTopToolBar.h"
#import "CAnnotStyle.h"
#import "CPDFListView.h"
#import "CPDFListView+UndoManager.h"
#import "CPDFListView+Private.h"
#import "CAnnotationManage.h"
#import "CPDFSignatureEditViewController.h"
#import "CPDFStampViewController.h"
#import "CSignatureManager.h"
#import "CPDFColorUtils.h"
#import "AAPLCustomPresentationController.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFAnnotationToolBar () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, CPDFSignatureViewControllerDelegate, CPDFSignatureEditViewControllerDelegate, CPDFNoteViewControllerDelegate, CPDFShapeCircleViewControllerDelegate, CPDFHighlightViewControllerDelegate, CPDFUnderlineViewControllerDelegate, CPDFStrikeoutViewControllerDelegate, CPDFSquigglyViewControllerDelegate, CPDFInkTopToolBarDelegate, CPDFInkViewControllerDelegate, CPDFShapeArrowViewControllerDelegate, CPDFStampViewControllerDelegate,CPDFLinkViewControllerDelegate, CPDFFreeTextViewControllerDelegate,CPDFDrawPencilViewDelegate,AAPLCustomPresentationControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *annotationBtns;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) UIView *propertiesBar;

@property (nonatomic, strong) UIButton *propertiesBtn;

@property (nonatomic, strong) UIButton *undoBtn;

@property (nonatomic, strong) UIButton *redoBtn;

@property (nonatomic, strong) CPDFListView *pdfListView;

@property (nonatomic, strong) CAnnotationManage *annotManage;

@property (nonatomic, strong) CPDFSignatureViewController *signatureVC;

@property (nonatomic, assign) CGPoint menuPoint;

@property (nonatomic, strong) CPDFPage * menuPage;

@property (nonatomic, assign) BOOL isAddAnnotation;

@property (nonatomic, strong) CPDFSignatureWidgetAnnotation * signatureAnnotation;

@property (nonatomic, strong) CPDFLinkViewController *linkVC;

@end

@implementation CPDFAnnotationToolBar

#pragma mark - Initializers

- (instancetype)initAnnotationManage:(CAnnotationManage *)annotationManage {
    if (self = [super init]) {
        self.annotManage = annotationManage;
        
        self.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        line.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:line];
        
        self.selectedIndex = 0;
        
        self.pdfListView = annotationManage.pdfListView;

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
    
    if (@available(iOS 11.0, *)) {
        self.topToolBar.frame = CGRectMake(self.pdfListView.frame.size.width-30-self.topToolBar.frame.size.width, self.window.safeAreaInsets.top, self.topToolBar.frame.size.width, 50);
    } else {
        self.topToolBar.frame = CGRectMake(self.pdfListView.frame.size.width-30-self.topToolBar.frame.size.width, 64, self.topToolBar.frame.size.width, 50);
    }
}

#pragma mark - Public Methods

- (void)reloadData {
    if(CPDFViewAnnotationModeNone == self.pdfListView.annotationMode) {
        if (self.selectedIndex >0) {
            for (NSInteger i = 0; i< self.annotationBtns.count; i++) {
                CPDFAnnotationBarButton *button = [self.annotationBtns objectAtIndex:i];
                if(button.tag == self.selectedIndex) {
                    button.backgroundColor = [UIColor clearColor];
                    self.selectedIndex = 0;
                    break;
                }
            }
        }
    } else {
        for (NSInteger i = 0; i< self.annotationBtns.count; i++) {
            UIButton *button = [self.annotationBtns objectAtIndex:i];
            if(button.tag == self.pdfListView.annotationMode) {
                button.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
                self.selectedIndex = button.tag;
            } else {
                button.backgroundColor = [UIColor clearColor];
            }
        }
    }
}

- (void)openSignatureAnnotation:(CPDFSignatureWidgetAnnotation *)signatureAnnotation {
    self.signatureAnnotation = signatureAnnotation;
    CAnnotStyle *annotStytle = self.annotManage.annotStyle;
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    self.signatureVC = [[CPDFSignatureViewController alloc] initWithStyle:annotStytle];
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:self.signatureVC presentingViewController:self.parentVC];
    self.signatureVC.delegate = self;
    self.signatureVC.transitioningDelegate = presentationController;
    [self.parentVC presentViewController:self.signatureVC animated:YES completion:nil];

}

- (void)addStampAnnotationWithPage:(CPDFPage *)page point:(CGPoint)point {
    self.isAddAnnotation = YES;
    self.menuPage = page;
    self.menuPoint = point;
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    CPDFStampViewController *stampVC = [[CPDFStampViewController alloc] init];
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:stampVC presentingViewController:self.parentVC];
    presentationController.tapDelegate = self;
    stampVC.delegate = self;
    stampVC.transitioningDelegate = presentationController;
    [self.parentVC presentViewController:stampVC animated:YES completion:nil];
}

- (void)addImageAnnotationWithPage:(CPDFPage *)page point:(CGPoint)point {
    self.isAddAnnotation = YES;
    self.menuPage = page;
    self.menuPoint = point;
    [self createImageAnnotaion];
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
    
    NSMutableArray *images = [NSMutableArray arrayWithArray:@[@"CPDFAnnotationBarImageNote",
                                                              @"CPDFAnnotationBarImageHighLight",
                                                              @"CPDFAnnotationBarImageUnderline",
                                                              @"CPDFAnnotationBarImageStrikeout",
                                                              @"CPDFAnnotationBarImageSquiggly",
                                                              @"CPDFAnnotationBarImageFreehand",
                                                              @"CPDFAnnotationBarImagePencilDraw",
                                                              @"CPDFAnnotationBarImageShapeCircle",
                                                              @"CPDFAnnotationBarImageShapeRectangle",
                                                              @"CPDFAnnotationBarImageShapeArrow",
                                                              @"CPDFAnnotationBarImageShapeLine",
                                                              @"CPDFAnnotationBarImageFreeText",
                                                              @"CPDFAnnotationBarImageSignature",
                                                              @"CPDFAnnotationBarImageStamp",
                                                              @"CPDFAnnotationBarImageImage",
                                                              @"CPDFAnnotationBarImageLink",
                                                              @"CPDFAnnotationBarImageSound"]];
    
    NSMutableArray *types = [NSMutableArray arrayWithArray:@[@(CPDFViewAnnotationModeNote),
                                                             @(CPDFViewAnnotationModeHighlight),
                                                             @(CPDFViewAnnotationModeUnderline),
                                                             @(CPDFViewAnnotationModeStrikeout),
                                                             @(CPDFViewAnnotationModeSquiggly),
                                                             @(CPDFViewAnnotationModeInk),
                                                             @(CPDFViewAnnotationModePencilDrawing),
                                                             @(CPDFViewAnnotationModeCircle),
                                                             @(CPDFViewAnnotationModeSquare),
                                                             @(CPDFViewAnnotationModeArrow),
                                                             @(CPDFViewAnnotationModeLine),
                                                             @(CPDFViewAnnotationModeFreeText),
                                                             @(CPDFViewAnnotationModeSignature),
                                                             @(CPDFViewAnnotationModeStamp),
                                                             @(CPDFViewAnnotationModeImage),
                                                             @(CPDFViewAnnotationModeLink),
                                                             @(CPDFViewAnnotationModeSound)]];

    if (@available(iOS 13.0, *)) {
    } else {
        [images removeObject:@"CPDFAnnotationBarImagePencilDraw"];
        [types removeObject:@(CPDFViewAnnotationModePencilDrawing)];
    }
    
    NSMutableArray *annotationBtns = [NSMutableArray array];
    for (int i = 0; i < types.count; i++) {
        CPDFViewAnnotationMode annotationMode = (CPDFViewAnnotationMode)[types[i] integerValue];
        CPDFAnnotationBarButton *button = [CPDFAnnotationBarButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(offsetX, topOffset, buttonSize, buttonSize);
        [button setImage:[UIImage imageNamed:images[i] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        button.layer.cornerRadius = 5.0;
        button.tag = annotationMode;
        if (CPDFViewAnnotationModeHighlight == annotationMode) {
            button.lineColor = CAnnotationManage.highlightAnnotationColor;
        } else if (CPDFViewAnnotationModeUnderline == annotationMode) {
            button.lineColor = CAnnotationManage.underlineAnnotationColor;
        } else if (CPDFViewAnnotationModeStrikeout == annotationMode) {
            button.lineColor = CAnnotationManage.strikeoutAnnotationColor;
        } else if (CPDFViewAnnotationModeSquiggly == annotationMode) {
            button.lineColor = CAnnotationManage.squigglyAnnotationColor;
        } else if (CPDFViewAnnotationModeInk== annotationMode) {
            button.lineColor = CAnnotationManage.freehandAnnotationColor;
        }
        [button addTarget:self action:@selector(buttonItemClicked_Switch:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];
        [annotationBtns addObject:button];
        if(i != types.count -1)
            offsetX += button.bounds.size.width + buttonOffset;
        else
          offsetX += button.bounds.size.width + 10;

    }
    self.annotationBtns = annotationBtns;
    
    _scrollView.contentSize = CGSizeMake(offsetX, _scrollView.bounds.size.height);
    [self.scrollView bringSubviewToFront:self.propertiesBar];
    
    CGFloat offset = 10;

    CGFloat prWidth = buttonSize * 3 + offset;
    _propertiesBar = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width - prWidth, 0, prWidth, 44)];
    _propertiesBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:self.propertiesBar];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(offset, 12, 1, 20)];
    if (@available(iOS 13.0, *)){
        if([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark)
            lineView.backgroundColor = [UIColor whiteColor];
        else
            lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    } else
        lineView.backgroundColor = [UIColor blackColor];

        [self.propertiesBar addSubview:lineView];
    offset += lineView.frame.size.width;
    
    _propertiesBtn = [[UIButton alloc] initWithFrame:CGRectMake(offset, topOffset, buttonSize, buttonSize)];
    [_propertiesBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBarImageProperties" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_propertiesBtn addTarget:self action:@selector(buttonItemClicked_openModel:) forControlEvents:UIControlEventTouchUpInside];
    [self.propertiesBar addSubview:self.propertiesBtn];
    offset += self.propertiesBtn.frame.size.width;

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
    if(CPDFViewAnnotationModeNone != self.pdfListView.annotationMode) {
        CPDFAnnotation *annotation = self.annotManage.pdfListView.activeAnnotations.firstObject;
        if([annotation isKindOfClass:[CPDFStampAnnotation class]] || [annotation isKindOfClass:[CPDFSignatureAnnotation class]] ||  [annotation isKindOfClass:[CPDFSoundAnnotation class]] || (CPDFViewAnnotationModeSound == self.selectedIndex) || [annotation isKindOfClass:[CPDFLinkAnnotation class]] || (CPDFViewAnnotationModeLink == self.selectedIndex)) {
            self.propertiesBtn.enabled = NO;
        } else {
            self.propertiesBtn.enabled = YES;
        }
    } else {
        self.propertiesBtn.enabled = NO;
    }
}

- (void)updateUndoRedoState {
    self.undoBtn.enabled = NO;
    self.redoBtn.enabled = NO;
    [self.pdfListView registerAsObserver];
}

#pragma mark - Action

- (void)buttonItemClicked_Switch:(UIButton *)button {
    if (CPDFViewAnnotationModeSound == self.selectedIndex) {
       [self.pdfListView stopRecord];
   }
    self.selectedIndex = button.tag;
    BOOL isSelect = YES;
    if (self.pdfListView.annotationMode != self.selectedIndex) {
        self.propertiesBtn.enabled = YES;
        
        button.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        if(CPDFViewAnnotationModeInk == self.selectedIndex) {
            [CPDFKitConfig sharedInstance].enableFreehandPencilKit = NO;
        } else if (CPDFViewAnnotationModePencilDrawing == self.selectedIndex) {
            [CPDFKitConfig sharedInstance].enableFreehandPencilKit = YES;
        }
        
        self.pdfListView.annotationMode = self.selectedIndex;

        isSelect = YES;

    } else {
        self.propertiesBtn.enabled = NO;
        if(CPDFViewAnnotationModeSound == self.selectedIndex) {
            [self.pdfListView stopRecord];
        } else if (CPDFViewAnnotationModeFreeText == self.selectedIndex) {
            [self.pdfListView commitEditAnnotationFreeText];
        }
        self.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
        self.selectedIndex = 0;
        button.backgroundColor = [UIColor clearColor];
        isSelect = NO;
    }
    
    [self updatePropertiesButtonState];
    
    [self createPropertyViewController];
        
    if([self.delegate respondsToSelector:@selector(annotationBarClick:clickAnnotationMode:forSelected:forButton:)]) {
        [self.delegate annotationBarClick:self clickAnnotationMode:(CPDFViewAnnotationMode)button.tag forSelected:isSelect forButton:button];
    }
}

- (void)buttonItemClicked_openModel:(id)button {
    [self.annotManage setAnnotStyleFromMode:self.pdfListView.annotationMode];
    [self buttonItemClicked_open:button];
}

- (void)buttonItemClicked_openAnnotation:(id)button {
    [self.annotManage setAnnotStyleFromAnnotations:self.pdfListView.activeAnnotations];
    [self buttonItemClicked_open:button];
}

- (void)buttonItemClicked_open:(id)button {
    CAnnotStyle *annotStytle = self.annotManage.annotStyle;
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    switch (annotStytle.annotMode) {
        case CPDFToolbarNote:
        {
            CPDFNoteViewController *noteVC = [[CPDFNoteViewController alloc] initWithStyle:annotStytle];
            noteVC.delegate = self;

            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:noteVC presentingViewController:self.parentVC];
            noteVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:noteVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarHighlight:
        {
            CPDFHighlightViewController *highlightVC = [[CPDFHighlightViewController alloc] initWithStyle:annotStytle];
            highlightVC.delegate = self;

            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:highlightVC presentingViewController:self.parentVC];
            highlightVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:highlightVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarUnderline:
        {
            CPDFUnderlineViewController *underlineVC = [[CPDFUnderlineViewController alloc] initWithStyle:annotStytle];
            underlineVC.delegate = self;

            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:underlineVC presentingViewController:self.parentVC];
            underlineVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:underlineVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarStrikeout:
        {
            CPDFStrikeoutViewController *strikeoutVC = [[CPDFStrikeoutViewController alloc] initWithStyle:annotStytle];
            strikeoutVC.delegate = self;

            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:strikeoutVC presentingViewController:self.parentVC];
            strikeoutVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:strikeoutVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarSquiggly:
        {
            CPDFSquigglyViewController *squigglyVC = [[CPDFSquigglyViewController alloc] initWithStyle:annotStytle];
            squigglyVC.delegate = self;

            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:squigglyVC presentingViewController:self.parentVC];
            squigglyVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:squigglyVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarFreehand:
        {
            CPDFInkViewController *inkVC = [[CPDFInkViewController alloc] initWithStyle:annotStytle];
            inkVC.delegate = self;
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:inkVC presentingViewController:self.parentVC];
            inkVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:inkVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarShapeCircle:
        {
            CPDFShapeCircleViewController *circleVC = [[CPDFShapeCircleViewController alloc] initWithStyle:annotStytle];
            circleVC.delegate = self;
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:circleVC presentingViewController:self.parentVC];
            circleVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:circleVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarShapeRectangle:
        {
            CPDFShapeCircleViewController *squareVC = [[CPDFShapeCircleViewController alloc] initWithStyle:annotStytle];
            squareVC.delegate = self;
            
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:squareVC presentingViewController:self.parentVC];
            squareVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:squareVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarShapeArrow:
        {
            CPDFShapeArrowViewController *arrowVC = [[CPDFShapeArrowViewController alloc] initWithStyle:annotStytle];
            arrowVC.lineDelegate = self;
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:arrowVC presentingViewController:self.parentVC];
            arrowVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:arrowVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarShapeLine:
        {
            CPDFShapeArrowViewController *lineVC = [[CPDFShapeArrowViewController alloc] initWithStyle:annotStytle];
            lineVC.lineDelegate = self;
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:lineVC presentingViewController:self.parentVC];
            lineVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:lineVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarFreeText:
        {
            CPDFFreeTextViewController *freeTextVC = [[CPDFFreeTextViewController alloc] initWithStyle:annotStytle];
            freeTextVC.delegate = self;
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:freeTextVC presentingViewController:self.parentVC];
            freeTextVC.pdfListView = self.annotManage.pdfListView;
            freeTextVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:freeTextVC animated:YES completion:nil];
        }
            break;
        case CPDFToolbarLink:
        {
            self.linkVC = [[CPDFLinkViewController alloc] initWithStyle:annotStytle];
            self.linkVC.pageCount = self.annotManage.pdfListView.document.pageCount;
            self.linkVC.delegate = self;
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:self.linkVC presentingViewController:self.parentVC];
            presentationController.tapDelegate = self;
            self.linkVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:self.linkVC animated:YES completion:nil];
        }
            break;
        default:
            break;
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

#pragma mark - Private Methods

- (void)createPropertyViewController {
    if (CPDFViewAnnotationModeInk == self.selectedIndex) {
        [self.annotManage setAnnotStyleFromMode:self.pdfListView.annotationMode];

        self.propertiesBtn.enabled = NO;
        if (@available(iOS 11.0, *)) {
            self.topToolBar = [[CPDFInkTopToolBar alloc] initWithFrame:CGRectMake(self.pdfListView.frame.size.width-30- 300, self.window.safeAreaInsets.top, 300, 50)];
            self.topToolBar.delegate = self;
            
            [self.pdfListView addSubview:self.topToolBar];
        } else {
            self.topToolBar = [[CPDFInkTopToolBar alloc] initWithFrame:CGRectMake(self.pdfListView.frame.size.width-30-300, 64, 300, 50)];
            self.topToolBar.delegate = self;
            [self.pdfListView addSubview:self.topToolBar];
        }
    } else if (CPDFViewAnnotationModeSignature == self.selectedIndex) {
        self.propertiesBtn.enabled = NO;
        CAnnotStyle *annotStytle = self.annotManage.annotStyle;
        AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
        self.signatureVC = [[CPDFSignatureViewController alloc] initWithStyle:annotStytle];
        presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:self.signatureVC presentingViewController:self.parentVC];
        presentationController.tapDelegate = self;
        self.signatureVC.delegate = self;
        self.signatureVC.transitioningDelegate = presentationController;
        [self.parentVC presentViewController:self.signatureVC animated:YES completion:nil];
    } else if (CPDFViewAnnotationModeStamp == self.selectedIndex) {
        self.propertiesBtn.enabled = NO;
        AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
        CPDFStampViewController *stampVC = [[CPDFStampViewController alloc] init];
        presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:stampVC presentingViewController:self.parentVC];
        presentationController.tapDelegate = self;
        stampVC.delegate = self;
        stampVC.transitioningDelegate = presentationController;
        [self.parentVC presentViewController:stampVC animated:YES completion:nil];
    } else if (CPDFViewAnnotationModeImage == self.selectedIndex) {
        self.propertiesBtn.enabled = NO;
        [self createImageAnnotaion];
    } else if (CPDFViewAnnotationModeLink == self.selectedIndex) {
        self.propertiesBtn.enabled = NO;
    } else if (CPDFViewAnnotationModeSound == self.selectedIndex) {
  
    } else if (CPDFViewAnnotationModePencilDrawing == self.selectedIndex) {
        self.propertiesBtn.enabled = NO;
        if (@available(iOS 13.0, *)) {
            float tWidth  = 412.0;
            float tHeight = 60.0;

            self.drawPencilFuncView = [[CPDFDrawPencilKitFuncView alloc] initWithFrame:CGRectMake(self.pdfListView.frame.size.width - 30, self.window.safeAreaInsets.top, tWidth, tHeight)];
            self.drawPencilFuncView.delegate = self;
            
            self.drawPencilFuncView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            [self.pdfListView addSubview:self.drawPencilFuncView];
        }
    }
}

- (void)createImageAnnotaion {
    UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([tRootViewControl presentedViewController]) {
        tRootViewControl = [tRootViewControl presentedViewController];
    }
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [tRootViewControl presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
        imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
        if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
            imagePickerController.popoverPresentationController.sourceView = (UIButton *)self.annotationBtns[14];
            imagePickerController.popoverPresentationController.sourceRect = ((UIButton *)self.annotationBtns[14]).bounds;
        }
        [tRootViewControl presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        self.annotManage.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
        [self reloadData];
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        alertController.popoverPresentationController.sourceView = (UIButton *)self.annotationBtns[14];
        alertController.popoverPresentationController.sourceRect = ((UIButton *)self.annotationBtns[14]).bounds;
    }
    
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    [alertController addAction:cancelAction];
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    [tRootViewControl presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - AAPLCustomPresentationControllerDelegate

- (void)AAPLCustomPresentationControllerTap:(AAPLCustomPresentationController *)AAPLCustomPresentationController {
    CPDFAnnotation *annotation = self.annotManage.pdfListView.activeAnnotations.firstObject;
    if([annotation isKindOfClass:[CPDFLinkAnnotation class]]) {
        if (!self.linkVC.isLink) {
            [((CPDFAnnotation *)self.pdfListView.activeAnnotations.firstObject).page removeAnnotation:self.pdfListView.activeAnnotations.firstObject];
            [self.annotManage.pdfListView setNeedsDisplayForPage:self.annotManage.pdfListView.activeAnnotation.page];
            [self.annotManage.pdfListView updateActiveAnnotations:@[]];
        }
    } else if (CPDFViewAnnotationModeSignature == self.selectedIndex || CPDFViewAnnotationModeStamp == self.selectedIndex) {
        self.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
    }
   
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image;
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    UIImageOrientation imageOrientation = image.imageOrientation;
    if (imageOrientation!=UIImageOrientationUp) {
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    if (imageData == nil || [imageData length] <= 0) {
        return;
    }
    image = [UIImage imageWithData:imageData];
    
    const CGFloat colorMasking[6] = {222, 255, 222, 255, 222, 255};
    CGImageRef imageRef = CGImageCreateWithMaskingColors(image.CGImage, colorMasking);
    if (imageRef) {
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    CPDFStampAnnotation *annotation = [[CPDFStampAnnotation alloc] initWithDocument:self.annotManage.pdfListView.document image:image];

    if(self.isAddAnnotation) {
        CGRect bounds = annotation.bounds;
        bounds.origin.x = self.menuPoint.x-bounds.size.width/2.0;
        bounds.origin.y = self.menuPoint.y-bounds.size.height/2.0;
        annotation.bounds = bounds;
        [self.pdfListView addAnnotation:annotation forPage:self.menuPage];
        
        self.isAddAnnotation = NO;
        self.menuPage = nil;
        self.menuPoint = CGPointZero;

    } else {
        self.annotManage.pdfListView.addAnnotation = annotation;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CPDFSignatureViewControllerDelegate

- (void)signatureViewControllerDismiss:(CPDFSignatureViewController *)signatureViewController {
    self.signatureAnnotation = nil;
    self.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
}

- (void)signatureViewController:(CPDFSignatureViewController *)signatureViewController image:(UIImage *)image {
    if(self.signatureAnnotation) {
        [self.signatureAnnotation signWithImage:image];
        [self.pdfListView setNeedsDisplayForPage:self.signatureAnnotation.page];
        self.signatureAnnotation = nil;
    } else {
        CPDFSignatureAnnotation *annotation = [[CPDFSignatureAnnotation alloc] initWithDocument:self.annotManage.pdfListView.document];
        [annotation setImage:image];

        self.annotManage.pdfListView.addAnnotation = annotation;
    }
}

#pragma mark - CPDFNoteViewControllerDelegate

- (void)noteViewController:(CPDFNoteViewController *)noteViewController annotSytle:(CAnnotStyle *)annotStyle {
    if (annotStyle.isSelectAnnot) {
        [self.annotManage refreshPageWithAnnotations:annotStyle.annotations];
    }
}

#pragma mark - CPDFShapeCircleViewControllerDelegate

- (void)circleViewController:(CPDFShapeCircleViewController *)circleViewController annotStyle:(CAnnotStyle *)annotStyle {
    if (annotStyle.isSelectAnnot) {
        [self.annotManage refreshPageWithAnnotations:annotStyle.annotations];
    }
}

#pragma mark - CPDFHighlightViewControllerDelegate

- (void)highlightViewController:(CPDFHighlightViewController *)highlightViewController annotStyle:(CAnnotStyle *)annotStyle {
    if (annotStyle.isSelectAnnot) {
        [self.annotManage refreshPageWithAnnotations:annotStyle.annotations];
    } else {
        for (CPDFAnnotationBarButton *button in self.annotationBtns) {
            if(CPDFViewAnnotationModeHighlight == button.tag) {
                button.lineColor = CAnnotationManage.highlightAnnotationColor;
                [button setNeedsDisplay];
                break;
            }
        }
    }
}

#pragma mark - CPDFUnderlineViewControllerDelegate

- (void)underlineViewController:(CPDFUnderlineViewController *)underlineViewController annotStyle:(CAnnotStyle *)annotStyle {
    if (annotStyle.isSelectAnnot) {
        [self.annotManage refreshPageWithAnnotations:annotStyle.annotations];
    } else {
        for (CPDFAnnotationBarButton *button in self.annotationBtns) {
            if (CPDFViewAnnotationModeUnderline == button.tag) {
                button.lineColor = CAnnotationManage.underlineAnnotationColor;
                [button setNeedsDisplay];
                break;
            }
        }
    }
}

#pragma mark - CPDFStrikeoutViewControllerDelegate

- (void)strikeoutViewController:(CPDFStrikeoutViewController *)strikeoutViewController annotStyle:(CAnnotStyle *)annotStyle {
    if (annotStyle.isSelectAnnot) {
        [self.annotManage refreshPageWithAnnotations:annotStyle.annotations];
    } else {
        for (CPDFAnnotationBarButton *button in self.annotationBtns) {
            if (CPDFViewAnnotationModeStrikeout == button.tag) {
                button.lineColor = CAnnotationManage.strikeoutAnnotationColor;
                [button setNeedsDisplay];
                break;

            }
        }
    }
}

#pragma mark - CPDFSquigglyViewControllerDelegate

- (void)squigglyViewController:(CPDFSquigglyViewController *)squigglyViewController annotStyle:(CAnnotStyle *)annotStyle {
    if (annotStyle.isSelectAnnot) {
        [self.annotManage refreshPageWithAnnotations:annotStyle.annotations];
    } else {
        for (CPDFAnnotationBarButton *button in self.annotationBtns) {
             if (CPDFViewAnnotationModeSquiggly == button.tag) {
                button.lineColor = CAnnotationManage.squigglyAnnotationColor;
                 [button setNeedsDisplay];
                 break;
            }
        }
    }
}

#pragma mark - CPDFAnnotationBarDelegate

- (void)inkTopToolBar:(CPDFInkTopToolBar *)inkTopToolBar tag:(CPDFInkTopToolBarSelect)tag isSelect:(BOOL)isSelect {
    UIButton *inkButton = nil;
    for (CPDFAnnotationBarButton *button in self.annotationBtns) {
         if (CPDFViewAnnotationModeInk == button.tag) {
             inkButton = button;
             break;
        }
    }
    switch (tag) {
        case CPDFInkTopToolBarSetting: {
            [self.pdfListView commitDrawing];
            
            CAnnotStyle *annotStytle = self.annotManage.annotStyle;
            AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
            CPDFInkViewController *inkVC = [[CPDFInkViewController alloc] initWithStyle:annotStytle];
            inkVC.delegate = self;
            presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:inkVC presentingViewController:self.parentVC];
            inkVC.transitioningDelegate = presentationController;
            [self.parentVC presentViewController:inkVC animated:YES completion:nil];
        }
            break;
        case CPDFInkTopToolBarErase: {
            [self.annotManage.pdfListView setDrawErasing:isSelect];
        }
            break;
        case CPDFInkTopToolBarUndo: {
            [self.annotManage.pdfListView drawUndo];
            if (((UIButton *)self.topToolBar.buttonArray[1]).selected) {
                ((UIButton *)self.topToolBar.buttonArray[1]).backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
            }
        }
            break;
        case CPDFInkTopToolBarRedo: {
            [self.annotManage.pdfListView drawRedo];
            if (((UIButton *)self.topToolBar.buttonArray[1]).selected) {
                ((UIButton *)self.topToolBar.buttonArray[1]).backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
            }
        }
            break;
        case CPDFInkTopToolBarClear: {
            if([self.delegate respondsToSelector:@selector(annotationBarClick:clickAnnotationMode:forSelected:forButton:)]) {
                [self.delegate annotationBarClick:self clickAnnotationMode:CPDFViewAnnotationModeInk forSelected:NO forButton:inkButton];
            }
            self.annotManage.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
            [self reloadData];
        }
            break;
        case CPDFInkTopToolBarSave: {
            if([self.delegate respondsToSelector:@selector(annotationBarClick:clickAnnotationMode:forSelected:forButton:)]) {
                [self.delegate annotationBarClick:self clickAnnotationMode:CPDFViewAnnotationModeInk forSelected:NO forButton:inkButton];
            }
            [self.annotManage.pdfListView commitDrawing];
            self.annotManage.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
        }
            [self reloadData];
    
        default:
            break;
    }
}

#pragma mark - CPDFInkViewControllerDelegate

- (void)inkViewController:(CPDFInkViewController *)inkViewController annotStyle:(CAnnotStyle *)annotStyle {
    if (annotStyle.isSelectAnnot) {
        [self.annotManage refreshPageWithAnnotations:annotStyle.annotations];
    } else {
       
        for (CPDFAnnotationBarButton *button in self.annotationBtns) {
             if (CPDFViewAnnotationModeInk == button.tag) {
                button.lineColor = CAnnotationManage.freehandAnnotationColor;
                 [button setNeedsDisplay];
                 break;
            }
        }
    }
}

- (void)inkViewControllerDimiss:(CPDFInkViewController *)inkViewController {
    if ([self.topToolBar isDescendantOfView:self.pdfListView]) {
        ((UIButton *)self.topToolBar.buttonArray[0]).backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        if (((UIButton *)self.topToolBar.buttonArray[1]).selected) {
            ((UIButton *)self.topToolBar.buttonArray[1]).backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        }
    }
}

#pragma mark - CPDFShapeArrowViewControllerDelegate

- (void)arrowViewController:(CPDFShapeArrowViewController *)arrowViewController annotStyle:(CAnnotStyle *)annotStyle {
    if (annotStyle.isSelectAnnot) {
        [self.annotManage refreshPageWithAnnotations:annotStyle.annotations];
    } else {
        
    }
}

#pragma mark - CPDFFreeTextViewControllerDelegate

- (void)freeTextViewController:(CPDFFreeTextViewController *)freeTextViewController annotStyle:(CAnnotStyle *)annotStyle {
    if (annotStyle.isSelectAnnot) {
        [self.annotManage refreshPageWithAnnotations:annotStyle.annotations];
    } else {
        
    }
}

#pragma mark - CPDFLinkViewControllerDelegate

- (void)linkViewController:(CPDFLinkViewController *)linkViewController linkType:(CPDFLinkType)linkType linkString:(NSString *)linkString {
    CPDFLinkAnnotation *linkAnnotation = linkViewController.annotStyle.annotations.firstObject;
    
    if (CPDFLinkTypeLink == linkType || CPDFLinkTypeEmail == linkType) {
        linkAnnotation.URL = linkString;
    } else if (CPDFLinkTypePage == linkType) {
        linkAnnotation.destination = [[CPDFDestination alloc] initWithDocument:self.pdfListView.document
                                                                     pageIndex:[linkString integerValue]-1
                                                                       atPoint:CGPointZero
                                                                          zoom:1];
    }
    [self.pdfListView updateActiveAnnotations:@[]];
    [self.pdfListView setNeedsDisplayForPage:linkAnnotation.page];
        
}

- (void)linkViewControllerDismiss:(CPDFLinkViewController *)linkViewController isLink:(BOOL)isLink {
    if (!isLink) {
        [((CPDFAnnotation *)self.pdfListView.activeAnnotations.firstObject).page removeAnnotation:self.pdfListView.activeAnnotations.firstObject];
        [self.annotManage.pdfListView setNeedsDisplayForPage:self.annotManage.pdfListView.activeAnnotation.page];
        [self.annotManage.pdfListView updateActiveAnnotations:@[]];
    }
}

#pragma mark - CPDFDrawPencilViewDelegate

- (void)drawPencilFuncView:(CPDFDrawPencilKitFuncView *)view eraserBtn:(UIButton *)btn {
    if (btn.isSelected) {
        self.pdfListView.scrollEnabled = YES;
    } else {
        self.pdfListView.scrollEnabled = NO;
    }
}

- (void)drawPencilFuncView:(CPDFDrawPencilKitFuncView *)view saveBtn:(UIButton *)btn {
    [self.pdfListView commitDrawing];
    [self.pdfListView endDrawing];
    
    self.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
    
    [self.drawPencilFuncView removeFromSuperview];
    _drawPencilFuncView.delegate = nil;
    _drawPencilFuncView = nil;
}

- (void)drawPencilFuncView:(CPDFDrawPencilKitFuncView *)view cancelBtn:(UIButton *)btn {
    self.pdfListView.annotationMode = CPDFViewAnnotationModeNone;

    [self.drawPencilFuncView removeFromSuperview];
    _drawPencilFuncView.delegate = nil;
    _drawPencilFuncView = nil;
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
    [self updatePropertiesButtonState];
}

#pragma mark - CPDFStampViewControllerDelegate

- (void)stampViewController:(CPDFStampViewController *)stampViewController selectedIndex:(NSInteger)selectedIndex stamp:(NSDictionary *)stamp {
    if(self.isAddAnnotation) {
        if (selectedIndex == -1) {
        } else {
            if (stamp.count > 0) {
                if (stamp[PDFAnnotationStampKeyImagePath]) {
                    UIImage *image = [UIImage imageWithContentsOfFile:stamp[PDFAnnotationStampKeyImagePath]];
                    CPDFStampAnnotation *annotation = [[CPDFStampAnnotation alloc] initWithDocument:self.annotManage.pdfListView.document image:image];
                    CGRect bounds = annotation.bounds;
                    bounds.origin.x = self.menuPoint.x-bounds.size.width/2.0;
                    bounds.origin.y = self.menuPoint.y-bounds.size.height/2.0;
                    annotation.bounds = bounds;
                    [self.annotManage.pdfListView addAnnotation:annotation forPage:self.menuPage];
                } else {
                    NSString *stampText = stamp[PDFAnnotationStampKeyText];
                    BOOL stampShowDate = [stamp[PDFAnnotationStampKeyShowDate] boolValue];
                    BOOL stampShowTime = [stamp[PDFAnnotationStampKeyShowTime] boolValue];
                    CPDFStampStyle stampStyle = [stamp[PDFAnnotationStampKeyStyle] integerValue];
                    CPDFStampShape stampShape = [stamp[PDFAnnotationStampKeyShape] integerValue];
                    
                    NSString *detailText = nil;
                    NSTimeZone *timename = [NSTimeZone systemTimeZone];
                    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                    [outputFormatter setTimeZone:timename];
                    if (stampShowDate && !stampShowTime){
                        [outputFormatter setDateFormat:@"yyyy/MM/dd"];
                        detailText = [outputFormatter stringFromDate:[NSDate date]];

                    } else if (stampShowTime && !stampShowDate) {
                        [outputFormatter setDateFormat:@"HH:mm:ss"];
                        detailText = [outputFormatter stringFromDate:[NSDate date]];
                    } else if (stampShowDate && stampShowTime) {
                        [outputFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
                        detailText = [outputFormatter stringFromDate:[NSDate date]];
                    }
                    
                    CPDFStampAnnotation *annotation = [[CPDFStampAnnotation alloc] initWithDocument:self.annotManage.pdfListView.document text:stampText detailText:detailText style:stampStyle shape:stampShape];
                    CGRect bounds = annotation.bounds;
                    bounds.origin.x = self.menuPoint.x-bounds.size.width/2.0;
                    bounds.origin.y = self.menuPoint.y-bounds.size.height/2.0;
                    annotation.bounds = bounds;
                    [self.annotManage.pdfListView addAnnotation:annotation forPage:self.menuPage];
                }
            } else {
                CPDFStampAnnotation *annotation = [[CPDFStampAnnotation alloc] initWithDocument:self.annotManage.pdfListView.document type:selectedIndex+1];
                CGRect bounds = annotation.bounds;
                bounds.origin.x = self.menuPoint.x-bounds.size.width/2.0;
                bounds.origin.y = self.menuPoint.y-bounds.size.height/2.0;
                annotation.bounds = bounds;
                [self.annotManage.pdfListView addAnnotation:annotation forPage:self.menuPage];
            }
        }
        self.isAddAnnotation = NO;
        self.menuPage = nil;
        self.menuPoint = CGPointZero;
    } else {
        if (selectedIndex == -1) {
            self.annotManage.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
            [self reloadData];
        } else {
            if (stamp.count > 0) {
                if (stamp[PDFAnnotationStampKeyImagePath]) {
                    UIImage *image = [UIImage imageWithContentsOfFile:stamp[PDFAnnotationStampKeyImagePath]];
                    CPDFStampAnnotation *annotation = [[CPDFStampAnnotation alloc] initWithDocument:self.annotManage.pdfListView.document image:image];
                    self.annotManage.pdfListView.addAnnotation = annotation;
                } else {
                    NSString *stampText = stamp[PDFAnnotationStampKeyText];
                    BOOL stampShowDate = [stamp[PDFAnnotationStampKeyShowDate] boolValue];
                    BOOL stampShowTime = [stamp[PDFAnnotationStampKeyShowTime] boolValue];
                    CPDFStampStyle stampStyle = [stamp[PDFAnnotationStampKeyStyle] integerValue];
                    CPDFStampShape stampShape = [stamp[PDFAnnotationStampKeyShape] integerValue];
                    
                    NSString *detailText = nil;
                    NSTimeZone *timename = [NSTimeZone systemTimeZone];
                    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                    [outputFormatter setTimeZone:timename];
                    if (stampShowDate && !stampShowTime){
                        [outputFormatter setDateFormat:@"yyyy/MM/dd"];
                        detailText = [outputFormatter stringFromDate:[NSDate date]];
                    } else if (stampShowTime && !stampShowDate) {
                        [outputFormatter setDateFormat:@"HH:mm:ss"];
                        detailText = [outputFormatter stringFromDate:[NSDate date]];
                    } else if (stampShowDate && stampShowTime) {
                        [outputFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
                        detailText = [outputFormatter stringFromDate:[NSDate date]];
                    }
                    
                    CPDFStampAnnotation *annotation = [[CPDFStampAnnotation alloc] initWithDocument:self.annotManage.pdfListView.document text:stampText detailText:detailText style:stampStyle shape:stampShape];
                    self.annotManage.pdfListView.addAnnotation = annotation;
                }
            } else {
                CPDFStampAnnotation *annotation = [[CPDFStampAnnotation alloc] initWithDocument:self.annotManage.pdfListView.document type:selectedIndex+1];
                self.annotManage.pdfListView.addAnnotation = annotation;
            }
        }
    }
    
}

- (void)stampViewControllerDismiss:(CPDFStampViewController *)stampViewController {
    self.pdfListView.annotationMode = CPDFViewAnnotationModeNone;
}

@end
