//
//  CPDFFormListOptionVC.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormListOptionVC.h"
#import "CPDFColorUtils.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFFormListOptionVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * options;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UILabel *noDataLabel;

@property (nonatomic, strong) UIButton *addOptionsBtn;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView * splitView;

@end

@implementation CPDFFormListOptionVC

- (instancetype)initWithPDFView:(CPDFView *)pdfView andAnnotation:(CPDFAnnotation*)annotation {
    if(self = [super init]) {
        _pdfView = pdfView;
        _annotation = annotation;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBaseImageBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    self.titleLabel = [[UILabel alloc] init];
    CPDFChoiceWidgetAnnotation * widget = (CPDFChoiceWidgetAnnotation *)self.annotation;
    if(widget.isListChoice) {
        self.titleLabel.text =  NSLocalizedString(@"Edit List Box", nil);
    }else{
        self.titleLabel.text =  NSLocalizedString(@"Edit ComBo Box", nil);
    }
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];

    
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
        
    self.splitView = [[UIView alloc] init];
    self.splitView.backgroundColor = [CPDFColorUtils CTableviewCellSplitColor];
    [self.view addSubview:self.splitView];
    
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    self.tableView.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    
    
    if (@available(iOS 11.0, *)) {
        _addOptionsBtn= [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - self.view.safeAreaInsets.right - 50 - 20, self.view.frame.size.height - self.view.safeAreaInsets.bottom - 70, 50, 50)];
    } else {
        _addOptionsBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 20 - 50, self.view.frame.size.height - 50 - 50, 50, 50)];
    }
    _addOptionsBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [_addOptionsBtn setImage:[UIImage imageNamed:@"CPDFBookmarkImageAdd" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [_addOptionsBtn addTarget:self action:@selector(buttonItemClicked_add:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addOptionsBtn];
    
    self.options = [[NSMutableArray alloc] init];
    
    [self createGestureRecognizer];
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];

    _noDataLabel = [[UILabel alloc] init];
    _noDataLabel.textColor = [UIColor lightGrayColor];
    _noDataLabel.text = NSLocalizedString(@"No Data", nil);
    [_noDataLabel sizeToFit];
    _noDataLabel.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    _noDataLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.noDataLabel];
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
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width,traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.5 : mHeight*0.6);
    } else {
        // This is an iPhone or iPod touch
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width,traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.9);
    }
}

- (void)buttonItemClicked_back:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

- (void)viewWillLayoutSubviews {
    
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
    self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    self.tableView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 50);
    self.splitView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.view.frame.size.width, 1);
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reloadData];
}

- (void)reloadData {
    
    CPDFChoiceWidgetAnnotation * mAnnotation = (CPDFChoiceWidgetAnnotation *)self.annotation;
    self.options = [NSMutableArray arrayWithArray:mAnnotation.items];
    CPDFPage *page = mAnnotation.page;
    [mAnnotation updateAppearanceStream];
    [self.pdfView setNeedsDisplayForPage:page];
    
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    if(self.options.count > 0) {
        self.noDataLabel.hidden = YES;
    } else {
        self.noDataLabel.hidden = NO;
    }
}

- (void)createGestureRecognizer {
    [self.addOptionsBtn setUserInteractionEnabled:YES];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panaddBookmarkBtn:)];
    [self.addOptionsBtn addGestureRecognizer:panRecognizer];
}

- (void)panaddBookmarkBtn:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer translationInView:self.view];
    CGFloat newX = self.addOptionsBtn.center.x + point.x;
    CGFloat newY = self.addOptionsBtn.center.y + point.y;
    if (CGRectContainsPoint(self.view.frame, CGPointMake(newX, newY))) {
        self.addOptionsBtn.center = CGPointMake(newX, newY);
    }
    [gestureRecognizer setTranslation:CGPointZero inView:self.view];
}

#pragma mark - Action

- (void)buttonItemClicked_add:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add Items", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Input Option", nil);
    }];
        
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(alert.textFields.firstObject.text.length > 0) {

            CPDFChoiceWidgetItem * widgetItem = [[CPDFChoiceWidgetItem alloc] init];
            widgetItem.string = widgetItem.value = alert.textFields.firstObject.text;
            [self.options addObject:widgetItem];
            CPDFChoiceWidgetAnnotation * mAnnotation = (CPDFChoiceWidgetAnnotation *)self.annotation;
            mAnnotation.items = self.options;
            if(!mAnnotation.isListChoice){
                mAnnotation.selectItemAtIndex = 0;
            }
            [self reloadData];
        }
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:addAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    CPDFChoiceWidgetItem * item = self.options[indexPath.row];
    cell.textLabel.text  = item.string;
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        if(indexPath.row+1 <= self.options.count){
            [self.options removeObjectAtIndex:indexPath.row];
            CPDFChoiceWidgetAnnotation * mAnnotation = (CPDFChoiceWidgetAnnotation *)self.annotation;
            mAnnotation.items = self.options;
            if(!mAnnotation.isListChoice){
                mAnnotation.selectItemAtIndex = 0;
            }
            [mAnnotation updateAppearanceStream];
            CPDFPage *page = mAnnotation.page;
            [self.pdfView setNeedsDisplayForPage:page];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
            [self.tableView setEditing:NO animated:YES];
            [self.tableView setUserInteractionEnabled:YES];
            [self reloadData];
        }
    }];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Edit", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Edit Items", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"Item Title", nil);
        }];
            
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            CPDFChoiceWidgetItem * widgetItem = [[CPDFChoiceWidgetItem alloc] init];
            widgetItem.string = widgetItem.value = alert.textFields.firstObject.text;
            [self.options addObject:widgetItem];
            CPDFChoiceWidgetAnnotation * mAnnotation = (CPDFChoiceWidgetAnnotation *)self.annotation;
            mAnnotation.items = self.options;
            if(!mAnnotation.isListChoice){
                mAnnotation.selectItemAtIndex = 0;
            }
            [mAnnotation updateAppearanceStream];
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
        //Delete Action
        if(indexPath.row+1 <= self.options.count){
            [self.options removeObjectAtIndex:indexPath.row];
            CPDFChoiceWidgetAnnotation * mAnnotation = (CPDFChoiceWidgetAnnotation *)self.annotation;
            mAnnotation.items = self.options;
            if(!mAnnotation.isListChoice){
                mAnnotation.selectItemAtIndex = 0;
            }
            [mAnnotation updateAppearanceStream];
            CPDFPage *page = mAnnotation.page;
            [self.pdfView setNeedsDisplayForPage:page];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
            [self.tableView setEditing:NO animated:YES];
            [self.tableView setUserInteractionEnabled:YES];
            [self reloadData];
        }
    }];
    
    UIContextualAction * editAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Edit Items", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(@"Item Title", nil);
            }];
    
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    
            UIAlertAction *addAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //Add action
//                [self.options obje:indexPath.row];
                CPDFChoiceWidgetItem * widgetItem = (CPDFChoiceWidgetItem *)[self.options objectAtIndex:indexPath.row];
                widgetItem.string = widgetItem.value = alert.textFields.firstObject.text;
                CPDFChoiceWidgetAnnotation * mAnnotation = (CPDFChoiceWidgetAnnotation *)self.annotation;
                mAnnotation.items = self.options;
                if(!mAnnotation.isListChoice){
                    mAnnotation.selectItemAtIndex = 0;
                }
                [mAnnotation updateAppearanceStream];
                [self reloadData];
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

@end
