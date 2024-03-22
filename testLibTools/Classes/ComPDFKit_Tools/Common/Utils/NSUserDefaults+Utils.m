//
//  NSUserDefaults+Utils.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "NSUserDefaults+Utils.h"

@implementation NSUserDefaults (Utils)

- (UIColor *)PDFListViewColorForKey:(NSString *)key {
    id colorString = [self objectForKey:key];
    UIColor *color;
    if ([colorString isKindOfClass:[NSData class]]) {
        NSData *data = (NSData *)colorString;
        color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } else {
        color = [NSUserDefaults colorWithHexString:colorString];
    }
    return color;
}

- (void)setPDFListViewColor:(UIColor *)color forKey:(NSString *)key {
    NSString *colorString = [NSUserDefaults hexStringWithAlphaColor:color];
    [self setObject:colorString forKey:key];
    [self synchronize];
}

+ (NSString *)hexStringWithAlphaColor:(UIColor *)color {
    NSString *colorStr = [NSUserDefaults hexStringWithColor:color];
    CGFloat a = 1.;
    CGFloat r,g,b;
    [color getRed:&r green:&g blue:&b alpha:&a];
    NSString *alphaStr = [NSUserDefaults getHexByDecimal:a*255];
    if (alphaStr.length < 2) {
        alphaStr = [@"0" stringByAppendingString:alphaStr];
    }
    return [colorStr stringByAppendingString:alphaStr];
}

+ (NSString *)hexStringWithColor:(UIColor *)color {
    if (!color) {
        return nil;
    }
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    return [NSString stringWithFormat:@"#%@%@%@",[NSUserDefaults colorStringWithValue:r],[NSUserDefaults colorStringWithValue:g],[NSUserDefaults colorStringWithValue:b]];
}

+ (NSString *)colorStringWithValue:(CGFloat )value {
    NSString *str = [NSUserDefaults getHexByDecimal:(NSInteger)(value*255)];
    if (str.length < 2) {
        return [NSString stringWithFormat:@"0%@",str];
    }
    return str;
}

+ (NSString *)getHexByDecimal:(NSInteger)decimal {
    NSString *hex =@"";
    NSString *letter;
    NSInteger number;
    for (int i = 0; i<9; i++) {
        
        number = decimal % 16;
        decimal = decimal / 16;
        switch (number) {
            case 10:
                letter =@"A"; break;
            case 11:
                letter =@"B"; break;
            case 12:
                letter =@"C"; break;
            case 13:
                letter =@"D"; break;
            case 14:
                letter =@"E"; break;
            case 15:
                letter =@"F"; break;
            default:
                letter = [NSString stringWithFormat:@"%ld", number];
        }
        hex = [letter stringByAppendingString:hex];
        if (decimal == 0) {
            
            break;
        }
    }
    return hex;
}

+ (UIColor *)colorWithHexString:(NSString *)hexStr {
    NSString *cString = [[hexStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return nil;
    }
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] < 6)
        return nil;

    NSRange range;
    range.location = 0;
    range.length = 2;
    //R、G、B
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b,a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    float alpha = 1.;
    if ([cString length] == 8) {
        NSString *aStr = [cString substringWithRange:NSMakeRange(6, 2)];
        [[NSScanner scannerWithString:aStr] scanHexInt:&a];
        alpha = a/255.;
    }
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}


@end
