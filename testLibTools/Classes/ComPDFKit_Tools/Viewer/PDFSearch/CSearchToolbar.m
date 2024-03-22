//
//  CSearchToolbar.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CSearchToolbar.h"

#import <ComPDFKit/ComPDFKit.h>
#import "CPDFColorUtils.h"
#import "CPDFListView.h"

#import "CPDFSearchResultsViewController.h"
#import "CNavigationController.h"
#import "CActivityIndicatorView.h"

#define offset 10

@interface CSearchToolbar()<UISearchBarDelegate>

@property (nonatomic, strong) UIButton *searchListItem;

@property (nonatomic, strong) UIButton *nextListItem;

@property (nonatomic, strong) UIButton *previousItem;

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIButton *doneItem;

@property (nonatomic, assign) NSInteger nowPageIndex;

@property (nonatomic, assign) NSInteger nowNumber;

@property (nonatomic, strong) NSArray *resultArray;

@property(nonatomic, strong) CPDFListView *pdfView;

@property (nonatomic, strong) CActivityIndicatorView *loadingView;

@property (nonatomic, assign) BOOL isSearched;

@end

@implementation CSearchToolbar

#pragma mark - Initializers

- (instancetype)initWithPDFView:(CPDFListView *)pdfview {
    if (self = [super init]) {
        self.pdfView = pdfview;
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _doneItem.frame = CGRectMake(offset, 5, ((self.bounds.size.width - (6*offset)) / 9), 30);
    if(!self.isSearched) {
        _searchBar.frame = CGRectMake(((self.bounds.size.width - (6*offset)) / 9) + offset*2, 5, ((self.bounds.size.width - (6*offset)) / 9)*8, 30);
    }else{
        _searchBar.frame = CGRectMake(((self.bounds.size.width - (6*offset)) / 9) + offset*2, 5, ((self.bounds.size.width - (6*offset)) / 9)*5, 30);
    }

    _previousItem.frame = CGRectMake(6*((self.bounds.size.width - (6*offset)) / 9) + offset*3, 5, ((self.bounds.size.width - (6*offset)) / 9), 30);
    _nextListItem.frame = CGRectMake(self.bounds.size.width - (2*((self.bounds.size.width - (6*offset)) / 9) + 2*offset), 5, ((self.bounds.size.width - (6*offset)) / 9), 30);
    _searchListItem.frame = CGRectMake(self.bounds.size.width - (((self.bounds.size.width - (6*offset)) / 9) + offset), 5, ((self.bounds.size.width - (6*offset)) / 9), 30);
}

#pragma mark - Public method

- (void)showInView:(UIView *)subView {
    [subView addSubview:self];
    
    self.frame = CGRectMake(0, 0, subView.bounds.size.width, 35);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.searchBar becomeFirstResponder];
}

- (void)beganSearchText:(NSString *)searchText {
    
    if ([searchText length] < 1){
        return;
    }
    
    if (self.pdfView.toolModel == CToolModelEdit) {
        [self conentEditSearch:searchText];
    } else {
        [self preViewSearch:searchText];
    }
}

- (void)preViewSearch:(NSString *)searchText {
    // The search for document characters cannot be repeated
    self.window.userInteractionEnabled = NO;
    
    if (![self.loadingView superview]) {
        [self.window addSubview:self.loadingView];
    }
    [self.loadingView startAnimating];
    
    __block __typeof(self) block_self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *results = [block_self.pdfView.document findString:searchText withOptions:CPDFSearchCaseInsensitive];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.window.userInteractionEnabled = YES;
            
            [self.loadingView stopAnimating];
            [self.loadingView removeFromSuperview];
            
            block_self.resultArray = results;
            
            if(results.count > 0){
                self.isSearched = YES;
                self.previousItem.hidden = self.nextListItem.hidden = self.searchListItem.hidden = NO;
                [self layoutSubviews];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([block_self.resultArray count] < 1) {
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                           style:UIAlertActionStyleCancel
                                                                         handler:nil];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:NSLocalizedString(@"Text not found!", nil)
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([tRootViewControl presentedViewController])
                        tRootViewControl = [tRootViewControl presentedViewController];
                    
                    [alert addAction:cancelAction];
                    [tRootViewControl presentViewController:alert animated:YES completion:nil];
                } else {
                    block_self.nowNumber = 0;
                    block_self.nowPageIndex = 0;
                    if(block_self.resultArray.count > block_self.nowPageIndex) {
                        NSArray *selections = [block_self.resultArray objectAtIndex:block_self.nowPageIndex];
                        if(selections.count > block_self.nowNumber) {
                            CPDFSelection *selection = [selections objectAtIndex:block_self.nowNumber];
                            CGFloat offsetY = CGRectGetMaxY(block_self.superview.frame);
                            NSInteger pageIndex = [block_self.pdfView.document indexForPage:selection.page];
                            [block_self.pdfView goToRect:selection.bounds onPage:selection.page offsetY:offsetY animated:NO];

                            [block_self.pdfView goToPageIndex:pageIndex animated:NO];
                            [block_self.pdfView setHighlightedSelection:selection animated:YES];
                        }
                    }
                }
            });
        });
    });
}

- (void)conentEditSearch:(NSString *)searchText {
    // The search for document characters cannot be repeated
    self.window.userInteractionEnabled = NO;
    
    if (![self.loadingView superview]) {
        [self.window addSubview:self.loadingView];
    }
    [self.loadingView startAnimating];
    
    __block __typeof(self) block_self = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       [block_self.pdfView.document findEditString:searchText withOptions:CPDFSearchCaseInsensitive];
        NSArray *results = [block_self.pdfView.document findEditSelections];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.window.userInteractionEnabled = YES;

            [self.loadingView stopAnimating];
            [self.loadingView removeFromSuperview];
            
            block_self.resultArray = results;
            
            if(results.count > 0){
                //To avoid modifying the text content when the text search results are available, set all operations to disable.
                self.pdfView.superview.userInteractionEnabled = NO;
                self.isSearched = YES;
                self.previousItem.hidden = self.nextListItem.hidden = self.searchListItem.hidden = NO;
                [self layoutSubviews];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([block_self.resultArray count] < 1) {
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                           style:UIAlertActionStyleCancel
                                                                         handler:nil];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:NSLocalizedString(@"Text not found!", nil)
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([tRootViewControl presentedViewController])
                        tRootViewControl = [tRootViewControl presentedViewController];
                    
                    [alert addAction:cancelAction];
                    [tRootViewControl presentViewController:alert animated:YES completion:nil];
                } else {
                    block_self.nowNumber = 0;
                    block_self.nowPageIndex = 0;
                    if(block_self.resultArray.count > block_self.nowPageIndex) {
                        NSArray *selections = [block_self.resultArray objectAtIndex:block_self.nowPageIndex];
                        if(selections.count > block_self.nowNumber) {
                            CGFloat offsetY = CGRectGetMaxY(block_self.superview.frame);
                            CPDFSelection *selection = [selections objectAtIndex:block_self.nowNumber];
                            NSInteger pageIndex = [block_self.pdfView.document indexForPage:selection.page];
                            [block_self.pdfView goToPageIndex:pageIndex animated:NO];
                            [block_self.pdfView goToRect:selection.bounds onPage:selection.page offsetY:offsetY animated:NO];
                            [block_self.pdfView setHighlightedSelection:selection animated:YES];
                        }
                    }
                }
            });
        });
    });
}

- (void)clearDatas {
    self.resultArray = nil;
    
    self.isSearched = NO;
    self.previousItem.hidden = self.nextListItem.hidden = self.searchListItem.hidden = YES;
    [self layoutSubviews];

    self.searchBar.text = @"";
}


#pragma mark - Accessors

- (UIActivityIndicatorView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[CActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _loadingView.center = self.window.center;
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _loadingView;
}

- (NSString *)searchKeyString {
    return self.searchBar.text;
}

#pragma mark - Private method

- (void)commonInit{
    _searchListItem = [[UIButton alloc] init];
    _nextListItem = [[UIButton alloc] init];
    _previousItem = [[UIButton alloc] init];
    _searchBar = [[UISearchBar alloc] init];
    _doneItem = [[UIButton alloc] init];
    
    [self addSubview:self.searchBar];
    [self addSubview:self.searchListItem];
    [self addSubview:self.nextListItem];
    [self addSubview:self.previousItem];
    [self addSubview:self.doneItem];
    
    [_doneItem setImage:[UIImage imageNamed:@"CPDFSearchImageClose" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    _doneItem.titleLabel.adjustsFontSizeToFitWidth = YES;
    _searchBar.placeholder = NSLocalizedString(@"Search", nil);
    if (@available(iOS 13.0, *)) {
        _searchBar.searchTextField.adjustsFontSizeToFitWidth = YES;
    } else {
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        searchField.adjustsFontSizeToFitWidth = YES;
    }
    [_previousItem setImage:[UIImage imageNamed:@"CPDFSearchImagePrevious" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_nextListItem setImage:[UIImage imageNamed:@"CPDFSearchImageNext" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_searchListItem setImage:[UIImage imageNamed:@"CPDFSearchImageList" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    [self.doneItem addTarget:self action:@selector(buttonItemClicked_Done:) forControlEvents:UIControlEventTouchUpInside];
    [self.previousItem addTarget:self action:@selector(buttonItemClicked_Previous:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextListItem addTarget:self action:@selector(buttonItemClicked_Next:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchListItem addTarget:self action:@selector(buttonItemClicked_SearchList:) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchBar.delegate = self;
    
    self.previousItem.hidden = self.nextListItem.hidden = self.searchListItem.hidden = YES;
}

#pragma mark - Action

- (void)buttonItemClicked_SearchList:(id)sender {
    if([self.delegate respondsToSelector:@selector(searchToolbar:onSearchQueryResults:)]) {
        [self.delegate searchToolbar:self onSearchQueryResults:self.resultArray];
    }
}

- (void)buttonItemClicked_Next:(id)sender {
    if (_nowNumber < [self.resultArray[self.nowPageIndex] count] - 1) {
        _nowNumber++;
    } else {
        if (self.nowPageIndex >= self.resultArray.count - 1) {
            self.nowNumber = 0;
            self.nowPageIndex = 0;
        } else {
            _nowPageIndex++;
            _nowNumber = 0;
        }
    }
    
    CGFloat offsetY = CGRectGetMaxY(self.superview.frame);
    CPDFSelection *selection = self.resultArray[self.nowPageIndex][self.nowNumber];
    NSInteger pageIndex = [self.pdfView.document indexForPage:selection.page];
    [self.pdfView goToPageIndex:pageIndex animated:NO];
    [self.pdfView goToRect:selection.bounds onPage:selection.page offsetY:offsetY animated:NO];
    [self.pdfView setHighlightedSelection:selection animated:YES];
}

- (void)buttonItemClicked_Previous:(id)sender {
    if (_nowNumber > 0) {
        _nowNumber--;
    } else {
        if (self.nowPageIndex == 0) {
            _nowPageIndex = self.resultArray.count - 1;
            _nowNumber = [self.resultArray[self.nowPageIndex] count] - 1;
        } else {
            _nowPageIndex--;
            _nowNumber = [self.resultArray[self.nowPageIndex] count] - 1;
        }
    }
    CGFloat offsetY = CGRectGetMaxY(self.superview.frame);
    CPDFSelection *selection = self.resultArray[self.nowPageIndex][self.nowNumber];
    NSInteger pageIndex = [self.pdfView.document indexForPage:selection.page];
    [self.pdfView goToPageIndex:pageIndex animated:NO];
    [self.pdfView goToRect:selection.bounds onPage:selection.page offsetY:offsetY animated:NO];
    [self.pdfView setHighlightedSelection:selection animated:YES];
}

- (void)buttonItemClicked_Done:(id)sender {
    [self clearDatas];
    self.pdfView.superview.userInteractionEnabled = YES;

    if ([self.delegate respondsToSelector:@selector(searchToolbarOnExitSearch:)])
        [self.delegate searchToolbarOnExitSearch:self];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString *string = searchBar.text;
    if ([string length] < 1)
        return;
    
    [self beganSearchText:string];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchText.length <1){
        self.isSearched = NO;
        self.previousItem.hidden = self.nextListItem.hidden = self.searchListItem.hidden = YES;
        [self layoutSubviews];
    }

}

@end
