//
//  CPDFBOTAViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFBOTAViewController.h"
#import "CPDFThumbnailViewController.h"
#import "CPDFOutlineViewController.h"
#import "CPDFBookmarkViewController.h"
#import "CPDFAnnotationViewController.h"
#import "CPDFColorUtils.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFBOTAViewController () <CPDFOutlineViewControllerDelegate, CPDFBookmarkViewControllerDelegate,CPDFAnnotationViewControllerDelegate>

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic, strong) CPDFOutlineViewController *outlineViewController;
@property (nonatomic, strong) CPDFBookmarkViewController *bookmarkViewController;
@property (nonatomic, strong) CPDFAnnotationViewController *annotationViewController;

@property (nonatomic, strong) UIButton *doneBtn;

@property (nonatomic, strong) NSArray *segmmentArray;

@property (nonatomic, assign) CPDFBOTATypeState type;

@end

@implementation CPDFBOTAViewController

#pragma mark - Initializers

- (instancetype)initWithPDFView:(CPDFView *)pdfView {
    if (self = [super init]) {
        _pdfView = pdfView;
        self.segmmentArray = @[@(CPDFBOTATypeStateOutline),@(CPDFBOTATypeStateBookmark)];
    }
    return self;
}

- (instancetype)initCustomizeWithPDFView:(CPDFView *)pdfView navArrays:(NSArray *)botaTypes {
    if (self = [super init]) {
        _pdfView = pdfView;
        self.segmmentArray = botaTypes;
    }
    return self;
}

#pragma mark - UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
            
    NSMutableArray *segmmentTitleArray = [NSMutableArray array];
    for (NSNumber *num in self.segmmentArray) {
        if(CPDFBOTATypeStateOutline == num.integerValue) {
            [segmmentTitleArray addObject:NSLocalizedString(@"Outlines", nil)];
            self.outlineViewController = [[CPDFOutlineViewController alloc] initWithPDFView:self.pdfView];
            self.outlineViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
            self.outlineViewController.delegate = self;
            [self addChildViewController:self.outlineViewController];

        } else if(CPDFBOTATypeStateBookmark == num.integerValue) {
            [segmmentTitleArray addObject:NSLocalizedString(@"Bookmarks", nil)];
            _bookmarkViewController = [[CPDFBookmarkViewController alloc] initWithPDFView:self.pdfView];
            _bookmarkViewController.delegate = self;
            _bookmarkViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
            [self addChildViewController:_bookmarkViewController];

        } else if(CPDFBOTATypeStateAnnotation == num.integerValue) {
            [segmmentTitleArray addObject:NSLocalizedString(@"Annotations", nil)];
            _annotationViewController = [[CPDFAnnotationViewController alloc] initWithPDFView:self.pdfView];
            _annotationViewController.delegate = self;
            _annotationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
            [self addChildViewController:_annotationViewController];
        }

    }
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:segmmentTitleArray];
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged_BOTA:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedControl;
    [self.view addSubview:self.segmentedControl];
//    self.currentViewController = self.outlineViewController;
    [self.view addSubview:self.outlineViewController.view];
    
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.doneBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.doneBtn setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneBtn];
    
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat mWidth = fmin(width, height);
    CGFloat mHeight = fmax(width, height);
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // This is an iPad
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.7);
    } else {
        // This is an iPhone or iPod touch
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.9);
    }
}


- (void)viewWillLayoutSubviews {
    _segmentedControl.frame = CGRectMake(15, 44 , self.view.frame.size.width - 30, 30);
    self.doneBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    if (@available(iOS 11.0, *)) {
        self.outlineViewController.view.frame = CGRectMake(0, self.view.safeAreaInsets.top + 80, self.view.bounds.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.bounds.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 80);
        
        _bookmarkViewController.view.frame = CGRectMake(0, self.view.safeAreaInsets.top + 80, self.view.bounds.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.bounds.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 80);
        
        _annotationViewController.view.frame = CGRectMake(0, self.view.safeAreaInsets.top + 80, self.view.bounds.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.bounds.size.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 80);

    } else {
        self.outlineViewController.view.frame = CGRectMake(0, 64 + 44, self.view.bounds.size.width, self.view.bounds.size.height - 64 - 44 - 30);
        
        _bookmarkViewController.view.frame = CGRectMake(0, 64 + 44, self.view.bounds.size.width, self.view.bounds.size.height - 64 - 30 - 44);
        
        _annotationViewController.view.frame = CGRectMake(0, 64 + 44, self.view.bounds.size.width, self.view.bounds.size.height - 64 - 30 - 44);

    }
}

- (void)buttonItemClicked_back:(id)sender {
    if([self.delegate respondsToSelector:@selector(botaViewControllerDismiss:)]) {
        [self.delegate botaViewControllerDismiss:self];
    }
}

#pragma mark - Action

- (void)segmentedControlValueChanged_BOTA:(id)sender {
    [self.currentViewController.view removeFromSuperview];
    
    if(self.currentViewController == nil) {
        if(self.outlineViewController != nil) {
            [self.outlineViewController.view removeFromSuperview];
        }
        
        if(self.bookmarkViewController.view != nil) {
            [self.bookmarkViewController.view removeFromSuperview];
        }
        
        if(self.annotationViewController.view != nil) {
            [self.annotationViewController.view removeFromSuperview];
        }
    }
    
    self.type = [[self.segmmentArray objectAtIndex:self.segmentedControl.selectedSegmentIndex] intValue];
    switch (self.type) {
        case CPDFBOTATypeStateOutline:
            self.currentViewController = self.outlineViewController;
            [self.view addSubview:self.outlineViewController.view];
            break;
        case CPDFBOTATypeStateBookmark:
            self.currentViewController = self.bookmarkViewController;
            [self.view addSubview:self.bookmarkViewController.view];
            break;

        default:
        case CPDFBOTATypeStateAnnotation:
            self.currentViewController = self.annotationViewController;
            [self.view addSubview:self.annotationViewController.view];

            break;
    }
}

#pragma mark - CPDFOutlineViewControllerDelegate

- (void)outlineViewController:(CPDFOutlineViewController *)outlineViewController pageIndex:(NSInteger)pageIndex {
    [self.pdfView goToPageIndex:pageIndex animated:NO];
    
    if([self.delegate respondsToSelector:@selector(botaViewControllerDismiss:)]) {
        [self.delegate botaViewControllerDismiss:self];
    }
}

#pragma mark - CPDFBookmarkViewControllerDelegate

- (void)boomarkViewController:(CPDFBookmarkViewController *)bookmarkViewController pageIndex:(NSInteger)pageIndex {
    [self.pdfView goToPageIndex:pageIndex animated:NO];
    
    if([self.delegate respondsToSelector:@selector(botaViewControllerDismiss:)]) {
        [self.delegate botaViewControllerDismiss:self];
    }
}

#pragma mark - CPDFAnnotationViewControllerDelegate

- (void)annotationViewController:(CPDFAnnotationViewController *)annotationViewController jumptoPage:(NSInteger)pageIndex selectAnnot:(CPDFAnnotation *)annot {
    [self.pdfView goToPageIndex:pageIndex animated:NO];
    if (@available(iOS 12.0, *)) {
        CGSize visibleRect = self.pdfView.documentView.visibleSize;
        [self.pdfView goToRect:CGRectMake(annot.bounds.origin.x, annot.bounds.origin.y+visibleRect.height/2, annot.bounds.size.width, annot.bounds.size.height) onPage:[self.pdfView.document pageAtIndex:pageIndex] animated:YES];
    } else {
        [self.pdfView goToRect:CGRectMake(annot.bounds.origin.x, annot.bounds.origin.y+100, annot.bounds.size.width, annot.bounds.size.height) onPage:[self.pdfView.document pageAtIndex:pageIndex] animated:YES];
    }

    if([self.delegate respondsToSelector:@selector(botaViewControllerDismiss:)]) {
        [self.delegate botaViewControllerDismiss:self];
    }

}

@end
