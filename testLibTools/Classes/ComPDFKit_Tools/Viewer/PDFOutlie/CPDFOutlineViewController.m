//
//  PDFOutlineViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFOutlineViewController.h"
#import "CPDFOutlineModel.h"
#import "CPDFOutlineViewCell.h"

#import <ComPDFKit/ComPDFKit.h>

#define kPDFOutlineItemMaxDeep 10

@interface CPDFOutlineViewController () <UITableViewDataSource, UITableViewDelegate, CPDFOutlineViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *outlines;

@property (nonatomic, strong) UILabel *noDataLabel;

@end

@implementation CPDFOutlineViewController

#pragma mark - Initializers

- (instancetype)initWithPDFView:(CPDFView *)pdfView {
    if (self = [super init]) {
        _pdfView = pdfView;
    }
    return self;
}

#pragma mark - Accessors

#pragma mark - UIViewController Methods

- (void)loadOutline:(CPDFOutline *)outline level:(NSInteger)level forOutlines:(NSMutableArray *)outlines {
    for (int i=0; i<[outline numberOfChildren]; i++) {
        CPDFOutline *data = [outline childAtIndex:i];
        CPDFDestination *destination = [data destination];
        if (!destination) {
            CPDFAction *action = [data action];
            if (action && [action isKindOfClass:[CPDFGoToAction class]]) {
                destination = [(CPDFGoToAction *)action destination];
            }
        }
        CPDFOutlineModel *model = [[CPDFOutlineModel alloc] init];
        model.level = level;
        model.hide = (1 << (kPDFOutlineItemMaxDeep - level)) - 1;
        model.title = data.label;
        model.count = data.numberOfChildren;
        model.number = destination.pageIndex;
        model.isShow = NO;
        [outlines addObject:model];
        
        [self loadOutline:data level:level+1 forOutlines:outlines];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CPDFOutline *outlineRoot = [self.pdfView.document outlineRoot];
    NSMutableArray *array = [NSMutableArray array];
    [self loadOutline:outlineRoot level:0 forOutlines:array];
    self.outlines = array;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.noDataLabel = [[UILabel alloc] init];
    self.noDataLabel.textColor = [UIColor grayColor];
    self.noDataLabel.text = NSLocalizedString(@"No Outlines", nil);
    [self.noDataLabel sizeToFit];
    self.noDataLabel.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
    self.noDataLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.noDataLabel];
}

#pragma mark - UITableViewDataSource

const static int kShowFlag = (1 << kPDFOutlineItemMaxDeep) -1;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int n = 0;
    for (CPDFOutlineModel *outline in self.outlines) {
        if (outline.hide == kShowFlag)
            n ++ ;
    }
    if (n > 0) {
        self.noDataLabel.hidden = YES;
    } else {
        self.noDataLabel.hidden = NO;
    }
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int t = -1;
    CPDFOutlineModel *outline = nil;
    for (CPDFOutlineModel *model in self.outlines) {
        if (model.hide == kShowFlag)
            t++;
        if (t == indexPath.row) {
            outline = model;
            break;
        }
    }
    
    CPDFOutlineViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CPDFOutlineViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.outline = outline;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32;
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    CPDFOutlineViewCell *cell = (CPDFOutlineViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    CPDFOutlineModel *outline = cell.outline;

    if([self.delegate respondsToSelector:@selector(outlineViewController:pageIndex:)]) {
        [self.delegate outlineViewController:self pageIndex:outline.number];
    }
}

#pragma mark - Action

- (void)buttonItemClicked_Arrow:(CPDFOutlineViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    int t = -1, p = 0;
    CPDFOutlineModel *outline = nil;
    for (CPDFOutlineModel *model in self.outlines) {
        if (model.hide == kShowFlag) t++;
        if (t == indexPath.row) {
            outline = model;
            break;
        }
        p++;
    }
    
    if (outline.level == kPDFOutlineItemMaxDeep-1) return;
    
    p++;
    if (p == self.outlines.count) return;
    CPDFOutlineModel *nextOutline = self.outlines[p];
    if (nextOutline.level > outline.level) {
        if (nextOutline.hide == kShowFlag) {
            [(CPDFOutlineViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] setIsShow:NO];
            NSMutableArray *array = [NSMutableArray array];
            while (true) {
                if (nextOutline.hide == kShowFlag) {
                    t ++;
                    NSIndexPath* path = [NSIndexPath indexPathForRow:t inSection:0];
                    [array addObject:path];
                }
                nextOutline.hide ^= 1 << (kPDFOutlineItemMaxDeep - outline.level - 1);
                p++;
                if (p == self.outlines.count) break;
                nextOutline = self.outlines[p];
                if (nextOutline.level <= outline.level) break;
            }
            [self.tableView deleteRowsAtIndexPaths:array
                                  withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [(CPDFOutlineViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] setIsShow:YES];
            NSMutableArray *array = [NSMutableArray array];
            while (true) {
                nextOutline.hide ^= 1 << (kPDFOutlineItemMaxDeep - outline.level - 1);
                if (nextOutline.hide == kShowFlag) {
                    t ++;
                    NSIndexPath* path = [NSIndexPath indexPathForRow:t inSection:0];
                    [array addObject:path];
                }
                p++;
                if (p == self.outlines.count) break;
                nextOutline = self.outlines[p];
                if (nextOutline.level <= outline.level) break;
            }
            [self.tableView insertRowsAtIndexPaths:array
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

@end
