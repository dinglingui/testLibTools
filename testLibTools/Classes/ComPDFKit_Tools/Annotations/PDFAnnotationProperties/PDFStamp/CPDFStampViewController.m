//
//  CPDFStampViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFStampViewController.h"
#import "CStampFileManger.h"
#import "CStampCollectionViewCell.h"
#import "CPDFColorUtils.h"
#import "CStampButton.h"
#import "CStampTextViewController.h"
#import "CStampTextViewController.h"
#import "CCustomizeStampTableViewCell.h"
#import "CStampPreview.h"

#import <ComPDFKit/ComPDFKit.h>
#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

#define kStamp_Cell_Height 60

PDFAnnotationStampKey const PDFAnnotationStampKeyType = @"PDFAnnotationStampKeyType";
PDFAnnotationStampKey const PDFAnnotationStampKeyImagePath = @"PDFAnnotationStampKeyImagePath";
PDFAnnotationStampKey const PDFAnnotationStampKeyText = @"PDFAnnotationStampKeyText";
PDFAnnotationStampKey const PDFAnnotationStampKeyShowDate = @"PDFAnnotationStampKeyShowDate";
PDFAnnotationStampKey const PDFAnnotationStampKeyShowTime = @"PDFAnnotationStampKeyShowTime";
PDFAnnotationStampKey const PDFAnnotationStampKeyStyle = @"PDFAnnotationStampKeyStyle";
PDFAnnotationStampKey const PDFAnnotationStampKeyShape = @"PDFAnnotationStampKeyShape";

@interface CPDFStampViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, CStampTextViewControllerDelegate, CCustomizeStampTableViewCellDelegate>

@property (nonatomic, strong) UICollectionView *collectView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSArray *standardArray;

@property (nonatomic, strong) NSArray *customTextArray;

@property (nonatomic, strong) NSArray *customImageArray;

@property (nonatomic, strong) NSMutableDictionary *imgDicCache;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *createButton;

@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) UIView *standardView;

@property (nonatomic, strong) UIView *customizeView;

@property (nonatomic, strong) CStampFileManger *stampFileManager;

@property (nonatomic, strong) CStampButton *textButton;

@property (nonatomic, strong) CStampButton *imageButton;

@property (nonatomic, strong) UIView *modelView;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation CPDFStampViewController

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    
    self.headerView = [[UIView alloc] init];
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.titleLabel.text = NSLocalizedString(@"Stamp", nil);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.headerView addSubview:self.titleLabel];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBaseImageBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.backBtn];
    
    NSArray *segmmentArray = [NSArray arrayWithObjects:NSLocalizedString(@"Standard", nil), NSLocalizedString(@"Custom", nil), nil];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmmentArray];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged_singature:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
    
    self.stampFileManager = [[CStampFileManger alloc] init];
    [self.stampFileManager readStampDataFromFile];
    self.customTextArray = [self.stampFileManager getTextStampData];
    self.customImageArray = [self.stampFileManager getImageStampData];
    
    // StandardView
    [self createStandardView];
    
    // CustomizeView
    [self createCustomizeView];
    
    // Data
    NSMutableArray *array = [NSMutableArray array];
    for (int i=1; i<13; i++) {
        NSString *tPicName = nil;
        if (i<10) {
            tPicName = [NSString stringWithFormat:@"CPDFStampImage-0%d.png",i];
        } else {
            tPicName = [NSString stringWithFormat:@"CPDFStampImage-%d.png",i];
        }
        [array addObject:tPicName];
    }
    [array addObjectsFromArray:@[@"CPDFStampImage-13", @"CPDFStampImage-14", @"CPDFStampImage-15", @"CPDFStampImage-16", @"CPDFStampImage-20", @"CPDFStampImage-18", @"CPDFStampImage_chick", @"CPDFStampImage_cross", @"CPDFStampImage_circle"]];
    self.standardArray = array;
    self.imgDicCache = [NSMutableDictionary dictionary];
    
    [self createGestureRecognizer];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 0, 120, 50);
    self.segmentedControl.frame = CGRectMake(50, 55, self.view.frame.size.width-100, 30);
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    self.emptyLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, (self.view.frame.size.height - 50)/2, 120, 50);
    if (@available(iOS 11.0, *)) {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 50);
        self.createButton.frame = CGRectMake(self.view.frame.size.width - 70 - self.view.safeAreaInsets.right, self.view.bounds.size.height - 200 - self.view.safeAreaInsets.bottom, 50, 50);
        self.textButton.frame = CGRectMake(self.view.frame.size.width - 180 - self.view.safeAreaInsets.right, self.view.bounds.size.height - 320 - self.view.safeAreaInsets.bottom, 160, 40);
        self.imageButton.frame = CGRectMake(self.view.frame.size.width - 180 - self.view.safeAreaInsets.right, self.view.bounds.size.height - 270 - self.view.safeAreaInsets.bottom, 160, 40);
    } else {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
        self.createButton.frame = CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 200, 50, 50);
        self.textButton.frame = CGRectMake(self.view.frame.size.width - 180, self.view.frame.size.height - 320, 160, 40);
        self.imageButton.frame = CGRectMake(self.view.frame.size.width - 180, self.view.frame.size.height - 270, 160, 40);
    }
    self.modelView.frame = CGRectMake(0, -200, self.view.bounds.size.width, self.view.bounds.size.height+200);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectView reloadData];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

#pragma mark - Private Methods

- (void)createStandardView {
    self.standardView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height-100)];
    self.standardView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.standardView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.itemSize = CGSizeMake(170,80);
    layout.sectionInset = UIEdgeInsetsMake(5, 20, 5, 20);
    
    self.collectView = [[UICollectionView alloc] initWithFrame:self.standardView.bounds collectionViewLayout:layout];
    self.collectView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.collectView.delegate = self;
    self.collectView.dataSource = self;
    self.collectView.backgroundColor = [UIColor clearColor];
    [self.collectView registerClass:[StampCollectionHeaderView class]
     forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
            withReuseIdentifier:@"header"];
    [self.collectView registerClass:[StampCollectionHeaderView1 class]
     forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
            withReuseIdentifier:@"header1"];
    [self.collectView registerClass:[CStampCollectionViewCell class]
     forCellWithReuseIdentifier:@"TStampViewCell"];
    
    if (@available(iOS 11.0, *)) {
        _collectView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    }
    [self.standardView addSubview:self.collectView];
}

- (void)createCustomizeView {
    self.customizeView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.height-100)];
    self.customizeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.customizeView];
    self.customizeView.hidden = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.customizeView.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 60;
    [self.customizeView addSubview:self.tableView];
    
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = NSLocalizedString(@"NO Custom", nil);
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.customizeView addSubview:self.emptyLabel];
    
    if ((self.customImageArray.count < 1) && (self.customTextArray.count < 1)) {
        self.tableView.hidden = YES;
        self.emptyLabel.hidden = NO;
    } else {
        self.emptyLabel.hidden = YES;
        self.tableView.hidden = NO;
    }
    
    self.modelView = [[UIView alloc] init];
    self.modelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.customizeView addSubview:self.modelView];
    self.modelView.hidden = YES;
    
    self.createButton = [[UIButton alloc] init];
    self.createButton.layer.cornerRadius = 25.0;
    self.createButton.clipsToBounds = YES;
    [self.createButton setImage:[UIImage imageNamed:@"CPDFSignatureImageAdd" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.createButton.backgroundColor = [UIColor blueColor];
    [self.createButton addTarget:self action:@selector(buttonItemClicked_create:) forControlEvents:UIControlEventTouchUpInside];
    [self.customizeView addSubview:self.createButton];
    
    self.textButton = [[CStampButton alloc] init];
    [self.textButton.stampBtn setImage:[UIImage imageNamed:@"CPDFStampImageText" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.textButton.titleLabel.text = NSLocalizedString(@"Text Stamp", nil);
    [self.textButton.stampBtn addTarget:self action:@selector(buttonItemClicked_text:) forControlEvents:UIControlEventTouchUpInside];
    [self.customizeView addSubview:self.textButton];
    self.textButton.hidden = YES;
    
    self.imageButton = [[CStampButton alloc] init];
    [self.imageButton.stampBtn setImage:[UIImage imageNamed:@"CPDFStampImageImage" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.imageButton.titleLabel.text = NSLocalizedString(@"Image Stamp", nil);
    [self.imageButton.stampBtn addTarget:self action:@selector(buttonItemClicked_image:) forControlEvents:UIControlEventTouchUpInside];
    [self.customizeView addSubview:self.imageButton];
    self.imageButton.hidden = YES;
}

- (void)createGestureRecognizer {
    [self.createButton setUserInteractionEnabled:YES];
    [self.modelView setUserInteractionEnabled:YES];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panaddBookmarkBtn:)];
    [self.createButton addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapModelView:)];
    [self.modelView addGestureRecognizer:tapRecognizer];
}

- (void)panaddBookmarkBtn:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer translationInView:self.view];
    CGFloat newX = self.createButton.center.x + point.x;
    CGFloat newY = self.createButton.center.y + point.y;
    if (CGRectContainsPoint(self.view.frame, CGPointMake(newX, newY))) {
        self.createButton.center = CGPointMake(newX, newY);
    }
    [gestureRecognizer setTranslation:CGPointZero inView:self.view];
}

- (void)tapModelView:(UIPanGestureRecognizer *)gestureRecognizer {
    self.textButton.hidden = YES;
    self.modelView.hidden = YES;
    self.imageButton.hidden = YES;
}

- (void)createImageSignature {
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
        imagePickerController.modalPresentationStyle = UIModalPresentationPopover;
        if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
            imagePickerController.popoverPresentationController.sourceView = self.imageButton;
            imagePickerController.popoverPresentationController.sourceRect = self.imageButton.bounds;
        }
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        actionSheet.popoverPresentationController.sourceView = self.imageButton;
        actionSheet.popoverPresentationController.sourceRect = self.imageButton.bounds;
    }
    
    [actionSheet addAction:cameraAction];
    [actionSheet addAction:photoAction];
    [actionSheet addAction:cancelAction];
    actionSheet.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (UIImage *)compressImage:(UIImage *)image {
    CGFloat maxWH = kStamp_Cell_Height;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        maxWH *=[UIScreen mainScreen].scale;
    CGFloat imageScale = 1.0;
    if (image.size.width > maxWH || image.size.height>maxWH)
        imageScale = MIN(maxWH / image.size.width, maxWH / image.size.height);
    CGSize newSize = CGSizeMake(image.size.width * imageScale, image.size.height * imageScale);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image;
    if ([info objectForKey:UIImagePickerControllerEditedImage]) {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
    } else if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    UIImageOrientation imageOrientation = image.imageOrientation;
    if (imageOrientation!=UIImageOrientationUp) {
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    if (imageData == nil || [imageData length] <= 0) {
        return;
    }
    image = [UIImage imageWithData:imageData];
    
    const CGFloat colorMasking[6] = {222, 255, 222, 255, 222, 255};
    CGImageRef imageRef = CGImageCreateWithMaskingColors(image.CGImage, colorMasking);
    if (imageRef) {
        image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    
    NSString *tPath = [self.stampFileManager saveStampWithImage:image];
    if (tPath) {
        NSMutableDictionary *tStampItem = [[NSMutableDictionary alloc] init];
        [tStampItem setObject:tPath forKey:@"path"];
        [self.stampFileManager insertStampItem:tStampItem type:PDFStampCustomType_Image];
        [self.tableView reloadData];
        if ((self.customImageArray.count < 1) && (self.customTextArray.count < 1)) {
            self.emptyLabel.hidden = NO;
            self.tableView.hidden = YES;
        } else {
            self.emptyLabel.hidden = YES;
            self.tableView.hidden = NO;
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Protect Methods

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat mWidth = fmin(width, height);
    CGFloat mHeight = fmax(width, height);
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if (currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // This is an iPad
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.5 : mHeight*0.6);
    } else {
        // This is an iPhone or iPod touch
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? mWidth*0.9 : mHeight*0.9);
    }
}

#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stampViewControllerDismiss:)]) {
        [self.delegate stampViewControllerDismiss:self];
    }
}

- (void)buttonItemClicked_create:(id)sender {
    self.textButton.hidden = !self.textButton.hidden;
    self.modelView.hidden = !self.modelView.hidden;
    self.imageButton.hidden = !self.imageButton.hidden;
}

- (void)segmentedControlValueChanged_singature:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.standardView.hidden = NO;
        self.customizeView.hidden = YES;
    } else {
        self.standardView.hidden = YES;
        self.customizeView.hidden = NO;
    }
}

- (void)buttonItemClicked_text:(id)sender {
    self.textButton.hidden = YES;
    self.modelView.hidden = YES;
    self.imageButton.hidden = YES;
    
    AAPLCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    CStampTextViewController *stampTextVC = [[CStampTextViewController alloc] init];
    stampTextVC.delegate = self;
    presentationController = [[AAPLCustomPresentationController alloc] initWithPresentedViewController:stampTextVC presentingViewController:self];
    stampTextVC.transitioningDelegate = presentationController;
    [self presentViewController:stampTextVC animated:YES completion:nil];
}

- (void)buttonItemClicked_image:(id)sender {
    self.textButton.hidden = YES;
    self.modelView.hidden = YES;
    self.imageButton.hidden = YES;
    [self createImageSignature];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.standardArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CStampCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TStampViewCell" forIndexPath:indexPath];
    cell.editing = NO;
    cell.stampImage.image = [UIImage imageNamed:self.standardArray[indexPath.item] inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(stampViewController:selectedIndex:stamp:)]) {
            [self.delegate stampViewController:self selectedIndex:indexPath.row stamp:[NSDictionary dictionary]];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return self.customTextArray.count;
        }
            break;
        case 1:
        {
            return self.customImageArray.count;
        }
            break;
            
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Text Stamp", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Image Stamp", nil);
    } else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CCustomizeStampTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CCustomizeStampTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    if (self.customTextArray.count>0 || self.customImageArray.count>0) {
        if (0 == indexPath.section) {
            NSDictionary *tDic = _customTextArray[indexPath.item];
            NSString *tText  = [tDic objectForKey:@"text"];
            NSInteger tStyle = [[tDic objectForKey:@"style"] integerValue];
            NSInteger tColorStyle = [[tDic objectForKey:@"colorStyle"] integerValue];
            BOOL tHaveDate   = [[tDic objectForKey:@"haveDate"] boolValue];
            BOOL tHaveTime   = [[tDic objectForKey:@"haveTime"] boolValue];
            
            CStampPreview *tPreview = [[CStampPreview alloc] initWithFrame:CGRectMake(0, 0, 320, kStamp_Cell_Height)];
            [tPreview setTextStampText:tText];
            [tPreview setTextStampColorStyle:tColorStyle];
            [tPreview setTextStampStyle:tStyle];
            [tPreview setTextStampHaveDate:tHaveDate];
            [tPreview setTextStampHaveTime:tHaveTime];
            tPreview.leftMargin = 0;
            UIImage *tImg = [tPreview renderImage];
            cell.customizeStampImageView.image = tImg;
        } else {
            NSDictionary *tDic = self.customImageArray[indexPath.item];
            UIImage *img = [self.imgDicCache objectForKey:tDic];
            if (!img) {
                NSString *tPath   = [tDic objectForKey:@"path"];
                NSString *tFileName = [[NSFileManager defaultManager] displayNameAtPath:tPath];
                NSString *tRealPath = [NSString stringWithFormat:@"%@/%@",kPDFStampDataFolder,tFileName];
                UIImage  *tImg    = [UIImage imageWithContentsOfFile:tRealPath];
                img = [self compressImage:tImg];
                [self.imgDicCache setObject:img forKey:tDic];
            }
            cell.customizeStampImageView.image = img;
        }
    }
    cell.deleteDelegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSDictionary *tDic = _customTextArray[indexPath.item];
        NSString *tText  = [tDic objectForKey:@"text"];
        NSInteger tStyle = [[tDic objectForKey:@"style"] integerValue];
        NSInteger tColorStyle = [[tDic objectForKey:@"colorStyle"] integerValue];
        BOOL tHaveDate   = [[tDic objectForKey:@"haveDate"] boolValue];
        BOOL tHaveTime   = [[tDic objectForKey:@"haveTime"] boolValue];
        NSInteger stampStype = 0;
        NSInteger stampShape = 0;
        
        switch (tColorStyle) {
            case TextStampColorTypeBlack:
            {
                stampStype = 0;
                switch (tStyle) {
                    case TextStampTypeNone:
                    {
                        stampShape = 3;
                    }
                        break;
                    case TextStampTypeRight:
                    {
                        stampShape = 2;
                    }
                        break;
                    case TextStampTypeLeft:
                    {
                        stampShape = 1;
                    }
                        break;
                    case TextStampTypeCenter:
                    {
                        stampShape = 0;
                    }
                        break;
                }
            }
                break;
            case TextStampColorTypeRed:
            {
                stampStype = 1;
                switch (tStyle) {
                    case TextStampTypeNone:
                    {
                        stampShape = 3;
                    }
                        break;
                    case TextStampTypeRight:
                    {
                        stampShape = 2;
                    }
                        break;
                    case TextStampTypeLeft:
                    {
                        stampShape = 1;
                    }
                        break;
                    case TextStampTypeCenter:
                    {
                        stampShape = 0;
                    }
                        break;
                }
            }
                break;
            case TextStampColorTypeGreen:
            {
                stampStype = 2;
                switch (tStyle) {
                    case TextStampTypeNone:
                    {
                        stampShape = 3;
                    }
                        break;
                    case TextStampTypeRight:
                    {
                        stampShape = 2;
                    }
                        break;
                    case TextStampTypeLeft:
                    {
                        stampShape = 1;
                    }
                        break;
                    case TextStampTypeCenter:
                    {
                        stampShape = 0;
                    }
                        break;
                }
            }
                break;
            case TextStampColorTypeBlue:
            {
                stampStype = 3;
                switch (tStyle) {
                    case TextStampTypeNone:
                    {
                        stampShape = 3;
                    }
                        break;
                    case TextStampTypeRight:
                    {
                        stampShape = 2;
                    }
                        break;
                    case TextStampTypeLeft:
                    {
                        stampShape = 1;
                    }
                        break;
                    case TextStampTypeCenter:
                    {
                        stampShape = 0;
                    }
                        break;
                }
            }
                break;
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(stampViewController:selectedIndex:stamp:)]) {
                [self.delegate stampViewController:self selectedIndex:indexPath.row stamp:@{PDFAnnotationStampKeyText : tText,
                                                                                            PDFAnnotationStampKeyShowDate : @(tHaveDate),
                                                                                            PDFAnnotationStampKeyShowTime : @(tHaveTime),
                                                                                            PDFAnnotationStampKeyStyle : @(stampStype),
                                                                                            PDFAnnotationStampKeyShape : @(stampShape)}];
            }
        }];
    } else if (indexPath.section == 1) {
        NSDictionary *tDict = self.customImageArray[indexPath.row];
        NSString *tPath = [tDict objectForKey:@"path"];
        NSString *tFileName = [[NSFileManager defaultManager] displayNameAtPath:tPath];
        NSString *tRealPath = [NSString stringWithFormat:@"%@/%@",kPDFStampDataFolder,tFileName];
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(stampViewController:selectedIndex:stamp:)]) {
                [self.delegate stampViewController:self selectedIndex:indexPath.row stamp:@{PDFAnnotationStampKeyImagePath : tRealPath}];
            }
        }];
    }
}

#pragma mark - CCustomizeStampTableViewCellDelegate

- (void)customizeStampTableViewCell:(CCustomizeStampTableViewCell *)customizeStampTableViewCell {
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        NSIndexPath *select = [self.tableView indexPathForCell:customizeStampTableViewCell];
        if (select.section == 0) {
            [self.stampFileManager removeStampItem:select.row type:PDFStampCustomType_Text];
        } else if (select.section == 1) {
            [self.stampFileManager removeStampItem:select.row type:PDFStampCustomType_Image];
        }
        
        [self.tableView reloadData];
        if ((self.customImageArray.count < 1) && (self.customTextArray.count < 1)) {
            self.emptyLabel.hidden = NO;
            self.tableView.hidden = YES;
        } else {
            self.emptyLabel.hidden = YES;
            self.tableView.hidden = NO;
        }
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil)
                                                                   message:NSLocalizedString(@"Are you sure to delete?", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancelAction];
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CStampTextViewControllerDelegate

- (void)stampTextViewController:(CStampTextViewController *)stampTextViewController dictionary:(NSDictionary *)dictionary {
    [self.stampFileManager insertStampItem:dictionary type:PDFStampCustomType_Text];
    [self.tableView reloadData];
    
    if ((self.customImageArray.count < 1) && (self.customTextArray.count < 1)) {
        self.emptyLabel.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.emptyLabel.hidden = YES;
        self.tableView.hidden = NO;
    }
}

@end
