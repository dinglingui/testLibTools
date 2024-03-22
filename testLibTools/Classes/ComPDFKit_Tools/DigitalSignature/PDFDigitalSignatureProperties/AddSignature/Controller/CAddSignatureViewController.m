//
//  CAddSignatureViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CAddSignatureViewController.h"
#import "CHeaderView.h"
#import "CPDFColorUtils.h"
#import "CAddSignatureCell.h"
#import "CPDFSignatureWidgetAnnotation+PDFListView.h"
#import "CPDFDigitalSignatureEditViewController.h"
#import "CLocationPropertiesViewController.h"
#import "CReasonPropertiesViewController.h"
#import "AAPLCustomPresentationController.h"

#import <ComPDFKit/ComPDFKit.h>

@interface CAddSignatureViewController ()  <CHeaderViewDelegate,CAddSignatureCellDelegate,CLocationPropertiesViewControllerDelegate,CReasonPropertiesViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) CHeaderView *headerView;

@property (nonatomic, strong) UIImageView *preImageView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong)  UIButton *saveBtn;

@property (nonatomic, strong) NSArray *textArray;

@property (nonatomic, strong) NSArray *includeArray;

@property (nonatomic, assign) BOOL isLocation;

@property (nonatomic, assign) BOOL isReason;

@property (nonatomic, assign) BOOL isName;

@property (nonatomic, assign) BOOL isDate;

@property (nonatomic, assign) BOOL isLogo;

@property (nonatomic, assign) BOOL isVersion;

@property (nonatomic, assign) BOOL isDraw;

@property (nonatomic, assign) BOOL isDN;

@property (nonatomic, assign) BOOL isLeftAlignment;

@property (nonatomic, assign) NSString *locationStr;

@property (nonatomic, assign) NSString *reasonStr;

@property (nonatomic, strong) CPDFSignatureConfig *signatureConfig;

@property (nonatomic, strong) CPDFSignatureWidgetAnnotation *annotation;

@end

@implementation CAddSignatureViewController

#pragma mark - Initializers

- (instancetype)initWithAnnotation:(CPDFSignatureWidgetAnnotation *)annotation SignatureConfig:(CPDFSignatureConfig *)signatureConfig {
    if (self = [super init]) {
        self.annotation = annotation;
        self.signatureConfig = signatureConfig;
    }
    return self;
}

#pragma mark - Accessors

- (NSArray *)textArray {
    if (!_textArray) {
        NSArray *dataArray = @[NSLocalizedString(@"Alignment", nil), NSLocalizedString(@"Location", nil), NSLocalizedString(@"Reason", nil)];
        _textArray = dataArray;
    }
    return _textArray;
}

- (NSArray *)includeArray {
    if (!_includeArray) {
        NSArray *dataArray = @[NSLocalizedString(@"Names", nil), NSLocalizedString(@"Date", nil), NSLocalizedString(@"Logo", nil), NSLocalizedString(@"Distinguishable name", nil), NSLocalizedString(@"ComPDFKit Version", nil),NSLocalizedString(@"Tab", nil)];
        _includeArray = dataArray;
    }
    return _includeArray;
}

#pragma mark - Viewcontroller Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.headerView = [[CHeaderView alloc] init];
    self.headerView.titleLabel.text = NSLocalizedString(@"Customize the Signature Appearance", nil);
    [self.headerView.cancelBtn setImage:nil forState:UIControlStateNormal];
    self.headerView.delegate = self;
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.saveBtn = [[UIButton alloc] init];
    [self.saveBtn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor colorWithRed:20.0/255.0 green:96.0/255.0 blue:243.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(buttonItemClicked_save:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
    
    self.preImageView = [[UIImageView alloc] init];
    [self.view addSubview:self.preImageView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 210, self.view.frame.size.width, self.view.frame.size.height-200) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self.view addSubview:self.tableView];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    [self reloadData];
    self.isLocation = NO;
    self.isReason = NO;
    
    self.isName = YES;
    self.isDate = YES;
    self.isLogo = YES;
    self.isDN = NO;
    self.isVersion = NO;
    self.isDraw = YES;
    self.isLeftAlignment = YES;
    
    self.locationStr = nil;
    self.reasonStr = nil;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 55);
    self.preImageView.frame = CGRectMake(20, CGRectGetMaxY(self.headerView.frame)+5, self.view.frame.size.width-40, 150);
    self.saveBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

#pragma mark - Private Methods

- (void)reloadData {
    for (CPDFSignatureConfigItem *item in self.signatureConfig.contents) {
        if ([item.key isEqual:DATE_KEY]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            item.value = [dateFormatter stringFromDate:[NSDate date]];
            break;
        }
    }
    [self.annotation signAppearanceConfig:self.signatureConfig];
    UIImage *originalImage = [self.annotation appearanceImage];
    UIImage *rotatedImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:UIImageOrientationDown];
    UIImage *mirroredImage = [UIImage imageWithCGImage:rotatedImage.CGImage scale:rotatedImage.scale orientation:UIImageOrientationDownMirrored];
    self.preImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.preImageView.image = mirroredImage;
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat mWidth = fmin(width, height);
    CGFloat mHeight = fmax(width, height);
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // This is an iPad
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.8 : mHeight*0.8);
    } else {
        // This is an iPhone or iPod touch
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.9);
    }
}

- (NSArray *)sortContens:(NSArray *)contens {
    NSMutableArray *tContens = [NSMutableArray array];
    
    CPDFSignatureConfigItem *nameItem = nil;
    CPDFSignatureConfigItem *dnItem = nil;
    CPDFSignatureConfigItem *reaItem = nil;
    CPDFSignatureConfigItem *locaItem = nil;
    CPDFSignatureConfigItem *dateItem = nil;
    CPDFSignatureConfigItem *verItem = nil;
    
    for (CPDFSignatureConfigItem *item in contens) {
        if ([item.key isEqual:NAME_KEY]) {
            nameItem = item;
        } else if ([item.key isEqual:DN_KEY]) {
            dnItem = item;
        } else if ([item.key isEqual:REASON_KEY]) {
            reaItem = item;
        } else if ([item.key isEqual:LOCATION_KEY]) {
            locaItem = item;
        } else if ([item.key isEqual:DATE_KEY]) {
            dateItem = item;
        } else if ([item.key isEqual:VERSION_KEY]) {
            verItem = item;
        }
    }
    
    
    
    if (nameItem) {
        [tContens addObject:nameItem];
    }
    if (dateItem) {
        [tContens addObject:dateItem];
    }
    
    if (reaItem) {
        [tContens addObject:reaItem];
    }
    
    if (dnItem) {
        [tContens addObject:dnItem];
    }
    
  
    if (verItem) {
        [tContens addObject:verItem];
    }
    if (locaItem) {
        [tContens addObject:locaItem];
    }
  
    return tContens;
}

- (NSString *)getDNString {
    NSString *result = @"";
    NSString *cn = [self.signatureCertificate.issuerDict objectForKey:@"C"];
    
    result = [result stringByAppendingFormat:@"C= %@", cn];
    
    if ([self.signatureCertificate.issuerDict objectForKey:@"O"]) {
        NSString *o = [self.signatureCertificate.issuerDict objectForKey:@"O"];
        result = [result stringByAppendingFormat:@",O= %@", o];
    }
    
    if ([self.signatureCertificate.issuerDict objectForKey:@"OU"]) {
        NSString *ou = [self.signatureCertificate.issuerDict objectForKey:@"OU"];
        result = [result stringByAppendingFormat:@",OU= %@", ou];
    }
    
    if ([self.signatureCertificate.issuerDict objectForKey:@"CN"]) {
        NSString *ou = [self.signatureCertificate.issuerDict objectForKey:@"CN"];
        result = [result stringByAppendingFormat:@",CN= %@", ou];
    }
    
    return result;
}

#pragma mark - CHeaderViewDelegate

- (void)CHeaderViewBack:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(CAddSignatureViewControllerCancel:)]) {
        [self.delegate CAddSignatureViewControllerCancel:self];
    }
}

- (void)CHeaderViewCancel:(CHeaderView *)headerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action

- (void)buttonItemClicked_save:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(CAddSignatureViewControllerSave:signatureConfig:)]) {
        [self.delegate CAddSignatureViewControllerSave:self signatureConfig:self.signatureConfig];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return self.textArray.count;
        }
            break;
        case 1:
        {
            return self.includeArray.count;
        }
            break;
            
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Text Properties", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Include Text", nil);
    } else {
        return @"";
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CAddSignatureCell *cell = [[CAddSignatureCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"signatureCell"];
    cell.delegate = self;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [cell setCellStyle:CAddSignatureCellAlignment label:self.textArray[indexPath.row]];
                [cell setLeftAlignment:self.isLeftAlignment];
                break;
            case 1:
                [cell setCellStyle:CAddSignatureCellAccess label:self.textArray[indexPath.row]];
                cell.accessSelectLabel.text = self.locationStr ? : @"Close";
                break;
            case 2:
                [cell setCellStyle:CAddSignatureCellAccess label:self.textArray[indexPath.row]];
                cell.accessSelectLabel.text = self.reasonStr ? : @"Close";
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [cell setCellStyle:CAddSignatureCellSelect label:self.includeArray[indexPath.row]];
                cell.textSelectBtn.selected = self.isName;
                break;
            case 1:
                [cell setCellStyle:CAddSignatureCellSelect label:self.includeArray[indexPath.row]];
                cell.textSelectBtn.selected = self.isDate;
                break;
            case 2:
                [cell setCellStyle:CAddSignatureCellSelect label:self.includeArray[indexPath.row]];
                cell.textSelectBtn.selected = self.isLogo;
                break;
            case 3:
                [cell setCellStyle:CAddSignatureCellSelect label:self.includeArray[indexPath.row]];
                cell.textSelectBtn.selected = self.isDN;
                break;
            case 4:
                [cell setCellStyle:CAddSignatureCellSelect label:self.includeArray[indexPath.row]];
                cell.textSelectBtn.selected = self.isVersion;
                break;
            case 5:
                [cell setCellStyle:CAddSignatureCellSelect label:self.includeArray[indexPath.row]];
                cell.textSelectBtn.selected = self.isDraw;
            default:
                break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CAddSignatureCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIButton *btn = cell.accessSelectBtn;
    if(indexPath.section == 0) {
        btn = nil;
    } else {
        btn = cell.textSelectBtn;
    }
    
    if (btn) {
        [self CAddSignatureCell:cell Button:btn];
    }

}

#pragma mark - CAddSignatureCellDelegate

- (void)CAddSignatureCell:(CAddSignatureCell *)addSignatureCell Button:(UIButton *)button {
    if (!self.customType) {
        NSLog(@"CustomType is nil");
        return;
    }
    
    addSignatureCell.textSelectBtn.selected = !addSignatureCell.textSelectBtn.selected;
    
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:1];
    CAddSignatureCell *cell2 = [self.tableView cellForRowAtIndexPath:indexPath2];
    
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:5 inSection:1];
    CAddSignatureCell *cell3 = [self.tableView cellForRowAtIndexPath:indexPath3];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:addSignatureCell];
    NSMutableArray *contents = [NSMutableArray arrayWithArray:self.signatureConfig.contents];
    
    if ((contents.count <= 1) && (self.customType == CSignatureCustomTypeNone)) {
        CPDFSignatureConfigItem *configItem = (CPDFSignatureConfigItem *)contents.firstObject;
        if ([configItem.key isEqualToString:NAME_KEY] && self.signatureConfig.isDrawKey) {
            UIButton *nameBtn = cell2.textSelectBtn;
            
            if (nameBtn.state == UIControlStateNormal) {
                [contents removeAllObjects];
            }
            
            UIButton *tapBtn = cell3.textSelectBtn;
            if (tapBtn.state == UIControlStateNormal) {
                self.signatureConfig.isDrawKey = NO;
            }
        }
    }
    
    CPDFSignatureConfigItem *configItem = nil;
    
    switch (indexPath.row) {
        case 0:
        {
            if (button.selected) {
                configItem = [[CPDFSignatureConfigItem alloc]init];
                configItem.key = NAME_KEY;
                configItem.value = NSLocalizedString([self.signatureCertificate.issuerDict objectForKey:@"CN"], nil);
                [contents addObject:configItem];
            } else {
                for (CPDFSignatureConfigItem *item in contents) {
                    if ([item.key isEqual:NAME_KEY]) {
                        configItem = item;
                        break;
                    }
                }
                if (configItem) {
                    [contents removeObject:configItem];
                }
            }
            self.isName = button.selected;
        }
            break;
        case 1:
        {
            if (button.selected) {
                configItem = [[CPDFSignatureConfigItem alloc]init];
                configItem.key = DATE_KEY;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                configItem.value = [dateFormatter stringFromDate:[NSDate date]];
                [contents addObject:configItem];
            } else {
                for (CPDFSignatureConfigItem *item in contents) {
                    if ([item.key isEqual:DATE_KEY]) {
                        configItem = item;
                        break;
                    }
                }
                if (configItem) {
                    [contents removeObject:configItem];
                }
            }
            self.isDate = button.selected;
        }
            break;
        case 2:
        {
            if (button.selected) {
                self.signatureConfig.isDrawLogo = YES;
            } else {
                self.signatureConfig.isDrawLogo = NO;
            }
            self.isLogo = button.selected;
        }
            break;
        case 3:
        {
            if (button.selected) {
                configItem = [[CPDFSignatureConfigItem alloc]init];
                configItem.key = DN_KEY;
                NSString *dn = [self getDNString];
                configItem.value = NSLocalizedString(dn, nil);
                [contents addObject:configItem];
            } else {
                for (CPDFSignatureConfigItem *item in contents) {
                    if ([item.key isEqual:DN_KEY]) {
                        configItem = item;
                        break;
                    }
                }
                if (configItem) {
                    [contents removeObject:configItem];
                }
            }
            self.isDN = button.selected;
        }
            break;
        case 4:
        {
            if (button.selected) {
                configItem = [[CPDFSignatureConfigItem alloc]init];
                configItem.key = VERSION_KEY;
                NSDictionary*infoDictionary = [[NSBundle mainBundle] infoDictionary];
                
                NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                configItem.value = app_Version;
                [contents addObject:configItem];
            } else {
                for (CPDFSignatureConfigItem *item in contents) {
                    if ([item.key isEqual:VERSION_KEY]) {
                        configItem = item;
                        break;
                    }
                }
                if (configItem) {
                    [contents removeObject:configItem];
                }
            }
            self.isVersion = button.selected;
        }
            break;
        case 5:
        {
            if (button.selected) {
                self.signatureConfig.isDrawKey = YES;
            } else {
                self.signatureConfig.isDrawKey = NO;
            }
            self.isDraw = button.selected;
        }
            break;
            
        default:
            break;
    }
    
    if (self.customType == CSignatureCustomTypeNone && (contents.count == 0)) {
        configItem = [[CPDFSignatureConfigItem alloc]init];
        configItem.key = NAME_KEY;
        configItem.value = NSLocalizedString([self.signatureCertificate.issuerDict objectForKey:@"CN"], nil);
        [contents addObject:configItem];
        
        self.signatureConfig.isDrawKey = YES;
    }
    
    self.signatureConfig.contents = [self sortContens:contents];
    
    [self reloadData];
}

- (void)CAddSignatureCellAccess:(CAddSignatureCell *)addSignatureCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:addSignatureCell];
    
    if (indexPath.row == 1) {
        AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
        CLocationPropertiesViewController *locationPropertiesVC = [[CLocationPropertiesViewController alloc] init];
        locationPropertiesVC.delegate = self;
        locationPropertiesVC.loactionProperties = addSignatureCell.accessSelectLabel.text;
        locationPropertiesVC.isLocation = self.isLocation;
        
        presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:locationPropertiesVC presentingViewController:self];
        locationPropertiesVC.transitioningDelegate = presentationController;
        [self presentViewController:locationPropertiesVC animated:YES completion:nil];
    } else if (indexPath.row == 2) {
        AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
        CReasonPropertiesViewController *reasonPropertiesVC = [[CReasonPropertiesViewController alloc] init];
        reasonPropertiesVC.delegate = self;
        reasonPropertiesVC.resonProperties = addSignatureCell.accessSelectLabel.text;
        reasonPropertiesVC.isReason = self.isReason;
        
        presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:reasonPropertiesVC presentingViewController:self];
        reasonPropertiesVC.transitioningDelegate = presentationController;
        [self presentViewController:reasonPropertiesVC animated:YES completion:nil];
    }
}

- (void)CAddSignatureCell:(CAddSignatureCell *)addSignatureCell Alignment:(BOOL)isLeft {
    self.signatureConfig.isContentAlginLeft = isLeft;
    self.isLeftAlignment = !isLeft;
    [self reloadData];
}

#pragma mark - CLocationPropertiesViewControllerDelegate

- (void)CLocationPropertiesViewController:(CLocationPropertiesViewController *)locationPropertiesViewController properties:(NSString *)properties isLocation:(BOOL)isLocation {
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
    CAddSignatureCell *cell1 = [self.tableView cellForRowAtIndexPath:indexPath1];
    
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:1];
    CAddSignatureCell *cell2 = [self.tableView cellForRowAtIndexPath:indexPath2];
    
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:5 inSection:1];
    CAddSignatureCell *cell3 = [self.tableView cellForRowAtIndexPath:indexPath3];
    
    self.isLocation = isLocation;
    cell1.accessSelectLabel.text = properties;
    self.locationStr = properties;
    
    NSMutableArray *contents = [NSMutableArray arrayWithArray:self.signatureConfig.contents];
    
    if ((contents.count <= 1) && (self.customType == CSignatureCustomTypeNone)) {
        CPDFSignatureConfigItem *configItem = (CPDFSignatureConfigItem *)contents.firstObject;
        if ([configItem.key isEqualToString:NAME_KEY] && self.signatureConfig.isDrawKey) {
            UIButton *nameBtn = cell2.textSelectBtn;
            
            if (nameBtn.state == UIControlStateNormal) {
                [contents removeAllObjects];
            }
            
            UIButton *tapBtn = cell3.textSelectBtn;
            if (tapBtn.state == UIControlStateNormal) {
                self.signatureConfig.isDrawKey = NO;
            }
        }
    }
    CPDFSignatureConfigItem *configItem = nil;
    if (isLocation) {
        configItem = [[CPDFSignatureConfigItem alloc]init];
        configItem.key = LOCATION_KEY;
        if (properties.length > 0)
            configItem.value = properties ?:@"";
        else
            configItem.value = NSLocalizedString(@"<your signing location here>", nil);
        [contents addObject:configItem];
    } else {
        for (CPDFSignatureConfigItem *item in contents) {
            if ([item.key isEqual:LOCATION_KEY]) {
                configItem = item;
                break;
            }
        }
        if (configItem) {
            [contents removeObject:configItem];
        }
        cell1.accessSelectLabel.text = @"Close";
        self.locationStr = nil;
    }
    
    if (self.customType == CSignatureCustomTypeNone && (contents.count == 0)) {
        configItem = [[CPDFSignatureConfigItem alloc]init];
        configItem.key = NAME_KEY;
        configItem.value = NSLocalizedString(@"<your common name here>", nil);
        [contents addObject:configItem];
        
        self.signatureConfig.isDrawKey = YES;
    }
    
    self.signatureConfig.contents = [self sortContens:contents];
    
    [self reloadData];
}

#pragma mark - CReasonPropertiesViewControllerDelegate

- (void)CReasonPropertiesViewController:(CReasonPropertiesViewController *)reasonPropertiesViewController properties:(NSString *)properties isReason:(BOOL)isReason {
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:2 inSection:0];
    CAddSignatureCell *cell1 = [self.tableView cellForRowAtIndexPath:indexPath1];
    
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:1];
    CAddSignatureCell *cell2 = [self.tableView cellForRowAtIndexPath:indexPath2];
    
    NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:5 inSection:1];
    CAddSignatureCell *cell3 = [self.tableView cellForRowAtIndexPath:indexPath3];
    
    cell1.accessSelectLabel.text = properties;
    self.reasonStr = properties;
    self.isReason = isReason;
    NSMutableArray *contents = [NSMutableArray arrayWithArray:self.signatureConfig.contents];
    
    if ((contents.count <= 1) && (self.customType == CSignatureCustomTypeNone)) {
        CPDFSignatureConfigItem *configItem = (CPDFSignatureConfigItem *)contents.firstObject;
        if ([configItem.key isEqualToString:NAME_KEY] && self.signatureConfig.isDrawKey) {
            UIButton *nameBtn = cell2.textSelectBtn;
            
            if (nameBtn.state == UIControlStateNormal) {
                [contents removeAllObjects];
            }
            
            UIButton *tapBtn = cell3.textSelectBtn;
            if (tapBtn.state == UIControlStateNormal) {
                self.signatureConfig.isDrawKey = NO;
            }
        }
    }
    
    CPDFSignatureConfigItem *configItem = nil;
    if (isReason) {
        configItem = [[CPDFSignatureConfigItem alloc]init];
        configItem.key = REASON_KEY;
        configItem.value = properties ? : @"";
        if ([configItem.value isEqualToString:@""] || [configItem.value isEqualToString:[NSString stringWithFormat:@"  %@",NSLocalizedString(@"none", nil)]]) {
            configItem.value = NSLocalizedString(@"<your signing reason here>", nil);
        }
        [contents addObject:configItem];
    } else {
        for (CPDFSignatureConfigItem *item in contents) {
            if ([item.key isEqual:REASON_KEY]) {
                configItem = item;
                break;
            }
        }
        if (configItem) {
            [contents removeObject:configItem];
        }
        cell1.accessSelectLabel.text = @"Close";
        self.reasonStr = nil;
    }
    
    if (self.customType == CSignatureCustomTypeNone && (contents.count == 0)) {
        configItem = [[CPDFSignatureConfigItem alloc]init];
        configItem.key = NAME_KEY;
        configItem.value = NSLocalizedString(@"<your common name here>", nil);
        [contents addObject:configItem];
        
        self.signatureConfig.isDrawKey = YES;
    }
    
    self.signatureConfig.contents = [self sortContens:contents];
    
    [self reloadData];
}

@end
