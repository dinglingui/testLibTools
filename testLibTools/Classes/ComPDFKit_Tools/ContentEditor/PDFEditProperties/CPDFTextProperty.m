//
//  CPDFTextProperty.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import "CPDFTextProperty.h"
#import "NSUserDefaults+Utils.h"

@implementation CPDFTextProperty

static CPDFTextProperty *_sharedSignManager;

+ (CPDFTextProperty *)sharedManager {
    if (!_sharedSignManager)
        _sharedSignManager = [[CPDFTextProperty alloc] init];
    return _sharedSignManager;
}

- (void)setFontColor:(UIColor *)fontColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(fontColor) {
        [userDefaults setPDFListViewColor:fontColor forKey:@"CPDFContentEditTextCreateFontColor"];
        [userDefaults synchronize];
    }
}

- (UIColor *)fontColor {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"CPDFContentEditTextCreateFontColor"]) {
        return [UIColor blackColor];
    } else {
        return [userDefaults PDFListViewColorForKey:@"CPDFContentEditTextCreateFontColor"];
    }
}

- (void)setTextOpacity:(CGFloat)textOpacity {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:textOpacity forKey:@"CPDFContentEditTextCreateFontOpacity"];
    [userDefaults synchronize];

}

- (CGFloat)textOpacity {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"CPDFContentEditTextCreateFontOpacity"]) {
        return 1;
    } else {
        return [userDefaults floatForKey:@"CPDFContentEditTextCreateFontOpacity"];
    }
}

- (void)setFontName:(NSString *)fontName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(fontName) {
        [userDefaults setObject:fontName forKey:@"CPDFContentEditTextCreateFontName"];
        [userDefaults synchronize];
    }
}

- (NSString *)fontName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"CPDFContentEditTextCreateFontName"]) {
        return @"Helvetica";
    } else {
        return [userDefaults objectForKey:@"CPDFContentEditTextCreateFontName"];
    }
}

- (void)setIsBold:(BOOL)isBold {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isBold forKey:@"CPDFContentEditTextCreateFontIsBold"];
    [userDefaults synchronize];

}

- (BOOL)isBold {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"CPDFContentEditTextCreateFontIsBold"]) {
        return NO;
    } else {
        return [userDefaults objectForKey:@"CPDFContentEditTextCreateFontIsBold"];
    }
}

- (void)setIsItalic:(BOOL)isItalic{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isItalic forKey:@"CPDFContentEditTextCreateFontIsItalic"];
    [userDefaults synchronize];

}

- (BOOL)isItalic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"CPDFContentEditTextCreateFontIsItalic"]) {
        return NO;
    } else {
        return [userDefaults objectForKey:@"CPDFContentEditTextCreateFontIsItalic"];
    }
}

- (void)setFontSize:(CGFloat)fontSize {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:fontSize forKey:@"CPDFContentEditTextCreateFontSize"];
    [userDefaults synchronize];

}

- (CGFloat)fontSize {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"CPDFContentEditTextCreateFontSize"]) {
        return 12;
    } else {
        return [userDefaults floatForKey:@"CPDFContentEditTextCreateFontSize"];
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:textAlignment forKey:@"CPDFContentEditTextCreateFontAlignment"];
    [userDefaults synchronize];

}

- (NSTextAlignment)textAlignment {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults objectForKey:@"CPDFContentEditTextCreateFontAlignment"]) {
        return NSTextAlignmentLeft;
    } else {
        return [userDefaults integerForKey:@"CPDFContentEditTextCreateFontAlignment"];
    }
}

@end
