//
//  CNavigationRightView.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CNavigationRightView.h"

#pragma mark - CNavigationRightAction

@interface CNavigationRightAction ()

@property(nonatomic, strong) UIImage *image;

@property(nonatomic, assign) NSUInteger tag;

@end

@implementation CNavigationRightAction

+ (CNavigationRightAction *)actionWithImage:(UIImage *)image tag:(NSUInteger)tag {
    CNavigationRightAction *action = [[CNavigationRightAction alloc] init];
    action.image = image;
    action.tag = tag;    
    return action;
}

@end

#pragma mark - CNavigationRightView

@interface CNavigationRightView ()

typedef void (^Clickback) (NSUInteger tag);

@property(nonatomic,copy)Clickback clickBack;

@property(nonatomic,strong)NSArray <CNavigationRightAction *> *dataArray;

@end

@implementation CNavigationRightView

#pragma mark - Initializers

- (instancetype)initWithRightActions:(NSArray<CNavigationRightAction *> *)rightActions clickBack:(void (^)(NSUInteger tag))clickBack {
    if(self = [super init]) {
        self.dataArray = rightActions;
        
        [self configurationUI];
        self.clickBack = clickBack;
    }
    return self;
}

- (instancetype)initWithDefaultItemsClickBack:(void (^)(NSUInteger tag))clickBack {
    if(self = [super init]) {
        NSArray *nums = [self defaultItems];
        NSMutableArray *actions = [NSMutableArray array];
        for (NSNumber *num in nums) {
            NSString *imageName = nil;
            switch (num.integerValue) {
                case CNavigationRightTypeSearch:
                    imageName = @"CNavigationImageNameSearch";
                    break;
                case CNavigationRightTypeBota:
                    imageName = @"CNavigationImageNameBota";
                    break;
                default:
                case CNavigationRightTypeMore:
                    imageName = @"CNavigationImageNameMore";
                    break;
            }
            UIImage *image = [UIImage imageNamed:imageName
                                        inBundle:[NSBundle bundleForClass:self.class]
                   compatibleWithTraitCollection:nil];
            CNavigationRightAction *action = [CNavigationRightAction actionWithImage:image tag:num.integerValue];
            [actions addObject:action];
        }
        self.dataArray = actions;
        
        [self configurationUI];
        
        self.clickBack = clickBack;

    }
    return self;
}

- (NSArray *)defaultItems {
    return @[@(CNavigationRightTypeSearch),@(CNavigationRightTypeBota),@(CNavigationRightTypeMore)];
}

#pragma mark - Private method

- (void)configurationUI {
    
    CGFloat offset = 20;
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        offset = 20;
    }
    CGFloat height = 0;
    CGFloat width = offset;

    for (NSUInteger i = 0; i< self.dataArray.count; i++) {
        CNavigationRightAction *rightAction = self.dataArray[i];
        UIImage *image = rightAction.image;
        height = MAX(height, image.size.height);
        
        if(i == 0) {
            width = 0;
        }
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(width, 0, image.size.width, image.size.height)];
        [button setImage:image forState:UIControlStateNormal];
        button.tag = rightAction.tag;
        [button addTarget:self action:@selector(buttonClickItem:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        if(i == self.dataArray.count - 1){
            width += 0;
        }else{
            width += (button.frame.size.width + offset);
        }

    }
    
    self.bounds = CGRectMake(0, 0, width + offset, height);
}

#pragma mark - Action
- (IBAction)buttonClickItem:(UIButton *)sender {
    NSUInteger tag = sender.tag;
    
    if (self.clickBack) {
        self.clickBack(tag);
    }
}

@end
