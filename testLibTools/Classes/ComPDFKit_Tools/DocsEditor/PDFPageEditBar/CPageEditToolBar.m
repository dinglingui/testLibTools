//
//  CPageEditToolBar.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPageEditToolBar.h"
#import "CPDFColorUtils.h"
#import "CPDFPageInsertViewController.h"
#import "CPDFPDFInsertViewController.h"
#import "CActivityIndicatorView.h"
#import "AAPLCustomPresentationController.h"
#import "CDocumentPasswordViewController.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPageEditToolBar () <UIDocumentPickerDelegate, CPDFPageInsertViewControllerDelegate, CPDFPDFInsertViewControllerDelegate, CDocumentPasswordViewControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSArray *pageEditBtns;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) CPDFDocument *insertDocument;

@property (nonatomic, strong) CPDFDocument *replaceDocument;

@property (nonatomic, strong) CActivityIndicatorView *loadingView;

@end

@implementation CPageEditToolBar

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        line.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:line];
        
        self.selectedIndex = -1;
        
        [self initSubview];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Public Methods

- (void)reloadData {
    if (self.selectedIndex >=0 &&
        self.selectedIndex < self.pageEditBtns.count) {
        UIButton *selectedButton = [self.pageEditBtns objectAtIndex:self.selectedIndex];
        selectedButton.backgroundColor = [UIColor clearColor];
    }
    self.selectedIndex = -1;
}

#pragma mark - Private Methods

- (void)initSubview {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    CGFloat offsetX = 20.0;
    CGFloat buttonOffset = 25;
    CGFloat buttonSize = 50;
    
    CGFloat topOffset = (60 - buttonSize)/2;
    
    NSMutableArray *images = [NSMutableArray arrayWithArray:@[@"CPageEditToolBarImageInsert",
                                                              @"CPageEditToolBarImageRepalce",
                                                              @"CPageEditToolBarImageExtract",
                                                              @"CPageEditToolBarImageCopy",
                                                              @"CPageEditToolBarImageRotate",
                                                              @"CPageEditToolBarImageRemove"]];
    
    NSMutableArray *names = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"Insert", nil),
                                                             NSLocalizedString(@"Repalce", nil),
                                                             NSLocalizedString(@"Extract", nil),
                                                             NSLocalizedString(@"Copy", nil),
                                                             NSLocalizedString(@"Rotate", nil),
                                                             NSLocalizedString(@"Delete", nil)]];
    
    NSMutableArray *pageEditBtns = [NSMutableArray array];
    for (int i = 0; i < images.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(offsetX, topOffset, buttonSize, buttonSize);
        [button setImage:[UIImage imageNamed:images[i] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [button setTitle:names[i] forState:UIControlStateNormal];
        [button setTitleColor:[CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        button.layer.cornerRadius = 5.0;
        button.titleLabel.font = [UIFont systemFontOfSize:12.0];
        button.tag = i;
        
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 24, 10);
        button.titleEdgeInsets = UIEdgeInsetsMake(button.imageView.frame.size.height, -button.imageView.frame.size.width, -1,-11);
        
        [button addTarget:self action:@selector(buttonItemClicked_switch:) forControlEvents:UIControlEventTouchUpInside];
        
        [_scrollView addSubview:button];
        [pageEditBtns addObject:button];
        if(i != images.count -1)
            offsetX += button.bounds.size.width + buttonOffset;
        else
          offsetX += button.bounds.size.width + 10;
    }
    self.pageEditBtns = pageEditBtns;
    
    _scrollView.contentSize = CGSizeMake(offsetX, _scrollView.bounds.size.height);
}

- (void)insertPage {
    UIAlertAction *insertBlankPageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Blank Page", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
        CPDFPageInsertViewController *pageInsertVC = [[CPDFPageInsertViewController alloc] init];
        pageInsertVC.currentPageIndex = self.currentPageIndex;
        pageInsertVC.currentPageCout = self.pdfView.document.pageCount;
        pageInsertVC.delegate = self;
        
        UIViewController *tRootViewControl = self.parentVC;
//        [tRootViewControl presentViewController:pageInsertVC animated:YES completion:nil];
        
        presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:pageInsertVC presentingViewController:tRootViewControl];
        pageInsertVC.transitioningDelegate = presentationController;
        [tRootViewControl presentViewController:pageInsertVC animated:YES completion:nil];
    }];
    UIAlertAction *insertPdfPageAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"From PDF", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self enterPDFAddFile];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self reloadData];
    }];
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:insertBlankPageAction];
    [alertController addAction:insertPdfPageAction];
    [alertController addAction:cancelAction];
    
    UIViewController *tRootViewControl = self.parentVC;

    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        alertController.popoverPresentationController.sourceView = (UIButton *)self.pageEditBtns[0];
        alertController.popoverPresentationController.sourceRect = ((UIButton *)self.pageEditBtns[0]).bounds;
    }
    
    [tRootViewControl presentViewController:alertController animated:YES completion:nil];
}

- (void)enterPDFAddFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *documentTypes = @[@"com.adobe.pdf"];
            UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
                    documentPickerViewController.delegate = self;
            
            UIViewController *tRootViewControl = self.parentVC;
            [tRootViewControl presentViewController:documentPickerViewController animated:YES completion:nil];
        });
    });
}

- (void)handleDocument {
    if (self.selectedIndex == CPageEditToolBarInsert) {
        AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
        CPDFPDFInsertViewController *pdfInsertVC = [[CPDFPDFInsertViewController alloc] initWithDocument:self.insertDocument];
        pdfInsertVC.delegate = self;
        pdfInsertVC.currentPageIndex =  self.currentPageIndex;
        pdfInsertVC.currentPageCout = self.pdfView.document.pageCount;
        pdfInsertVC.modalPresentationStyle = UIModalPresentationPageSheet;
        
        UIViewController *tRootViewControl = self.parentVC;
//        [tRootViewControl presentViewController:pdfInsertVC animated:YES completion:nil];
        
        presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:pdfInsertVC presentingViewController:tRootViewControl];
        pdfInsertVC.transitioningDelegate = presentationController;
        [tRootViewControl presentViewController:pdfInsertVC animated:YES completion:nil];
    } else if (self.selectedIndex == CPageEditToolBarReplace) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageEditToolBarReplace:document:)]) {
            [self.delegate pageEditToolBarReplace:self document:self.replaceDocument];
        }
    }
}

- (void)popoverWarning {
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        [self reloadData];
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil)
                                                                   message:NSLocalizedString(@"Can not delete all pages. Please keep at least one page.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:OKAction];
    UIViewController *tRootViewControl = self.parentVC;
    [tRootViewControl presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Action

- (void)buttonItemClicked_switch:(UIButton *)button {
    if (self.selectedIndex >=0 &&
        self.selectedIndex < self.pageEditBtns.count) {
        UIButton *selectedButton = [self.pageEditBtns objectAtIndex:self.selectedIndex];
        selectedButton.backgroundColor = [UIColor clearColor];
    }
    self.selectedIndex = button.tag;
    
    switch (button.tag) {
        case CPageEditToolBarInsert:
            [self insertPage];
            break;
        case CPageEditToolBarReplace:
        {
            if (self.isSelect) {
                [self enterPDFAddFile];
            } else {
                [self popoverWarning];
            }
        }
            break;
        case CPageEditToolBarExtract:
        {
            if (self.isSelect) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(pageEditToolBarExtract:)]) {
                    [self.delegate pageEditToolBarExtract:self];
                }
            } else {
                [self popoverWarning];
            }
        }
            break;
        case CPageEditToolBarRotate:
        {
            if (self.isSelect) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(pageEditToolBarRotate:)]) {
                    [self.delegate pageEditToolBarRotate:self];
                }
            } else {
                [self popoverWarning];
            }
        }
            break;
        case CPageEditToolBarCopy:
        {
            if (self.isSelect) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(pageEditToolBarCopy:)]) {
                    [self.delegate pageEditToolBarCopy:self];
                }
            } else {
                [self popoverWarning];
            }
        }
            break;
        case CPageEditToolBarDelete:
        {
            if (self.isSelect) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(pageEditToolBarDelete:)]) {
                    [self.delegate pageEditToolBarDelete:self];
                }
            } else {
                [self popoverWarning];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - CPDFPageInsertViewControllerDelegate

- (void)pageInsertViewControllerSave:(CPDFPageInsertViewController *)PageInsertViewController pageModel:(CBlankPageModel *)pageModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageEditToolBarBlankPageInsert:pageModel:)]) {
        [self.delegate pageEditToolBarBlankPageInsert:self pageModel:pageModel];
    }
    
    [self reloadData];
}

- (void)pageInsertViewControllerCancel:(CPDFPageInsertViewController *)PageInsertViewController {
    [self reloadData];
}

#pragma mark - CPDFPDFInsertViewControllerDelegate

- (void)pdfInsertViewControllerSave:(CPDFPDFInsertViewController *)PageInsertViewController document:(CPDFDocument *)document pageModel:(CBlankPageModel *)pageModel {
    self.insertDocument = document;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageEditToolBarPDFInsert:pageModel:document:)]) {
        [self.delegate pageEditToolBarPDFInsert:self pageModel:pageModel document:self.insertDocument];
    }
    
    [self reloadData];
}

- (void)pdfInsertViewControllerCancel:(CPDFPDFInsertViewController *)PageInsertViewController {
    [self reloadData];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls{
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if(fileUrlAuthozied){
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
            
            if (document.error && document.error.code != CPDFDocumentPasswordError) {
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:NSLocalizedString(@"Sorry PDF Reader Can't open this pdf file!", nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:okAction];
                UIViewController *tRootViewControl = self.parentVC;
                [tRootViewControl presentViewController:alert animated:YES completion:nil];
            } else {
                if([document isLocked]) {
                    CDocumentPasswordViewController *documentPasswordVC = [[CDocumentPasswordViewController alloc] initWithDocument:document];
                    documentPasswordVC.delegate = self;
                    documentPasswordVC.modalPresentationStyle = UIModalPresentationFullScreen;
                    
                    UIViewController *tRootViewControl = self.parentVC;
                    [tRootViewControl presentViewController:documentPasswordVC animated:YES completion:nil];
                } else {
                    if (self.selectedIndex == CPageEditToolBarInsert) {
                        self.insertDocument = document;
                    } else if (self.selectedIndex == CPageEditToolBarReplace) {
                        self.replaceDocument = document;
                    }
                    
                    [self handleDocument];
                }
                
            }
            
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    [self reloadData];
}

#pragma mark - CDocumentPasswordViewControllerDelegate

- (void)documentPasswordViewControllerOpen:(CDocumentPasswordViewController *)documentPasswordViewController document:(nonnull CPDFDocument *)document {
    if (self.selectedIndex == CPageEditToolBarInsert) {
        self.insertDocument = document;
    } else if (self.selectedIndex == CPageEditToolBarReplace) {
        self.replaceDocument = document;
    }
    
    [self handleDocument];
    [self reloadData];
}

- (void)documentPasswordViewControllerCancel:(CDocumentPasswordViewController *)documentPasswordViewController {
    [self reloadData];
}

@end
