//
//  CStampFileManger.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CStampFileManger.h"

@implementation CStampFileManger

#pragma mark - Init Method
- (id)init
{
    self = [super init];
    if (self) {
        _deleteList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSString *)getDateTime
{
    NSTimeZone* timename = [NSTimeZone systemTimeZone];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init ];
    [outputFormatter setTimeZone:timename ];
    
    NSString *tDate = nil;
    
    [outputFormatter setDateFormat:@"YYYYMMddHHmmss"];
    tDate = [outputFormatter stringFromDate:[NSDate date]];
    
    return tDate;
}

#pragma mark - File Manager

- (void)readStampDataFromFile {
    [self readCustomStamp_TextStamp];
    [self readCustomStamp_ImageStamp];
}

- (void)readCustomStamp_TextStamp {
    NSFileManager *tManager = [NSFileManager defaultManager];
    if (![tManager fileExistsAtPath:kPDFStampTextList])
    {
        _stampTextList = [[NSMutableArray alloc] init];
    }
    else
    {
        if (_stampTextList)
        {
            _stampTextList = nil;
        }
        
        _stampTextList = [NSMutableArray arrayWithContentsOfFile:kPDFStampTextList];
        if (_stampTextList == nil) {
            _stampTextList = [[NSMutableArray alloc] init];
        }
    }
}

- (void)readCustomStamp_ImageStamp {
    NSFileManager *tManager = [NSFileManager defaultManager];
    if (![tManager fileExistsAtPath:kPDFStampImageList])
    {
        _stampImageList = [[NSMutableArray alloc] init];
    }
    else
    {
        if (_stampImageList)
        {
            _stampImageList = nil;
        }
        
        _stampImageList = [NSMutableArray arrayWithContentsOfFile:kPDFStampImageList];
        if (_stampImageList == nil) {
            _stampImageList = [[NSMutableArray alloc] init];
        }
    }
}

- (NSArray *)getTextStampData {
    return _stampTextList;
}

- (NSArray *)getImageStampData {
    return _stampImageList;
}

- (NSString *)saveStampWithImage:(UIImage *)image {
    NSFileManager *tManager = [NSFileManager defaultManager];
    NSData *imageData = UIImagePNGRepresentation(image);
    
    if (imageData == nil || [imageData length] <= 0)
        return nil;
    
    NSString *tName = [self getDateTime];
    NSString *tPath = [kPDFStampDataFolder stringByAppendingFormat:@"/%@.png",tName];
    
    if ([imageData writeToFile:tPath atomically:NO]) {
        return tPath;
    }
    else
    {
        NSString *tPath_dic = kPDFStampDataFolder;
        BOOL tIsDirectory = NO;
        while (1)
        {
            if ([tManager fileExistsAtPath:tPath_dic isDirectory:&tIsDirectory]) {
                if (tIsDirectory)
                    break;
            }
            else
            {
                [tManager createDirectoryAtPath:tPath_dic withIntermediateDirectories:NO attributes:nil error:nil];
            }
            tPath_dic = [tPath_dic stringByDeletingLastPathComponent];
        }
        if ([imageData writeToFile:tPath atomically:NO]) {
            return tPath;
        }
    }
    
    return nil;
}

- (void)removeStampImage {
    for (NSDictionary *tDict in _deleteList)
    {
        NSString *tPath = [tDict objectForKey:@"path"];
        NSFileManager *tFileManager = [NSFileManager defaultManager];
        [tFileManager removeItemAtPath:tPath error:nil];
    }
}

- (BOOL)saveStampDataToFile:(PDFStampCustomType)stampType {
    NSFileManager *tManager = [NSFileManager defaultManager];
    
    switch (stampType)
    {
        case PDFStampCustomType_Text:
            if ([_stampTextList writeToFile:kPDFStampTextList atomically:NO])
            {
                return YES;
            }
            else
            {
                NSString *tPath_dic = kPDFStampTextList;
                BOOL tIsDirectory = NO;
                while (1)
                {
                    tPath_dic = [tPath_dic stringByDeletingLastPathComponent];
                    
                    if ([tManager fileExistsAtPath:tPath_dic isDirectory:&tIsDirectory]) {
                        if (tIsDirectory)
                            break;
                    }
                    else
                    {
                        [tManager createDirectoryAtPath:tPath_dic withIntermediateDirectories:NO attributes:nil error:nil];
                    }
                }
                if ([_stampTextList writeToFile:kPDFStampTextList atomically:NO])
                {
                    return YES;
                }
            }
            return NO;
            
        case PDFStampCustomType_Image:
            if ([_stampImageList writeToFile:kPDFStampImageList atomically:NO])
            {
                return YES;
            }
            else
            {
                NSString *tPath_dic = kPDFStampImageList;
                BOOL tIsDirectory = NO;
                while (1)
                {
                    tPath_dic = [tPath_dic stringByDeletingLastPathComponent];
                    
                    if ([tManager fileExistsAtPath:tPath_dic isDirectory:&tIsDirectory]) {
                        if (tIsDirectory)
                            break;
                    }
                    else
                    {
                        [tManager createDirectoryAtPath:tPath_dic withIntermediateDirectories:NO attributes:nil error:nil];
                    }
                }
                if ([_stampImageList writeToFile:kPDFStampImageList atomically:NO])
                {
                    return YES;
                }
            }
            return NO;
            
        default:
            return NO;
    }
}

- (BOOL)insertStampItem:(NSDictionary *)stampItem type:(PDFStampCustomType)stampType {
    switch (stampType)
    {
        case PDFStampCustomType_Text:
            if (!_stampTextList) {
                [self readCustomStamp_TextStamp];
            }
            
            if (stampItem)
            {
                [_stampTextList insertObject:stampItem atIndex:0];
                if ([self saveStampDataToFile:PDFStampCustomType_Text])
                    return YES;
                else
                    return NO;
            }
            else
                return NO;
            
        case PDFStampCustomType_Image:
            if (!_stampImageList) {
                [self readCustomStamp_ImageStamp];
            }
            
            if (stampItem)
            {
                [_stampImageList insertObject:stampItem atIndex:0];
                if ([self saveStampDataToFile:PDFStampCustomType_Image])
                    return YES;
                else
                    return NO;
            }
            else
                return NO;
            
        default:
            return NO;
    }
}

- (BOOL)removeStampItem:(NSInteger)index type:(PDFStampCustomType)stampType {
    switch (stampType)
    {
        case PDFStampCustomType_Text:
            if (!_stampTextList) {
                [self readCustomStamp_TextStamp];
            }
            
            if (index >= 0 && index <= [_stampTextList count])
            {
                [_stampTextList removeObjectAtIndex:index];
                if ([self saveStampDataToFile:PDFStampCustomType_Text])
                    return YES;
                else
                    return NO;
            }
            else
                return NO;
            
        case PDFStampCustomType_Image:
            if (!_stampImageList) {
                [self readCustomStamp_ImageStamp];
            }
            
            if (index >= 0 && index < [_stampImageList count])
            {
                if (!_deleteList) {
                    _deleteList = [[NSMutableArray alloc] init];
                }
                NSDictionary *tDict = [_stampImageList objectAtIndex:index];
                [_deleteList addObject:tDict];
                
                [_stampImageList removeObjectAtIndex:index];
                if ([self saveStampDataToFile:PDFStampCustomType_Image])
                    return YES;
                else
                    return NO;
            }
            else
                return NO;
            
        default:
            return NO;
    }
}

@end
