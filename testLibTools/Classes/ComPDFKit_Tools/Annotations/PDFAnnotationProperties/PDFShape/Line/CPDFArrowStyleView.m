//
//  CPDFArrowStyleView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFArrowStyleView.h"
#import "CPDFArrowStyleCell.h"
#import "CPDFDrawArrowView.h"

#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CPDFArrowStyleView () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UICollectionView *collectView;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation CPDFArrowStyleView

#pragma mark - Initializers

- (instancetype)initWirhTitle:(NSString *)title {
    if (self = [super init]) {
        self.headerView = [[UIView alloc] init];
        self.headerView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        self.headerView.layer.borderWidth = 1.0;
        self.headerView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
        [self addSubview:self.headerView];
        
        self.backBtn = [[UIButton alloc] init];
        [self.backBtn setImage:[UIImage imageNamed:@"CPDFAnnotationBarImageUndo" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(buttonItemClicked_back:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:self.backBtn];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = title;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.headerView addSubview:self.titleLabel];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((self.frame.size.width - 5.0* 7)/6, 30);
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 5;
        self.collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        [self.collectView registerClass:[CPDFArrowStyleCell class] forCellWithReuseIdentifier:@"cell"];
        self.collectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.collectView.delegate = self;
        self.collectView.dataSource = self;
        self.collectView.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        [self addSubview:self.collectView];
        
        self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backBtn.frame = CGRectMake(15, 5, 60, 50);
    self.titleLabel.frame = CGRectMake((self.frame.size.width - 150)/2, 5, 150, 50);
    self.headerView.frame = CGRectMake(0, 0, self.bounds.size.width, 50);
}

#pragma mark - Action

- (void)buttonItemClicked_back:(id)sender {
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(arrowStyleRemoveView:)]) {
        [self.delegate arrowStyleRemoveView:self];
    }
}

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.frame.size.width - 5.0* 7)/6, 30);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPDFArrowStyleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (self.selectIndex == indexPath.item) {
        cell.contextView.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    }
    cell.contextView.selectIndex = indexPath.item;
    [cell.contentView setNeedsDisplay];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<UICollectionViewCell *> *cells = [collectionView visibleCells];
    for (UICollectionViewCell *cell in cells) {
        ((CPDFArrowStyleCell *)cell).contextView.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    }
    CPDFArrowStyleCell *cell = (CPDFArrowStyleCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.contextView.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(arrowStyleView:selectIndex:)]) {
        [self.delegate arrowStyleView:self selectIndex:indexPath.item];
    }
}

@end
