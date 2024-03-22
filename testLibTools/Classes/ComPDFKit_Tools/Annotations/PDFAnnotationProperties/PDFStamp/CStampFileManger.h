//
//  CStampFileManger.h
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

#define kPDFStampDataFolder [NSHomeDirectory() stringByAppendingPathComponent:@"Library/PDFKitResources/Stamp"]
#define kPDFStampTextList   [NSHomeDirectory() stringByAppendingPathComponent:@"Library/PDFKitResources/Stamp/stamp_text.plist"]
#define kPDFStampImageList  [NSHomeDirectory() stringByAppendingPathComponent:@"Library/PDFKitResources/Stamp/stamp_image.plist"]

typedef enum : NSUInteger {
    PDFStampCustomType_Text,
    PDFStampCustomType_Image,
} PDFStampCustomType;

@interface CStampFileManger : NSObject

@property (nonatomic, strong) NSMutableArray *stampTextList;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *stampImageList;

@property (nonatomic, strong) NSMutableArray *deleteList;

- (void)readStampDataFromFile;

- (NSArray *)getTextStampData;

- (NSArray *)getImageStampData;

- (BOOL)saveStampDataToFile:(PDFStampCustomType)stampType;

- (BOOL)insertStampItem:(NSDictionary *)stampItem type:(PDFStampCustomType)stampType;

- (BOOL)removeStampItem:(NSInteger)index type:(PDFStampCustomType)stampType;

- (NSString *)saveStampWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
