//
//  CDigitalPropertyTableView.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CDigitalPropertyTableView;

@protocol CDigitalPropertyTableViewDelegate <NSObject>

- (void)digitalPropertyTableViewSelect:(CDigitalPropertyTableView *)digitalPropertyTableView text:(NSString *)text index:(NSInteger)index;

@end

@interface CDigitalPropertyTableView : UIView

@property (nonatomic, weak) id<CDigitalPropertyTableViewDelegate> delegate;
 
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) NSString *data;

- (void)showinView:(UIView *)superView;

- (instancetype)initWithFrame:(CGRect)frame height:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
