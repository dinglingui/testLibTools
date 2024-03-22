//
//  CInssertBlankPageCell.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CInsertBlankPageCell.h"
#import "CPDFColorUtils.h"

@interface CInsertBlankPageCell () <UITextFieldDelegate>

@property (nonatomic, assign) BOOL isSelect;

@end

@implementation CInsertBlankPageCell

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
    
    if (self.cellType == CInsertBlankPageCellSizeSelect) {
        if (selected) {
            self.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            self.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    // Configure the view for the selected state
}

#pragma mark - Pubulic Methods

- (void)setCellStyle:(CInsertBlankPageCellType)cellType label:(NSString *)label {
    if (self.locationTextField) {
        self.locationTextField.delegate = nil;
    }
    
    self.locationSelectBtn = nil;
    self.locationSelectLabel.text = nil;
    self.sizeSelectLabel.text = nil;
    self.textLabel.text = nil;
    self.sizeSelectLabel.text = nil;
    self.locationTextField  = nil;
    
    self.cellType = cellType;
    switch (self.cellType) {
        case CInsertBlankPageCellSize:
        {
            self.textLabel.text = label;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *tSelectView = [self sizeSelectViewCreate];
            
            self.accessoryView = tSelectView;
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
        case CInsertBlankPageCellDirection:
        {
            self.textLabel.text = label;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *tSelectView = [self directSelectViewCreate];
            
            self.accessoryView = tSelectView;
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
        case CInsertBlankPageCellLocation:
        {
            self.textLabel.text = label;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
        case CInsertBlankPageCellSizeSelect:
        {
            if (!self.sizeSelectLabel) {
                self.sizeSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, self.bounds.size.width-60, 50)];
            }
            self.sizeSelectLabel.text = @"";
            self.sizeSelectLabel.text = label;
            self.sizeLabel.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:self.sizeSelectLabel];
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
        case CInsertBlankPageCellLocationSelect:
        {
            if (!self.locationSelectBtn) {
                self.locationSelectBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 5, 50, 50)];
            }
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            self.locationSelectBtn.selected = NO;
            [self.locationSelectBtn setImage:[UIImage imageNamed:@"CInsertBlankPageCellLocationSelectOn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
            [self.locationSelectBtn setImage:[UIImage imageNamed:@"CInsertBlankPageCellLocationSelectOff" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [self.locationSelectBtn addTarget:self action:@selector(buttonItemClicked_location:) forControlEvents:UIControlEventTouchUpInside];
            self.locationSelectBtn.layer.cornerRadius = 25.0;
            self.locationSelectBtn.layer.masksToBounds = YES;
            [self.contentView addSubview:self.locationSelectBtn];
            
            if (!self.locationSelectLabel) {
                self.locationSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, self.bounds.size.width-80, 50)];
            }
            self.locationSelectLabel.text = label;
            self.locationSelectLabel.textColor = [UIColor grayColor];
            [self.contentView addSubview:self.locationSelectLabel];
            
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
        case CInsertBlankPageCellLocationTextFiled:
        {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGRect tFieldRect = CGRectMake(50.0, 15.0f, 300.0f, 30.0f);
            UITextField *tTextField = [self textFieldItemCreate_text:tFieldRect];
            tTextField.delegate = self;
            tTextField.placeholder = label;
            self.locationTextField = tTextField;
            [self.locationTextField addTarget:self action:@selector(textField_location:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:self.locationTextField];
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
            self.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, self.bounds.size.width);
        }
            break;
        case CInsertBlankPageCellRangeSelect:
        {
            if (!self.rangeSelectBtn) {
                self.rangeSelectBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 5, 50, 50)];
            }
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            self.rangeSelectBtn.selected = NO;
            [self.rangeSelectBtn setImage:[UIImage imageNamed:@"CInsertBlankPageCellLocationSelectOn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
            [self.rangeSelectBtn setImage:[UIImage imageNamed:@"CInsertBlankPageCellLocationSelectOff" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [self.rangeSelectBtn addTarget:self action:@selector(buttonItemClicked_range:) forControlEvents:UIControlEventTouchUpInside];
            self.rangeSelectBtn.layer.cornerRadius = 25.0;
            self.rangeSelectBtn.layer.masksToBounds = YES;
            [self.contentView addSubview:self.rangeSelectBtn];
            
            if (!self.rangeSelectLabel) {
                self.rangeSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, self.bounds.size.width-80, 50)];
            }
            self.rangeSelectLabel.text = label;
            self.rangeSelectLabel.textColor = [UIColor grayColor];
            [self.contentView addSubview:self.rangeSelectLabel];
        
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
        case CInsertBlankPageCellRangeTextFiled:
        {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGRect tFieldRect = CGRectMake(50.0, 15.0f, 300.0f, 30.0f);
            UITextField *tTextField = [self textFieldItemCreate_text:tFieldRect];
            tTextField.delegate = self;
            tTextField.placeholder = label;
            self.rangeTextField = tTextField;
            [self.rangeTextField addTarget:self action:@selector(textField_range:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:self.rangeTextField];
            self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Private Methods

- (UIView *)sizeSelectViewCreate {
    UIView *tSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 240, 50)];
    self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.sizeLabel.textAlignment = NSTextAlignmentRight;
    self.sizeLabel.font = [UIFont systemFontOfSize:18];
    self.sizeLabel.text = NSLocalizedString(@"A4 (210 X 297mm)", nil);
    
    self.sizeSelectBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, 0, 40, 50)];
    self.sizeSelectBtn.selected = NO;
    [self.sizeSelectBtn setImage:[UIImage imageNamed:@"CInsertBlankPageCellSelectDown" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [self.sizeSelectBtn setImage:[UIImage imageNamed:@"CInsertBlankPageCellSelect" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.sizeSelectBtn addTarget:self action:@selector(buttonItemClicked_size:) forControlEvents:UIControlEventTouchUpInside];
    
    [tSelectView addSubview:self.sizeLabel];
    [tSelectView addSubview:self.sizeSelectBtn];
    
    return tSelectView;
}

- (UIView *)directSelectViewCreate {
    UIView *tSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 88, 44)];
    tSelectView.layer.cornerRadius = 5;
    tSelectView.layer.masksToBounds = YES;
    
    self.verticalPageBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    self.verticalPageBtn.tag = 0;
    self.verticalPageBtn.selected = NO;
    self.verticalPageBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    [self.verticalPageBtn setImage:[UIImage imageNamed:@"CInsertBlankPageCellVertical" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.verticalPageBtn addTarget:self action:@selector(buttonItemClicked_direction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.horizontalPageBtn = [[UIButton alloc]initWithFrame:CGRectMake(44, 0, 44, 44)];
    self.horizontalPageBtn.selected = NO;
    self.horizontalPageBtn.tag = 1;
    self.horizontalPageBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    [self.horizontalPageBtn setImage:[UIImage imageNamed:@"CInsertBlankPageCellHorizontal" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.horizontalPageBtn addTarget:self action:@selector(buttonItemClicked_direction:) forControlEvents:UIControlEventTouchUpInside];
    
    [tSelectView addSubview:self.horizontalPageBtn];
    [tSelectView addSubview:self.verticalPageBtn];
    
    return tSelectView;
}

- (UITextField *)textFieldItemCreate_text:(CGRect)rect {
    UITextField *tTextField = [[UITextField alloc] initWithFrame:rect];
    
    tTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tTextField.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    tTextField.returnKeyType = UIReturnKeyDone;
    tTextField.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    tTextField.leftViewMode = UITextFieldViewModeAlways;
    tTextField.rightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 0)];
    tTextField.rightViewMode = UITextFieldViewModeAlways;
    tTextField.clearButtonMode = YES;
    tTextField.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
    tTextField.layer.borderWidth = 1.0;
    tTextField.borderStyle = UITextBorderStyleNone;
    
    return tTextField;
}

- (BOOL)validateValue:(NSString *)number {
    BOOL res = YES;
    NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    NSInteger i = 0;
    while (i < number.length) {
        NSString *str = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [str rangeOfCharacterFromSet:numberSet];
        
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    
    return  res;
}

- (void)setButtonSelectedStatus:(BOOL)buttonSelectedStatus {
    _buttonSelectedStatus = buttonSelectedStatus;
    
    if(buttonSelectedStatus == YES) {
        [self.sizeSelectBtn setSelected:YES];
    }else{
        [self.sizeSelectBtn setSelected:NO];
    }
}

#pragma mark - Action

- (void)buttonItemClicked_size:(UIButton *)button {
    button.selected = !button.selected;

    if (self.delegate && [self.delegate respondsToSelector:@selector(insertBlankPageCell:isSelect:)]) {
        [self.delegate insertBlankPageCell:self isSelect:button.selected];
    }
}

- (void)buttonItemClicked_direction:(UIButton *)button {
    self.horizontalPageBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    self.verticalPageBtn.backgroundColor = [CPDFColorUtils CAnnotationBarNoSelectBackgroundColor];
    
    if (button.tag == 0) {
        self.verticalPageBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        if (self.delegate && [self.delegate respondsToSelector:@selector(insertBlankPageCell:rotate:)]) {
            [self.delegate insertBlankPageCell:self rotate:button.tag];
        }
    } else if (button.tag == 1) {
        self.horizontalPageBtn.backgroundColor = [CPDFColorUtils CAnnotationBarSelectBackgroundColor];
        if (self.delegate && [self.delegate respondsToSelector:@selector(insertBlankPageCell:rotate:)]) {
            [self.delegate insertBlankPageCell:self rotate:button.tag];
        }
    }
}

- (void)textField_location:(UITextField *)sender {
    NSInteger pageIndex = [sender.text integerValue];
    if (self.delegate && [self.delegate respondsToSelector:@selector(insertBlankPageCell:pageIndex:)]) {
        [self.delegate insertBlankPageCell:self pageIndex:pageIndex];
    }
}

- (void)textField_range:(UITextField *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(insertBlankPageCell:pageRange:)]) {
        [self.delegate insertBlankPageCell:self pageRange:sender.text];
    }
}

- (void)buttonItemClicked_location:(UIButton *)button {
    [self.locationTextField resignFirstResponder];
    if (self.delegate && [self.delegate respondsToSelector:@selector(insertBlankPageCellLocation:button:)]) {
        [self.delegate insertBlankPageCellLocation:self button:button];
    }
}

- (void)buttonItemClicked_range:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(insertBlankPageCellRange:button:)]) {
        [self.delegate insertBlankPageCellRange:self button:button];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.locationTextField) {
        return [self validateValue:string];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.locationTextField == textField) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(insertBlankPageCellLocationTextFieldBegin:)]) {
            [self.delegate insertBlankPageCellLocationTextFieldBegin:self];
        }
    } else if (self.rangeTextField == textField) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(insertBlankPageCellRangeTextFieldBegin:)]) {
            [self.delegate insertBlankPageCellRangeTextFieldBegin:self];
        }
    }
}

@end
