//
//  CPDFInfoTableCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFInfoTableCell.h"

NSString* kDocumentInfoTitle = @"kDocumentInfoTitle";
NSString* kDocumentInfoValue = @"kDocumentInfoValue";

@implementation CPDFInfoTableCell
@synthesize dataDictionary;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self)
    {
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.opaque = NO;
        titleLabel.textColor = [UIColor colorWithRed:102./255. green:102/255. blue:102/255. alpha:1];
        titleLabel.highlightedTextColor = [UIColor lightGrayColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:13];
        titleLabel.numberOfLines = 2;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        
        
        infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.opaque = NO;
        infoLabel.textColor = [UIColor colorWithRed:20/255. green:96/255. blue:243/255. alpha:1];
        infoLabel.highlightedTextColor = [UIColor lightGrayColor];
        infoLabel.font = [UIFont boldSystemFontOfSize:13];
        infoLabel.numberOfLines = 2;
        infoLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:infoLabel];
        
        CGRect contentRect = [self.contentView bounds];
        titleLabel.frame = CGRectMake(10 , -2, contentRect.size.width/2-50, contentRect.size.height);
        infoLabel.frame = CGRectMake(contentRect.size.width/2-35 , -2, contentRect.size.width/2, contentRect.size.height);
        
    }
    return self;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentRect = [self.contentView bounds];
    titleLabel.frame = CGRectMake(16 , -2, contentRect.size.width/2-16, contentRect.size.height);
    infoLabel.frame = CGRectMake(contentRect.size.width/2-16 , -2, contentRect.size.width/2, contentRect.size.height);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)setDataDictionary:(NSMutableDictionary *)newDictionary
{
    
    titleLabel.text = [newDictionary objectForKey:kDocumentInfoTitle];
    infoLabel.text = [newDictionary objectForKey:kDocumentInfoValue];
    
    [self setNeedsLayout];
}


@end
