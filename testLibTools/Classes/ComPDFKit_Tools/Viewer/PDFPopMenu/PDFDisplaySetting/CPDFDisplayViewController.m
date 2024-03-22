//
//  CPDFDisplayViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFDisplayViewController.h"

#import <ComPDFKit/ComPDFKit.h>

#import "CPDFDisplayTableViewCell.h"
#import "CActivityIndicatorView.h"
#import "CPDFColorUtils.h"

typedef NS_ENUM(NSUInteger, CDisplayPDFType) {
    CDisplayPDFTypeSinglePage = 0,
    CDisplayPDFTypeTwoPages,
    CDisplayPDFTypeBookMode,
    CDisplayPDFTypeContinuousScroll,
    CDisplayPDFTypeCropMode,
    CDisplayPDFTypeVerticalScrolling,
    CDisplayPDFTypeHorizontalScrolling,
    CDisplayPDFTypeThemesLight,
    CDisplayPDFTypeThemesDark,
    CDisplayPDFTypeThemesSepia,
    CDisplayPDFTypeThemesReseda
};

#pragma mark - CPDFDisplayModel

@interface CPDFDisplayModel : NSObject

@property(nonatomic, strong) UIImage *image;

@property(nonatomic, strong) NSString *titilName;

@property(nonatomic, assign) CDisplayPDFType tag;

- (instancetype)initWithType:(CDisplayPDFType)displayType;

@end

@implementation CPDFDisplayModel

- (instancetype)initWithType:(CDisplayPDFType)displayType {
    if(self = [super init]) {
        switch (displayType) {
            case CDisplayPDFTypeSinglePage:
                self.image = [UIImage imageNamed:@"CDisplayImageNameSinglePage"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                
                self.titilName = NSLocalizedString(@"Single Page", nil);
                break;
            case CDisplayPDFTypeTwoPages:
                self.image = [UIImage imageNamed:@"CDisplayImageNameTwoPages"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Double Page", nil);
                break;
                
            case CDisplayPDFTypeBookMode:
                self.image = [UIImage imageNamed:@"CDisplayImageNameBookMode"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Book Mode", nil);

                break;
            case CDisplayPDFTypeContinuousScroll:
                self.image = [UIImage imageNamed:@"CDisplayImageNameContinuousScroll"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Continuous Scrolling", nil);
                break;
            case CDisplayPDFTypeCropMode:
                self.image = [UIImage imageNamed:@"CDisplayImageNameCropMode"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Crop", nil);
                break;
            case CDisplayPDFTypeVerticalScrolling:
                self.image = [UIImage imageNamed:@"CDisplayImageNameVerticalScrolling"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Vertical Scrolling", nil);
                break;
                
            case CDisplayPDFTypeHorizontalScrolling:
                self.image = [UIImage imageNamed:@"CDisplayImageNameHorizontalScrolling"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Horizontal Scrolling", nil);
                break;
            case CDisplayPDFTypeThemesLight:
                self.image = [UIImage imageNamed:@"CDisplayImageNameThemesLight"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Light", nil);
                break;
            case CDisplayPDFTypeThemesDark:
                self.image = [UIImage imageNamed:@"CDisplayImageNameThemesDark"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Dark", nil);
                break;
            case CDisplayPDFTypeThemesSepia:
                self.image = [UIImage imageNamed:@"CDisplayImageNameThemesSepia"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Sepia", nil);
                break;
            default:
            case CDisplayPDFTypeThemesReseda:
                self.image = [UIImage imageNamed:@"CDisplayImageNameThemesReseda"
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
                self.titilName = NSLocalizedString(@"Reseda", nil);
                break;
        }
        self.tag = displayType;
    }
    return self;
}

@end

#pragma mark - CPDFDisplayViewController

@interface CPDFDisplayViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) NSArray* displayModeArray;

@property (nonatomic, strong) NSArray* themesArray;

@property (nonatomic, strong) CPDFView * pdfview;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *doneBtn;

@end

@implementation CPDFDisplayViewController

#pragma mark - Initializers

- (instancetype)initWithPDFView:(CPDFView *)pdfview {
    if(self = [super init]) {
        self.pdfview = pdfview;
        [self updateDisplayView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.doneBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.doneBtn setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.doneBtn];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text =  NSLocalizedString(@"View Setting", nil);
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
}

- (void)buttonItemClicked_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

- (void)viewWillLayoutSubviews {
    self.doneBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
    self.tableView.frame = CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height - 50);
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

#pragma mark - Accessors

- (NSArray *)displayModeArray {
    if(!_displayModeArray) {
        _displayModeArray = @[
                             @(CDisplayPDFTypeVerticalScrolling),
                             @(CDisplayPDFTypeHorizontalScrolling),
                              @(CDisplayPDFTypeSinglePage),
                              @(CDisplayPDFTypeTwoPages),
                              @(CDisplayPDFTypeBookMode),
                              @(CDisplayPDFTypeContinuousScroll),
                              @(CDisplayPDFTypeCropMode)];
    }
    return _displayModeArray;
}

- (NSArray *)themesArray {
    if(!_themesArray) {
        _themesArray = @[@(CDisplayPDFTypeThemesLight),
                         @(CDisplayPDFTypeThemesDark),
                         @(CDisplayPDFTypeThemesSepia),
                         @(CDisplayPDFTypeThemesReseda)];
    }
    return _themesArray;
}

- (BOOL)isSinglePage {
    if(!self.pdfview.displayTwoUp)
        return YES;
    
    return NO;
}

- (void)setIsSinglePage:(BOOL)isSinglePage {
    self.pdfview.displayTwoUp = NO;
    self.pdfview.displaysAsBook = NO;
    [self.pdfview layoutDocumentView];
}

- (BOOL)isTwoPage {
    if(self.pdfview.displayTwoUp && !self.pdfview.displaysAsBook)
        return YES;
    
    return NO;
}

- (void)setIsTwoPage:(BOOL)isTwoPage {
    self.pdfview.displayTwoUp = YES;
    self.pdfview.displaysAsBook = NO;
    [self.pdfview layoutDocumentView];
}

- (BOOL)isBookMode {
    if(self.pdfview.displayTwoUp && self.pdfview.displaysAsBook)
        return YES;
    return NO;
}

- (void)setIsBookMode:(BOOL)isBookMode {
    self.pdfview.displayTwoUp = YES;
    self.pdfview.displaysAsBook = YES;
    [self.pdfview layoutDocumentView];
}

#pragma mark - Public method

- (void)updateDisplayView {
    [self.tableView reloadData];
}

#pragma mark - Private method

- (void)changePDFViewCropMode:(BOOL)isCropMode {
    [self.navigationController.view setUserInteractionEnabled:YES];
    CActivityIndicatorView *loadingView = [[CActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingView.center = self.view.center;
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    if (![loadingView superview]) {
        [self.view addSubview:loadingView];
    }
    [loadingView startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.pdfview.displayCrop = isCropMode;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pdfview layoutDocumentView];
            
            [loadingView stopAnimating];
            [loadingView removeFromSuperview];
            [self.navigationController.view setUserInteractionEnabled:NO];

            if([self.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [self.delegate displayViewControllerDismiss:self];
        });
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 2;
    }else if(section == 1){
        return 3;
    }else if(section == 2){
        return 2;
    }else{
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CPDFDisplayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[CPDFDisplayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    CPDFDisplayModel *model = nil;

    if(indexPath.section == 0){
        model = [[CPDFDisplayModel alloc]initWithType:[[self.displayModeArray objectAtIndex:indexPath.row] integerValue]];
    }else if(indexPath.section == 1){
        model = [[CPDFDisplayModel alloc]initWithType:[[self.displayModeArray objectAtIndex:indexPath.row + 2] integerValue]];
    }else if(indexPath.section == 2){
        model = [[CPDFDisplayModel alloc]initWithType:[[self.displayModeArray objectAtIndex:indexPath.row + 5] integerValue]];
    }else{
        model = [[CPDFDisplayModel alloc]initWithType:[[self.themesArray objectAtIndex:indexPath.row] integerValue]];
    }
        
    switch (model.tag) {
        case CDisplayPDFTypeSinglePage:
            cell.modeSwitch.hidden = YES;
            cell.checkImageView.hidden = YES;
            if([self isSinglePage])
                cell.checkImageView.hidden = NO;
            break;
        case CDisplayPDFTypeTwoPages:
            cell.modeSwitch.hidden = YES;
            cell.checkImageView.hidden = YES;
            if([self isTwoPage])
                cell.checkImageView.hidden = NO;
            break;
        case CDisplayPDFTypeBookMode:
            cell.modeSwitch.hidden = YES;
            cell.checkImageView.hidden = YES;
            if([self isBookMode])
                cell.checkImageView.hidden = NO;
            break;
        case CDisplayPDFTypeContinuousScroll:
            cell.modeSwitch.hidden = NO;
            cell.checkImageView.hidden = YES;
            if(self.pdfview.displaysPageBreaks)
               [cell.modeSwitch setOn:YES animated:NO];
            else
                [cell.modeSwitch setOn:NO animated:NO];
            break;
        case CDisplayPDFTypeCropMode:
            cell.checkImageView.hidden = YES;
            cell.modeSwitch.hidden = NO;
            if(self.pdfview.displayCrop)
               [cell.modeSwitch setOn:YES animated:NO];
            else
                [cell.modeSwitch setOn:NO animated:NO];
            break;
        case CDisplayPDFTypeVerticalScrolling:
            cell.modeSwitch.hidden = YES;
            cell.checkImageView.hidden = NO;
            if(CPDFDisplayDirectionVertical == self.pdfview.displayDirection)
                cell.checkImageView.hidden = NO;
            else
                cell.checkImageView.hidden = YES;
            break;
            
        case CDisplayPDFTypeHorizontalScrolling:
            cell.modeSwitch.hidden = YES;
            cell.checkImageView.hidden = NO;
            if(CPDFDisplayDirectionHorizontal == self.pdfview.displayDirection)
                cell.checkImageView.hidden = NO;
            else
                cell.checkImageView.hidden = YES;
            break;
        case CDisplayPDFTypeThemesLight:
            cell.modeSwitch.hidden = YES;
            cell.checkImageView.hidden = YES;
            if(CPDFDisplayModeNormal == self.pdfview.displayMode)
                cell.checkImageView.hidden = NO;
            break;
        case CDisplayPDFTypeThemesDark:
            cell.modeSwitch.hidden = YES;
            cell.checkImageView.hidden = YES;
            if(CPDFDisplayModeNight == self.pdfview.displayMode)
                cell.checkImageView.hidden = NO;
            break;
        case CDisplayPDFTypeThemesSepia:
            cell.modeSwitch.hidden = YES;
            cell.checkImageView.hidden = YES;
            if(CPDFDisplayModeSoft == self.pdfview.displayMode)
                cell.checkImageView.hidden = NO;
            break;
        case CDisplayPDFTypeThemesReseda:
            cell.modeSwitch.hidden = YES;
            cell.checkImageView.hidden = YES;
            if(CPDFDisplayModeGreen == self.pdfview.displayMode)
                cell.checkImageView.hidden = NO;
            break;
        default:
            cell.checkImageView.hidden = YES;
            cell.modeSwitch.hidden = YES;
            break;
    }
    
    cell.iconImageView.image = model.image;
    cell.titleLabel.text = model.titilName?:@"";
    __block typeof(self) blockSelf = self;
    __block CPDFDisplayTableViewCell * blockCell = cell;

    cell.switchBlock = ^{
        if (CDisplayPDFTypeContinuousScroll == model.tag) {
            BOOL isDisplaysPageBreaks = blockCell.modeSwitch.isOn;
            blockSelf.pdfview.displaysPageBreaks = isDisplaysPageBreaks;
            [blockSelf.pdfview layoutDocumentView];
            
            if([blockSelf.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [blockSelf.delegate displayViewControllerDismiss:blockSelf];
        } else if (CDisplayPDFTypeCropMode == model.tag) {
            BOOL isCropMode = blockCell.modeSwitch.on;
            [blockSelf changePDFViewCropMode:isCropMode];
        } else if (CDisplayPDFTypeVerticalScrolling == model.tag) {
            if(blockCell.modeSwitch.on) {
                blockSelf.pdfview.displayDirection = CPDFDisplayDirectionVertical;
            } else {
                blockSelf.pdfview.displayDirection = CPDFDisplayDirectionHorizontal;
            }
            [blockSelf.pdfview layoutDocumentView];
            
            if([blockSelf.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [blockSelf.delegate displayViewControllerDismiss:blockSelf];
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    if(section == 0){
        return NSLocalizedString(@"Display Mode",nil);
    }else if(section == 1){
        return @"";
    }else if(section == 2){
        return @"";
    }else{
        return NSLocalizedString(@"Themes",nil);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 1 || section == 2){
        return 10;
    }else{
        return 30.0;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CDisplayPDFType type = CDisplayPDFTypeCropMode;
    NSInteger index = self.pdfview.currentPageIndex;

    if(indexPath.section == 0){
        type = (CDisplayPDFType)[[self.displayModeArray objectAtIndex:indexPath.row] integerValue];
    }else if(indexPath.section == 1) {
        type = (CDisplayPDFType)[[self.displayModeArray objectAtIndex:indexPath.row + 2] integerValue];
    }else if(indexPath.section == 2) {
        type = (CDisplayPDFType)[[self.displayModeArray objectAtIndex:indexPath.row + 5] integerValue];
    }else {
        type = (CDisplayPDFType)[[self.themesArray objectAtIndex:indexPath.row] integerValue];
    }
        
    switch (type) {
        case CDisplayPDFTypeSinglePage:
            [self setIsSinglePage:YES];
            
            [self.tableView reloadData];
            
            if([self.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [self.delegate displayViewControllerDismiss:self];
            break;
        case CDisplayPDFTypeTwoPages:
            [self setIsTwoPage:YES];
            
            [self.tableView reloadData];

            if([self.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [self.delegate displayViewControllerDismiss:self];
            break;
        case CDisplayPDFTypeBookMode:
            [self setIsBookMode:YES];
            
            [self.tableView reloadData];

            if([self.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [self.delegate displayViewControllerDismiss:self];
            break;
        case CDisplayPDFTypeThemesLight:
            self.pdfview.displayMode = CPDFDisplayModeNormal;
            [self.pdfview layoutDocumentView];
            
            [self.tableView reloadData];

            if([self.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [self.delegate displayViewControllerDismiss:self];
            break;
        case CDisplayPDFTypeThemesDark:
            self.pdfview.displayMode = CPDFDisplayModeNight;
            [self.pdfview layoutDocumentView];
            
            [self.tableView reloadData];

            if([self.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [self.delegate displayViewControllerDismiss:self];
            break;
        case CDisplayPDFTypeThemesSepia:
            self.pdfview.displayMode = CPDFDisplayModeSoft;
            [self.pdfview layoutDocumentView];
            
            [self.tableView reloadData];

            if([self.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [self.delegate displayViewControllerDismiss:self];
            break;
        case CDisplayPDFTypeThemesReseda:
            self.pdfview.displayMode = CPDFDisplayModeGreen;
            [self.pdfview layoutDocumentView];
            
            [self.tableView reloadData];

            if([self.delegate respondsToSelector:@selector(displayViewControllerDismiss:)])
               [self.delegate displayViewControllerDismiss:self];
            break;
        case CDisplayPDFTypeHorizontalScrolling:
            self.pdfview.displayDirection = CPDFDisplayDirectionHorizontal;
            [self.pdfview layoutDocumentView];
            [self.tableView reloadData];
            break;
        case CDisplayPDFTypeVerticalScrolling:
            self.pdfview.displayDirection = CPDFDisplayDirectionVertical;
            [self.pdfview layoutDocumentView];
            [self.tableView reloadData];
            break;
        default:
            break;
    }
    [self.pdfview goToPageIndex:index animated:NO];
}

@end
