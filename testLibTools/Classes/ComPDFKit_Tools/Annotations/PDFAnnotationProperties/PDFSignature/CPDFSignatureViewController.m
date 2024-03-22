//
//  CPDFSignatureViewController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSignatureViewController.h"
#import "CAnnotStyle.h"
#import "CPDFSignatureViewCell.h"
#import "CSignatureManager.h"
#import "CPDFSignatureEditViewController.h"
#import "SignatureCustomPresentationController.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif

@interface CPDFSignatureViewController () <UITableViewDelegate, UITableViewDataSource, CPDFSignatureViewCellDelegate,CPDFSignatureEditViewControllerDelegate>

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) CAnnotStyle *annotStyle;

@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) UIButton *createButton;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation CPDFSignatureViewController

#pragma mark - Initializers

- (instancetype)initWithStyle:(CAnnotStyle *)annotStyle {
    if (self = [super init]) {
        self.annotStyle = annotStyle;
    }
    return self;
}

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.headerView = [[UIView alloc] init];
    self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    self.headerView.layer.borderWidth = 1.0;
    self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    [self.view addSubview:self.headerView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.text = NSLocalizedString(@"Signatures", nil);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.headerView addSubview:self.titleLabel];
    
    self.backBtn = [[UIButton alloc] init];
    self.backBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.backBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBaseImageBack" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.backBtn];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height - 70) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.rowHeight = 120;
    [self.view addSubview:self.tableView];
    
    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = NSLocalizedString(@"NO Signature", nil);
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.emptyLabel];
    
    self.createButton = [[UIButton alloc] init];
    self.createButton.layer.cornerRadius = 25.0;
    self.createButton.clipsToBounds = YES;
    [self.createButton setImage:[UIImage imageNamed:@"CPDFSignatureImageAdd" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.createButton addTarget:self action:@selector(buttonItemClicked_create:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createButton];
    
    self.view.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
    [self createGestureRecognizer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, 5, 120, 50);
    self.headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    
    self.emptyLabel.frame = CGRectMake((self.view.frame.size.width - 120)/2, (self.view.frame.size.height - 50)/2, 120, 50);
    
    if (@available(iOS 11.0, *)) {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60 - self.view.safeAreaInsets.right, 5, 50, 50);
        self.createButton.frame = CGRectMake(self.view.frame.size.width - 70 - self.view.safeAreaInsets.right, self.view.frame.size.height - 100 - self.view.safeAreaInsets.bottom, 50, 50);
    } else {
        self.backBtn.frame = CGRectMake(self.view.frame.size.width - 60, 5, 50, 50);
        self.createButton.frame = CGRectMake(self.view.frame.size.width - 70, self.view.frame.size.height - 100, 50, 50);
    }
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

#pragma mark - Private Methods

- (void)createGestureRecognizer {
    [self.createButton setUserInteractionEnabled:YES];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panaddBookmarkBtn:)];
    [self.createButton addGestureRecognizer:panRecognizer];
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

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact ? 350 : 660);
}

#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate && [self.delegate respondsToSelector:@selector(signatureViewControllerDismiss:)]) {
        [self.delegate signatureViewControllerDismiss:self];
    }
}

- (void)buttonItemClicked_create:(id)sender {
    SignatureCustomPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    CPDFSignatureEditViewController *editVC = [[CPDFSignatureEditViewController alloc] init];
    
    editVC.delegate = self;
    
    presentationController = [[SignatureCustomPresentationController alloc] initWithPresentedViewController:editVC presentingViewController:self];
    editVC.transitioningDelegate = presentationController;
    [self presentViewController:editVC animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([CSignatureManager sharedManager].signatures.count <= 0) {
        self.emptyLabel.hidden = NO;
        self.tableView.hidden = YES;
    } else {
        self.emptyLabel.hidden = YES;
        self.tableView.hidden = NO;
    }
    return [CSignatureManager sharedManager].signatures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPDFSignatureViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[CPDFSignatureViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }

    cell.signatureImageView.image = [UIImage imageWithContentsOfFile:[CSignatureManager sharedManager].signatures[indexPath.row]];

    cell.deleteDelegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(signatureViewController:image:)]) {
                UIImage *image = [UIImage imageWithContentsOfFile:[CSignatureManager sharedManager].signatures[indexPath.row]];
                [self.delegate signatureViewController:self image:image];
            }
        }];
    }
}

#pragma mark - CPDFSignatureViewCellDelegate

- (void)signatureViewCell:(CPDFSignatureViewCell *)signatureViewCell {
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                           style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        NSIndexPath *indexSet = [self.tableView indexPathForCell:signatureViewCell];
        [[CSignatureManager sharedManager] removeSignaturesAtIndexe:indexSet.row];
        if ([CSignatureManager sharedManager].signatures.count < 1) {
            [self setEditing:NO animated:YES];
        }
        [self.tableView reloadData];
    }];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", nil)
                                                                   message:NSLocalizedString(@"Are you sure to delete?", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:cancelAction];
    [alert addAction:OKAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CPDFSignatureEditViewControllerDelegate

- (void)signatureEditViewController:(CPDFSignatureEditViewController *)signatureEditViewController image:(UIImage *)image{
    [signatureEditViewController dismissViewControllerAnimated:YES completion:nil];
    [[CSignatureManager sharedManager] addImageSignature:image];
    [self.tableView reloadData];
}

@end
