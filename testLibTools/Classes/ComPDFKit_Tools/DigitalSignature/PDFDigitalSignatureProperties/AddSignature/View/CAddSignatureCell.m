//
//  CAddSignatureCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//


#import "CAddSignatureCell.h"
#import "CPDFColorUtils.h"

@implementation CAddSignatureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Pubulic Methods

- (void)setCellStyle:(CAddSignatureCellType)cellType label:(NSString *)label {
    self.cellType = cellType;
    
    switch (self.cellType) {
        case CAddSignatureCellAlignment:
        {
            self.textLabel.text = label;
            self.textLabel.font = [UIFont systemFontOfSize:13];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            UIView *tSelectView = [self alignmentSelectViewCreate];
            
            self.accessoryView = tSelectView;
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
        case CAddSignatureCellAccess:
        {
            self.textLabel.text = label;
            self.textLabel.font = [UIFont systemFontOfSize:13];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *tSelectView = [self accessSelectViewCreate];
            
            self.accessoryView = tSelectView;
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
        case CAddSignatureCellSelect:
        {
            if (!self.textSelectBtn) {
                self.textSelectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 50, 50)];
            }
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            self.textSelectBtn.selected = NO;
            [self.textSelectBtn setImage:[UIImage imageNamed:@"CAddSignatureCellSelect" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
            [self.textSelectBtn setImage:[UIImage imageNamed:@"CAddSignatureCellNoSelect" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [self.textSelectBtn addTarget:self action:@selector(buttonItemClicked_select:) forControlEvents:UIControlEventTouchUpInside];
            self.textSelectBtn.layer.cornerRadius = 25.0;
            self.textSelectBtn.layer.masksToBounds = YES;
            [self.contentView addSubview:self.textSelectBtn];
            
            if (!self.textSelectLabel) {
                self.textSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, self.bounds.size.width-80, 50)];
            }
            self.textSelectLabel.text = label;
            self.textSelectLabel.font = [UIFont systemFontOfSize:13];
            [self.contentView addSubview:self.textSelectLabel];
            
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private Methods

- (UIView *)alignmentSelectViewCreate {
    UIView *tSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 88, 44)];
    tSelectView.layer.cornerRadius = 5;
    tSelectView.layer.masksToBounds = YES;
    
    self.leftAlignmentBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.leftAlignmentBtn.tag = 0;
    self.leftAlignmentBtn.selected = NO;
    self.leftAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
    [self.leftAlignmentBtn setImage:[UIImage imageNamed:@"CAddSignatureCellLeft" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.leftAlignmentBtn addTarget:self action:@selector(buttonItemClicked_alignment:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightAlignmentBtn = [[UIButton alloc]initWithFrame:CGRectMake(44, 0, 44, 44)];
    self.rightAlignmentBtn.selected = NO;
    self.rightAlignmentBtn.tag = 1;
    self.rightAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    [self.rightAlignmentBtn setImage:[UIImage imageNamed:@"CAddSignatureCellRight" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.rightAlignmentBtn addTarget:self action:@selector(buttonItemClicked_alignment:) forControlEvents:UIControlEventTouchUpInside];
    
    [tSelectView addSubview:self.leftAlignmentBtn];
    [tSelectView addSubview:self.rightAlignmentBtn];
    
    return tSelectView;
}

- (void)setLeftAlignment:(BOOL)isLeftAlignment {
    if (isLeftAlignment) {
        self.leftAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        self.rightAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    } else {
        self.rightAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        self.leftAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    }
}

- (UIView *)accessSelectViewCreate {
    UIView *tSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 240, 50)];
    self.accessSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.accessSelectLabel.textAlignment = NSTextAlignmentRight;
    self.accessSelectLabel.font = [UIFont systemFontOfSize:13];
    self.accessSelectLabel.adjustsFontSizeToFitWidth = YES;
    self.accessSelectLabel.text = NSLocalizedString(@"Close", nil);
    
    self.accessSelectBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 0, 40, 50)];
    self.accessSelectBtn.selected = NO;
    [self.accessSelectBtn setImage:[UIImage imageNamed:@"CInsertBlankPageCellSelect" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.accessSelectBtn addTarget:self action:@selector(buttonItemClicked_access:) forControlEvents:UIControlEventTouchUpInside];

    [tSelectView addSubview:self.accessSelectLabel];
    [tSelectView addSubview:self.accessSelectBtn];
    
    return tSelectView;
}

- (void)buttonItemClicked_alignment:(UIButton *)button {
    self.rightAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    self.leftAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    
    if (button.tag == 0) {
        self.leftAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        if (self.delegate && [self.delegate respondsToSelector:@selector(CAddSignatureCell:Alignment:)]) {
            [self.delegate CAddSignatureCell:self Alignment:NO];
        }
    } else if (button.tag == 1) {
        self.rightAlignmentBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        if (self.delegate && [self.delegate respondsToSelector:@selector(CAddSignatureCell:Alignment:)]) {
            [self.delegate CAddSignatureCell:self Alignment:YES];
        }
    }
}

- (void)buttonItemClicked_access:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(CAddSignatureCellAccess:)]) {
        [self.delegate CAddSignatureCellAccess:self];
    }
}

- (void)buttonItemClicked_select:(UIButton *)button {

    if (self.delegate && [self.delegate respondsToSelector:@selector(CAddSignatureCell:Button:)]) {
        [self.delegate CAddSignatureCell:self Button:button];
    }
}

@end
