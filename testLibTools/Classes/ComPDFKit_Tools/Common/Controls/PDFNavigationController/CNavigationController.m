//
//  CNavigationController.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CNavigationController.h"

#import "CPDFColorUtils.h"

@interface CNavigationController ()

@end

@implementation CNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *navgationBarApp = [[UINavigationBarAppearance alloc] init];
        navgationBarApp.backgroundColor = [CPDFColorUtils CNavBackgroundColor];
        [UINavigationBar appearance].scrollEdgeAppearance = navgationBarApp;
        [UINavigationBar appearance].standardAppearance = navgationBarApp;
        
        [UITableView appearance].sectionHeaderTopPadding = 0;
    }    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
