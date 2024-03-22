//
//  CPDFListView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFListView.h"
#import "CPDFListView+Annotation.h"
#import "CPDFListView+Form.h"

#import "CPDFListView+UndoManager.h"
#import "CPDFListView+Private.h"

#import "CPDFColorUtils.h"
#import "CPDFSlider.h"
#import "CPDFPageIndicatorView.h"
#import "CPDFListViewAnnotationConfig.h"

NSNotificationName const CPDFListViewToolModeChangeNotification = @"CPDFListViewToolModeChangeNotification";

NSNotificationName const CPDFListViewAnnotationModeChangeNotification = @"CPDFListViewAnnotationModeChangeNotification";

NSNotificationName const CPDFListViewActiveAnnotationsChangeNotification = @"CPDFListViewActiveAnnotationsChangeNotification";

NSNotificationName const CPDFListViewAnnotationsOperationChangeNotification = @"CPDFListViewAnnotationsOperationChangeNotification";

@interface  CPDFListView() <UITextFieldDelegate>

@property (nonatomic, strong) CPDFPageIndicatorView * pageIndicatorView;

@property (nonatomic, strong) UIAlertController *alert;

@end

@implementation CPDFListView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor lightGrayColor];
        
        [CPDFListViewAnnotationConfig initializeAnnotationConfig];

        [self commomInit];
        
        [self addNotification];
        
        // undo redo
        [self registerAsObserver];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];

        [CPDFListViewAnnotationConfig initializeAnnotationConfig];

        [self commomInit];

        [self addNotification];
        
        // undo redo
        [self registerAsObserver];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    if (@available(iOS 11.0, *)) {
        _pageSliderView.frame = CGRectMake(self.bounds.size.width-22, self.safeAreaInsets.top, 22, self.bounds.size.height- self.safeAreaInsets.top - self.safeAreaInsets.bottom);
    } else {
        _pageSliderView.frame = CGRectMake(self.bounds.size.width-22, 0, 22, self.bounds.size.height);
    }
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma mark - Accessors

- (void)setAnnotationMode:(CPDFViewAnnotationMode)annotationMode {
    if (CPDFViewAnnotationModeHighlight == annotationMode ||
        CPDFViewAnnotationModeUnderline == annotationMode ||
        CPDFViewAnnotationModeStrikeout == annotationMode ||
        CPDFViewAnnotationModeSquiggly == annotationMode) {
        self.textSelectionMode = YES;
    } else {
        self.textSelectionMode = NO;
    }
        
    if (CPDFViewAnnotationModeLink == annotationMode) {
        self.scrollEnabled = NO;
        [self endDrawing];
    } else if (CPDFViewFormModeText == annotationMode ||
               CPDFViewFormModeCheckBox == annotationMode ||
               CPDFViewFormModeRadioButton == annotationMode ||
               CPDFViewFormModeCombox == annotationMode ||
               CPDFViewFormModeList == annotationMode ||
               CPDFViewFormModeButton == annotationMode ||
               CPDFViewFormModeSign == annotationMode) {
        self.scrollEnabled = NO;
        [self endDrawing];
    } else if (CPDFViewAnnotationModeInk == annotationMode || CPDFViewAnnotationModePencilDrawing == annotationMode) {
        self.scrollEnabled = NO;
        [self beginDrawing];
    } else {
        if (self.activeAnnotation) {
            self.scrollEnabled = NO;
        } else {
            self.scrollEnabled = YES;
        }
        [self endDrawing];
        [self becomeFirstResponder];
    }
    
    if (CPDFViewAnnotationModeNone != annotationMode || CPDFViewAnnotationModeNone != _annotationMode) {
        if(self.activeAnnotations.count > 0) {
            CPDFPage *page = self.activeAnnotation.page;
            [self updateActiveAnnotations:@[]];
            [self setNeedsDisplayForPage:page];
        }
    }
    _annotationMode = annotationMode;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CPDFListViewAnnotationModeChangeNotification object:self];
        
        if([self.performDelegate respondsToSelector:@selector(PDFListViewChangedAnnotationType:forAnnotationMode:)]) {
            [self.performDelegate PDFListViewChangedAnnotationType:self forAnnotationMode:self.annotationMode];
        }
    });    
}

-(void)setToolModel:(CToolModel)toolModel {
    if(CToolModelAnnotation == _toolModel && CToolModelAnnotation != toolModel)
        [self stopRecord];
    if(_toolModel != toolModel) {
        _toolModel = toolModel;
        if(self.activeAnnotations.count > 0) {
            [self updateActiveAnnotations:@[]];
            [self setNeedsDisplayForVisiblePages];
        }
        self.annotationMode = CPDFViewAnnotationModeNone;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CPDFListViewToolModeChangeNotification object:self];
            
            if([self.performDelegate respondsToSelector:@selector(PDFListViewChangedToolMode:forToolMode:)]) {
                [self.performDelegate PDFListViewChangedToolMode:self forToolMode:self.toolModel];
            }
        });

    }
}

- (NSMutableArray *)activeAnnotations {
    if(!_activeAnnotations) {
        _activeAnnotations = [[NSMutableArray alloc] init];
    }
    return _activeAnnotations;
}

- (CPDFAnnotation *)activeAnnotation {
    return self.activeAnnotations.firstObject;
}

#pragma mark - Action

- (void)menuItemClick_CopyAction:(id)sender {
    if (self.currentSelection.string)
        [[UIPasteboard generalPasteboard] setString:self.currentSelection.string];
    
    [self clearSelection];
}

#pragma mark - Touch

- (void)touchBeganAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if (CToolModelAnnotation == self.toolModel) {
        [self annotationTouchBeganAtPoint:point forPage:page];
    } else if (CToolModelForm == self.toolModel) {
        [self formTouchBeganAtPoint:point forPage:page];
    } else if (CToolModelEdit == self.toolModel) {
        
    } else {
    }
}

- (void)touchMovedAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if (CToolModelAnnotation == self.toolModel) {
        [self annotationTouchMovedAtPoint:point forPage:page];
    } else if (CToolModelForm == self.toolModel) {
        [self formTouchMovedAtPoint:point forPage:page];
    } else if (CToolModelEdit == self.toolModel) {
        
    } else {
    }
    
}

- (void)touchEndedAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if (CToolModelAnnotation == self.toolModel) {
        [self annotationTouchEndedAtPoint:point forPage:page];
    } else if (CToolModelForm == self.toolModel) {
        [self formTouchEndedAtPoint:point forPage:page];
    } else if (CToolModelEdit == self.toolModel) {
        
    } else {
        CPDFAnnotation *annotation = [page annotationAtPoint:point];
        if(annotation && [annotation isHidden]) {
            annotation = nil;
        }
        if(annotation) {
            if ([annotation isKindOfClass:[CPDFSignatureWidgetAnnotation class]]) {
                if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformSignatureWidget:forAnnotation:)]) {
                    [self.performDelegate PDFListViewPerformSignatureWidget:self forAnnotation:(CPDFSignatureWidgetAnnotation *)annotation];
                }
            } else{
                [super touchEndedAtPoint:point forPage:page];
            }
        } else {
            if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformTouchEnded:)]) {
                [self.performDelegate PDFListViewPerformTouchEnded:self];
            }
        }
    }
}

- (void)touchCancelledAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if (CToolModelAnnotation == self.toolModel) {
        [self annotationTouchCancelledAtPoint:point forPage:page];
    } else if (CToolModelForm == self.toolModel) {
        
    } else if (CToolModelEdit == self.toolModel) {
        
    } else {
    }    
}

- (NSArray<UIMenuItem *> *)menuItemsAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    NSMutableArray *menuItems = [NSMutableArray array];

    if (CToolModelAnnotation == self.toolModel) {
        [menuItems addObjectsFromArray:[self annotationMenuItemsAtPoint:point forPage:page]];
    } else if (CToolModelForm == self.toolModel) {
        if (self.currentSelection) {
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", nil)
                                                              action:@selector(menuItemClick_CopyAction:)];
            [menuItems addObject:copyItem];
        }
    } else if (CToolModelEdit == self.toolModel) {
        
    } else {
        if (self.currentSelection) {
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Copy", nil)
                                                              action:@selector(menuItemClick_CopyAction:)];
            [menuItems addObject:copyItem];
        }
    }
    if([self.performDelegate respondsToSelector:@selector(PDFListView:customizeMenuItems:forPage:forPagePoint:)])
        return [self.performDelegate PDFListView:self customizeMenuItems:menuItems forPage:page forPagePoint:point];

    return menuItems;
}

#pragma mark - Private method

- (void)commomInit {
    _pageSliderView = [[CPDFSlider alloc] initWithPDFView:self];
    if (@available(iOS 11.0, *)) {
        _pageSliderView.frame = CGRectMake(self.bounds.size.width-22, self.safeAreaInsets.top, 22, self.bounds.size.height- self.safeAreaInsets.top - self.safeAreaInsets.bottom);
    } else {
        _pageSliderView.frame = CGRectMake(self.bounds.size.width-22, 64, 22, self.bounds.size.height-114);
    }
    _pageSliderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:self.pageSliderView];
    
    self.backgroundColor = [UIColor colorWithRed:242/255. green:242/255. blue:242/255. alpha:1.];
    
    _pageIndicatorView = [[CPDFPageIndicatorView alloc] init];
    
    __weak typeof(self) weakSelf = self;
    _pageIndicatorView.touchCallBack = ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter a Page Number", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        weakSelf.alert = alertController;
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *pageTextField = alertController.textFields.firstObject;
            NSInteger pageIndex = [pageTextField.text integerValue] - 1;
            
            if (pageIndex > weakSelf.document.pageCount){
                pageIndex = weakSelf.document.pageCount - 1;
            } else if(pageIndex<0){
                pageIndex = weakSelf.document.pageCount - 1;
            } else  if(pageTextField.text.length == 0){
                pageIndex = (int)weakSelf.currentPageIndex;
            }
            
            [weakSelf goToPageIndex:pageIndex animated:YES];
        }]];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            NSString *str = [NSString stringWithFormat:@"%@(1~%lu)",NSLocalizedString(@"Page", nil),weakSelf.document.pageCount];
            textField.placeholder = NSLocalizedString(str, nil);
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([tRootViewControl presentedViewController]) {
            tRootViewControl = [tRootViewControl presentedViewController];
        }
        
        [tRootViewControl presentViewController:alertController animated:true completion:nil];
    };
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentChangedNotification:) name:CPDFViewDocumentChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageChangedNotification:) name:CPDFViewPageChangedNotification object:nil];
}

- (void)showPageNumIndicator {
    __weak typeof(self) weakSelf = self;
    if(![self.pageIndicatorView superview])
        [self.pageIndicatorView showInView:weakSelf position:CPDFPageIndicatorViewPositionCenterBottom];

    [self.pageIndicatorView updatePageCount:weakSelf.document.pageCount currentPageIndex:self.currentPageIndex + 1];
}

- (NSString *)annotationUserName {
    NSString *annotationUserName = CPDFKitShareConfig.annotationAuthor;
    if (!annotationUserName || [annotationUserName length] <= 0) {
        annotationUserName = [[UIDevice currentDevice] name];
    }
    return annotationUserName ? : @"";
}

- (void)updateActiveAnnotations:(NSArray <CPDFAnnotation *> *)activeAnnotations {
    if(activeAnnotations) {
        self.activeAnnotations = [NSMutableArray arrayWithArray:activeAnnotations];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CPDFListViewActiveAnnotationsChangeNotification object:self];
        
        if([self.performDelegate respondsToSelector:@selector(PDFListViewChangeatioActiveAnnotations:forActiveAnnotations:)]) {
            [self.performDelegate PDFListViewChangeatioActiveAnnotations:self forActiveAnnotations:self.activeAnnotations];
        }
    } else if (!activeAnnotations && self.activeAnnotations.count > 0) {
        for (CPDFAnnotation *annotation in self.activeAnnotations) {
            if ([annotation isKindOfClass:[CPDFLinkAnnotation class]]) {
                CPDFLinkAnnotation *link = (CPDFLinkAnnotation *)annotation;
                if (!(link.destination || (link.URL && link.URL.length >0)))
                    [link.page removeAnnotation:link];
            }
        }
        
        [self.activeAnnotations removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CPDFListViewActiveAnnotationsChangeNotification object:self];
            
            if([self.performDelegate respondsToSelector:@selector(PDFListViewChangeatioActiveAnnotations:forActiveAnnotations:)]) {
                [self.performDelegate PDFListViewChangeatioActiveAnnotations:self forActiveAnnotations:self.activeAnnotations];
            }
        });
    }
}

#pragma mark - Public Methods

- (void)addAnnotation:(CPDFAnnotation *)annotation forPage:(CPDFPage *)page {
    if (!annotation || !page) {
        return;
    }
    [annotation setModificationDate:[NSDate date]];
    [annotation setUserName:[self annotationUserName]];
    [page addAnnotation:annotation];
    
    [self updateActiveAnnotations:@[annotation]];
    [self setNeedsDisplayForPage:page];
    [self updateScrollEnabled];
    
    [self showMenuForAnnotation:annotation];
}

- (void)addAnnotation:(CPDFAnnotation *)annotation {
    CPDFPage *page = [self.document pageAtIndex:self.currentPageIndex];
    CGPoint center = [self convertPoint:self.center toPage:page];
    if (CGPointEqualToPoint(center, CGPointZero)) {
        return;
    }
    
    CGRect bounds = annotation.bounds;
    bounds.origin.x = center.x-bounds.size.width/2.0;
    bounds.origin.y = center.y-bounds.size.height/2.0;
    bounds.origin.y = MIN(MAX(0, bounds.origin.y), page.bounds.size.height-bounds.size.height);
    annotation.bounds = bounds;
    [self addAnnotation:annotation forPage:page];
}

- (void)stopRecord {
    CPDFPage *page = self.mediaSelectionPage;
    if(page) {
        self.mediaSelectionPage = nil;
        [self setNeedsDisplayForPage:page];
    }
}

- (void)stopObserving {
    [self stopObservingNotes:self.notes];
}

#pragma mark - NotificationCenter

- (void)documentChangedNotification:(NSNotification *)notification {
    CPDFView *pdfview = notification.object;
    if (pdfview.document == self.document) {
        [self showPageNumIndicator];
        [self.pageSliderView reloadData];
    }
}

- (void)pageChangedNotification:(NSNotification *)notification {
    CPDFView *pdfview = notification.object;
    if (pdfview.document == self.document) {
        [self showPageNumIndicator];
        [self.pageSliderView reloadData];
    }
}

#pragma mark - Rendering

- (void)drawPage:(CPDFPage *)page toContext:(CGContextRef)context {
    
    if (CToolModelAnnotation == self.toolModel) {
        [self annotationDrawPage:page toContext:context];
    } else if (CToolModelForm == self.toolModel) {
        [self formDrawPage:page toContext:context];
    } else if (CToolModelEdit == self.toolModel) {
    } else {
    }
}

@end
