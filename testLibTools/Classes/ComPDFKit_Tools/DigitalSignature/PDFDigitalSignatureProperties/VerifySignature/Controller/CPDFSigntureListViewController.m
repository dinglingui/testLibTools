//
//  CPDFSigntureListViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSigntureListViewController.h"
#import "CPDFSigntureCell.h"
#import "CPDFSigntureDetailsViewController.h"
#import "CNavigationController.h"
#define kMaxDeep 10
const static int kShowFlag = (1 << kMaxDeep) -1;

@implementation CPDFSigntureModel

@end

@interface CPDFSigntureListViewController () <UITableViewDelegate,UITableViewDataSource,CPDFSigntureDetailsViewControllerDelegate>

@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *models;

@end

@implementation CPDFSigntureListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Signture List", nil);

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CPDFViewImageBack" inBundle:[NSBundle bundleForClass:CPDFSigntureDetailsViewController.class] compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(buttonItemClicked_back:)];
    self.navigationItem.leftBarButtonItems = @[backItem];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 60;
    tableView.rowHeight = UITableViewAutomaticDimension;
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CPDFSigntureCell class]) bundle:[NSBundle bundleForClass:self.class]] forCellReuseIdentifier:@"cell"];

    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    self.models = [NSMutableArray array];
    CPDFSigner *signer = self.signer;
    for (int i=0; i<signer.certificates.count; i++) {
        CPDFSignatureCertificate *cert = signer.certificates[i];
        CPDFSigntureModel *model = [[CPDFSigntureModel alloc] init];
        model.certificate = cert;
        model.level = i;
        model.hide = kShowFlag;
        model.isShow = YES;
        model.count = signer.certificates.count - i - 1;
        [self.models addObject:model];
    }
    [self.tableView reloadData];
}

- (void)buttonItemClicked_back:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CPDFSigntureDetailsViewControllerDelegate

- (void)signtureDetailsViewControllerTrust:(CPDFSigntureDetailsViewController *)signtureDetailsViewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(signtureListViewControllerUpdate:)]) {
        [self.delegate signtureListViewControllerUpdate:self];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int n = 0;
    for (CPDFSigntureModel *model in self.models) {
        if (model.hide == kShowFlag) n++;
    }
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFSigntureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CPDFSigntureCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    int t = -1;
    CPDFSigntureModel *model = nil;
    for (CPDFSigntureModel *m in self.models) {
        if (m.hide == kShowFlag) t++;
        if (t == indexPath.row) {
            model = m;
            break;
        }
    }
    
    CPDFSignatureCertificate *cert = model.certificate;
    cell.titleLabel.text = cert.subject;
    cell.indentationLevel = model.level;
    cell.model = model;
    __block typeof(CPDFSigntureCell *) blockSell = cell;
    __block typeof(self)weakself = self;
    cell.callback = ^{
        [weakself outLineCellArrowButtonTapped:blockSell];
    };
    
    if (model.count > 0) {
        [cell.arrowButton setHidden:NO];
        cell.isShow = model.isShow;
    } else{
        [cell.arrowButton setHidden:YES];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CPDFSigntureCell *cell = (CPDFSigntureCell *)[tableView cellForRowAtIndexPath:indexPath];
    CPDFSigntureDetailsViewController *vc = [[CPDFSigntureDetailsViewController alloc] init];
    vc.delegate = self;
    vc.certificate = cell.model.certificate;
    CNavigationController *nav = [[CNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)outLineCellArrowButtonTapped:(CPDFSigntureCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    int t = -1, p = 0;
    CPDFSigntureModel *m;
    for (CPDFSigntureModel *model in self.models) {
        if (model.hide == kShowFlag) t++;
        if (t == indexPath.row) {
            m = model;
            break;
        }
        p++;
    }
    
    if (m.level == kMaxDeep-1) return;
    
    p++;
    if (p == self.models.count) return;
    CPDFSigntureModel *nxtModel = self.models[p];
    if (nxtModel.level > m.level) {
        if (nxtModel.hide == kShowFlag) {
            [(CPDFSigntureCell *)[self.tableView cellForRowAtIndexPath:indexPath] setIsShow:NO];
            NSMutableArray* arr = [NSMutableArray array];
            while (true) {
                if (nxtModel.hide == kShowFlag) {
                    t ++;
                    NSIndexPath* path = [NSIndexPath indexPathForRow:t inSection:0];
                    [arr addObject:path];
                }
                nxtModel.hide ^= 1 << (kMaxDeep - m.level - 1);
                p++;
                if (p == self.models.count) break;
                nxtModel = self.models[p];
                if (nxtModel.level <= m.level) break;
            }
            [self.tableView deleteRowsAtIndexPaths:arr
                                  withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [(CPDFSigntureCell *)[self.tableView cellForRowAtIndexPath:indexPath] setIsShow:YES];
            NSMutableArray* arr = [NSMutableArray array];
            while (true) {
                nxtModel.hide ^= 1 << (kMaxDeep - m.level - 1);
                
                if (nxtModel.hide == kShowFlag) {
                    t ++;
                    NSIndexPath* path = [NSIndexPath indexPathForRow:t inSection:0];
                    [arr addObject:path];
                }
                
                p++;
                if (p == self.models.count) break;
                nxtModel = self.models[p];
                if (nxtModel.level <= m.level) break;
            }
            [self.tableView insertRowsAtIndexPaths:arr
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-  (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewAutomaticDimension;
}

@end
