//
//  CPDFToolsViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFToolsViewController.h"
#import "CPDFColorUtils.h"
#import "CPDFDisplayTableViewCell.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CPDFToolsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSMutableArray * iconArr;

@property (nonatomic, strong) NSMutableArray * titleArr;

@property (nonatomic, strong) NSArray * toolsTypes;

@property (nonatomic, strong) UIView * splitView;

@end

@implementation CPDFToolsViewController

- (instancetype)init{
    if(self = [super init]) {
        self.titleArr = [[NSMutableArray alloc] initWithObjects:NSLocalizedString(@"Viewer",nil),NSLocalizedString(@"Content Editor",nil), nil];
        self.iconArr = [[NSMutableArray alloc] initWithObjects:@"CNavigationImageNameViewer",@"CNavigationImageNameEditTool",nil];
        self.toolsTypes = @[@(CPDFToolFunctionTypeStateViewer),@(CPDFToolFunctionTypeStateEdit)];
    }
    return self;
}

- (instancetype)initCustomizeWithToolArrays:(NSArray *)toolsTypes {
    if(self = [super init]) {
        self.titleArr  = [NSMutableArray array];
        self.iconArr  = [NSMutableArray array];
        self.toolsTypes = toolsTypes;

        for (NSNumber *num in toolsTypes) {
            if(CPDFToolFunctionTypeStateViewer == num.integerValue) {
                [self.titleArr addObject:NSLocalizedString(@"Viewer",nil)];
                [self.iconArr addObject:@"CNavigationImageNameViewer"];
            } else if (CPDFToolFunctionTypeStateEdit == num.integerValue) {
                [self.titleArr addObject:NSLocalizedString(@"Content Editor",nil)];
                [self.iconArr addObject:@"CNavigationImageNameEditTool"];
            } else if (CPDFToolFunctionTypeStateAnnotation == num.integerValue) {
                [self.titleArr addObject:NSLocalizedString(@"Annotation",nil)];
                [self.iconArr addObject:@"CNavigationImageNameAnnotationTool"];
            } else if (CPDFToolFunctionTypeStateForm == num.integerValue) {
                [self.titleArr addObject:NSLocalizedString(@"Form",nil)];
                [self.iconArr addObject:@"CPDFForm"];
            } else if (CPDFToolFunctionTypeStateSignature == num.integerValue) {
                [self.titleArr addObject:NSLocalizedString(@"Signature",nil)];
                [self.iconArr addObject:@"CNavigationImageNameDigitalTool"];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBaseImageBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text =  NSLocalizedString(@"Tools", nil);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
        
    self.splitView = [[UIView alloc] init];
    self.splitView.backgroundColor = [CPDFColorUtils CTableviewCellSplitColor];
    [self.view addSubview:self.splitView];
    
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    self.tableView.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    
}

- (void)viewWillLayoutSubviews {
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
    self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    self.tableView.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height - 50);
    self.splitView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.view.frame.size.width, 1);
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection
{
    if(self.iconArr.count > 3){
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 300 : 300);
    }else{
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 220 : 220);
    }


}

- (void)buttonItemClicked_back:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.iconArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CPDFDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CPDFDisplayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    cell.titleLabel.text = self.titleArr[indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:self.iconArr[indexPath.row] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    if(indexPath.row == self.iconArr.count - 1) {
        cell.hiddenSplitView = YES;
    }else{
        cell.hiddenSplitView = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
    
    NSNumber *toolNum = self.toolsTypes[indexPath.row];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFToolsViewControllerDismiss:selectItemAtIndex:)]){
        [self.delegate CPDFToolsViewControllerDismiss:self selectItemAtIndex:toolNum.integerValue];
    }
    
}



@end
