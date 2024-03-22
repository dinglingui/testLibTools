//
//  CLocationPropertiesViewController.h
//  ComPDFKit_Tools
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CLocationPropertiesViewController;

@protocol CLocationPropertiesViewControllerDelegate <NSObject>

@optional

- (void)CLocationPropertiesViewController:(CLocationPropertiesViewController *)locationPropertiesViewController properties:(NSString *)properties isLocation:(BOOL)isLocation;

@end

@interface CLocationPropertiesViewController : UIViewController

@property (nonatomic, weak) id<CLocationPropertiesViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *loactionProperties;

@property (nonatomic, assign) BOOL isLocation;

@end

NS_ASSUME_NONNULL_END
