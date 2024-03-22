//
//  CPDFPopMenuItem.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFPopMenuItem.h"

@interface CPDFPopMenuItem()
@property (weak, nonatomic) IBOutlet UIView *splitView;

@end

@implementation CPDFPopMenuItem

+(instancetype)LoadCPDFPopMenuItem {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [[bundle loadNibNamed:@"CPDFPopMenuItem" owner:nil options:nil] lastObject];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.splitView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.12];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)hiddenLineView:(BOOL)isHidden {
    self.splitView.hidden = isHidden;
}

@end
