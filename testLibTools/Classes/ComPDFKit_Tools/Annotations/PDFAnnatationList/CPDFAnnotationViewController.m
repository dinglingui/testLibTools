//
//  CPDFAnnotationViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import "CPDFAnnotationViewController.h"

#import "CAnnotListHeaderInSection.h"
#import "CPDFAnnotationListCell.h"
#import "CActivityIndicatorView.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CPDFAnnotationViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSMutableArray* sequenceList;

@property (nonatomic, strong) NSMutableDictionary* annotsDict;

@property (nonatomic, strong) NSMutableDictionary* totalAnnotlistDict;

@property (nonatomic, strong) NSMutableArray *selectIndexArray;

@property (nonatomic, strong) UILabel* emptyLabel;

@property (nonatomic, strong) CPDFView *pdfView;

@property (nonatomic, strong) CActivityIndicatorView* activityView;

@property (nonatomic,assign) BOOL stopLoadAnnots;

@end

@implementation CPDFAnnotationViewController

- (instancetype)initWithPDFView:(CPDFView *)pdfView {
    if (self = [super init]) {
        self.pdfView = pdfView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 60;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    self.emptyLabel.hidden = YES;

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.stopLoadAnnots = NO;
    
    [self.activityView startAnimating];
    
    [self loadAndRefreshAnnots];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.stopLoadAnnots = YES;
}

#pragma mark - Asset

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        if (@available(iOS 13.0, *)) {
            [_emptyLabel setTextColor:[UIColor labelColor]];
        } else {
            [_emptyLabel setTextColor:[UIColor blackColor]];
        }
        _emptyLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _emptyLabel.text = NSLocalizedString(@"No annotations", nil);
        _emptyLabel.textColor = [UIColor grayColor];
        [_emptyLabel sizeToFit];
        [self.view addSubview:_emptyLabel];
        [self.view bringSubviewToFront:_emptyLabel];
        _emptyLabel.center = CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0);
        _emptyLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    }
    return _emptyLabel;
}

- (CActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[CActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.center = self.view.center;
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _activityView;
}

- (void)loadAndRefreshAnnots {
    self.stopLoadAnnots = NO;

    self.totalAnnotlistDict = [[NSMutableDictionary alloc] init];
    self.annotsDict = [[NSMutableDictionary alloc] init];
    self.sequenceList = [[NSMutableArray alloc] init];
    
    [self.activityView startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger pageCount = self.pdfView.document.pageCount;
        NSInteger currentPage = 0;
        for (NSInteger i=0; i < pageCount; i++) {
            if (self.stopLoadAnnots) {
                break;
            }
            
            currentPage = i;
            CPDFPage *page = [self.pdfView.document pageAtIndex:i];
            NSArray *annotations = page.annotations;
            NSMutableArray *annotsInpage = [NSMutableArray array];
            for (CPDFAnnotation *annotation in annotations) {
                if (![annotation isKindOfClass:[CPDFWidgetAnnotation  class]] &&
                    ![annotation isKindOfClass:[CPDFLinkAnnotation class]] &&
                    ![annotation isKindOfClass:[CPDFSignatureAnnotation class]]) {
                    [annotsInpage addObject:annotation];
                }
            }
            if ([annotsInpage count] > 0) {
                NSArray *sortArray = [self annotSort:(NSArray *)annotsInpage];
                if (sortArray) {
                    [self.totalAnnotlistDict setObject:[NSMutableArray arrayWithArray:sortArray] forKey:[NSNumber numberWithInteger:i]];
                    [self.sequenceList addObject:[NSNumber numberWithInteger:i]];
                }
            }
            
            if (currentPage == pageCount - 1) {
                self.stopLoadAnnots = YES;
            }
        }
        [self.totalAnnotlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self.annotsDict setObject:[NSMutableArray arrayWithArray:obj] forKey:key];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityView stopAnimating];
            [self.tableView reloadData];
        });
    });
}

- (NSMutableArray *)selectIndexArray {
    if (!_selectIndexArray) {
        _selectIndexArray = [[NSMutableArray alloc] init];
    }
    return _selectIndexArray;
}

static NSInteger sortByDate(CPDFAnnotation *annot1, CPDFAnnotation *annot2, void *context) {
    return NSOrderedAscending;
}

- (NSArray *)annotSort:(NSArray *)array {
    NSArray *result;
    NSInteger (*sortFunction)(id, id, void *) = NULL;
    sortFunction = sortByDate;
    
    if (sortFunction) {
        result = [array sortedArrayUsingFunction:sortFunction context:NULL];
    } else {
        result = array;
    }
    
    return result;
}

#pragma mark - tableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [self.sequenceList count];
    if (count < 1) {
        self.emptyLabel.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.emptyLabel.hidden = YES;
        self.tableView.hidden = NO;
    }

    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.sequenceList count] == section)
        return 1;
    
    if (section >= self.sequenceList.count) {
        return 0;
    }
    NSNumber *key = [self.sequenceList objectAtIndex:section];
    NSArray *val = [self.annotsDict objectForKey:key];
    
    return [val count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.sequenceList count] == section) {
        return 0;
    }
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.sequenceList count] == indexPath.section){
        return 44;
    }
    
    NSNumber *key = [self.sequenceList objectAtIndex:indexPath.section];
    NSArray *val = [self.annotsDict objectForKey:key];
    
    CPDFAnnotation *annot = [val objectAtIndex:indexPath.row];
    if ([annot isKindOfClass:[CPDFMarkupAnnotation class]]){
        NSString *text = [(CPDFMarkupAnnotation *)annot markupText];
        NSArray<NSString *> *contextArray = [text componentsSeparatedByString:@"\n"];
        switch (contextArray.count) {
            case 0:
                return 44;
            case 1:
                return 44+25;
            case 2:
                return 44+45;
            case 3:
                return 44+60;
            default:
                return 44+60;
        }
        
    }else if (([annot contents] && ![[annot contents] isEqualToString:@""])){
        NSArray<NSString *> *contextArray = [[annot contents] componentsSeparatedByString:@"\n"];
        switch (contextArray.count) {
            case 1:
                return 44+25;
            case 2:
                return 44+40;
            case 3:
                return 44+60;
            default:
                return 44+60;
        }
    }else{
        return 40;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.sequenceList count] == section)
        return nil;
    
    if (section >= self.sequenceList.count) {
        return nil;
    }
    
    NSNumber *key = [self.sequenceList objectAtIndex:section];
    NSArray *val = [self.annotsDict objectForKey:key];
    
    CAnnotListHeaderInSection *headerView = [[CAnnotListHeaderInSection alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44.0)];
    [headerView setPageNumber:[key integerValue] + 1];
    [headerView setAnnotsCount:[val count]];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFAnnotationListCell *cell = (CPDFAnnotationListCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CPDFAnnotationListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if ([self.sequenceList count] == indexPath.section){
 
    }else{
        NSNumber *key = [self.sequenceList objectAtIndex:indexPath.section];
        NSArray *val = [self.annotsDict objectForKey:key];
        CPDFAnnotation *annot = [val objectAtIndex:indexPath.row];
        
        [cell updateCellWithAnnotation:annot];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.sequenceList count] == indexPath.section){
        return;
    }
    
    NSNumber *key = [self.sequenceList objectAtIndex:indexPath.section];
    NSArray *val = [self.annotsDict objectForKey:key];
    CPDFAnnotation *annot = [val objectAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(annotationViewController:jumptoPage:selectAnnot:)]) {
        [self.delegate annotationViewController:self jumptoPage:[key integerValue] selectAnnot:annot];
    }
}

@end
