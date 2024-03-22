//
//  CFontStyleTableView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFontStyleTableView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface CPDFFontStyleTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation CPDFFontStyleTableView

#pragma mark - Initializers

- (NSArray *)dataArray {
    if (!_dataArray) {
        NSMutableArray *dataArray = [NSMutableArray array];
        NSArray *fontNameArray = [[NSArray alloc] initWithObjects:@"Helvetica",@"Courier",@"Times-Roman",nil];
        
        for (int i = 0; i < fontNameArray.count; i++) {
            [dataArray addObject:fontNameArray[i]];
        }
        _dataArray = (NSArray *)dataArray;
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
        self.titleLabel.text = NSLocalizedString(@"Font Style", nil);
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

#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {
    [self removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fontName"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fontName"];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fontStyleTableView:fontName:)]) {
        [self.delegate fontStyleTableView:self fontName:self.dataArray[indexPath.row]];
    }
}

@end
