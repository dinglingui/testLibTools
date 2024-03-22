//
//  CPDFEditViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//


#import "CPDFEditViewController.h"
#import "CPDFImagePropertyCell.h"
#import "CPDFTextPropertyCell.h"
#import "CPDFColorPickerView.h"
#import "CPDFEditFontNameSelectView.h"
#import <ComPDFKit/ComPDFKit.h>
#import "CPDFColorUtils.h"
#import "CPDFEditTextSampleView.h"
#import "CPDFEditImageSampleView.h"
#import "CPDFTextProperty.h"

@interface CPDFEditViewController ()<UITableViewDelegate,UITableViewDataSource,CPDFColorPickerViewDelegate,CPDFEditFontNameSelectViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIColorPickerViewControllerDelegate>

@property (nonatomic, strong) UIView      * splitView;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) CPDFColorPickerView * colorPickerView;
@property (nonatomic, strong) CPDFEditFontNameSelectView * fontSelectView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) CPDFEditTextSampleView * textSampleView;
@property (nonatomic, strong) CPDFEditImageSampleView * imageSampleView;

@end

@implementation CPDFEditViewController

#pragma mark - Initializers

- (instancetype)initWithPDFView:(CPDFView *)pdfView {
    if (self = [super init]) {
        _pdfView = pdfView;
    }
    return self;
}


#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat  topPadding = 0;
    CGFloat bottomPadding = 0;
    CGFloat leftPadding = 0;
    CGFloat rightPadding = 0;
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        topPadding = window.safeAreaInsets.top;
        bottomPadding = window.safeAreaInsets.bottom;
        leftPadding = window.safeAreaInsets.left;
        rightPadding = window.safeAreaInsets.right;
    }
    
    self.view.frame = CGRectMake(leftPadding, [UIScreen mainScreen].bounds.size.height - bottomPadding , [UIScreen mainScreen].bounds.size.width - leftPadding - rightPadding,self.view.frame.size.height);
    // Do any additional setup after loading the view.
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    if(self.editMode == CPDFEditModeText){
        self.titleLabel.text =  NSLocalizedString(@"Text Properties", nil);
    }else{
        self.titleLabel.text =  NSLocalizedString(@"Image Properties", nil);
    }
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:self.titleLabel];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFEditClose" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    
    self.splitView  = [[UIView alloc] init];
    self.splitView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    [self.view addSubview:self.splitView];
    
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    
    self.tableView  = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    } else {
        // Fallback on earlier versions
    }
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    
    self.tableView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
}

- (void)viewWillLayoutSubviews {
    
    if (@available(iOS 11.0, *)) {
        
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
        self.splitView.frame = CGRectMake(self.view.safeAreaInsets.left, 51, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, 1);
        self.tableView.frame = CGRectMake(self.view.safeAreaInsets.left, 52, self.view.frame.size.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right, self.view.frame.size.height - 52);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
        
    } else {
        self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
        self.splitView.frame = CGRectMake(0, 51, self.view.frame.size.width, 1);
        self.tableView.frame = CGRectMake(0, 52, self.view.frame.size.width, self.view.frame.size.height - 52);
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
    }

}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection
{
    if(self.editMode == CPDFEditModeText){
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 300 : 600);
    }else{
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 300 : 600);
    }

}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.editMode == CPDFEditModeText){
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width-40, 120)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        
        self.textSampleView = [[CPDFEditTextSampleView alloc] init];
        self.textSampleView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.textSampleView.layer.borderWidth = 1.0;
        self.textSampleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.textSampleView.frame  = CGRectMake((self.view.frame.size.width - 300)/2, 15, 300, view.bounds.size.height - 30);
        CPDFEditArea *editArea = self.pdfView.editingArea;
        if(editArea) {
            if ([editArea IsTextArea]) {
                CPDFEditTextArea *editTextArea = (CPDFEditTextArea *)editArea;
                self.textSampleView.textAlignmnet = [self.pdfView editingSelectionAlignmentWithTextArea:editTextArea];
                self.textSampleView.textColor = [self.pdfView editingSelectionFontColorWithTextArea:editTextArea];
                self.textSampleView.textOpacity = [self.pdfView getCurrentOpacity];
                self.textSampleView.fontName = [self.pdfView editingSelectionFontNameWithTextArea:editTextArea];
                self.textSampleView.isBold = [self.pdfView isBoldCurrentSelectionWithTextArea:editTextArea];;
                self.textSampleView.isItalic = [self.pdfView isItalicCurrentSelectionWithTextArea:editTextArea];
                self.textSampleView.fontSize = [self.pdfView editingSelectionFontSizesWithTextArea:editTextArea];
            }
        } else {
            self.textSampleView.textAlignmnet = [CPDFTextProperty sharedManager].textAlignment;
            self.textSampleView.textColor = [CPDFTextProperty sharedManager].fontColor;
            self.textSampleView.textOpacity = [CPDFTextProperty sharedManager].textOpacity;
            self.textSampleView.fontName = [CPDFTextProperty sharedManager].fontName;
            self.textSampleView.isBold = [CPDFTextProperty sharedManager].isBold;
            self.textSampleView.isItalic = [CPDFTextProperty sharedManager].isItalic;
            self.textSampleView.fontSize = [CPDFTextProperty sharedManager].fontSize;
        }
                
        [view addSubview:self.textSampleView];
        
        return view;
    } else {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width-40, 120)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderWidth = 1.0;
        view.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        
        self.imageSampleView = [[CPDFEditImageSampleView alloc] init];
        self.imageSampleView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.imageSampleView.layer.borderWidth = 1.0;
        self.imageSampleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.imageSampleView.frame  = CGRectMake((self.view.frame.size.width - 300)/2, 15, 300, view.bounds.size.height - 30);
        UIImage *image = nil;
        if(self.pdfView.editingArea.IsImageArea) {
            CPDFEditImageArea *editImageArea = (CPDFEditImageArea *)self.pdfView.editingArea;
            image = [editImageArea thumbnailImageWithSize:editImageArea.bounds.size];
        }
        
        if(image) {
            self.imageSampleView.imageView.image = image;
        } else {
            if ([self.pdfView getRotationEditArea:(CPDFEditImageArea *)self.pdfView.editingArea] > 0) {
                if ([self.pdfView getRotationEditArea:(CPDFEditImageArea *)self.pdfView.editingArea] > 90) {
                    self.imageSampleView.imageView.transform = CGAffineTransformRotate(self.imageSampleView.imageView.transform, M_PI);
                } else {
                    self.imageSampleView.imageView.transform = CGAffineTransformRotate(self.imageSampleView.imageView.transform, M_PI/2);
                }
            } else if (([self.pdfView getRotationEditArea:(CPDFEditImageArea *)self.pdfView.editingArea] < 0)) {
                self.imageSampleView.imageView.transform = CGAffineTransformRotate(self.imageSampleView.imageView.transform, -M_PI/2);
            }
    //        self.imageSampleView.transFormType = 0;
            self.imageSampleView.imageView.alpha = [self.pdfView getCurrentOpacity];
        }
        
        [view addSubview:self.imageSampleView];
        
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.editMode == CPDFEditModeText){
        return 120;
    }else{
        return 120;
    }

}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.editMode == CPDFEditModeText){
        CPDFTextPropertyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Textcell"];
        if (!cell) {
            cell = [[CPDFTextPropertyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Textcell"];
        }
        cell.backgroundColor = [UIColor colorWithRed:250./255 green:252/255. blue:255/255. alpha:1.];
        
        if(self.fontSelectView.fontName.length > 0){
            cell.currentSelectFontName = self.fontSelectView.fontName;
        }else{
            if(self.pdfView.editingArea) {
                cell.currentSelectFontName  = [self.pdfView editingSelectionFontNameWithTextArea:self.pdfView.editingArea];
            } else {
                cell.currentSelectFontName = [CPDFTextProperty sharedManager].fontName;
            }
        }
        
        cell.pdfView = self.pdfView;
        __block __typeof(self) blockSelf = self;

        cell.actionBlock = ^(CPDFTextActionType actionType) {
            if(actionType == CPDFTextActionColorSelect){
                //Add colorSelectView
                
                if (@available(iOS 14.0, *)) {
                    UIColorPickerViewController *picker = [[UIColorPickerViewController alloc] init];
                    picker.delegate = blockSelf;
                    [blockSelf presentViewController:picker animated:YES completion:nil];
                } else {
                    blockSelf.colorPickerView = [[CPDFColorPickerView alloc] initWithFrame:self.view.frame];
                    blockSelf.colorPickerView.delegate = blockSelf;
                    blockSelf.colorPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    blockSelf.colorPickerView.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
                    [blockSelf.view addSubview:blockSelf.colorPickerView];
                }
                
            }else if(actionType == CPDFTextActionFontNameSelect) {
                //Add actionFontNameSelect
                blockSelf.fontSelectView = [[CPDFEditFontNameSelectView alloc] initWithFrame:blockSelf.view.bounds];
                blockSelf.fontSelectView.fontNameArr = [NSMutableArray arrayWithArray:[blockSelf.pdfView getFontList]];
                blockSelf.fontSelectView.fontName = blockSelf.textSampleView.fontName;
                blockSelf.fontSelectView.delegate = blockSelf;
                blockSelf.fontSelectView.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
                
                [blockSelf.view addSubview:blockSelf.fontSelectView];
            }
        };
        
        cell.colorBlock = ^(UIColor * _Nonnull selectColor) {
            blockSelf.textSampleView.textColor = selectColor;
            if (blockSelf.pdfView.editingArea) {
                [blockSelf.pdfView setEditingSelectionFontColor:selectColor withTextArea:blockSelf.pdfView.editingArea];
            } else {
                [CPDFTextProperty sharedManager].fontColor = selectColor;
            }
        };
        __block __typeof(CPDFTextPropertyCell *) blockCell = cell;
        cell.boldBlock = ^(BOOL isBold) {
            blockSelf.textSampleView.isBold = isBold;
            CPDFEditArea *editingArea = blockSelf.pdfView.editingArea;

            if (editingArea.IsTextArea) {
                BOOL result = [blockSelf.pdfView setCurrentSelectionIsBold:isBold withTextArea:(CPDFEditTextArea *)editingArea];
                blockCell.boldBtn.selected = [blockSelf.pdfView isBoldCurrentSelectionWithTextArea:(CPDFEditTextArea *)editingArea];
                if(!result) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ComPDFKit cannot change this font style because not all styles are available for this font.",nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    
                    [alert addAction:okAction];
                    
                    [blockSelf presentViewController:alert animated:YES completion:nil];
                }
            } else {
                [CPDFTextProperty sharedManager].isBold = isBold;
            }
        };
        
        cell.italicBlock = ^(BOOL isItalic) {
            blockSelf.textSampleView.isItalic = isItalic;
            CPDFEditArea *editingArea = blockSelf.pdfView.editingArea;
            if (editingArea.IsTextArea) {
                BOOL result = [blockSelf.pdfView setCurrentSelectionIsItalic:isItalic withTextArea:(CPDFEditTextArea *)editingArea];
                blockCell.italicBtn.selected = [blockSelf.pdfView isItalicCurrentSelectionWithTextArea:(CPDFEditTextArea *)editingArea];

                if(!result) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ComPDFKit cannot change this font style because not all styles are available for this font.",nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    
                    [alert addAction:okAction];
                    
                    [blockSelf presentViewController:alert animated:YES completion:nil];
                }
            } else {
                [CPDFTextProperty sharedManager].isItalic = isItalic;
            }
        };
        
        cell.alignmentBlock = ^(CPDFTextAlignment alignment) {
            blockSelf.textSampleView.textAlignmnet = alignment;
            if (blockSelf.pdfView.editingArea) {
                [blockSelf.pdfView setCurrentSelectionAlignment:(NSTextAlignment)alignment withTextArea:blockSelf.pdfView.editingArea];
            } else {
                [CPDFTextProperty sharedManager].textAlignment = (NSTextAlignment)alignment;
            }
        };
        
        cell.fontSizeBlock = ^(CGFloat fontSize) {
            blockSelf.textSampleView.fontSize = fontSize * 10;
            if (blockSelf.pdfView.editingArea) {
                [blockSelf.pdfView setEditingSelectionFontSize:fontSize * 10 withTextArea:blockSelf.pdfView.editingArea isAutoSize:YES];
            } else {
                [CPDFTextProperty sharedManager].fontSize = fontSize * 10;
            }
        };
        
        cell.opacityBlock = ^(CGFloat opacity) {
            blockSelf.textSampleView.textOpacity = opacity;
            if (blockSelf.pdfView.editingArea) {
                [blockSelf.pdfView setCharsFontTransparency:opacity withTextArea:blockSelf.pdfView.editingArea];
            } else {
                [CPDFTextProperty sharedManager].textOpacity = opacity;
            }
        };
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        return cell;
    }else{
        CPDFImagePropertyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
        if (!cell) {
            cell = [[CPDFImagePropertyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CPDFImagePropertyCell"];
        }
        cell.backgroundColor = [UIColor colorWithRed:250./255 green:252/255. blue:255/255. alpha:1.];
        cell.pdfView = self.pdfView;
        
        __block typeof(self) blockSelf = self;
        cell.rotateBlock = ^(CPDFImageRotateType rotateType, BOOL isRotated) {
            if(rotateType == CPDFImageRotateTypeLeft){
                [blockSelf.pdfView rotateEditArea:(CPDFEditImageArea*)blockSelf.pdfView.editingArea rotateAngle:-90];
                blockSelf.imageSampleView.imageView.transform = CGAffineTransformRotate(blockSelf.imageSampleView.imageView.transform, -M_PI/2);
                [blockSelf.imageSampleView setNeedsLayout];
            }else if(rotateType == CPDFImageRotateTypeRight){
                [blockSelf.pdfView rotateEditArea:(CPDFEditImageArea*)blockSelf.pdfView.editingArea rotateAngle:90];
                blockSelf.imageSampleView.imageView.transform = CGAffineTransformRotate(blockSelf.imageSampleView.imageView.transform, M_PI/2);
                [blockSelf.imageSampleView setNeedsLayout];
            }
        };
        
        cell.transFormBlock = ^(CPDFImageTransFormType transformType, BOOL isTransformed) {
            if(transformType == CPDFImageTransFormTypeVertical){
                [blockSelf.pdfView verticalMirrorEditArea:(CPDFEditImageArea*)blockSelf.pdfView.editingArea];
                blockSelf.imageSampleView.imageView.transform = CGAffineTransformScale(blockSelf.imageSampleView.imageView.transform, 1.0, -1.0);
                [blockSelf.imageSampleView setNeedsLayout];
            }else if(transformType == CPDFImageTransFormTypeHorizontal){
                [blockSelf.pdfView horizontalMirrorEditArea:(CPDFEditImageArea*)blockSelf.pdfView.editingArea];
                blockSelf.imageSampleView.imageView.transform = CGAffineTransformScale(blockSelf.imageSampleView.imageView.transform, -1.0, 1.0);
                [blockSelf.imageSampleView setNeedsLayout];
            }
        };
        
        cell.transparencyBlock = ^(CGFloat transparency) {
            [blockSelf.pdfView setImageTransparencyEditArea:(CPDFEditImageArea*)blockSelf.pdfView.editingArea transparency:transparency];
            blockSelf.imageSampleView.imageView.alpha = transparency;
            [blockSelf.imageSampleView setNeedsLayout];
        };
        
        cell.replaceImageBlock = ^{
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = blockSelf;
            [self presentViewController:imagePicker animated:YES completion:nil];
        };
        
        cell.cropImageBlock = ^{
            [self.pdfView beginCropEditArea:(CPDFEditImageArea*)self.pdfView.editingArea];
            [self controllerDismiss];
        };
        
        cell.exportImageBlock = ^{
            BOOL saved = [blockSelf.pdfView extractImageWithEditImageArea:blockSelf.pdfView.editingArea];
            if(saved){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Export Successfully!", nil) preferredStyle:UIAlertControllerStyleAlert];

                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK!", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [blockSelf controllerDismiss];
                }]];

                [blockSelf presentViewController:alertController animated:YES completion:nil];
            }else{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Export Failed!", nil) preferredStyle:UIAlertControllerStyleAlert];

                [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK!", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [blockSelf controllerDismiss];
                }]];

                [blockSelf presentViewController:alertController animated:YES completion:nil];
            }
        };
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editMode == CPDFEditModeText){
        return 400;
    }else{
        return 380;
    }
}

#pragma mark - ColorPickerDelegate
- (void)pickerView:(CPDFColorPickerView *)colorPickerView color:(UIColor *)color {
    self.textSampleView.textColor = color;
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    if (self.pdfView.editingArea) {
        [self.pdfView setEditingSelectionFontColor:color withTextArea:self.pdfView.editingArea];
    } else {
        [CPDFTextProperty sharedManager].fontColor = color;
    }
}

#pragma mark - CPDFEditFontNameSelectViewDelegate
- (void)pickerView:(CPDFEditFontNameSelectView *)colorPickerView fontName:(NSString *)fontName{
    self.textSampleView.fontName  = fontName;
    if (self.pdfView.editingArea) {
        [self.pdfView setEditingSelectionFontName:fontName withTextArea:self.pdfView.editingArea];
    } else {
        [CPDFTextProperty sharedManager].fontName = fontName;
    }
    [self.tableView reloadData];
}

#pragma mark - UIColorPickerViewControllerDelegate

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController API_AVAILABLE(ios(14.0)) {
    self.textSampleView.textColor = viewController.selectedColor;
    
    CGFloat red, green, blue, alpha;
    [viewController.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    if (self.pdfView.editingArea) {
        [self.pdfView setEditingSelectionFontColor:viewController.selectedColor withTextArea:self.pdfView.editingArea];
        [self.pdfView setCharsFontTransparency:alpha withTextArea:self.pdfView.editingArea];
    } else {
        [CPDFTextProperty sharedManager].fontColor = viewController.selectedColor;
        [CPDFTextProperty sharedManager].textOpacity = alpha;
    }
    
    self.textSampleView.textOpacity = alpha;
    [self.tableView reloadData];
}

#pragma mark - setMode
- (void)setEditMode:(CPDFEditMode)editMode{
    _editMode = editMode;
    
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

#pragma mark - Action
- (void)buttonItemClicked_back:(UIButton *)button {
    [self controllerDismiss];
}

#pragma mark - Accessors

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    if (@available(iOS 11.0, *)) {
        NSURL * url = info[UIImagePickerControllerImageURL];
        [self.pdfView replaceEditImageArea:(CPDFEditImageArea*)self.pdfView.editingArea imagePath:url.path];

    } else {
        NSURL * url = info[UIImagePickerControllerMediaURL];
        [self.pdfView replaceEditImageArea:(CPDFEditImageArea*)self.pdfView.editingArea imagePath:url.path];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self controllerDismiss];
}

- (void)controllerDismiss {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

@end
