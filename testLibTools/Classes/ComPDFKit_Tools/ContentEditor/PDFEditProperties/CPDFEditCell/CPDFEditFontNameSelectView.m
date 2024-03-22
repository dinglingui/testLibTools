//
//  CPDFEditFontNameSelectView.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//


#import "CPDFEditFontNameSelectView.h"
#import <ComPDFKit/ComPDFKit.h>

#define kSetTodoRemindCycle @"SetTodoRemindCycle"
@interface CPDFEditFontNameSelectView()<UITableViewDelegate,UITableViewDataSource>{
    NSIndexPath *current;

    NSInteger recordRow;
}

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UITableView *mTableView;

@property (nonatomic, copy)   NSString * selectedFontName;



@end

@implementation CPDFEditFontNameSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 120)/2, 0, 120, (self.bounds.size.height - 40)/6)];
        _titleLabel.text = NSLocalizedString(@"Font Style", nil);
        _titleLabel.autoresizingMask  = UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.titleLabel];
        
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 40, (self.bounds.size.height - 40)/6)];
        _backBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_backBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBarImageUndo" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backBtn];
        
        if(!self.fontNameArr) {
            self.fontNameArr = [[NSMutableArray alloc] initWithObjects:@"FontName1",@"fontName2",@"fontName3",nil];
        }
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(!self.mTableView){
        self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.frame.size.width, self.frame.size.height - self.titleLabel.frame.size.height)];
        self.mTableView.delegate = self;
        [self addSubview:self.mTableView];
        
        self.mTableView.delegate = self;
        self.mTableView.dataSource = self;
        [self.mTableView reloadData];
    }
}


#pragma mark - Private Methods

#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {

    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:fontName:)]) {
        [self.delegate pickerView:self fontName:self.selectedFontName];
    }
}

#pragma mark - UItableViewDeleagte && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fontNameArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentity = @"fontNameSelectCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    }
    
    UIFont *cellFont = [UIFont fontWithName:self.fontNameArr[indexPath.row] size:15];
    UIFont *selectFont = [UIFont fontWithName:self.fontName size:15];
    
    if([cellFont isEqual:selectFont]){
        recordRow = indexPath.row;
        current = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    cell.textLabel.text = self.fontNameArr[indexPath.row];
    cell.textLabel.font = cellFont;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row != current.row) {

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:current];

        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    
    if (indexPath.row != recordRow) {

       recordRow = indexPath.row;

       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

       cell.accessoryType = UITableViewCellAccessoryCheckmark;

        NSIndexPath *indexPath = [self.mTableView indexPathForSelectedRow];

        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:indexPath.row] forKey:kSetTodoRemindCycle];

       }
    self.selectedFontName = self.fontNameArr[indexPath.row];
    self.fontName = self.selectedFontName;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(pickerView:fontName:)]){
        [self.delegate pickerView:self fontName:self.selectedFontName];
    }
    
    [self.mTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end
