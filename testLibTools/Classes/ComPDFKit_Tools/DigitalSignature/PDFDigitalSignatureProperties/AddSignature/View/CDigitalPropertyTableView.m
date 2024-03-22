//
//  CDigitalPropertyTableView.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CDigitalPropertyTableView.h"

@interface CDigitalPropertyTableView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *modelView;

@end

@implementation CDigitalPropertyTableView

- (instancetype)initWithFrame:(CGRect)frame height:(CGFloat)height {
    if (self = [super initWithFrame:frame]) {
        self.modelView = [[UIView alloc] initWithFrame:frame];
        self.modelView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.modelView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, height) style:UITableViewStylePlain];
        self.tableView.layer.borderWidth = 0.5;
        self.tableView.layer.borderColor = [UIColor grayColor].CGColor;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self addSubview:self.tableView];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self createGestureRecognizer];
    }
    
    return self;
}

- (void)layoutSubviews {
    self.tableView.center = self.center;
    self.modelView.frame = self.frame;
}


#pragma mark - Pubilc Methods

- (void)showinView:(UIView *)superView {
    if (superView) {
        [superView addSubview:self];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        [self.tableView reloadData];
        [self setPageSizeRefresh];
    }
}

- (void)setPageSizeRefresh {
   
    NSInteger index = [self.dataArray indexOfObject:self.data];
    
    NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - Private Methods

- (void)createGestureRecognizer {
    [self.modelView setUserInteractionEnabled:YES];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapModelView:)];
    [self.modelView addGestureRecognizer:tapRecognizer];
}

- (void)tapModelView:(UIPanGestureRecognizer *)gestureRecognizer {
    [self removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArray.count ?: 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(digitalPropertyTableViewSelect:text:index:)]) {
        [self.delegate digitalPropertyTableViewSelect:self text:cell.textLabel.text index:indexPath.row];
    }
    [self removeFromSuperview];
}


@end
