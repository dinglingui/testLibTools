//
//  CPDFOutlineModel.h
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPDFOutlineModel : NSObject

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger hide;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL isShow;

@end

NS_ASSUME_NONNULL_END
