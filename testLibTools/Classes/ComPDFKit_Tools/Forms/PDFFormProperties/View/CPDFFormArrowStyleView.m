//
//  CPDFFormArrowStyleView.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormArrowStyleView.h"

@interface CPDFFormArrowStyleView()

@property (nonatomic, strong) UIView * arrowCoverView;
@property (nonatomic, strong) UIImageView * arrowDirectionView;
@property (nonatomic, strong) UIButton * selectButton;

@end

@implementation CPDFFormArrowStyleView


- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.titleLabel = [[UILabel alloc] init];
        [self addSubview:self.titleLabel];
        
        self.arrowCoverView = [[UIView alloc] init];
        self.arrowCoverView.layer.cornerRadius = 1;
        self.arrowCoverView.layer.borderWidth = 1;
        self.arrowCoverView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
        [self addSubview:self.arrowCoverView];
        
        self.arrowImageView = [[UIImageView alloc] init];
        [self.arrowCoverView addSubview:self.arrowImageView];
        
//        CPDFFormCircle
        self.arrowImageView.image = [UIImage imageNamed:@"CPDFFormCircle" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        
        self.arrowDirectionView = [[UIImageView alloc] init];
        [self.arrowCoverView addSubview:self.arrowDirectionView];

        self.arrowDirectionView.image = [UIImage imageNamed:@"CPDFFormEditRight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.selectButton addTarget:self action:@selector(buttonItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.arrowCoverView addSubview:self.selectButton];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(20, 7, 120, 30);
    self.arrowCoverView.frame = CGRectMake(self.frame.size.width - 100, 8, 80, 28);
    self.arrowImageView.frame = CGRectMake(18+10, 4, 20, 20);
    self.arrowDirectionView.frame = CGRectMake(CGRectGetMaxX(self.arrowImageView.frame)+10, 6.5, 15, 15);
    self.selectButton.frame = self.arrowCoverView.bounds;
}

- (void)buttonItemClick:(UIButton*)button {
    if(self.delegate && [self.delegate respondsToSelector:@selector(CPDFFormArrowStyleViewClicked:)]) {
        [self.delegate CPDFFormArrowStyleViewClicked:self];
    }
}


@end
