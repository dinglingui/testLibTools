//
//  CPDFPageInsertViewController.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFPageInsertViewController.h"
#import "CPDFColorUtils.h"
#import "CInsertBlankPageCell.h"
#import "CBlankPageModel.h"

@interface CPDFPageInsertViewController () <UITableViewDelegate, UITableViewDataSource, CInsertBlankPageCellDelegate>

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, strong) NSMutableArray *pageLoactionBtns;

@property (nonatomic, strong) CBlankPageModel *pageModel;

@property (nonatomic, strong) UITextField *locationTextField;

@property (nonatomic, strong) CInsertBlankPageCell *preCell;

@property (nonatomic, assign) CPDFPageInsertType pageInsertType;

@property (nonatomic, strong) NSString *pageType;

@end

@implementation CPDFPageInsertViewController

#pragma mark - Accessors

- (NSArray *)dataArray {
    if (!_dataArray) {
        NSArray *dataArray = @[NSLocalizedString(@"Page Size", nil), NSLocalizedString(@"Page Direction", nil), NSLocalizedString(@"Insert To", nil),NSLocalizedString(@"First Page", nil), NSLocalizedString(@"Last Page", nil), NSLocalizedString(@"Insert Before Specifiled Page", nil), NSLocalizedString(@"Please Enter a Page", nil), NSLocalizedString(@"Insert After Specifiled Page", nil)];
        _dataArray = dataArray;
    }
    return _dataArray;
}

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.headerView = [[UIView alloc] init];
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.titleLabel.text = NSLocalizedString(@"Insert a Blank Page", nil);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.headerView addSubview:self.titleLabel];
    
    self.saveButton = [[UIButton alloc] init];
    self.saveButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [self.saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(buttonItemClicked_save:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.saveButton];
    
    self.cancelBtn = [[UIButton alloc] init];
    self.cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.cancelBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(buttonItemClicked_cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.cancelBtn];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-100) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self.view addSubview:self.tableView];
    
    self.isSelect = NO;
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    
    self.pageModel = [[CBlankPageModel alloc] init];
    self.pageModel.pageIndex = 0;
    self.pageModel.size = CGSizeMake(210, 297);
    self.pageModel.rotation = 0;
    
    self.pageLoactionBtns = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardwillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.pageType = @"A4 (210 X 297mm)";
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 200)/2, 0, 200, 50);
    
    if (@available(iOS 11.0, *)) {
        self.saveButton.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 40);
        self.cancelBtn.frame = CGRectMake( self.view.safeAreaInsets.left+20, 5, 50, 40);
    } else {
        self.saveButton.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 40);
        self.cancelBtn.frame = CGRectMake(20, 5, 50, 40);
    }
    
}

//fixed rotated cell split bug
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView reloadData];
    [self setPageSizeRefresh];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

#pragma mark - Private Methods

- (void)popoverWarning {
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil)
                                                                   message:NSLocalizedString(@"The page range is invalid or out of range. Please enter the valid page.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setPageSizeRefresh {
    NSArray *szieArray = @[@"A3 (297 X 420mm)", @"A4 (210 X 297mm)", @"A5 (148 X 210mm)"];
    if (self.isSelect) {
        NSInteger index = [szieArray indexOfObject:self.pageType];
        
        switch (index) {
            case 0:
            {
                NSIndexPath* path = [NSIndexPath indexPathForRow:1 inSection:0];
                [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            }
                break;
            case 1:
            {
                NSIndexPath* path = [NSIndexPath indexPathForRow:2 inSection:0];
                [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            }
                break;
            case 2:
            {
                NSIndexPath* path = [NSIndexPath indexPathForRow:3 inSection:0];
                [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
            }
                break;
        }
    }
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat mWidth = fmin(width, height);
    CGFloat mHeight = fmax(width, height);
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // This is an iPad
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.8 : mHeight*0.8);
    } else {
        // This is an iPhone or iPod touch
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.9);
    }
}

#pragma mark - Action

- (void)buttonItemClicked_save:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageInsertViewControllerSave:pageModel:)]) {
            [self.delegate pageInsertViewControllerSave:self pageModel:self.pageModel];
        }
    }];
}

- (void)buttonItemClicked_cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageInsertViewControllerCancel:)]) {
            [self.delegate pageInsertViewControllerCancel:self];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CInsertBlankPageCell *cell = [[CInsertBlankPageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"pageCell"];
    cell.delegate = self;
    
    if (self.pageLoactionBtns.count > 3) {
        [self.pageLoactionBtns removeAllObjects];
    }

    switch (indexPath.row) {
        case 0:
            [cell setCellStyle:CInsertBlankPageCellSize label:self.dataArray[indexPath.row]];
            cell.buttonSelectedStatus = self.isSelect;
            break;
        case 1:
        {
            if (self.isSelect) {
                [cell setCellStyle:CInsertBlankPageCellSizeSelect label:self.dataArray[indexPath.row]];
                cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
            } else {
                [cell setCellStyle:CInsertBlankPageCellDirection label:self.dataArray[indexPath.row]];
                cell.verticalPageBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
            }
        }
            break;
        case 2:
        {
            if (self.isSelect) {
                [cell setCellStyle:CInsertBlankPageCellSizeSelect label:self.dataArray[indexPath.row]];
                cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
            } else {
                [cell setCellStyle:CInsertBlankPageCellLocation label:self.dataArray[indexPath.row]];
            }
        }
            break;
        case 3:
        {
            if (self.isSelect) {
                [cell setCellStyle:CInsertBlankPageCellSizeSelect label:self.dataArray[indexPath.row]];
            } else {
                [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
                if (!self.currentPageIndex) {
                    self.preCell = cell;
                    cell.locationSelectBtn.selected = !cell.locationSelectBtn.selected;
                    cell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
                }
                
                if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                    [self.pageLoactionBtns addObject:cell.locationSelectBtn];
                }
                cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
            }
        }
            break;
        case 4:
        {
            if(self.isSelect){
                [cell setCellStyle:CInsertBlankPageCellDirection label:self.dataArray[indexPath.row]];
                cell.verticalPageBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
            }else{
                [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
                if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                    [self.pageLoactionBtns addObject:cell.locationSelectBtn];
                }
                cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
            }

        }
            break;
        case 5:
        {
            if(self.isSelect) {
                [cell setCellStyle:CInsertBlankPageCellLocation label:self.dataArray[indexPath.row]];
            }else{
                [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
                if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                    [self.pageLoactionBtns addObject:cell.locationSelectBtn];
                }
                if (self.currentPageIndex) {
                    self.preCell = cell;
                    cell.locationSelectBtn.selected = !cell.locationSelectBtn.selected;
                    cell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
                }
                cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
            }

        }
            break;
        case 6:
        {
            if(self.isSelect) {
                [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
                if (!self.currentPageIndex) {
                    self.preCell = cell;
                    cell.locationSelectBtn.selected = !cell.locationSelectBtn.selected;
                    cell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
                }
                
                if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                    [self.pageLoactionBtns addObject:cell.locationSelectBtn];
                }
                cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
            }else{
                [cell setCellStyle:CInsertBlankPageCellLocationTextFiled label:self.dataArray[indexPath.row]];
                if (self.currentPageIndex) {
                    cell.locationTextField.text = [NSString stringWithFormat:@"%lu", self.currentPageIndex];
                    self.pageModel.pageIndex = self.currentPageIndex-1;
                }
                self.locationTextField = cell.locationTextField;
                cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
            }

        }
            break;
        case 7:
        {
            [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
            if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                [self.pageLoactionBtns addObject:cell.locationSelectBtn];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
        }
            break;
        
        case 8:
        {
            [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
            if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                [self.pageLoactionBtns addObject:cell.locationSelectBtn];
            }
            if (self.currentPageIndex) {
                self.preCell = cell;
                cell.locationSelectBtn.selected = !cell.locationSelectBtn.selected;
                cell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
        }
            break;
            
        case 9:
        {
            [cell setCellStyle:CInsertBlankPageCellLocationTextFiled label:self.dataArray[indexPath.row]];
            if (self.currentPageIndex) {
                cell.locationTextField.text = [NSString stringWithFormat:@"%lu", self.currentPageIndex];
                self.pageModel.pageIndex = self.currentPageIndex-1;
            }
            self.locationTextField = cell.locationTextField;
            cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
        }
            break;
            
        case 10:
        {
            [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
            if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                [self.pageLoactionBtns addObject:cell.locationSelectBtn];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
        }
            break;
            
        default:
            break;
    }
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
    CInsertBlankPageCell *cell = [tableView cellForRowAtIndexPath:path];
    switch (indexPath.row) {
        case 1:
        {
            if (self.isSelect) {
                self.pageModel.size = CGSizeMake(297, 420);
                cell.sizeLabel.text = @"A3 (297 X 420mm)";
                self.pageType = @"A3 (297 X 420mm)";
            }
        }
            break;
        case 2:
        {
            if (self.isSelect) {
                self.pageModel.size = CGSizeMake(210, 297);
                cell.sizeLabel.text = @"A4 (210 X 297mm)";
                self.pageType = @"A4 (210 X 297mm)";
            }
        }
            break;
        case 3:
        {
            if (self.isSelect) {
                self.pageModel.size = CGSizeMake(148, 210);
                cell.sizeLabel.text = @"A5 (148 X 210mm)";
                self.pageType = @"A5 (148 X 210mm)";
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - CInsertBlankPageCellDelegate

- (void)insertBlankPageCell:(CInsertBlankPageCell *)insertBlankPageCell isSelect:(BOOL)isSelect {
    NSArray *szieArray = @[@"A3 (297 X 420mm)", @"A4 (210 X 297mm)", @"A5 (148 X 210mm)"];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:insertBlankPageCell];
    self.isSelect = !self.isSelect;
    insertBlankPageCell.sizeSelectBtn.selected = self.isSelect;
    
    if (isSelect) {
        NSInteger t = indexPath.row;
        NSMutableArray *data = [NSMutableArray arrayWithArray:self.dataArray];
        for (NSString *str in szieArray) {
            t++;
            if([self.dataArray containsObject:str]){
                
            }else{
                [data insertObject:str atIndex:t];
            }
            
        }
        self.dataArray = (NSArray *)data;
        
        [self.tableView reloadData];
        [self setPageSizeRefresh];
    } else {
        NSInteger t = indexPath.row;
        NSMutableArray *data = [NSMutableArray arrayWithArray:self.dataArray];
        for (int i = 0; i < szieArray.count; i++) {
            t++;
            NSString * str = szieArray[i];
            if([data containsObject:str]) {
                [data removeObject:str];
            }
        }
        self.dataArray = (NSArray *)data;
        
        [self.tableView reloadData];
    }
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
    CInsertBlankPageCell *cell = [self.tableView cellForRowAtIndexPath:path];
    cell.sizeLabel.text = self.pageType;
}

- (void)insertBlankPageCellLocation:(CInsertBlankPageCell *)insertBlankPageCell button:(nonnull UIButton *)buttom {
    if (self.preCell) {
        self.preCell.locationSelectBtn.selected = !self.preCell.locationSelectBtn.selected;
        self.preCell.locationSelectLabel.textColor = [UIColor grayColor];
        if (self.preCell.locationSelectBtn != buttom) {
            buttom.selected = !buttom.selected;
            insertBlankPageCell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
            self.preCell = insertBlankPageCell;
        } else {
            self.preCell.locationSelectLabel.textColor = [UIColor grayColor];
            self.preCell = nil;
        }
    } else {
        self.preCell = insertBlankPageCell;
        buttom.selected = !buttom.selected;
        insertBlankPageCell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
    }
    
    NSInteger location = [self.pageLoactionBtns indexOfObject:buttom];
    switch (location) {
        case 0:
        {
            self.pageInsertType = CPDFPageInsertTypeNone;
            self.pageModel.pageIndex = 0;
            self.saveButton.userInteractionEnabled = YES;
            [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            self.pageInsertType = CPDFPageInsertTypeNone;
            self.pageModel.pageIndex = -2;
            self.saveButton.userInteractionEnabled = YES;
            [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            self.pageInsertType = CPDFPageInsertTypeBefore;
            self.pageModel.pageIndex = [self.locationTextField.text intValue]-1;
            if ([self.locationTextField.text isEqual:@""]) {
                self.saveButton.userInteractionEnabled = NO;
                [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            } else {
                self.saveButton.userInteractionEnabled = YES;
                [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            }
        }
            break;
        case 3:
        {
            self.pageInsertType = CPDFPageInsertTypeAfter;
            self.pageModel.pageIndex = [self.locationTextField.text intValue];
            if ([self.locationTextField.text isEqual:@""]) {
                self.saveButton.userInteractionEnabled = NO;
                [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            } else {
                self.saveButton.userInteractionEnabled = YES;
                [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)insertBlankPageCell:(CInsertBlankPageCell *)insertBlankPageCell pageIndex:(NSInteger)pageIndex {
    if (pageIndex) {
        self.saveButton.userInteractionEnabled = YES;
        [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    } else {
        self.saveButton.userInteractionEnabled = NO;
        [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    
    if (pageIndex > self.currentPageCout) {
        [self popoverWarning];
        self.pageModel.pageIndex = 0;
    } else {
        self.pageModel.pageIndex = pageIndex-1;
        if (self.pageInsertType == CPDFPageInsertTypeBefore) {
            self.pageModel.pageIndex = self.pageModel.pageIndex-1;
        } else if (self.pageInsertType == CPDFPageInsertTypeAfter) {
            self.pageModel.pageIndex = self.pageModel.pageIndex+1;
        }
    }
}

- (void)insertBlankPageCell:(CInsertBlankPageCell *)insertBlankPageCell rotate:(NSInteger)rotate {
    self.pageModel.rotation = rotate;
}

- (void)insertBlankPageCellLocationTextFieldBegin:(CInsertBlankPageCell *)insertBlankPageCell {
    for (UIButton *button in self.pageLoactionBtns) {
        NSInteger location = [self.pageLoactionBtns indexOfObject:button];
        switch (location) {
            case 0 ... 1:
                if (button.selected) {
                    self.preCell.locationSelectBtn.selected = !self.preCell.locationSelectBtn.selected;
                    self.preCell.locationSelectLabel.textColor = [UIColor grayColor];
                }
                break;
            case 2:
                if (!button.selected && !((UIButton *)self.pageLoactionBtns[3]).selected) {
                    self.pageInsertType = CPDFPageInsertTypeBefore;
                    if (self.isSelect) {
                        CInsertBlankPageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:8 inSection:0]];
                        cell.locationSelectBtn.selected = !cell.locationSelectBtn.selected;
                        cell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
                        self.preCell = cell;
                    } else {
                        CInsertBlankPageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                        cell.locationSelectBtn.selected = !cell.locationSelectBtn.selected;
                        cell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
                        self.preCell = cell;
                    }
                }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - NSNotification

- (void)keyboardwillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect frame = value.CGRectValue;
    CGRect rect = [self.locationTextField convertRect:self.locationTextField.frame toView:self.view];
    if(CGRectGetMaxY(rect) > self.view.frame.size.height - frame.size.height) {
        UIEdgeInsets insets = self.tableView.contentInset;
        insets.bottom = frame.size.height + self.locationTextField.frame.size.height;
        self.tableView.contentInset = insets;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = 0;
    self.tableView.contentInset = insets;
}

@end
