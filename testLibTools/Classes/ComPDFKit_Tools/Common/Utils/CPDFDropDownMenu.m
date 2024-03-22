//
//  CPDFDropDownMenu.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFDropDownMenu.h"

@interface CPDFDropDownMenu()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * optionList;

@property (nonatomic, strong) UIButton    * pullDownButton;

@property (nonatomic, assign) BOOL        isShown;

@property (nonatomic, assign) CGFloat     menuMaxHeight;

@property (nonatomic, strong) UITextField * contextField;

@end

@implementation CPDFDropDownMenu

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)setUp{
    self.contextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.contextField.delegate = self;
    self.contextField.enabled = YES;
    self.contextField.textColor = [UIColor darkGrayColor];
    [self addSubview:self.contextField];
    
    self.pullDownButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pullDownButton addTarget:self action:@selector(showOrHide) forControlEvents:UIControlEventTouchUpInside];
    [self.pullDownButton setImage:[UIImage imageNamed:@"CPDFEditArrow" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self addSubview:self.pullDownButton];
    
    self.showBorder = YES;
    self.textColor = [UIColor darkGrayColor];
    self.font  = [UIFont systemFontOfSize:16.];
    self.rowHeight = 40;
    self.userInteractionEnabled = YES;
}

- (void)showOrHide{
    if(self.isShown){
        [UIView animateWithDuration:0.3 animations:^{
            self.pullDownButton.transform = CGAffineTransformMakeRotation(M_PI *2);
            CGRect frame =  CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height - 0.5, self.frame.size.width, 0);
            CGRect newFrame = [self convertRect:frame toView:self.superview.superview];
            self.optionList.frame = newFrame;
                    
         } completion:^(BOOL finished) {
             self.pullDownButton.transform = CGAffineTransformMakeRotation(0);
             self.isShown = false;
        }];
    }else{
        [self.contextField resignFirstResponder];
        [self.optionList reloadData];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.pullDownButton.transform = CGAffineTransformMakeRotation(M_PI);
            
            CGRect frame =  CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height - 0.5, self.frame.size.width, self.menuHeight);
            CGRect newFrame = [self convertRect:frame toView:self.superview.superview];
            
            self.optionList.frame  = newFrame;
                    
          } completion:^(BOOL finished) {
              self.isShown = true;
        }];
    }
    
}

- (void)setShowBorder:(BOOL)showBorder {
    _showBorder = showBorder;
    if(self.showBorder){
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2.5;
    }else{
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 0;
        self.layer.borderWidth = 0;
    }
    
}

#pragma mark - Setter and Getter
- (void)setMenuHeight:(CGFloat)menuHeight{
    _menuHeight = menuHeight;
    [self reloadData];
}

- (void)setRowHeight:(CGFloat)rowHeight{
    _rowHeight = rowHeight;
    [self reloadData];
}

- (void)setOptions:(NSMutableArray *)options{
    _options = options;
    [self reloadData];
}

- (void)setDefaultValue:(NSString *)defaultValue{
    _defaultValue = defaultValue;
    self.contextField.text = defaultValue;
}

- (void)reloadData{
    if(!self.isShown){
        return;
    }
    
    [self.optionList reloadData];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.pullDownButton.transform = CGAffineTransformMakeRotation(M_PI);
        CGRect frame =  CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height - 0.5, self.frame.size.width, self.menuHeight);
        CGRect newFrame = [self convertRect:frame toView:self.superview.superview];
        
        self.optionList.frame  = newFrame;
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.contextField.frame = CGRectMake(15, 5, self.frame.size.width - 50, self.frame.size.height - 10);
    self.pullDownButton.frame = CGRectMake(self.frame.size.width - 35, 0, 30, 30);

}

#pragma mark - listView
- (UITableView *)optionList{
    if(!_optionList){
        CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, 0);
//        CGRect newFrame = [self convertRect:frame toView:self.superview];
        _optionList = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
        _optionList.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        _optionList.delegate = self;
        _optionList.dataSource = self;
        _optionList.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _optionList.layer.borderWidth = 0.5;
        _optionList.allowsSelection = YES;
        [self addSubview:_optionList];
    }
    
    return _optionList;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.text.length > 0){
        self.defaultValue = textField.text;
        if(self.delegate  && [self.delegate respondsToSelector:@selector(dropDownMenu:didEditWithText:)]){
            [self.delegate dropDownMenu:self didEditWithText:textField.text];
        }
    }
    
    return YES;
}

#pragma mark - UItableViewDelegate + UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"tableViewIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    };
    cell.textLabel.text = self.options[indexPath.row];
    cell.textLabel.font = self.font;
    cell.textLabel.textColor = self.textColor;
    cell.userInteractionEnabled = YES;

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.contextField.text = self.options[indexPath.row];
    self.defaultValue = self.contextField.text;
    if(self.delegate && [self.delegate respondsToSelector:@selector(dropDownMenu:didSelectWithIndex:)]) {
        [self.delegate dropDownMenu:self didSelectWithIndex:indexPath.row];
    }
    [self showOrHide];
}

@end
