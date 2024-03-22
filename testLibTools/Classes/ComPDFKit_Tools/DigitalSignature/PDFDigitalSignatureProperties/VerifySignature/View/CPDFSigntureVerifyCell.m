//
//  CPDFSigntureVerifyCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFSigntureVerifyCell.h"
#import "CPDFColorUtils.h"

@interface CPDFSigntureVerifyCell ()

@end

@implementation CPDFSigntureVerifyCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    _verifyConetentView.layer.borderWidth = 1.0;
    self.verifyConetentView.backgroundColor = [CPDFColorUtils CViewBackgroundColor];
    self.verifyConetentView.layer.cornerRadius = 5.0;
    
    _stateLabel.text = NSLocalizedString(@"Status:", nil);
    _expiredDateLabel.text = NSLocalizedString(@"Date:", nil);
    _grantorLabel.text = NSLocalizedString(@"Signed by:", nil);
    _grantorsubLabel.numberOfLines = 0;
    _grantorsubLabel.adjustsFontSizeToFitWidth = YES;
    self.stateSubLabel.adjustsFontSizeToFitWidth = YES;
    
    _deleteButton.titleLabel.text = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Action

- (IBAction)buttonClickItem_Delete:(id)sender {
    if(self.deleteCallback) {
        self.deleteCallback();
    }
}


@end
