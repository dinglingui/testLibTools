//
//  CPDFEditToolBar.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import "CPDFEditToolBar.h"
#import <ComPDFKit/ComPDFKit.h>

#import "CPDFColorUtils.h"

@interface CPDFEditToolBar()

@property(nonatomic,strong) UIButton * undoButton;
@property(nonatomic,strong) UIButton * redoButton;
@property(nonatomic,strong) UIButton * propertyButton;

@property(nonatomic,strong) UIButton * textEditButton;
@property(nonatomic,strong) UIButton * imageEditButton;

@property(nonatomic,strong) UIView * leftView;
@property(nonatomic,strong) UIView * rightView;
@property(nonatomic,strong) UIView * splitView;

@property(nonatomic, assign) CPDFEditMode editToolBarSelectType;

@end

@implementation CPDFEditToolBar

- (instancetype)initWithPDFView:(CPDFView *)pdfView {
    if (self = [super init]) {
        _pdfView = pdfView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageChangedNotification:) name:CPDFViewPageChangedNotification object:nil];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self removeViews];
    [self setUp];
}

- (void)removeViews{
    [self.leftView removeFromSuperview];
    [self.rightView removeFromSuperview];
    [self.splitView removeFromSuperview];
}

- (void)setUp {
    self.textEditButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 30, 30)];
    [self.textEditButton addTarget:self action:@selector(textEditAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.textEditButton setImage:[UIImage imageNamed:@"CPDFEditAddText" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];

    self.imageEditButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.textEditButton.frame) + 10, 7, 30, 30)];
     [self.imageEditButton addTarget:self action:@selector(imageEditAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageEditButton setImage:[UIImage imageNamed:@"CPDFEditAddImage" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    self.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.bounds.size.width - 110, 44)];
    [self addSubview:self.leftView];
    [self.leftView addSubview:self.textEditButton];
    [self.leftView addSubview:self.imageEditButton];
    self.leftView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.textEditButton.frame = CGRectMake(CGRectGetMidX(self.leftView.frame) - 50, self.textEditButton.frame.origin.y, self.textEditButton.frame.size.width, self.textEditButton.frame.size.height);
    self.imageEditButton.frame = CGRectMake(CGRectGetMidX(self.leftView.frame) + 20, self.imageEditButton.frame.origin.y, self.imageEditButton.frame.size.width, self.imageEditButton.frame.size.height);
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(19, 12, 1, 20)];
    if (@available(iOS 13.0, *)){
        if([UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark)
            lineView.backgroundColor = [UIColor whiteColor];
        else
            lineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    } else
        lineView.backgroundColor = [UIColor blackColor];
    
    self.propertyButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 7, 30, 30)];
    [self.propertyButton setImage:[UIImage imageNamed:@"CPDFAnnotationBarImageProperties" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.propertyButton.frame = CGRectMake(20, 7, 30, 30);
    [self.propertyButton addTarget:self action:@selector(propertyAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.undoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.propertyButton.frame), 7, 30, 30)];
    [self.undoButton addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.undoButton setImage:[UIImage imageNamed:@"CPDFAnnotationBarImageUndo" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    self.redoButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.undoButton.frame), 7,30, 30)];
    [self.redoButton addTarget:self action:@selector(redoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.redoButton setImage:[UIImage imageNamed:@"CPDFAnnotationBarImageRedo" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    self.rightView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.leftView.frame), 0, 110, 44)];
    [self addSubview:self.self.rightView];
    
    [self.rightView addSubview:self.redoButton];
    [self.rightView addSubview:self.undoButton];
    [self.rightView addSubview:self.propertyButton];
    [self.rightView addSubview:lineView];

    self.backgroundColor = [UIColor colorWithRed:0.98 green:0.99 blue:1.0 alpha:1.0];
    
    [self updateButtonState];
    self.backgroundColor = [CPDFColorUtils CPDFViewControllerBackgroundColor];
    
    self.editToolBarSelectType = CPDFEditModeAll;
}


#pragma mark - Action

- (void)textEditAction:(UIButton*)sender {
    self.textEditButton.selected = !self.textEditButton.selected;
    if(self.textEditButton.selected == YES){
        [self.imageEditButton setSelected:NO];
        [self.imageEditButton setBackgroundColor:[UIColor clearColor]];
    }
    
    
    if(sender.selected == NO && self.imageEditButton.selected == NO){
        [self.pdfView changeEditingLoadType:CEditingLoadTypeText | CEditingLoadTypeImage];
        [self.pdfView setShouAddEditAreaType:CAddEditingAreaTypeNone];
        if(self.delegate && [self.delegate respondsToSelector:@selector(editClickInToolBar:editMode:)]){
            [self.delegate editClickInToolBar:self editMode:CPDFEditModeAll];
        }
        self.editToolBarSelectType = CPDFEditModeAll;
    }else{
        [self.pdfView changeEditingLoadType:CEditingLoadTypeText];
        [self.pdfView setShouAddEditAreaType:CAddEditingAreaTypeText];

        if(self.delegate && [self.delegate respondsToSelector:@selector(editClickInToolBar:editMode:)]){
            [self.delegate editClickInToolBar:self editMode:CPDFEditModeText];
        }
        self.editToolBarSelectType = CPDFEditModeText;
    }
    [self updateButtonState];
    
    if(sender.selected == YES){
        [self.textEditButton setBackgroundColor:[UIColor colorWithRed:221./255. green:233/255. blue:255./255 alpha:1.]];
    }else{
        [self.textEditButton setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)imageEditAction:(UIButton*)sender {
    self.imageEditButton.selected = !self.imageEditButton.selected;
    
    
    if(self.imageEditButton.selected == YES){
        [self.textEditButton setSelected:NO];
        [self.textEditButton setBackgroundColor:[UIColor clearColor]];
    }
    if(sender.selected == NO && self.textEditButton.selected == NO){
        [self.pdfView changeEditingLoadType:CEditingLoadTypeText | CEditingLoadTypeImage];
        [self.pdfView setShouAddEditAreaType:CAddEditingAreaTypeNone];

        if(self.delegate && [self.delegate respondsToSelector:@selector(editClickInToolBar:editMode:)]){
            [self.delegate editClickInToolBar:self editMode:CPDFEditModeAll];
        }
        self.editToolBarSelectType = CPDFEditModeAll;
    } else{
        [self.pdfView changeEditingLoadType:CEditingLoadTypeImage];
        [self.pdfView setShouAddEditAreaType:CAddEditingAreaTypeImage];
        if(self.delegate && [self.delegate respondsToSelector:@selector(editClickInToolBar:editMode:)]){
            [self.delegate editClickInToolBar:self editMode:CPDFEditModeImage];
        }
        self.editToolBarSelectType = CPDFEditModeImage;
    }
    [self updateButtonState];

    if(sender.selected == YES){
        [self.imageEditButton setBackgroundColor:[UIColor colorWithRed:221./255. green:233/255. blue:255./255 alpha:1.]];
    }else{
        [self.imageEditButton setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)redoAction:(UIButton*)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(redoDidClickInToolBar:)]){
        [self.delegate redoDidClickInToolBar:self];
    }
}

- (void)undoAction:(UIButton*)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(undoDidClickInToolBar:)]){
        [self.delegate undoDidClickInToolBar:self];
    }
}

- (void)propertyAction:(UIButton*)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(propertyEditDidClickInToolBar:)]){
        [self.delegate propertyEditDidClickInToolBar:self];
    }
}


- (void)updateButtonState {
    if (self.pdfView.editingLoadType == CEditingLoadTypeText) {
        //Text
        [self.textEditButton setSelected:YES];
        [self.imageEditButton setSelected:NO];
    } else if((self.pdfView.editingLoadType == CEditingLoadTypeImage)){
        [self.textEditButton setSelected:NO];
        [self.imageEditButton setSelected:YES];
    } else {
        [self.textEditButton setSelected:NO];
        [self.imageEditButton setSelected:NO];
    }
    
    if(self.textEditButton.selected == YES){
        [self.textEditButton setBackgroundColor:[UIColor colorWithRed:221./255. green:233/255. blue:255./255 alpha:1.]];
    }else{
        [self.textEditButton setBackgroundColor:[UIColor clearColor]];
    }
    
    if(self.imageEditButton.selected == YES){
        [self.imageEditButton setBackgroundColor:[UIColor colorWithRed:221./255. green:233/255. blue:255./255 alpha:1.]];
    }else{
        [self.imageEditButton setBackgroundColor:[UIColor clearColor]];
    }
    
    if (CAddEditingAreaTypeText == self.pdfView.shouAddEditAreaType) {
        self.propertyButton.enabled = YES;
    } else if (self.pdfView.editStatus == CEditingSelectStateEmpty){
        self.propertyButton.enabled = NO;
    } else{
        self.propertyButton.enabled = YES;
    }
    
    if ([self.pdfView canEditTextRedo])
        self.redoButton.enabled  = YES;
     else
        self.redoButton.enabled  = NO;
    
    if ([self.pdfView canEditTextUndo])
        self.undoButton.enabled  = YES;
     else
        self.undoButton.enabled  = NO;
}

#pragma mark - NSNotification

- (void)pageChangedNotification:(NSNotification *)notification {
    CPDFView *pdfview = notification.object;
    if (pdfview.document == self.pdfView.document) {
        [self updateButtonState];
    }
}

@end
