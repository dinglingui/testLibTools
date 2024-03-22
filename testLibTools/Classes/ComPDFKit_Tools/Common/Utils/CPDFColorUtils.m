//
//  CPDFColorUtils.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFColorUtils.h"

@implementation CPDFColorUtils

+ (UIColor *)CPDFViewControllerBackgroundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CPDFViewControllerBackgroundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor whiteColor];
    }
}

+ (UIColor *)CAnnotationBarSelectBackgroundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CAnnotationBarSelectBackgroundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:221.0/255.0 green:233.0/255.0  blue:1.0 alpha:1.0];
    }
}

+ (UIColor *)CAnnotationSampleBackgoundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CAnnotationSampleBackgoundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:250.0/255.0 green:252.0/255.0  blue:1.0 alpha:1.0];
    }
}

+ (UIColor *)CAnnotationSampleDrawBackgoundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CAnnotationSampleDrawBackgoundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0  blue:1.0 alpha:1.0];
    }
}

+ (UIColor *)CAnnotationPropertyViewControllerBackgoundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CAnnotationPropertyViewControllerBackgoundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0  blue:1.0 alpha:1.0];
    }
}

+ (UIColor *)CNoteOpenBackgooundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CNoteOpenBackgooundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:255.0/255.0 green:244.0/255.0  blue:213.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)CAnyReverseBackgooundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CcommonReverseBackGroundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:0 green:0  blue:0 alpha:1.0];
    }
}

+ (UIColor *)CTableviewCellSplitColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CTableviewCellSplitColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:255.0/255.0 green:244.0/255.0  blue:213.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)CViewBackgroundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CViewBackgroundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:242.0/255.0 green:242.0/255.0  blue:242.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)CPageEditToolbarFontColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CPageEditToolbarFontColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:61.0/255.0 green:71.0/255.0 blue:77.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)CAnnotationBarNoSelectBackgroundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CAnnotationBarNoSelectBackgroundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:253.0/255.0 green:254.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)CFormFontColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CFormFontColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    }
}

+ (UIColor *)CPDFKeyboardToolbarColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CPDFKeyboardToolbarColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:242.0/255.0 green:243.0/255.0 blue:245.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)CNavBackgroundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"KMNavBackgroundColor"];
    } else {
        return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
}

+ (UIColor *)CMessageLabelColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CMessageLabelColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    }
}

+ (UIColor *)CVerifySignatureBackgroundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorNamed:@"CVerifySignatureBackgroundColor" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    } else {
        return [UIColor colorWithRed:221.0/255.0 green:233.0/255.0 blue:1.0 alpha:1.0];
    }
}

@end
