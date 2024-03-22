//
//  KMPDFPageSelectView.m
//  PDFConnoisseur
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CDigitalTypeSelectView.h"
#import "CPDFColorUtils.h"

@interface CDigitalTypeSelectView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UIButton *certificateSelected;

@property (weak, nonatomic) IBOutlet UIButton *selfSignedSelected;

@property (weak, nonatomic) IBOutlet UILabel *certificateLabel;

@property (weak, nonatomic) IBOutlet UILabel *selfSignedLabel;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIButton *importButton;

@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (nonatomic, assign) CDigitalSelectType digitalSelectType;

@end

@implementation CDigitalTypeSelectView

#pragma mark - Initializers

- (instancetype)init {
    if(self = [[ [NSBundle bundleForClass:CDigitalTypeSelectView.class] loadNibNamed:@"CDigitalTypeSelectView" owner:self options:nil] firstObject]) {
        self.digitalSelectType = CDigitalSelectTypeSelfSigned;
        [self.importButton setTitle:@"" forState:UIControlStateNormal];
        [self.createButton setTitle:@"" forState:UIControlStateNormal];
        
        self.certificateSelected.selected = YES;
        self.selfSignedSelected.selected = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.title.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
    self.certificateLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
    self.selfSignedLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
    self.certificateLabel.adjustsFontSizeToFitWidth = YES;
    self.selfSignedLabel.adjustsFontSizeToFitWidth = YES;
    
    [self.certificateSelected setImage:[UIImage imageNamed:@"CDigitalIDOff" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.certificateSelected setImage:[UIImage imageNamed:@"CDigitalIDOn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    
    [self.selfSignedSelected setImage:[UIImage imageNamed:@"CDigitalIDOff" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.selfSignedSelected setImage:[UIImage imageNamed:@"CDigitalIDOn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    
    self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
    self.contentView.layer.borderWidth = 0.5;
    self.contentView.layer.cornerRadius = 10.0;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [CPDFColorUtils CAnnotationPropertyViewControllerBackgoundColor];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)showinView:(UIView *)superView{
    
    if (superView) {
        [superView addSubview:self];
        [self setNeedsLayout];
        [self layoutIfNeeded];
        [self importClicked:self.importButton];
    }
}

#pragma mark - Action

- (IBAction)doneClicked:(UIButton *)sender {
    [self performSelector:@selector(done) withObject:nil afterDelay:0.3];
    switch (self.digitalSelectType) {
        case CDigitalSelectTypeCertificate:
            if (self.delegate && [self.delegate respondsToSelector:@selector(CDigitalTypeSelectViewUse:)]) {
                [self.delegate CDigitalTypeSelectViewUse:self];
            }
            break;
            
        case CDigitalSelectTypeSelfSigned:
            if (self.delegate && [self.delegate respondsToSelector:@selector(CDigitalTypeSelectViewCreate:)]) {
                [self.delegate CDigitalTypeSelectViewCreate:self];
            }
            break;
        default:
            break;
    }
}

- (IBAction)importClicked:(id)sender {
    self.certificateSelected.selected = YES;
    self.selfSignedSelected.selected = NO;
    
    self.digitalSelectType = CDigitalSelectTypeCertificate;
}

- (IBAction)createClicked:(id)sender {
    self.selfSignedSelected.selected = YES;
    self.certificateSelected.selected = NO;
    
    self.digitalSelectType = CDigitalSelectTypeSelfSigned;
}


- (IBAction)cancelClicked:(id)sender {
    [self performSelector:@selector(cancel) withObject:nil afterDelay:0.3];
}

- (void)done {
    [self removeFromSuperview];
    [self removeFromSuperview];
}

- (void)cancel {
    [self removeFromSuperview];
}

- (void)dissView {
    if(self) {
        [self removeFromSuperview];
    }
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    if (!CGRectContainsPoint(self.contentView.bounds, [sender locationInView:self.contentView])){
        [self removeFromSuperview];
    }
}

@end
