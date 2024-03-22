//
//  CPDFArrowStyleTableView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CPDFArrowStyleTableView.h"
#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
#import "CPDFFormArrowModel.h"
#import "CPDFFormArrowCell.h"


@interface CPDFArrowStyleTableView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation CPDFArrowStyleTableView

#pragma mark - Initializers

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        NSMutableArray *dataArray = [NSMutableArray array];
        
        CPDFFormArrowModel * checkModel = [[CPDFFormArrowModel alloc] init];
        checkModel.isSelected = NO;
        checkModel.iconImage = [UIImage imageNamed:@"CPDFFormCheck" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        checkModel.title = NSLocalizedString(@"Check", nil);
        [dataArray addObject:checkModel];
        
    
        CPDFFormArrowModel * roundModel = [[CPDFFormArrowModel alloc] init];
        roundModel.isSelected = NO;
        roundModel.iconImage = [UIImage imageNamed:@"CPDFFormCircle" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        roundModel.title = NSLocalizedString(@"Circle", nil);
        [dataArray addObject:roundModel];
        
        
        CPDFFormArrowModel * forkModel = [[CPDFFormArrowModel alloc] init];
        forkModel.isSelected = NO;
        forkModel.iconImage = [UIImage imageNamed:@"CPDFFormCross" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        forkModel.title = NSLocalizedString(@"Cross", nil);
        [dataArray addObject:forkModel];
        
        CPDFFormArrowModel * RhombusModel = [[CPDFFormArrowModel alloc] init];
        RhombusModel.isSelected = NO;
        RhombusModel.iconImage = [UIImage imageNamed:@"CPDFFormDiamond" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        RhombusModel.title = NSLocalizedString(@"Diamond", nil);
        [dataArray addObject:RhombusModel];
        
        CPDFFormArrowModel *SsquareModel = [[CPDFFormArrowModel alloc] init];
        SsquareModel.isSelected = NO;
        SsquareModel.iconImage = [UIImage imageNamed:@"CPDFFormSquare" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        SsquareModel.title = NSLocalizedString(@"Square", nil);
        [dataArray addObject:SsquareModel];
        
        CPDFFormArrowModel * starModel = [[CPDFFormArrowModel alloc] init];
        starModel.isSelected = NO;
        starModel.iconImage = [UIImage imageNamed:@"CPDFFormStar" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        starModel.title = NSLocalizedString(@"Star", nil);
        [dataArray addObject:starModel];
        
     
        _dataArray = dataArray;
    }
    return _dataArray;
}

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
        self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.headerView.layer.borderWidth = 1.0;
        self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        [self addSubview:self.headerView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 120)/2, 0, 120, 50)];
        self.titleLabel.text = NSLocalizedString(@"Style", nil);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.autoresizingMask  = UIViewAutoresizingFlexibleHeight;
        [self.headerView addSubview:self.titleLabel];
        
        self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 40, 50)];
        self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.backBtn setImage:[UIImage imageNamed:@"CPFFormBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.backBtn];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.bounds.size.width, self.bounds.size.height) style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        [self addSubview:self.tableView];
        
        self.backgroundColor =  self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];;
    }
    return self;;
}

#pragma mark - Setter
- (void)setStyle:(CPDFWidgetButtonStyle)style {
    _style = style;
    NSString * titleString = @"";
    switch (style) {
        case CPDFWidgetButtonStyleCircle:{
            titleString = NSLocalizedString(@"Circle", nil);
        }
            break;
            
        case CPDFWidgetButtonStyleCheck:{
            titleString = NSLocalizedString(@"Check", nil);
        }
            break;
            
        case CPDFWidgetButtonStyleCross:{
            titleString = NSLocalizedString(@"Cross", nil);
        }
            break;
            
        case CPDFWidgetButtonStyleDiamond:{
            titleString = NSLocalizedString(@"Diamond", nil);
        }
            break;
            
        case CPDFWidgetButtonStyleStar:{
            titleString = NSLocalizedString(@"Star", nil);
        }
            break;
            
        case CPDFWidgetButtonStyleSquare:{
            titleString = NSLocalizedString(@"Square", nil);
        }
            break;
            
        default:
            break;
    }
    for (CPDFFormArrowModel * model in self.dataArray) {
        if([model.title isEqualToString:titleString]){
            model.isSelected  = YES;
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {
    [self removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFFormArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CPDFFormArrowCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.contentView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self addSubview:self.headerView];
    
    cell.model  = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDatasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CPDFFormArrowModel * model = self.dataArray[indexPath.row];
    
    CPDFWidgetButtonStyle style = CPDFWidgetButtonStyleNone;
    
    if([model.title isEqualToString:NSLocalizedString(@"Circle",nil)]) {
        style = CPDFWidgetButtonStyleCircle;
    }else if([model.title isEqualToString:NSLocalizedString(@"Check",nil)]) {
        style = CPDFWidgetButtonStyleCheck;
    }else if([model.title isEqualToString:NSLocalizedString(@"Cross",nil)]) {
        style = CPDFWidgetButtonStyleCross;
    }else if([model.title isEqualToString:NSLocalizedString(@"Diamond",nil)]) {
        style = CPDFWidgetButtonStyleDiamond;
    }else if([model.title isEqualToString:NSLocalizedString(@"Star",nil)]) {
        style = CPDFWidgetButtonStyleStar;
    }else if([model.title isEqualToString:NSLocalizedString(@"Square",nil)]){
        style = CPDFWidgetButtonStyleSquare;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFArrowStyleTableView:style:)]) {
        [self.delegate CPDFArrowStyleTableView:self style:style];
    }
    
    //
    for (CPDFFormArrowModel * mModel in self.dataArray) {
        if([mModel.title isEqualToString:model.title]){
            mModel.isSelected = YES;
        }else{
            mModel.isSelected = NO;
        }
    }
    [self.tableView reloadData];
}


@end
