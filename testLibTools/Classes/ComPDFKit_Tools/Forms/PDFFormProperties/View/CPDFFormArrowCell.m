//
//  CPDFFormArrowCell.m
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFFormArrowCell.h"
#if __has_include(<ComPDFKit_Tools/ComPDFKit_Tools.h>)
#import <ComPDFKit_Tools/ComPDFKit_Tools.h>
#else
#import "ComPDFKit_Tools.h"
#endif
@interface CPDFFormArrowCell()

@property (nonatomic, strong) UIImageView * selectView;

@property (nonatomic, strong) UIImageView * iconView;

@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation CPDFFormArrowCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.selectView.frame) + 10, 15, 20, 20)];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.iconView.frame) + 10, 15, 100, 20);
        self.titleLabel.font  = [UIFont systemFontOfSize:13];
        self.titleLabel.textColor = [CPDFColorUtils CPageEditToolbarFontColor];
        
        [self.contentView addSubview:self.selectView];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
        
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
}

- (void)setModel:(CPDFFormArrowModel *)model {
    _model = model;
    if(model.isSelected) {
        self.selectView.image = [UIImage imageNamed:@"CPDFFormOptionOn" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];;
    }else{
        self.selectView.image = [UIImage imageNamed:@"CPDFFormOptionOff" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];;
    }
    self.iconView.image = model.iconImage;
    self.titleLabel.text = model.title;
}

@end
