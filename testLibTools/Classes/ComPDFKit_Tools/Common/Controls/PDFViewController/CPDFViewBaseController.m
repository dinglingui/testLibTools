//
//  CPDFViewBaseController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFViewBaseController.h"
#import "CDocumentPasswordViewController.h"
#import "CPDFListView+UndoManager.h"
#import "CPDFConfiguration.h"

#import <ComPDFKit/ComPDFKit.h>
#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CPDFViewBaseController ()<UISearchBarDelegate,CPDFViewDelegate,CPDFListViewDelegate, CSearchToolbarDelegate, CPDFDisplayViewDelegate, CPDFBOTAViewControllerDelegate,CPDFSearchResultsDelegate, CPDFThumbnailViewControllerDelegate,CPDFPopMenuViewDelegate,UIDocumentPickerDelegate,CPDFPopMenuDelegate,CDocumentPasswordViewControllerDelegate,CPDFPageEditViewControllerDelegate>

@property(nonatomic, strong) NSString *filePath;

@property(nonatomic, strong) CPDFListView *pdfListView;

@property(nonatomic, strong) CSearchToolbar *searchToolbar;

@property(nonatomic, strong)  CPDFPopMenu *popMenu;

@property(nonatomic, strong) NSArray * leftBarButtonItems;

@property(nonatomic, strong) NSArray * rightBarButtonItems;

@property(nonatomic, strong) NSString *password;

@property(nonatomic, strong) CPDFConfiguration *configuration;

@property (nonatomic, strong) UIBarButtonItem *thumbnailBarItem;

@property (nonatomic, strong) UIBarButtonItem *backBarItem;

@end

@implementation CPDFViewBaseController

#pragma mark - Initializers

- (instancetype)initWithFilePath:(NSString *)filePath password:(nullable NSString *)password{
    if(self = [super init]) {
        self.filePath = filePath;
        self.password = password;
        
        _configuration = [[CPDFConfiguration alloc] init];
        CNavBarButtonItem *thumbnail = [[CNavBarButtonItem alloc]initWithViewLeftBarButtonItem:CPDFViewBarLeftButtonItem_Thumbnail];
        
        CNavBarButtonItem *search = [[CNavBarButtonItem alloc]initWithViewRightBarButtonItem:CPDFViewBarRightButtonItem_Search];
        CNavBarButtonItem *bota = [[CNavBarButtonItem alloc]initWithViewRightBarButtonItem:CPDFViewBarRightButtonItem_Bota];
        CNavBarButtonItem *more = [[CNavBarButtonItem alloc]initWithViewRightBarButtonItem:CPDFViewBarRightButtonItem_More];
        
        _configuration.showleftItems = @[thumbnail];
        _configuration.showRightItems = @[search,bota,more];
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath password:(nullable NSString *)password configuration:(CPDFConfiguration *)configuration {
    if(self = [super init]) {
        self.filePath = filePath;
        self.password = password;
        
        self.configuration = configuration;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    
    [self initWitPDFListView];
    
    [self initWitNavigation];
    
    [self initWitNavigationTitle];
    
    [self initWithSearchTool];
            
    [self reloadDocumentWithFilePath:self.filePath password:self.password completion:^(BOOL result) {
        
    }];
}

#pragma mark - Private method

-(void)updatePDFViewDocumentView {
    UIScrollView * documentView = [self.pdfListView documentView];
    if (CPDFDisplayDirectionVertical == [CPDFKitConfig  sharedInstance].displayDirection) {
        if (self.pdfListView.currentPageIndex != 0) {
            if (@available(iOS 11.0, *)) {
                documentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                self.automaticallyAdjustsScrollViewInsets = NO;
            }
        } else {
            if (@available(iOS 11.0, *)) {
                documentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
            } else {
                self.automaticallyAdjustsScrollViewInsets = YES;
            }
        }
    } else {
        if (@available(iOS 11.0, *)) {
            documentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
}

- (void)initWitPDFListView {
    self.pdfListView = [[CPDFListView alloc] initWithFrame:self.view.bounds];
    self.pdfListView.performDelegate = self;
    self.pdfListView.delegate = self;
    self.pdfListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.pdfListView];
}

- (CActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[CActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingView.center = self.view.center;
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _loadingView;
}

- (void)initWitNavigation {
    UIBarButtonItem *thumbnailItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CPDFThunbnailImageEnter" inBundle:[NSBundle bundleForClass:CPDFViewBaseController.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemClicked_thumbnail:)];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CPDFViewImageBack" inBundle:[NSBundle bundleForClass:CPDFViewBaseController.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemClicked_back:)];
    
    self.thumbnailBarItem = thumbnailItem;
    self.backBarItem = backItem;
    
    NSMutableArray *leftItems = [NSMutableArray array];
    for (CNavBarButtonItem *item in self.configuration.showleftItems) {
        if(CPDFViewBarLeftButtonItem_Back == item.leftBarItem)
            [leftItems addObject:backItem];
        else if (CPDFViewBarLeftButtonItem_Thumbnail == item.leftBarItem)
            [leftItems addObject:thumbnailItem];
    }
    
    self.navigationItem.leftBarButtonItems = leftItems;
    
    __block typeof(self) blockSelf = self;
    NSMutableArray *actions = [NSMutableArray array];
    
    for (CNavBarButtonItem *item in self.configuration.showRightItems) {
        if(CPDFViewBarRightButtonItem_Bota == item.rightBarItem) {
            UIImage *image = [UIImage imageNamed:@"CNavigationImageNameBota"
                                        inBundle:[NSBundle bundleForClass:CPDFViewBaseController.class]
                   compatibleWithTraitCollection:nil];
            CNavigationRightAction *action = [CNavigationRightAction actionWithImage:image tag:CNavigationRightTypeBota];
            [actions addObject:action];
            
        } else if (CPDFViewBarRightButtonItem_Search == item.rightBarItem) {
            UIImage *image = [UIImage imageNamed:@"CNavigationImageNameSearch"
                                        inBundle:[NSBundle bundleForClass:CPDFViewBaseController.class]
                   compatibleWithTraitCollection:nil];
            CNavigationRightAction *action = [CNavigationRightAction actionWithImage:image tag:CNavigationRightTypeSearch];
            [actions addObject:action];
            
        } else if (CPDFViewBarRightButtonItem_More == item.rightBarItem) {
            UIImage *image = [UIImage imageNamed:@"CNavigationImageNameMore"
                                        inBundle:[NSBundle bundleForClass:CPDFViewBaseController.class]
                   compatibleWithTraitCollection:nil];
            CNavigationRightAction *action = [CNavigationRightAction actionWithImage:image tag:CNavigationRightTypeMore];
            [actions addObject:action];
        }
    }
    
    self.rightView = [[CNavigationRightView alloc] initWithRightActions:actions clickBack:^(NSUInteger tag) {
        switch (tag) {
            case CNavigationRightTypeSearch:
                [blockSelf buttonItemClicked_Search:self.rightView];
                break;
            case CNavigationRightTypeBota:
                [blockSelf buttonItemClicked_Bota:self.rightView];
                break;
            default:
            case CNavigationRightTypeMore:
                [blockSelf buttonItemClicked_More:self.rightView];
                break;
        }
    }];
}

- (void)initWithSearchTool {
    self.searchToolbar = [[CSearchToolbar alloc] initWithPDFView:self.pdfListView];
    self.searchToolbar.delegate = self;
}

- (void)enterPDFSetting  {
    [self.popMenu hideMenu];
    CPDFDisplayViewController *displayVc = [[CPDFDisplayViewController alloc] initWithPDFView:self.pdfListView];
    displayVc.delegate = self;
    
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:displayVc presentingViewController:self];
    displayVc.transitioningDelegate = presentationController;
    [self presentViewController:displayVc animated:YES completion:nil];
}

- (void)enterPDFInfo  {
    [self.popMenu hideMenu];
    CPDFInfoViewController * infoVc = [[CPDFInfoViewController alloc] initWithPDFView:self.pdfListView];
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:infoVc presentingViewController:self];
    infoVc.transitioningDelegate = presentationController;
    [self presentViewController:infoVc animated:YES completion:nil];
}

- (void)enterPDFShare  {
    [self.popMenu hideMenu];
    
    if (self.pdfListView.isEditing && self.pdfListView.isEdited) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.pdfListView commitEditing];
            
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingFormat:@"/%@/%@", @"Documents", self.pdfListView.document.documentURL.lastPathComponent];
            if([[NSFileManager defaultManager] fileExistsAtPath:documentFolder]) {
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:documentFolder] error:nil];
            }
            NSURL *url = [NSURL fileURLWithPath:documentFolder];
            
            [self.pdfListView.document writeToURL:url];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self shareAction:url];
            });

        });
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *documentFolder = [NSHomeDirectory() stringByAppendingFormat:@"/%@/%@", @"Documents", self.pdfListView.document.documentURL.lastPathComponent];
            if([[NSFileManager defaultManager] fileExistsAtPath:documentFolder]) {
                [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:documentFolder] error:nil];
            }
            NSURL *url = [NSURL fileURLWithPath:documentFolder];
            
            [self.pdfListView.document writeToURL:url];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self shareAction:url];
            });
        });

    }
    
}

- (void)enterPDFAddFile  {
    [self.popMenu hideMenu];
    
    NSArray *documentTypes = @[@"com.adobe.pdf"];
    self.documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    self.documentPickerViewController.delegate = self;
    [self presentViewController:self.documentPickerViewController animated:YES completion:nil];
}

- (void)enterPDFPageEdit{
    [self.popMenu hideMenu];
    if(self.pdfListView.activeAnnotations.count > 0) {
        [self.pdfListView updateActiveAnnotations:@[]];
        [self.pdfListView setNeedsDisplayForVisiblePages];
    }
    
    if(self.pdfListView.isEditing) {
        if(self.pdfListView.isEdited) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.pdfListView commitEditing];
                dispatch_async(dispatch_get_main_queue(), ^{
                    CPDFPageEditViewController *pageEditViewcontroller = [[CPDFPageEditViewController alloc] initWithPDFView:self.pdfListView];
                    pageEditViewcontroller.pageEditDelegate = self;
                    CNavigationController *nav = [[CNavigationController alloc]initWithRootViewController:pageEditViewcontroller];
                    nav.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                    [pageEditViewcontroller beginEdit];
                });
            });
        } else {
            CPDFPageEditViewController *pageEditViewcontroller = [[CPDFPageEditViewController alloc] initWithPDFView:self.pdfListView];
            pageEditViewcontroller.pageEditDelegate = self;
            CNavigationController *nav = [[CNavigationController alloc]initWithRootViewController:pageEditViewcontroller];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            [pageEditViewcontroller beginEdit];
        }
    } else {
        CPDFPageEditViewController *pageEditViewcontroller = [[CPDFPageEditViewController alloc] initWithPDFView:self.pdfListView];
        pageEditViewcontroller.pageEditDelegate = self;
        CNavigationController *nav = [[CNavigationController alloc]initWithRootViewController:pageEditViewcontroller];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        [pageEditViewcontroller beginEdit];
    }
}

#pragma mark - CPDFPageEditViewControllerDelegate

- (void)pageEditViewControllerDone:(CPDFPageEditViewController *)pageEditViewController {
    __weak typeof(self) weakSelf = self;
    [pageEditViewController dismissViewControllerAnimated:YES completion:^{
        if (pageEditViewController.isPageEdit) {
            [weakSelf reloadDocumentWithFilePath:self.filePath password:weakSelf.pdfListView.document.password completion:^(BOOL result) {
                [weakSelf.pdfListView reloadInputViews];
                [weakSelf selectDocumentRefresh];
            }];
        }
    }];
}

- (void)pageEditViewController:(CPDFPageEditViewController *)pageEditViewController pageIndex:(NSInteger)pageIndex isPageEdit:(BOOL)isPageEdit {
    __weak typeof(self) weakSelf = self;
    [pageEditViewController dismissViewControllerAnimated:YES completion:^{
        if (isPageEdit) {
            [weakSelf reloadDocumentWithFilePath:self.pdfListView.document.documentURL.path password:weakSelf.pdfListView.document.password completion:^(BOOL result) {
                [weakSelf.pdfListView reloadInputViews];
                [self.pdfListView goToPageIndex:pageIndex animated:NO];
            }];
            
            [weakSelf.pdfListView reloadInputViews];
        } else {
            [weakSelf.pdfListView goToPageIndex:pageIndex animated:NO];
        }
    }];
}

#pragma mark - Public method

- (void)initWitNavigationTitle {
    CNavigationBarTitleButton * navTitleButton = [[CNavigationBarTitleButton alloc] init];
    self.titleButton = navTitleButton;
    self.navigationTitle = NSLocalizedString(@"View", nil);
    [navTitleButton setImage:[UIImage imageNamed:@"syasarrow" inBundle:[NSBundle bundleForClass:CPDFViewBaseController.class]
                   compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [navTitleButton addTarget:self action:@selector(titleButtonClickd:) forControlEvents:UIControlEventTouchUpInside];
    [navTitleButton setTitle:self.navigationTitle forState:UIControlStateNormal];
    [navTitleButton setTitleColor:[CPDFColorUtils CAnyReverseBackgooundColor] forState:UIControlStateNormal];
    self.titleButton.frame = CGRectMake(0, 0, 100, 30);
    self.navigationItem.titleView = self.titleButton;
}

- (void)reloadDocumentWithFilePath:(NSString *)filePath password:(nullable NSString *)password completion:(void (^)(BOOL result))completion {
    
    [self.navigationController.view setUserInteractionEnabled:NO];
    
    if (![self.loadingView superview]) {
        [self.view addSubview:self.loadingView];
    }
    [self.loadingView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL fileURLWithPath:filePath];
        CPDFDocument *document = [[CPDFDocument alloc] initWithURL:url];
        if([document isLocked]) {
            [document unlockWithPassword:password];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController.view setUserInteractionEnabled:YES];
            [self.loadingView stopAnimating];
            [self.loadingView removeFromSuperview];
            
            if (document.error && document.error.code != CPDFDocumentPasswordError) {
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:NSLocalizedString(@"Sorry PDF Reader Can't open this pdf file!", nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:okAction];
                if (completion) {
                    completion(NO);
                }
            } else {
                self.pdfListView.document = document;
                if (completion) {
                    completion(YES);
                }
            }
        });
    });
}

- (void)setTitleRefresh {
    
}

- (void)selectDocumentRefresh {
    
}

- (void)shareRefresh {
    
}

#pragma mark - Action

- (void)buttonItemClicked_Search:(id)sender {
    [self.searchToolbar showInView:self.navigationController.navigationBar];
    self.navigationTitle = @"";
    self.navigationItem.titleView.hidden = YES;
    self.leftBarButtonItems = self.navigationItem.leftBarButtonItems;
    self.rightBarButtonItems = self.navigationItem.rightBarButtonItems;
    self.navigationItem.rightBarButtonItems = @[];
    self.navigationItem.leftBarButtonItems = @[];
}

- (void)buttonItemClicked_Bota:(id)sender {
    CPDFBOTAViewController *botaViewController = [[CPDFBOTAViewController alloc] initWithPDFView:self.pdfListView];
    botaViewController.delegate = self;
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
   
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:botaViewController presentingViewController:self];
    botaViewController.transitioningDelegate = presentationController;
    
    [self presentViewController:botaViewController animated:YES completion:nil];
}

- (void)buttonItemClicked_More:(id)sender {
    CPDFPopMenuView * menuView = [[CPDFPopMenuView alloc] initWithFrame:CGRectMake(0, 0, 200, 250)];
    menuView.delegate = self;
    self.popMenu = [CPDFPopMenu popMenuWithContentView:menuView];
    self.popMenu.dimCoverLayer = YES;
    self.popMenu.delegate = self;
    
    if (@available(iOS 11.0, *)) {
        [self.popMenu showMenuInRect:CGRectMake(self.view.frame.size.width - self.view.safeAreaInsets.right - 250, CGRectGetMaxY(self.navigationController.navigationBar.frame), 250, 250)];
    } else {
        // Fallback on earlier versions
        [self.popMenu showMenuInRect:CGRectMake(self.view.frame.size.width - 250, CGRectGetMaxY(self.navigationController.navigationBar.frame), 250, 250)];
    }
}

- (void)buttonItemClicked_thumbnail:(id)sender {
    if(self.pdfListView.activeAnnotations.count > 0) {
        [self.pdfListView updateActiveAnnotations:@[]];
        [self.pdfListView setNeedsDisplayForVisiblePages];
    }
    
    if(self.pdfListView.isEditing) {
        if(self.pdfListView.isEdited) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.pdfListView commitEditing];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self enterThumbnail];
                });
            });
        } else {
            [self enterThumbnail];
        }
    } else {
        [self enterThumbnail];
    }
}

- (void)enterThumbnail {
    CPDFThumbnailViewController *thumbnailViewController = [[CPDFThumbnailViewController alloc] initWithPDFView:self.pdfListView];
    thumbnailViewController.delegate = self;
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:thumbnailViewController presentingViewController:self];
    thumbnailViewController.transitioningDelegate = presentationController;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:thumbnailViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)buttonItemClicked_back:(id)sender {
    if (self.pdfListView.isEdited) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.pdfListView commitEditing];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pdfListView endOfEditing];
                if([self.delegate respondsToSelector:@selector(PDFViewBaseControllerDissmiss:)]) {
                    [self.delegate PDFViewBaseControllerDissmiss:self];
                }
            });
        });
    } else {
        [self.pdfListView endOfEditing];
        if([self.delegate respondsToSelector:@selector(PDFViewBaseControllerDissmiss:)]) {
            [self.delegate PDFViewBaseControllerDissmiss:self];
        }
    }
}

#pragma mark - CPDFViewDelegate

- (void)PDFViewDocumentDidLoaded:(CPDFView *)pdfView {
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightView];
    self.navigationItem.rightBarButtonItems = @[rightItem];
    
    [self updatePDFViewDocumentView];
    
    [self.navigationController.view setUserInteractionEnabled:NO];
    
        if (![self.loadingView superview]) {
            [self.view addSubview:self.loadingView];
        }
        [self.loadingView startAnimating];
        NSArray *signatures = [pdfView.document signatures];
        NSMutableArray *mSignatures = [NSMutableArray array];
        for (CPDFSignature *sign in signatures) {
            if (sign.signers.count > 0) {
                [mSignatures addObject:sign];
            }
        }
        self.signatures = mSignatures;
        [self.navigationController.view setUserInteractionEnabled:YES];
        [self.loadingView stopAnimating];
        [self.loadingView removeFromSuperview];
}

- (void)PDFViewCurrentPageDidChanged:(CPDFListView *)pdfView {
    [self updatePDFViewDocumentView];
}


- (void)PDFViewPerformURL:(CPDFView *)pdfView withContent:(NSString *)content {
    if (content) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:content]];
    } else {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                       message:NSLocalizedString(@"The hyperlink is invalid.", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)PDFViewPerformReset:(CPDFView *)pdfView {
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.pdfListView.document resetForm];
        [self.pdfListView setNeedsDisplayForVisiblePages];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:[NSString stringWithFormat:NSLocalizedString(@"Do you really want to reset the form?", nil)]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)PDFViewPerformPrint:(CPDFView *)pdfView {
    NSLog(@"Print");
}

#pragma mark - CSearchToolbarDelegate

- (void)searchToolbar:(CSearchToolbar *)searchToolbar onSearchQueryResults:(NSArray *)results {
    if ([results count] < 1) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:NSLocalizedString(@"your have‘t search result", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    CPDFSearchResultsViewController* searchResultController = [[CPDFSearchResultsViewController alloc] initWithResultArray:results keyword:searchToolbar.searchKeyString document:self.pdfListView.document];
    searchResultController.pdfListView = self.pdfListView;
    searchResultController.delegate = self;
    searchResultController.searchString = searchToolbar.searchKeyString;
    CNavigationController *nav = [[CNavigationController alloc]initWithRootViewController:searchResultController];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)searchToolbarOnExitSearch:(CSearchToolbar *)searchToolbar {
    if([searchToolbar superview]) {
        [searchToolbar removeFromSuperview];
        self.title = self.navigationTitle;
        
        self.navigationItem.leftBarButtonItems = self.leftBarButtonItems;
        self.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
    }
    self.navigationTitle = NSLocalizedString(@"Viewer",nil);
    self.navigationItem.titleView.hidden = NO;
    
    [self.pdfListView setHighlightedSelection:nil animated:YES];
    [self.pdfListView setNeedsDisplayForVisiblePages];
    [self.searchToolbar clearDatas];
}

#pragma mark - CPDFDisplayViewDelegate

- (void)displayViewControllerDismiss:(CPDFDisplayViewController *)displayViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CPDFBOTAViewControllerDelegate

- (void)botaViewControllerDismiss:(CPDFBOTAViewController *)botaViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CPDFSearchResultsDelegate

- (void)searchResultsView:(CPDFSearchResultsViewController *)resultVC forSelection:(CPDFSelection *)selection indexPath:(NSIndexPath *)indexPath {
    
    NSInteger pageIndex = [self.pdfListView.document indexForPage:selection.page];
    [self.pdfListView goToPageIndex:pageIndex animated:NO];
    [self.pdfListView setHighlightedSelection:selection animated:YES];
}

- (void)searchResultsViewControllerDismiss:(CPDFSearchResultsViewController *)searchResultsViewController {
   
    [searchResultsViewController dismissViewControllerAnimated:YES completion:nil];

}

- (void)searchResultsViewControllerReplace:(CPDFSearchResultsViewController *)searchResultsViewController {
   
    [searchResultsViewController dismissViewControllerAnimated:YES completion:^{
        [self.pdfListView setHighlightedSelection:nil animated:YES];
        [self.pdfListView setNeedsDisplayForVisiblePages];
        if([self.searchToolbar superview]) {
            [self.searchToolbar removeFromSuperview];
            self.title = self.navigationTitle;
            
            self.navigationItem.leftBarButtonItems = self.leftBarButtonItems;
            self.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
        }
        self.navigationItem.titleView.hidden = NO;
        [self.searchToolbar clearDatas];
        self.pdfListView.superview.userInteractionEnabled = YES;

    }];
}

#pragma mark - CPDFPopMenuDelegate

- (void)menuDidClosedIn:(CPDFPopMenu *)menu isClosed:(BOOL)isClosed {
    
}

#pragma mark - CPDFThumbnailViewControllerDelegate

- (void)thumbnailViewController:(CPDFThumbnailViewController *)thumbnailViewController pageIndex:(NSInteger)pageIndex {
    [thumbnailViewController dismissViewControllerAnimated:YES completion:^{
        [self.pdfListView goToPageIndex:pageIndex animated:NO];
    }];
}

- (void)thumbnailViewControllerDismiss:(CPDFThumbnailViewController *)thumbnailViewController {
    [thumbnailViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CPDFMenuViewdelegate

- (void)menuDidClickAtView:(CPDFPopMenuView *)view clickType:(CPDFPopMenuViewType)viewType {
    switch (viewType) {
        case CPDFPopMenuViewTypeSetting: {
            [self enterPDFSetting];
        }
            break;
            
        case CPDFPopMenuViewTypePageEdit: {
            [self enterPDFPageEdit];
        }
            break;
            
        case CPDFPopMenuViewTypeInfo:{
            [self enterPDFInfo];
        }
            break;
            
        case CPDFPopMenuViewTypeShare: {
            [self enterPDFShare];
        }
            break;
            
        case CPDFPopMenuViewTypeAddFile: {
            [self enterPDFAddFile];
            break;
        }
            
        default:
            break;
    }
}

- (void)titleButtonClickd:(UIButton *) button {
    
}

- (void)shareAction:(NSURL *)url {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:@[url] applicationActivities:nil];
        activityVC.definesPresentationContext = YES;
        if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
            activityVC.popoverPresentationController.sourceView = self.rightView;
            activityVC.popoverPresentationController.sourceRect = CGRectMake(self.rightView.bounds.origin.x + (self.rightView.bounds.size.width)/3*2 + 10, CGRectGetMaxY(self.rightView.bounds), 1, 1);
        }
        [self presentViewController:activityVC animated:YES completion:nil];
        activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {

            if (completed) {
                NSLog(@"Success!");
            } else {
                NSLog(@"Failed Or Canceled!");
            }
        };
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls{
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if(fileUrlAuthozied){
        if (self.pdfListView.isEditing) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if(self.pdfListView.isEdited)
                    [self.pdfListView commitEditing];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pdfListView endOfEditing];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        if(self.pdfListView.document.isModified)
                            [self.pdfListView.document writeToURL:self.pdfListView.document.documentURL];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self openFileWithUrls:urls];
                        });
                    });
                });
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if(self.pdfListView.document.isModified) {
                    [self.pdfListView.document writeToURL:self.pdfListView.document.documentURL];
                }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self openFileWithUrls:urls];
                    });
                
            });
        }
        
    }
}

- (void)openFileWithUrls:(NSArray<NSURL *> *)urls {
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
    NSError *error;
    [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
        
        NSString *documentFolder = [NSHomeDirectory() stringByAppendingFormat:@"/%@/%@", @"Documents",@"Files"];

        if (![[NSFileManager defaultManager] fileExistsAtPath:documentFolder])
            [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL fileURLWithPath:documentFolder] withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString * documentPath = [documentFolder stringByAppendingPathComponent:[newURL lastPathComponent]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
           [[NSFileManager defaultManager] copyItemAtPath:newURL.path toPath:documentPath error:NULL];

        }
        NSURL *url = [NSURL fileURLWithPath:documentPath];
        CPDFDocument *document = [[CPDFDocument alloc] initWithURL:url];
        self.filePath = documentPath;
        
        if (document.error && document.error.code != CPDFDocumentPasswordError) {
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                           message:NSLocalizedString(@"Sorry PDF Reader Can't open this pdf file!", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:okAction];
            UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
            if ([tRootViewControl presentedViewController]) {
                tRootViewControl = [tRootViewControl presentedViewController];
            }
            [tRootViewControl presentViewController:alert animated:YES completion:nil];
        } else {
            if([document isLocked]) {
                CDocumentPasswordViewController *documentPasswordVC = [[CDocumentPasswordViewController alloc] initWithDocument:document];
                documentPasswordVC.delegate = self;
                documentPasswordVC.modalPresentationStyle = UIModalPresentationFullScreen;
                
                UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
                if ([tRootViewControl presentedViewController]) {
                    tRootViewControl = [tRootViewControl presentedViewController];
                }
                [tRootViewControl presentViewController:documentPasswordVC animated:YES completion:nil];
            } else {
                [self.pdfListView updateActiveAnnotations:[NSMutableArray array]];
                self.pdfListView.document = document;
                [self.pdfListView registerAsObserver];
                [self selectDocumentRefresh];
                [self setTitleRefresh];
            }
            
        }
        
    }];
    [urls.firstObject stopAccessingSecurityScopedResource];

}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
}

#pragma mark - CDocumentPasswordViewControllerDelegate

- (void)documentPasswordViewControllerOpen:(CDocumentPasswordViewController *)documentPasswordViewController document:(nonnull CPDFDocument *)document {
    self.pdfListView.document = document;
    [self selectDocumentRefresh];
    [self setTitleRefresh];
}

- (void)PDFPageDidFindSearchChangeNotification:(NSNotification *)notification {
    [self.pdfListView setHighlightedSelection:nil animated:YES];
    [self.pdfListView setNeedsDisplayForVisiblePages];
    if([self.searchToolbar superview]) {
        [self.searchToolbar removeFromSuperview];
        self.title = self.navigationTitle;
        
        self.navigationItem.leftBarButtonItems = self.leftBarButtonItems;
        self.navigationItem.rightBarButtonItems = self.rightBarButtonItems;
    }
    self.navigationItem.titleView.hidden = NO;
    [self.searchToolbar clearDatas];

}

@end
