//
//  CSignatureTextField.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//
#import "CSignatureTextField.h"

@implementation CSignatureTextField

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x+150, bounds.origin.y, bounds.size.width, bounds.size.height);
         return inset;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    return inset;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect inset = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
         return inset;
}

@end
