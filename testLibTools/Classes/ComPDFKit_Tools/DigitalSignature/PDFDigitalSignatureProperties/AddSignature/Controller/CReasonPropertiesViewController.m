//
//  CReasonPropertiesViewController.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CReasonPropertiesViewController.h"
#import "CReasonPropertiesCell.h"
#import "CHeaderView.h"
#import "CPDFColorUtils.h"

@interface CReasonPropertiesViewController () <CHeaderViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) CHeaderView *headerView;

@property (nonatomic, strong) UILabel *selectLabel;

@property (nonatomic, strong) UISwitch *selectSwitch;

@property (nonatomic, strong) UIView *splitView;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) NSString *resonSelectStr;

@end

@implementation CReasonPropertiesViewController

#pragma mark - Accessors

- (NSArray *)dataArray {
    if (!_dataArray) {
        NSArray *dataArray = @[NSLocalizedString(@"I am the owner of the document", nil), NSLocalizedString(@"I am approving the document", nil), NSLocalizedString(@"I am reviewed this document", nil), NSLocalizedString(@"None", nil)];
        _dataArray = dataArray;
    }
    return _dataArray;
}

#pragma mark - Viewcontroller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.headerView = [[CHeaderView alloc] init];
    self.headerView.titleLabel.text = NSLocalizedString(@"Reasons", nil);
    self.headerView.cancelBtn.hidden = YES;
    self.headerView.delegate = self;
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.selectLabel = [[UILabel alloc] init];
    self.selectLabel.text = NSLocalizedString(@"Reason", nil);
    self.selectLabel.textColor = [UIColor grayColor];
    self.selectLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:self.selectLabel];
    
    self.selectSwitch = [[UISwitch alloc] init];
    [self.selectSwitch addTarget:self action:@selector(selectChange_switch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.selectSwitch];
    
    self.splitView = [[UIView alloc] init];
    self.splitView.backgroundColor = [CPDFColorUtils CMessageLabelColor];
    [self.view addSubview:self.splitView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 130, self.view.frame.size.width, self.view.frame.size.height-200) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self.view addSubview:self.tableView];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    if (self.isReason) {
        [self.selectSwitch setOn:YES];
        self.splitView.hidden = NO;
        self.tableView.hidden = NO;
    } else {
        self.splitView.hidden = YES;
        self.tableView.hidden = YES;
    }
    
    [self setPageSizeRefresh];
    self.resonSelectStr = @"";
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    self.selectLabel.frame = CGRectMake(25, 50, 100, 50);
    self.selectSwitch.frame = CGRectMake(self.view.frame.size.width - 75, 55, 50, 50);
    self.splitView.frame = CGRectMake(0, 100, self.view.frame.size.width, 30);
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

#pragma mark - Private Methods

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

- (void)setPageSizeRefresh {
    NSArray *szieArray = @[NSLocalizedString(@"I am the owner of the document", nil), NSLocalizedString(@"I am approving the document", nil), NSLocalizedString(@"I am reviewed this document", nil), NSLocalizedString(@"None", nil)];
   
    NSInteger index = [szieArray indexOfObject:self.resonProperties];
    
    switch (index) {
        case 0:
        {
            NSIndexPath* path = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
            break;
        case 1:
        {
            NSIndexPath* path = [NSIndexPath indexPathForRow:1 inSection:0];
            [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
            break;
        case 2:
        {
            NSIndexPath* path = [NSIndexPath indexPathForRow:2 inSection:0];
            [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
            break;
        case 3:
        {
            NSIndexPath* path = [NSIndexPath indexPathForRow:3 inSection:0];
            [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
            break;
    }
    
}

#pragma mark - CHeaderViewDelegate

- (void)CHeaderViewBack:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(CReasonPropertiesViewController:properties:isReason:)]) {
        [self.delegate CReasonPropertiesViewController:self properties:self.resonSelectStr isReason:self.selectSwitch.isOn];
    }
}

#pragma mark - Action

- (void)selectChange_switch:(UISwitch *)sender {
    if (sender.isOn) {
        self.tableView.hidden = NO;
        self.splitView.hidden = NO;
    } else {
        self.tableView.hidden = YES;
        self.splitView.hidden = YES;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CReasonPropertiesCell *cell = [[CReasonPropertiesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reasonPropertiesCell"];
    
    switch (indexPath.row) {
        case 0 ... 3:
            [cell setCellLabel:self.dataArray[indexPath.row]];
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CReasonPropertiesCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.resonSelectStr = cell.resonSelectLabel.text;
}

@end
