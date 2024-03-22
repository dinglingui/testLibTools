//
//  CReasonPropertiesViewController.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CReasonPropertiesViewController;

@protocol CReasonPropertiesViewControllerDelegate <NSObject>

@optional

- (void)CReasonPropertiesViewController:(CReasonPropertiesViewController *)reasonPropertiesViewController properties:(NSString *)properties isReason:(BOOL)isReason;

@end

@interface CReasonPropertiesViewController : UIViewController

@property (nonatomic, weak) id<CReasonPropertiesViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *resonProperties;

@property (nonatomic, assign) BOOL isReason;

@end

NS_ASSUME_NONNULL_END
