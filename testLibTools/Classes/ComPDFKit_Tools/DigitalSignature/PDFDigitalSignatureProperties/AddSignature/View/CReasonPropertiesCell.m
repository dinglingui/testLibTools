//
//  CReasonPropertiesCell.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CReasonPropertiesCell.h"
#import "CPDFColorUtils.h"

@implementation CReasonPropertiesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

#pragma mark - Pubulic Methods

- (void)setCellLabel:(NSString *)label {
    if (!self.resonSelectLabel) {
        self.resonSelectLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.bounds.size.width-60, 50)];
    }
    self.resonSelectLabel.text = @"";
    self.resonSelectLabel.text = label;
    self.resonSelectLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.resonSelectLabel];
    self.backgroundColor = [CPDFColorUtils CAnnotationSampleBackgoundColor];
}

@end
