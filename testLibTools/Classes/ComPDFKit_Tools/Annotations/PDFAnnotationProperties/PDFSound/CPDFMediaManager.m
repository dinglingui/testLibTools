//
//  CPDFMediaManager.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFMediaManager.h"

@implementation CPDFMediaManager

+ (CPDFMediaManager*)shareManager {
    static CPDFMediaManager* mediaManager = nil;
    static dispatch_once_t  predicate;
    dispatch_once(&predicate, ^{
        mediaManager = [[CPDFMediaManager alloc] init];
    });
    return mediaManager;
}

@end
