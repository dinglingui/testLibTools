//
//  CPDFInfoViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFInfoViewController.h"
#import "CPDFInfoTableCell.h"
#import <ComPDFKit/ComPDFKit.h>
#import "CPDFColorUtils.h"


@interface CPDFInfoViewController()<UITableViewDelegate,UITableViewDataSource>

@property  (nonatomic, retain) UITableView* curTableView;
@property  (nonatomic, retain) NSArray*     curTableArray;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *doneBtn;

@end

@implementation CPDFInfoViewController

#pragma mark - Initializers
- (instancetype)initWithPDFView:(CPDFView *)pdfView {
    if (self = [super init]) {
        _pdfView = pdfView;
    }
    return self;
}

#pragma mark life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (@available(iOS 12.0, *)) {
        BOOL isDark = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
        if(isDark){
            self.view.backgroundColor = [UIColor blackColor];
        }else{
            self.view.backgroundColor = [UIColor colorWithRed:240/255. green:240/255. blue:240/255. alpha:1.];
        }
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:240/255. green:240/255. blue:240/255. alpha:1.];
    }
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text =  NSLocalizedString(@"Information", nil);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    [self loadDocumentInfo];
    
    [self.view addSubview:self.curTableView];
    
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.doneBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.doneBtn setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneBtn];
    
    
}

- (void)buttonItemClicked_back:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat mWidth = fmin(width, height);
    CGFloat mHeight = fmax(width, height);
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // This is an iPad
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.7);
    } else {
        // This is an iPhone or iPod touch
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.9);
    }

}

- (void)viewWillLayoutSubviews {
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
    self.curTableView.frame = CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height - 50);
    self.doneBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - getter && setter

- (UITableView*) curTableView {
    
    if (!_curTableView) {
        _curTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _curTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _curTableView.delegate = self;
        _curTableView.dataSource = self;
        _curTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _curTableView.backgroundColor = [UIColor clearColor];
    }
    return _curTableView;
}


#pragma mark - private method

- (NSString *)fileSizeStr {

    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if (![defaultManager fileExistsAtPath:self.currentPath]) {
        return @"";
    }
    
    NSDictionary *attrib = [[NSFileManager defaultManager] attributesOfItemAtPath:self.currentPath error:nil];
    float tFileSize   = [[attrib objectForKey:NSFileSize] floatValue];
    
    float fileSize = tFileSize / 1024;
    float size = fileSize >= 1024 ?(fileSize < 1048576 ? fileSize/1024.0 : fileSize/1048576.0) : fileSize;
    char  unit = fileSize >= 1024 ? (fileSize < 1048576 ? 'M':'G'):'K';
    return [NSString stringWithFormat:@"%0.1f%c", size, unit];
}

- (void) loadDocumentInfo {

    NSDictionary *documentAttributes = [self.pdfView.document documentAttributes];
    self.currentPath = self.pdfView.document.documentURL.path;
    NSMutableArray* tableArray = [NSMutableArray array];
    // 1.abstract
    NSMutableArray*        mArray = [NSMutableArray array];
    if (self.currentPath) {
        [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"File Name:",kDocumentInfoTitle nil),kDocumentInfoTitle, [self.currentPath lastPathComponent], kDocumentInfoValue, nil]];
        
        [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Size:",kDocumentInfoTitle nil),kDocumentInfoTitle, [self fileSizeStr], kDocumentInfoValue, nil]];
    }
    
    if (documentAttributes[CPDFDocumentTitleAttribute]) {
        [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Title:",kDocumentInfoTitle nil),kDocumentInfoTitle, documentAttributes[CPDFDocumentTitleAttribute], kDocumentInfoValue, nil]];

    }
    if (documentAttributes[CPDFDocumentAuthorAttribute]) {
        [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Author:",kDocumentInfoTitle nil),kDocumentInfoTitle, documentAttributes[CPDFDocumentAuthorAttribute], kDocumentInfoValue, nil]];
    }
    if (documentAttributes[CPDFDocumentSubjectAttribute]) {
        [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Subject:",kDocumentInfoTitle nil),kDocumentInfoTitle, documentAttributes[CPDFDocumentSubjectAttribute], kDocumentInfoValue, nil]];
    }
    if (documentAttributes[CPDFDocumentKeywordsAttribute]) {
        [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Keywords:",kDocumentInfoTitle nil),kDocumentInfoTitle, documentAttributes[CPDFDocumentKeywordsAttribute], kDocumentInfoValue, nil]];
    }
    [tableArray addObject:mArray];
    
    // 2.create
    mArray = [NSMutableArray array];
    NSString * versionString = [NSString stringWithFormat:@"%ld.%ld",(long)self.pdfView.document.majorVersion,(long)self.pdfView.document.minorVersion];
    [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Version:",kDocumentInfoTitle nil),kDocumentInfoTitle, versionString, kDocumentInfoValue, nil]];

    [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Pages:",kDocumentInfoTitle nil),kDocumentInfoTitle, [NSString stringWithFormat:@"%zd", self.pdfView.document.pageCount], kDocumentInfoValue, nil]];
    if (documentAttributes[CPDFDocumentCreatorAttribute]) {
        [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Creator:",kDocumentInfoTitle nil),kDocumentInfoTitle, documentAttributes[CPDFDocumentCreatorAttribute], kDocumentInfoValue, nil]];
    }
    
    if (documentAttributes[CPDFDocumentCreationDateAttribute]){
        NSMutableString* mSting = [NSMutableString string];
        NSString*    tstring = [NSString stringWithFormat:@"%@",documentAttributes[CPDFDocumentCreationDateAttribute]];
        if (tstring.length >= 16) {
            NSRange        range;
            range.location = 2;range.length=4;
            [mSting appendString:[tstring substringWithRange:range]];
            range.location = 6;range.length=2;
            [mSting appendFormat:@"-%@",[tstring substringWithRange:range]];
            range.location = 8;range.length=2;
            [mSting appendFormat:@"-%@",[tstring substringWithRange:range]];
            
            range.location = 10;range.length=2;
            [mSting appendFormat:@" %@",[tstring substringWithRange:range]];
            range.location = 12;range.length=2;
            [mSting appendFormat:@":%@",[tstring substringWithRange:range]];
            range.location = 14;range.length=2;
            [mSting appendFormat:@":%@",[tstring substringWithRange:range]];
            
            [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Creation Date:",kDocumentInfoTitle nil),kDocumentInfoTitle, mSting, kDocumentInfoValue, nil]];
        }
    }
    
    
    if (documentAttributes[CPDFDocumentModificationDateAttribute]){
        NSMutableString* mSting = [NSMutableString string];
        NSString*    tstring = [NSString stringWithFormat:@"%@",documentAttributes[CPDFDocumentModificationDateAttribute]];

        if (tstring.length >= 16) {
            NSRange        range;
            range.location = 2;range.length=4;
            [mSting appendString:[tstring substringWithRange:range]];
            range.location = 6;range.length=2;
            [mSting appendFormat:@"-%@",[tstring substringWithRange:range]];
            range.location = 8;range.length=2;
            [mSting appendFormat:@"-%@",[tstring substringWithRange:range]];
            
            range.location = 10;range.length=2;
            [mSting appendFormat:@" %@",[tstring substringWithRange:range]];
            range.location = 12;range.length=2;
            [mSting appendFormat:@":%@",[tstring substringWithRange:range]];
            range.location = 14;range.length=2;
            [mSting appendFormat:@":%@",[tstring substringWithRange:range]];
            
            [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Modification Date:",kDocumentInfoTitle nil),kDocumentInfoTitle, mSting, kDocumentInfoValue, nil]];
        }
    }
    [tableArray addObject:mArray];
    
    // 3.execute
    mArray = [NSMutableArray array];
    
    [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Printing:",kDocumentInfoTitle nil),kDocumentInfoTitle, (self.pdfView.document.allowsPrinting ? NSLocalizedString(@"Allowed", nil) : NSLocalizedString(@"Not Allowed", nil)), kDocumentInfoValue, nil]];
    
    [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Content Copying:",kDocumentInfoTitle nil),kDocumentInfoTitle, (self.pdfView.document.allowsCopying ? NSLocalizedString(@"Allowed", nil) : NSLocalizedString(@"Not Allowed", nil)), kDocumentInfoValue, nil]];
    
    [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Document Change:",kDocumentInfoTitle nil),kDocumentInfoTitle, (self.pdfView.document.allowsDocumentChanges ? NSLocalizedString(@"Allowed", nil) : NSLocalizedString(@"Not Allowed", nil)), kDocumentInfoValue, nil]];
    
    [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Document Assembly:",kDocumentInfoTitle nil),kDocumentInfoTitle, (self.pdfView.document.allowsDocumentAssembly ? NSLocalizedString(@"Allowed", nil) : NSLocalizedString(@"Not Allowed", nil)), kDocumentInfoValue, nil]];
    
    [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Commenting:",kDocumentInfoTitle nil),kDocumentInfoTitle, ((self.pdfView.document.allowsCommenting == YES) ? NSLocalizedString(@"Allowed", nil) : NSLocalizedString(@"Not Allowed", nil)), kDocumentInfoValue, nil]];
    
    
    [mArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Filling of Form Field:",kDocumentInfoTitle nil),kDocumentInfoTitle, ((self.pdfView.document.allowsFormFieldEntry == YES) ? NSLocalizedString(@"Allowed", nil) : NSLocalizedString(@"Not Allowed", nil)), kDocumentInfoValue, nil]];

    [tableArray addObject:mArray];
    
    self.curTableArray = tableArray;
}

#pragma mark - tableview delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.curTableArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    switch (section)
    {
        case 0:
        {
            title = NSLocalizedString(@"Abstract:", nil);
            break;
        }
        case 1:
        {
            title = NSLocalizedString(@"Create Information:", nil);
            break;
        }
        case 2:
        {
            title = NSLocalizedString(@"Access Permissions:", nil);
            break;
        }
    }
    return title;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
   
    UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, tableView.bounds.size.width, 20)];
    
    NSString *title;
    switch (section)
    {
        case 0:
        {
            title = NSLocalizedString(@"Abstract:", nil);
            break;
        }
        case 1:
        {
            title = NSLocalizedString(@"Create Information:", nil);
            break;
        }
        case 2:
        {
            title = NSLocalizedString(@"Access Permissions:", nil);
            break;
        }
    }
    
    
    title = [NSString stringWithFormat:@"    %@",title];
    headerLabel.text = title;
    headerLabel.font = [UIFont boldSystemFontOfSize:22];
//    headerLabel.textColor = [UIColor blackColor];

    return headerLabel;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray* array = [self.curTableArray objectAtIndex:section];
    return [array count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CPDFInfoTableCell *cell = (CPDFInfoTableCell*)[tableView  dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil)
    {
        cell = [[CPDFInfoTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MyIdentifier"];
    }
    NSMutableArray* array = [self.curTableArray objectAtIndex:indexPath.section];
    cell.dataDictionary =  [array objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


@end
