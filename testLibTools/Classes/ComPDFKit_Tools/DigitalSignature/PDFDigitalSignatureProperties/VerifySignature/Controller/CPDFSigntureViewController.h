//
//  CPDFSigntureViewController.h
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

@interface CPDFSigntureViewController : UIViewController

@property (nonatomic,readonly) UIButton *button;

@property (nonatomic,readonly) NSArray *signatures;

@property (nonatomic,copy) void (^callback)(void);

-(void)updateCertState:(NSArray *)signatures;

@property (nonatomic, assign) BOOL expiredTrust;

@end
