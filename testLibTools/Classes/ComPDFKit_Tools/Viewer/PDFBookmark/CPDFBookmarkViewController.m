//
//  CPDFBookmarkViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// 

#import "CPDFBookmarkViewController.h"
#import "CPDFBookmarkViewCell.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFBookmarkViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *bookmarks;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *noDataLabel;

@property (nonatomic, strong) UIButton *addBookmarkBtn;

@end

@implementation CPDFBookmarkViewController

#pragma mark - Initializers

- (instancetype)initWithPDFView:(CPDFView *)pdfView {
    if (self = [super init]) {
        _pdfView = pdfView;
    }
    return self;
}

#pragma mark - UIViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 60;
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    
    _noDataLabel = [[UILabel alloc] init];
    _noDataLabel.textColor = [UIColor grayColor];
    _noDataLabel.text = NSLocalizedString(@"No Bookmarks", nil);
    [_noDataLabel sizeToFit];
    _noDataLabel.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    _noDataLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.noDataLabel];
    
    if (@available(iOS 11.0, *)) {
        _addBookmarkBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - self.view.safeAreaInsets.right - 50 - 20, self.view.frame.size.height - self.view.safeAreaInsets.bottom - 50, 50, 50)];
    } else {
        _addBookmarkBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 20 - 50, self.view.frame.size.height - 50 - 50, 50, 50)];
    }
    _addBookmarkBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [_addBookmarkBtn setImage:[UIImage imageNamed:@"CPDFBookmarkImageAdd" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_addBookmarkBtn addTarget:self action:@selector(buttonItemClicked_add:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addBookmarkBtn];
    
    [self createGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadData];
}

#pragma mark - Private Methods

- (void)reloadData {
    if ([self.pdfView.document bookmarks].count > 0) {
        self.bookmarks = [self.pdfView.document bookmarks];
        self.tableView.hidden = NO;
        self.noDataLabel.hidden = YES;
    } else {
        self.tableView.hidden = YES;
        self.noDataLabel.hidden = NO;
    }
    [self.tableView reloadData];
}

- (void)createGestureRecognizer {
    [self.addBookmarkBtn setUserInteractionEnabled:YES];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panaddBookmarkBtn:)];
    [self.addBookmarkBtn addGestureRecognizer:panRecognizer];
}

- (void)panaddBookmarkBtn:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer translationInView:self.view];
    CGFloat newX = self.addBookmarkBtn.center.x + point.x;
    CGFloat newY = self.addBookmarkBtn.center.y + point.y;
    if (CGRectContainsPoint(self.view.frame, CGPointMake(newX, newY))) {
        self.addBookmarkBtn.center = CGPointMake(newX, newY);
    }
    [gestureRecognizer setTranslation:CGPointZero inView:self.view];
}

#pragma mark - Action

- (void)buttonItemClicked_add:(id)sender {
    if (![self.pdfView.document bookmarkForPageIndex:self.pdfView.currentPageIndex]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add Bookmarks", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"Bookmark Title", nil);
        }];
            
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if(alert.textFields.firstObject.text.length > 0) {
                [self.pdfView.document addBookmark:alert.textFields.firstObject.text forPageIndex:self.pdfView.currentPageIndex];
                
                CPDFPage *page = [self.pdfView.document pageAtIndex:self.pdfView.currentPageIndex];
                [self.pdfView setNeedsDisplayForPage:page];
                [self reloadData];
            }
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:addAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            [self.pdfView.document removeBookmarkForPageIndex:self.pdfView.currentPageIndex];
            CPDFPage *page = [self.pdfView.document pageAtIndex:self.pdfView.currentPageIndex];
            [self.pdfView setNeedsDisplayForPage:page];
            [self.tableView setEditing:NO animated:YES];
            [self.tableView setUserInteractionEnabled:YES];
            [self reloadData];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:NSLocalizedString(@"Do you want to remove old mark?", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:cancelAction];
        [alert addAction:okAction];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.bookmarks.count > 0) {
        self.noDataLabel.hidden = YES;
    } else {
        self.noDataLabel.hidden = NO;
    }
    return self.bookmarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFBookmarkViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CPDFBookmarkViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    CPDFBookmark *bookmark = self.bookmarks[indexPath.row];
    cell.pageIndexLabel.text = [NSString stringWithFormat:@"%@ %ld",NSLocalizedString(@"Page", nil) ,bookmark.pageIndex+1];
    cell.titleLabel.text = bookmark.label;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        CPDFBookmarkViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self.pdfView.document removeBookmarkForPageIndex:cell.pageIndexLabel.text.floatValue - 1];
        NSMutableArray *bookmarks = (NSMutableArray *)self.bookmarks;
        [bookmarks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        [self.tableView setEditing:NO animated:YES];
        [self.tableView setUserInteractionEnabled:YES];
        [self reloadData];
    }];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Edit",nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Edit BookMark",nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"Bookmark Title", nil);
        }];
            
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Create", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            CPDFBookmarkViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.titleLabel.text = alert.textFields.firstObject.text;
            self.pdfView.document.bookmarks[indexPath.row].label = alert.textFields.firstObject.text;
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:addAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        [tableView setEditing:NO animated:YES];
        [tableView setUserInteractionEnabled:YES];
    }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    editAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction, editAction];
}


- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIContextualAction * deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        CPDFBookmark *bookmark = self.bookmarks[indexPath.row];
        [self.pdfView.document removeBookmarkForPageIndex:bookmark.pageIndex];
        
        CPDFPage *page = [self.pdfView.document pageAtIndex:bookmark.pageIndex];
        [self.pdfView setNeedsDisplayForPage:page];
        
        NSMutableArray *bookmarks = (NSMutableArray *)self.bookmarks;
        [bookmarks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        [self.tableView setEditing:NO animated:YES];
        [self.tableView setUserInteractionEnabled:YES];
        [self reloadData];
    }];
    
    UIContextualAction * editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Edit BookMark",nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"Bookmark Title", nil);
            }];
    
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    
            UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                CPDFBookmarkViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.titleLabel.text = alert.textFields.firstObject.text;
                self.pdfView.document.bookmarks[indexPath.row].label = alert.textFields.firstObject.text;
            }];
    
            [alert addAction:cancelAction];
            [alert addAction:addAction];
    
            [self presentViewController:alert animated:YES completion:nil];
            [tableView setEditing:NO animated:YES];
            [tableView setUserInteractionEnabled:YES];
    }];
    
    deleteAction.image = [UIImage imageNamed:@"CPDFBookmarkImageDelete" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    deleteAction.backgroundColor = [UIColor redColor];
    editAction.image = [UIImage imageNamed:@"CPDFBookmarkImageEraser" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    
    return [UISwipeActionsConfiguration configurationWithActions: @[deleteAction, editAction]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFBookmark *bookmark = self.bookmarks[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(boomarkViewController:pageIndex:)]) {
        [self.delegate boomarkViewController:self pageIndex:bookmark.pageIndex];
    }
}

@end
