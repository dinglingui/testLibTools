//
//  CSignatureTypeSelectView.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CSignatureTypeSelectView.h"
#import "CPDFColorUtils.h"

@interface CSignatureTypeSelectView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *electronicBtn;

@property (nonatomic, strong) UIButton *electronicSubBtn;

@property (nonatomic, strong) UILabel *electronicLabel;

@property (nonatomic, strong) UIButton *digitalBtn;

@property (nonatomic, strong) UIButton *digitalSubBtn;

@property (nonatomic, strong) UILabel *digitalLabel;

@property (nonatomic, strong) UIView *signatureTypeSelectView;

@property (nonatomic, strong) UIButton *signBtn;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIView *splitView;

@property (nonatomic, strong) UIView *centerSplitView;

@property (nonatomic, strong) UIView *modelView;

@property (nonatomic, assign) CSignatureSelectType signatureSelectType;

@end

@implementation CSignatureTypeSelectView

- (instancetype)initWithFrame:(CGRect)frame height:(CGFloat)height {
    if (self = [super initWithFrame:frame]) {
        self.modelView = [[UIView alloc] initWithFrame:frame];
        self.modelView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.modelView];
        
        self.signatureTypeSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, height)];
        [self addSubview:self.signatureTypeSelectView];
        self.signatureTypeSelectView.layer.borderColor = [UIColor grayColor].CGColor;
        self.signatureTypeSelectView.layer.borderWidth = 0.5;
        self.signatureTypeSelectView.layer.cornerRadius = 10;
        self.signatureTypeSelectView.layer.masksToBounds = YES;
        self.signatureTypeSelectView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = NSLocalizedString(@"Select Signature Type", nil);
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.signatureTypeSelectView addSubview:self.titleLabel];
        
        self.electronicBtn = [[UIButton alloc] init];
        [self.electronicBtn setImage:[UIImage imageNamed:@"CDigitalIDOff" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.electronicBtn setImage:[UIImage imageNamed:@"CDigitalIDOn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [self.electronicBtn addTarget:self action:@selector(buttonItemClicked_electronic:) forControlEvents:UIControlEventTouchUpInside];
        self.electronicBtn.selected = YES;
        [self.signatureTypeSelectView addSubview:self.electronicBtn];
        
        self.electronicLabel = [[UILabel alloc] init];
        self.electronicLabel.text = NSLocalizedString(@"Electronic Signatures", nil);
        self.electronicLabel.font = [UIFont systemFontOfSize:14.0];
        [self.signatureTypeSelectView addSubview:self.electronicLabel];
        
        self.digitalBtn = [[UIButton alloc] init];
        [self.digitalBtn setImage:[UIImage imageNamed:@"CDigitalIDOff" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.digitalBtn setImage:[UIImage imageNamed:@"CDigitalIDOn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        [self.signatureTypeSelectView addSubview:self.digitalBtn];
        
        self.digitalLabel = [[UILabel alloc] init];
        self.digitalLabel.text = NSLocalizedString(@"Digital Signature", nil);
        self.digitalLabel.font = [UIFont systemFontOfSize:14.0];
        [self.signatureTypeSelectView addSubview:self.digitalLabel];
        
        self.signBtn = [[UIButton alloc] init];
        [self.signBtn setTitle:NSLocalizedString(@"Sign", nil) forState:UIControlStateNormal];
        [self.signBtn setTitleColor:[CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        self.signBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.signBtn addTarget:self action:@selector(buttonItemClicked_sign:) forControlEvents:UIControlEventTouchUpInside];
        [self.signatureTypeSelectView addSubview:self.signBtn];
        
        self.cancelBtn = [[UIButton alloc] init];
        [self.cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[CPDFColorUtils CPageEditToolbarFontColor] forState:UIControlStateNormal];
        self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.cancelBtn addTarget:self action:@selector(buttonItemClicked_cancel:) forControlEvents:UIControlEventTouchUpInside];
        [self.signatureTypeSelectView addSubview:self.cancelBtn];
        
        self.splitView = [[UIView alloc] init];
        self.splitView.backgroundColor = [UIColor grayColor];
        [self.signatureTypeSelectView addSubview:self.splitView];
        
        self.centerSplitView = [[UIView alloc] init];
        self.centerSplitView.backgroundColor = [UIColor grayColor];
        [self.signatureTypeSelectView addSubview:self.centerSplitView];
        
        self.electronicSubBtn = [[UIButton alloc] init];
        self.electronicSubBtn.backgroundColor = [UIColor clearColor];
        [self.electronicSubBtn addTarget:self action:@selector(buttonItemClicked_electronic:) forControlEvents:UIControlEventTouchUpInside];
        [self.signatureTypeSelectView addSubview:self.electronicSubBtn];
        
        self.digitalSubBtn = [[UIButton alloc] init];
        self.digitalSubBtn.backgroundColor = [UIColor clearColor];
        [self.digitalSubBtn addTarget:self action:@selector(buttonItemClicked_digital:) forControlEvents:UIControlEventTouchUpInside];
        [self.signatureTypeSelectView addSubview:self.digitalSubBtn];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.signatureSelectType = CSignatureSelectTypeElectronic;
        
        [self createGestureRecognizer];
    }
    
    return self;
}

- (void)layoutSubviews {
    self.signatureTypeSelectView.center = self.center;
    self.titleLabel.frame = CGRectMake(10, 5, self.signatureTypeSelectView.bounds.size.width - 20, 44);
    self.electronicBtn.frame = CGRectMake(10, CGRectGetMaxY(self.titleLabel.frame)+10, 30, 30);
    self.electronicLabel.frame = CGRectMake(40, CGRectGetMaxY(self.titleLabel.frame)+10, self.signatureTypeSelectView.bounds.size.width - 50, 30);
    self.digitalBtn.frame = CGRectMake(10, CGRectGetMaxY(self.electronicLabel.frame)+10, 30, 30);
    self.digitalLabel.frame = CGRectMake(40, CGRectGetMaxY(self.electronicLabel.frame)+10, self.signatureTypeSelectView.bounds.size.width - 50, 30);
    
    self.splitView.frame = CGRectMake(0, self.signatureTypeSelectView.bounds.size.height- 44, self.signatureTypeSelectView.bounds.size.width, 0.5);
    self.centerSplitView.frame = CGRectMake(120, self.signatureTypeSelectView.bounds.size.height- 44, 0.5, 44);
    self.signBtn.frame = CGRectMake(120, self.signatureTypeSelectView.bounds.size.height- 44, 120, 44);
    self.cancelBtn.frame = CGRectMake(0, self.signatureTypeSelectView.bounds.size.height - 44, 120, 44);
    
    self.electronicSubBtn.frame = CGRectMake(10, CGRectGetMaxY(self.titleLabel.frame)+10, self.signatureTypeSelectView.bounds.size.width - 20, 30);
    self.digitalSubBtn.frame = CGRectMake(10, CGRectGetMaxY(self.electronicSubBtn.frame)+10, self.signatureTypeSelectView.bounds.size.width - 20, 30);
    self.modelView.frame = self.frame;
}

#pragma mark - Pubilc Methods

- (void)showinView:(UIView *)superView {
    if (superView) {
        [superView addSubview:self];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
}

#pragma mark - Private Methods

- (void)createGestureRecognizer {
    [self.modelView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapModelView:)];
    [self.modelView addGestureRecognizer:tapRecognizer];
}

- (void)tapModelView:(UIPanGestureRecognizer *)gestureRecognizer {
    [self removeFromSuperview];
}

#pragma mark - Action

- (void)buttonItemClicked_electronic:(UIButton *)button {
    self.electronicBtn.selected = YES;
    self.digitalBtn.selected = NO;
    
    self.signatureSelectType = CSignatureSelectTypeElectronic;
}

- (void)buttonItemClicked_digital:(UIButton *)button {
    self.electronicBtn.selected = NO;
    self.digitalBtn.selected = YES;
    
    self.signatureSelectType = CSignatureSelectTypeDigital;
}

- (void)buttonItemClicked_sign:(UIButton *)button {
    [self performSelector:@selector(done) withObject:nil afterDelay:0.1];
    switch (self.signatureSelectType) {
        case CSignatureSelectTypeElectronic:
            if (self.delegate && [self.delegate respondsToSelector:@selector(signatureTypeSelectViewElectronic:)]) {
                [self.delegate signatureTypeSelectViewElectronic:self];
            }
            break;
        case CSignatureSelectTypeDigital:
            if (self.delegate && [self.delegate respondsToSelector:@selector(signatureTypeSelectViewDigital:)]) {
                [self.delegate signatureTypeSelectViewDigital:self];
            }
            break;
            
        default:
            break;
    }
}

- (void)buttonItemClicked_cancel:(UIButton *)button {
    [self removeFromSuperview];
}

- (void)done {
    [self removeFromSuperview];
    [self removeFromSuperview];
}

@end
