//
//  CSignatureManager.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CSignatureManager.h"

#define kPDFSignatureDataFileName (@"PDFKitResources/Signature/PDFSignatureData.plist")
#define kPDFSignatureImageFolder  (@"PDFKitResources/Signature/PDFSignatureImageFolder")

@implementation CSignatureManager

static CSignatureManager *_sharedSignManager;

+ (CSignatureManager *)sharedManager {
    if (!_sharedSignManager)
        _sharedSignManager = [[CSignatureManager alloc] init];
    return _sharedSignManager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
        NSString *filePath = [library stringByAppendingPathComponent:kPDFSignatureDataFileName];
        NSString *folderPath = [library stringByAppendingPathComponent:kPDFSignatureImageFolder];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSMutableArray *signatures = [NSMutableArray array];
            NSArray *fileNames = [[NSArray alloc] initWithContentsOfFile:filePath];
            for (NSString *fileName in fileNames) {
                [signatures addObject:[folderPath stringByAppendingPathComponent:fileName]];
            }
            _signatures = signatures;
        } else {
            _signatures = [[NSArray alloc] init];
        }
    }
    return self;
}

- (NSString *)randomString {
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, cfuuid);
    NSString *cfuuidString = [NSString stringWithString:(__bridge NSString *)cfstring];
    CFRelease(cfuuid);
    CFRelease(cfstring);
    return cfuuidString;
}

- (void)save {
    NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *filePath = [library stringByAppendingPathComponent:kPDFSignatureDataFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    NSMutableArray *fileNames = [NSMutableArray array];
    for (NSString *filePath in self.signatures) {
        [fileNames addObject:filePath.lastPathComponent];
    }
    if (fileNames.count > 0) {
        [fileNames writeToFile:filePath atomically:YES];
    }
}

- (void)addImageSignature:(UIImage *)image {
    NSString *library = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSString *folderPath = [library stringByAppendingPathComponent:kPDFSignatureImageFolder];
    NSString *randomStr = [self randomString];
    if (image) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *imageName = [randomStr stringByAppendingPathExtension:@"png"];
        NSString *imagePath = [folderPath stringByAppendingPathComponent:imageName];
        if ([UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES]) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.signatures];
            [array insertObject:imagePath atIndex:0];
            self.signatures = array;
            [self save];
        }
    }
}

- (void)addTextSignature:(NSString *)text {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.signatures];
    [array insertObject:text atIndex:0];
    self.signatures = array;
    [self save];
}

- (void)removeSignaturesAtIndexes:(NSIndexSet *)indexes {
    for (NSString *filePath in [self.signatures objectsAtIndexes:indexes]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.signatures];
    [array removeObjectsAtIndexes:indexes];
    self.signatures = array;
    [self save];
}

- (void)removeSignaturesAtIndexe:(NSInteger)row {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.signatures];
    [array removeObjectAtIndex:row];
    self.signatures = array;
    [self save];
}

@end
