//
//  CPDFPDFInsertViewController.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFPDFInsertViewController.h"
#import "CPDFColorUtils.h"
#import "CInsertBlankPageCell.h"
#import "CBlankPageModel.h"
#import "CDocumentPasswordViewController.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFPDFInsertViewController () <UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, CInsertBlankPageCellDelegate, CDocumentPasswordViewControllerDelegate>

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, strong) CPDFDocument *document;

@property (nonatomic, strong) UIButton *selectRangeBtn;

@property (nonatomic, strong) CInsertBlankPageCell *rangePreCell;

@property (nonatomic, strong) UIButton *selectLocationBtn;

@property (nonatomic, strong) CInsertBlankPageCell *locationPreCell;

@property (nonatomic, strong) NSMutableArray *pageLoactionBtns;

@property (nonatomic, strong) NSMutableArray *pageRangeBtns;

@property (nonatomic, strong) CBlankPageModel *pageModel;

@property (nonatomic, strong) UITextField *locationTextField;

@property (nonatomic, strong) UITextField *rangeTextField;

@property (nonatomic, assign) CPDFPDFInsertType pdfInsertType;

@end

@implementation CPDFPDFInsertViewController

#pragma mark - Initializers

- (instancetype)initWithDocument:(CPDFDocument *)document {
    if (self = [super init]) {
        self.document = document;
    }
    return self;
}

#pragma mark - Accessors

- (NSArray *)dataArray {
    if (!_dataArray) {
        NSArray *dataArray = @[NSLocalizedString(@"File Name", nil), NSLocalizedString(@"Page Range", nil), NSLocalizedString(@"All Pages", nil), NSLocalizedString(@"Odd Pages Only", nil), NSLocalizedString(@"Even Pages Only", nil), NSLocalizedString(@"Custom Range", nil), NSLocalizedString(@"e.g. 1,3-5,10", nil), NSLocalizedString(@"Insert To", nil),NSLocalizedString(@"First Page", nil), NSLocalizedString(@"Last Page", nil), NSLocalizedString(@"Insert Before Specifiled Page", nil), NSLocalizedString(@"Please Enter a Page", nil), NSLocalizedString(@"Insert After Specifiled Page", nil)];
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
    self.titleLabel.text = NSLocalizedString(@"Insert From PDF", nil);
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
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 60.0;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self.view addSubview:self.tableView];
    
    self.isSelect = NO;
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    
    self.pageModel = [[CBlankPageModel alloc] init];
    self.pageModel.pageIndex = 0;
    self.pageModel.rotation = 0;
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i = 0; i < self.document.pageCount; i++) {
        [indexSet addIndex:i];
    }
    self.pageModel.indexSet = indexSet;
    
    self.pageLoactionBtns = [NSMutableArray array];
    self.pageRangeBtns = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardwillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
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

- (NSString *)stringByTruncatingMiddleWithFont:(UIFont *)font maxLength:(CGFloat)maxLength {
    if ([[self.document.documentURL lastPathComponent] sizeWithAttributes:@{NSFontAttributeName: font}].width <= maxLength) {
        return [self.document.documentURL lastPathComponent];
    }

    NSInteger halfLength = ([self.document.documentURL lastPathComponent].length) / 4;
    
    NSString *firstHalf = [[self.document.documentURL lastPathComponent] substringToIndex:halfLength];
    
    NSString *secondHalf = [[self.document.documentURL lastPathComponent] substringFromIndex:[self.document.documentURL lastPathComponent].length - halfLength];
    
    NSString *truncatedStr = [NSString stringWithFormat:@"%@...%@", firstHalf, secondHalf];
    
    return truncatedStr;
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

- (void)enterPDFAddFile {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *documentTypes = @[@"com.adobe.pdf"];
            UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
                    documentPickerViewController.delegate = self;
            
            [self presentViewController:documentPickerViewController animated:YES completion:nil];
        });
    });
}

#pragma mark - Action

- (void)buttonItemClicked_save:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pdfInsertViewControllerSave:document:pageModel:)]) {
            [self.delegate pdfInsertViewControllerSave:self document:self.document pageModel:self.pageModel];
        }
    }];
}

- (void)buttonItemClicked_cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(pdfInsertViewControllerCancel:)]) {
            [self.delegate pdfInsertViewControllerCancel:self];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CInsertBlankPageCell *cell = [[CInsertBlankPageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"pageCell"];
    cell.delegate = self;
    switch (indexPath.row) {
        case 0:
        {
            [cell setCellStyle:CInsertBlankPageCellSize label:self.dataArray[indexPath.row]];
            CGFloat maxLength = 200.0;
            UIFont *font = [UIFont systemFontOfSize:18.0];
            cell.sizeLabel.text = [self stringByTruncatingMiddleWithFont:font maxLength:maxLength];
        }
            break;
        case 1:
            [cell setCellStyle:CInsertBlankPageCellLocation label:self.dataArray[indexPath.row]];
            break;
        case 2:
        {
            [cell setCellStyle:CInsertBlankPageCellRangeSelect label:self.dataArray[indexPath.row]];
            if (![self.pageRangeBtns containsObject:cell.rangeSelectBtn]) {
                [self.pageRangeBtns addObject:cell.rangeSelectBtn];
            }
            
            self.rangePreCell = cell;
            cell.rangeSelectBtn.selected = !cell.rangeSelectBtn.selected;
            cell.rangeSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
            cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
        }
            break;
        case 3 ... 5:
        {
            [cell setCellStyle:CInsertBlankPageCellRangeSelect label:self.dataArray[indexPath.row]];
            if (![self.pageRangeBtns containsObject:cell.rangeSelectBtn]) {
                [self.pageRangeBtns addObject:cell.rangeSelectBtn];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
        }
            break;
        case 6:
            [cell setCellStyle:CInsertBlankPageCellRangeTextFiled label:self.dataArray[indexPath.row]];
            break;
        case 7:
            [cell setCellStyle:CInsertBlankPageCellLocation label:self.dataArray[indexPath.row]];
            break;
        case 8:
        {
            [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
            if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                [self.pageLoactionBtns addObject:cell.locationSelectBtn];
            }
            
            if (!self.currentPageIndex) {
                self.locationPreCell = cell;
                cell.locationSelectBtn.selected = !cell.locationSelectBtn.selected;
                cell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
        }
            break;
        case 9:
        {
            [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
            if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                [self.pageLoactionBtns addObject:cell.locationSelectBtn];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
        }
            break;
        case 10:
        {
            [cell setCellStyle:CInsertBlankPageCellLocationSelect label:self.dataArray[indexPath.row]];
            if (![self.pageLoactionBtns containsObject:cell.locationSelectBtn]) {
                [self.pageLoactionBtns addObject:cell.locationSelectBtn];
            }
            if (self.currentPageIndex) {
                self.locationPreCell = cell;
                cell.locationSelectBtn.selected = !cell.locationSelectBtn.selected;
                cell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
        }
            break;
        case 11:
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
        case 12:
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
    
    return cell;
}

#pragma mark - CInsertBlankPageCellDelegate

- (void)insertBlankPageCell:(CInsertBlankPageCell *)insertBlankPageCell isSelect:(BOOL)isSelect {
    insertBlankPageCell.sizeSelectBtn.selected = !insertBlankPageCell.sizeSelectBtn.selected;
    [self enterPDFAddFile];
}

- (void)insertBlankPageCellRange:(CInsertBlankPageCell *)insertBlankPageCell button:(UIButton *)buttom {
    if (self.rangePreCell) {
        self.rangePreCell.rangeSelectBtn.selected = !self.rangePreCell.rangeSelectBtn.selected;
        self.rangePreCell.rangeSelectLabel.textColor = [UIColor grayColor];
        if (self.rangePreCell.rangeSelectBtn != buttom) {
            buttom.selected = !buttom.selected;
            insertBlankPageCell.rangeSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
            self.rangePreCell = insertBlankPageCell;
        } else {
            self.rangePreCell.rangeSelectLabel.textColor = [UIColor grayColor];
            self.rangePreCell = nil;
        }
    } else {
        self.rangePreCell = insertBlankPageCell;
        buttom.selected = !buttom.selected;
        insertBlankPageCell.rangeSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
    }
    
    NSInteger range = [self.pageRangeBtns indexOfObject:buttom];
    switch (range) {
        case 0:
        {
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            for (int i = 0; i < self.document.pageCount; i++) {
                [indexSet addIndex:i];
            }
            self.pageModel.indexSet = indexSet;
            self.rangeTextField.userInteractionEnabled = NO;
        }
            break;
        case 1:
        {
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            for (int i = 0; i < self.document.pageCount; i += 2) {
                [indexSet addIndex:i];
            }
            self.pageModel.indexSet = indexSet;
            self.rangeTextField.userInteractionEnabled = NO;
        }
            break;
        case 2:
        {
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            for (int i = 1; i < self.document.pageCount; i += 2) {
                [indexSet addIndex:i];
            }
            self.pageModel.indexSet = indexSet;
            self.rangeTextField.userInteractionEnabled = NO;
        }
            break;
        case 4:
            self.rangeTextField.userInteractionEnabled = YES;
            break;
            
        default:
            break;
    }
}

- (void)insertBlankPageCellLocation:(CInsertBlankPageCell *)insertBlankPageCell button:(UIButton *)buttom {
    if (self.locationPreCell) {
        self.locationPreCell.locationSelectBtn.selected = !self.locationPreCell.locationSelectBtn.selected;
        self.locationPreCell.locationSelectLabel.textColor = [UIColor grayColor];
        if (self.locationPreCell.locationSelectBtn != buttom) {
            buttom.selected = !buttom.selected;
            insertBlankPageCell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
            self.locationPreCell = insertBlankPageCell;
        } else {
            self.locationPreCell.locationSelectLabel.textColor = [UIColor grayColor];
            self.locationPreCell = nil;
        }
    } else {
        self.locationPreCell = insertBlankPageCell;
        buttom.selected = !buttom.selected;
        insertBlankPageCell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
    }
    
    NSInteger location = [self.pageLoactionBtns indexOfObject:buttom];
    switch (location) {
        case 0:
        {
            self.pdfInsertType = CPDFPDFInsertTypeNone;
            self.pageModel.pageIndex = 0;
            self.saveButton.userInteractionEnabled = YES;
            [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
        case 1:
        {
            self.pdfInsertType = CPDFPDFInsertTypeNone;
            self.pageModel.pageIndex = -2;
            self.saveButton.userInteractionEnabled = YES;
            [self.saveButton setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        }
            break;
        case 2:
        {
            self.pdfInsertType = CPDFPDFInsertTypeBefore;
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
            self.pdfInsertType = CPDFPDFInsertTypeAfter;
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

- (void)insertBlankPageCell:(CInsertBlankPageCell *)insertBlankPageCell pageRange:(NSString *)pageRange {
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    if ([pageRange containsString:@","]) {
        NSArray<NSString *> *pageIndexsArray = [pageRange componentsSeparatedByString:@","];
        for (NSString *pageIndexStr in pageIndexsArray) {
            if ([pageIndexStr containsString:@"-"]) {
                NSArray<NSString *> *pageIndexs = [pageIndexStr componentsSeparatedByString:@"-"];
                NSInteger start = [pageIndexs[0] integerValue];
                NSInteger end = [pageIndexs[1] integerValue];
                if (end > self.document.pageCount-1) {
                    [self popoverWarning];
                } else {
                    for (NSInteger i = start-1; i <= end-1; i++) {
                        [indexSet addIndex:i];
                    }
                }
            } else {
                if ([pageIndexStr integerValue] > self.document.pageCount-1) {
                    [self popoverWarning];
                } else {
                    [indexSet addIndex:[pageIndexStr integerValue]-1];
                }
            }
        }
    } else {
        if ([pageRange containsString:@"-"]) {
            NSArray<NSString *> *pageIndexs = [pageRange componentsSeparatedByString:@"-"];
            NSInteger start = [pageIndexs[0] integerValue];
            NSInteger end = [pageIndexs[1] integerValue];
            if (end > self.document.pageCount-1) {
                [self popoverWarning];
            } else {
                for (NSInteger i = start-1; i <= end-1; i++) {
                    [indexSet addIndex:i];
                }
            }
        } else {
            if ([pageRange integerValue] > self.document.pageCount-1) {
                [self popoverWarning];
            } else {
                [indexSet addIndex:[pageRange integerValue]-1];
            }
        }
    }
    
    self.pageModel.indexSet = indexSet;
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
        if (self.pdfInsertType == CPDFPDFInsertTypeBefore) {
            self.pageModel.pageIndex = self.pageModel.pageIndex - 1;
        } else if (self.pdfInsertType == CPDFPDFInsertTypeAfter) {
            self.pageModel.pageIndex = self.pageModel.pageIndex + 1;
        }
    }
}

- (void)insertBlankPageCellLocationTextFieldBegin:(CInsertBlankPageCell *)insertBlankPageCell {
    for (UIButton *button in self.pageLoactionBtns) {
        NSInteger location = [self.pageLoactionBtns indexOfObject:button];
        switch (location) {
            case 0 ... 1:
                if (button.selected) {
                    self.locationPreCell.locationSelectBtn.selected = !self.locationPreCell.locationSelectBtn.selected;
                    self.locationPreCell.locationSelectLabel.textColor = [UIColor grayColor];
                }
                break;
            case 2:
                if (!button.selected && !((UIButton *)self.pageLoactionBtns[3]).selected) {
                    self.pdfInsertType = CPDFPDFInsertTypeBefore;
                    CInsertBlankPageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0]];
                    cell.locationSelectBtn.selected = !cell.locationSelectBtn.selected;
                    cell.locationSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
                    self.locationPreCell = cell;
                }
                break;
                
            default:
                break;
        }
    }
}

- (void)insertBlankPageCellRangeTextFieldBegin:(CInsertBlankPageCell *)insertBlankPageCell {
    for (UIButton *button in self.pageRangeBtns) {
        NSInteger location = [self.pageRangeBtns indexOfObject:button];
        switch (location) {
            case 0 ... 2:
                if (button.selected) {
                    self.rangePreCell.rangeSelectBtn.selected = !self.rangePreCell.rangeSelectBtn.selected;
                    self.rangePreCell.locationSelectLabel.textColor = [UIColor grayColor];
                }
                break;
            case 3:
                if (!button.selected) {
                    CInsertBlankPageCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
                    cell.rangeSelectBtn.selected = !cell.rangeSelectBtn.selected;
                    cell.rangeSelectLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
                    self.rangePreCell = cell;
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
                    
                    [self presentViewController:documentPasswordVC animated:YES completion:nil];
                } else {
                    self.document = document;
                    [self.tableView reloadData];
                    
                    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
                    for (int i = 0; i < self.document.pageCount; i++) {
                        [indexSet addIndex:i];
                    }
                    self.pageModel.indexSet = indexSet;
                }
                
            }
            
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    
}

#pragma mark - CDocumentPasswordViewControllerDelegate

- (void)documentPasswordViewControllerOpen:(CDocumentPasswordViewController *)documentPasswordViewController document:(nonnull CPDFDocument *)document {
    self.document = document;
    [self.tableView reloadData];
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i = 0; i < self.document.pageCount; i++) {
        [indexSet addIndex:i];
    }
    self.pageModel.indexSet = indexSet;
}

- (void)documentPasswordViewControllerCancel:(CDocumentPasswordViewController *)documentPasswordViewController {
   
}

@end
