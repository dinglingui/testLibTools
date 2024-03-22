//
//  CPDFPopMenuView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CPDFPopMenuView.h"
#import "CPDFPopMenuItem.h"

@interface CPDFPopMenuView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray * menuItemTitleArr;

@property (nonatomic, strong) NSMutableArray * menuItemIconArr;

@end

@implementation CPDFPopMenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setUp {
    self.menuItemTitleArr = [@[NSLocalizedString(@"View Setting", nil),NSLocalizedString(@"Document Editor", nil),NSLocalizedString(@"Document Info", nil), NSLocalizedString(@"Share", nil), NSLocalizedString(@"Open...", nil)] mutableCopy];
    self.menuItemIconArr = [@[@"CNavigationImageNamePreview", @"CNavigationImageNamePageEditTool",@"CNavigationImageNameInformation", @"CNavigationImageNameShare", @"CNavigationImageNameNewFile"] mutableCopy];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.layer.cornerRadius = 5.0;
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.menuItemTitleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"CPDFPopMenuItem";
    CPDFPopMenuItem *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [CPDFPopMenuItem LoadCPDFPopMenuItem];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleL.text = self.menuItemTitleArr[indexPath.row];
    cell.iconImage.image = [UIImage imageNamed:self.menuItemIconArr[indexPath.row] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    
    if(indexPath.row == 4){
        [cell hiddenLineView:YES];
    }else{
        [cell hiddenLineView:NO];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.delegate && [self.delegate respondsToSelector:@selector(menuDidClickAtView:clickType:)]){
        [self.delegate menuDidClickAtView:self clickType:indexPath.row];
    }
}

@end
