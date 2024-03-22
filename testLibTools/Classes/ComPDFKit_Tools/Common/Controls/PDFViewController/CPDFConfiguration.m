//
//  CPDFConfiguration.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFConfiguration.h"

@interface CNavBarButtonItem()

@property(nonatomic,assign)CPDFViewBarLeftButtonItem leftBarItem;

@property(nonatomic,assign)CPDFViewBarRightButtonItem rightBarItem;

@end

@implementation CNavBarButtonItem

- (instancetype)initWithViewLeftBarButtonItem:(CPDFViewBarLeftButtonItem)barButtonItem {
    if(self = [super init]) {
        self.leftBarItem = barButtonItem;
    }
    return self;
}

- (instancetype)initWithViewRightBarButtonItem:(CPDFViewBarRightButtonItem)barButtonItem {
    if(self = [super init]) {
        self.rightBarItem = barButtonItem;
    }
    return self;
}

@end

@implementation CPDFConfiguration

@end
