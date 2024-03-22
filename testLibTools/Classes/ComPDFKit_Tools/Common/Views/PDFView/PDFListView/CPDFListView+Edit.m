//
//  PDFListView+ContentEditor.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2023 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFListView+ContentEditor.h"
#import "CPDFListView+Private.h"

@implementation CPDFListView (ContentEditor)
 
- (NSArray<UIMenuItem *> *)menuItemsEditingAtPoint:(CGPoint)point forPage:(CPDFPage *)page{
    
    NSArray *menuItem = [super menuItemsEditingAtPoint:point forPage:page];
    
    self.menuPoint = point;
    self.menuPage = page;

    NSMutableArray *menuItems =[NSMutableArray array];
    if (menuItem) {
        [menuItems addObjectsFromArray:menuItem];
    }
    
    BOOL isCropMode = NO;
    if (self.editingArea.IsImageArea) {
        isCropMode = [(CPDFEditImageArea *)self.editingArea isCropMode];
    }
    
    UIMenuItem *editItem;
    UIMenuItem *copyItem;
    UIMenuItem *cutItem;
    UIMenuItem *deleteItem;
    UIMenuItem *pasteItem;
    UIMenuItem *pasteMatchStyleItem;
    
    for (UIMenuItem * item in menuItem) {
        if ([NSStringFromSelector(item.action) isEqualToString:@"editEditingItemAction:"]){
            editItem = item;
        } else  if ([NSStringFromSelector(item.action) isEqualToString:@"copyEditingItemAction:"]){
            copyItem = item;
        } else if([NSStringFromSelector(item.action) isEqualToString:@"cutEditingItemAction:"]){
            cutItem = item;
        } else if([NSStringFromSelector(item.action) isEqualToString:@"deleteEditingItemAction:"]){
            deleteItem = item;
        } else if ([NSStringFromSelector(item.action) isEqualToString:@"pastEditingItemAction:"]) {
            pasteItem = item;
        } else if ([NSStringFromSelector(item.action) isEqualToString:@"pasteMatchStyleEditingItemAction:"]) {
            pasteMatchStyleItem = item;
        }
    }
        
    if(self.editStatus == CEditingSelectStateEmpty){
        [menuItems removeAllObjects];
        if(self.editingLoadType == CEditingLoadTypeText){
            UIMenuItem *addTextItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Add Text", nil)
                                                                  action:@selector(addTextEditingItemAction:)];
            [menuItems addObject:addTextItem];
        }else if(self.editingLoadType == CEditingLoadTypeImage){
            UIMenuItem *addImageItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Add Image", nil)
                                                                   action:@selector(addImageEditingItemAction:)];
            [menuItems addObject:addImageItem];
        }
        
        if(pasteItem)
            [menuItems addObject:pasteItem];
        
        if(pasteMatchStyleItem)
            [menuItems addObject:pasteMatchStyleItem];
    }
    
    if(isCropMode){
        UIMenuItem * doneItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) action:@selector(doneActionClick:)];
        UIMenuItem * cancelItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) action:@selector(cancelActionClick:)];
        
        [menuItems addObject:doneItem];
        [menuItems addObject:cancelItem];
    }else{
        UIMenuItem * propertyItem  = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Properties", nil) action:@selector(propertyEditingItemAction:)];

        if(self.editingArea){
            if (self.editingArea.IsImageArea) {
                
                [menuItems removeAllObjects];
                
                UIMenuItem * leftRotateItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Rotate", nil) action:@selector(leftRotateCropActionClick:)];
                
                UIMenuItem * rPlaceItem  = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Replace", nil) action:@selector(replaceActionClick:)];
                
                UIMenuItem * cropItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Crop", nil) action:@selector(enterCropActionClick:)];
                
                UIMenuItem * opacityItem  = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Opacity", nil) action:@selector(opacityEditingItemAction:)];
                
                UIMenuItem * hMirrorItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Flip horizontal", nil) action:@selector(horizontalMirrorClick:)];
                UIMenuItem * vMirrorItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Flip vertical", nil) action:@selector(verticalMirrorClick:)];
                
                UIMenuItem * extractItem  = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Export", nil) action:@selector(extractActionClick:)];
                
                if(propertyItem)
                    [menuItems addObject:propertyItem];
                
                [menuItems addObject:leftRotateItem];
                [menuItems addObject:rPlaceItem];
                [menuItems addObject:extractItem];
                [menuItems addObject:opacityItem];
                [menuItems addObject:hMirrorItem];
                [menuItems addObject:vMirrorItem];
                if(cropItem)
                    [menuItems addObject:cropItem];
                if(cutItem)
                    [menuItems addObject:cutItem];
                if(copyItem)
                    [menuItems addObject:copyItem];
                if(deleteItem)
                    [menuItems addObject:deleteItem];
            }else if(self.editingArea.IsTextArea){
                CEditingSelectState state = self.editStatus;
                if (state == CEditingSelectStateEditSelectText) {
                    [menuItems removeAllObjects];
                    UIMenuItem * opacityItem  = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Opacity", nil) action:@selector(opacityEditingItemAction:)];

                    if(propertyItem)
                        [menuItems addObject:propertyItem];
                    if(opacityItem)
                        [menuItems addObject:opacityItem];
                    if(cutItem)
                        [menuItems addObject:cutItem];
                    if(copyItem)
                        [menuItems addObject:copyItem];
                    if(deleteItem)
                        [menuItems addObject:deleteItem];
                } else if(state == CEditingSelectStateEditTextArea) {
                    [menuItems removeAllObjects];

                    if(propertyItem)
                        [menuItems addObject:propertyItem];
                    if(editItem)
                        [menuItems addObject:editItem];
                    if(cutItem)
                        [menuItems addObject:cutItem];
                    if(copyItem)
                        [menuItems addObject:copyItem];
                    if(deleteItem)
                        [menuItems addObject:deleteItem];
                }
            }
        }
    }
    
    if([self.performDelegate respondsToSelector:@selector(PDFListView:customizeMenuItems:forPage:forPagePoint:)])
        return [self.performDelegate PDFListView:self customizeMenuItems:menuItems forPage:page forPagePoint:point];
    return menuItems;
}

- (void)leftRotateCropActionClick:(UIMenuItem*)menuItem {
    if([self.editingArea IsImageArea]) {
        [self rotateEditArea:(CPDFEditImageArea *)self.editingArea rotateAngle:-90];
    }
}

- (void)addTextEditingItemAction:(UIMenuItem*)menuItem{
    CPDFPage *page = self.menuPage;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    CGRect rect = CGRectMake(self.menuPoint.x, self.menuPoint.y, 60.0, 20);
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:style forKey:NSParagraphStyleAttributeName];
    [dic setValue:[UIColor blueColor] forKey:NSForegroundColorAttributeName];
    [dic setValue:[UIFont fontWithName:@"Helvetica-Bold" size:18.0] forKey:NSFontAttributeName];
    
    [self createEmptyStringBounds:rect withAttributes:dic page:page];
}
- (void)addImageEditingItemAction:(UIMenuItem*)menuItem{
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)doneActionClick:(UIMenuItem*)menuItem{
    CPDFEditImageArea * editArea = (CPDFEditImageArea *)self.editingArea;
    [self cropEditArea:editArea withRect:editArea.cropRect];
    [self endCropEditArea:editArea];
}

- (void)cancelActionClick:(UIMenuItem*)menuItem{
    [self endCropEditArea:(CPDFEditImageArea*)self.editingArea];
}

- (void)deleteActionClick:(UIMenuItem*)menuItem{
    [self deleteEditingArea:self.editingArea];
}

- (void)replaceActionClick:(UIMenuItem*)menuItem{
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)propertyEditingItemAction:(UIMenuItem*)menuItem {
    if(self.performDelegate && [self.performDelegate respondsToSelector:@selector(PDFListViewContentEditProperty:point:)]){
        [self.performDelegate PDFListViewContentEditProperty:self point:self.menuPoint];
    }
}

- (void)opacityEditingItemAction:(UIMenuItem*)menuItem{
    NSMutableArray *menuItems = [NSMutableArray array];
    UIMenuItem *opacity25Item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"25%", nil)
                                                            action:@selector(opacity25ItemAction:)];
    UIMenuItem *opacity50Item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"50%", nil)
                                                            action:@selector(opacity50ItemAction:)];
    UIMenuItem *opacity75Item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"75%", nil)
                                                            action:@selector(opacity75ItemAction:)];
    UIMenuItem *opacity100Item = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"100%", nil)
                                                             action:@selector(opacity100ItemAction:)];
    [menuItems addObject:opacity25Item];
    [menuItems addObject:opacity50Item];
    [menuItems addObject:opacity75Item];
    [menuItems addObject:opacity100Item];
    
    
    CGRect bounds = self.editingArea.bounds;
    bounds = CGRectInset(bounds, -15, -15);
    CGRect rect = [self convertRect:bounds fromPage:self.editingArea.page];
    [self becomeFirstResponder];
    [UIMenuController sharedMenuController].menuItems = menuItems;
    [[UIMenuController sharedMenuController] setTargetRect:rect inView:self];
    [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
}

- (void)opacity25ItemAction:(id)sender {
    [self setCharsFontTransparency:0.25];
}

- (void)opacity50ItemAction:(id)sender {
    [self setCharsFontTransparency:0.5];
}

- (void)opacity75ItemAction:(id)sender {
    [self setCharsFontTransparency:0.75];
}

- (void)opacity100ItemAction:(id)sender {
    [self setCharsFontTransparency:1.0];
}

#pragma mark - imagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    if (@available(iOS 11.0, *)) {
     NSURL * url = info[UIImagePickerControllerImageURL];
        if(self.editStatus == CEditingSelectStateEmpty){
            UIImage * image = [[UIImage alloc] initWithContentsOfFile:url.path];
            
            CGFloat img_width = 0;
            CGFloat img_height = 0;
            CGFloat scaled_width = 149;
            CGFloat scaled_height = 210;
            

            if(image.imageOrientation!=UIImageOrientationUp){
                // Adjust picture Angle
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                img_width = image.size.height;
                img_height = image.size.width;
            }else{
                img_width = image.size.width;
                img_height = image.size.height;
            }
            
            CGFloat scaled = MIN(scaled_width/img_width, scaled_height/img_height);
            scaled_height =  img_height*scaled;
            scaled_width =  img_width*scaled;

            CGRect rect = CGRectMake(self.menuPoint.x, self.menuPoint.y, scaled_width, scaled_height);
            [self createEmptyImage:rect page:self.menuPage path:url.path];
        }else{
            [self replaceEditImageArea:(CPDFEditImageArea *)self.editingArea imagePath:url.path];
        }

    } else {
        NSURL * url = info[UIImagePickerControllerMediaURL];
        if(self.editStatus == CEditingSelectStateEmpty){
            UIImage * image = [[UIImage alloc] initWithContentsOfFile:url.path];
            
            CGFloat img_width = 0;
            CGFloat img_height = 0;
            CGFloat scaled_width = 14;
            CGFloat scaled_height = 0;

            if(image.imageOrientation!=UIImageOrientationUp){
                        // Adjust picture Angle
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                img_width = image.size.height;
                img_height = image.size.width;
            }else{
                img_width = image.size.width;
                img_height = image.size.height;
            }
            scaled_height =  scaled_width*img_height/img_width;
            
            CGRect rect = CGRectMake(self.menuPoint.x, self.menuPoint.y, scaled_width, scaled_height);
            [self createEmptyImage:rect page:self.menuPage path:url.path];
        }else{
            [self replaceEditImageArea:(CPDFEditImageArea *)self.editingArea imagePath:url.path];
        }

    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



- (void)extractActionClick:(UIMenuItem*)menuItem{
    BOOL saved = [self extractImageWithEditImageArea:(CPDFEditImageArea*)self.editingArea];
    
    if(saved){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Export Successfully!", nil) preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK!", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([tRootViewControl presentedViewController]) {
            tRootViewControl = [tRootViewControl presentedViewController];
        }

        [tRootViewControl presentViewController:alertController animated:YES completion:nil];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Export Failed!", nil) preferredStyle:UIAlertControllerStyleAlert];

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK!", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        UIViewController *tRootViewControl = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([tRootViewControl presentedViewController]) {
            tRootViewControl = [tRootViewControl presentedViewController];
        }
        [tRootViewControl presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)horizontalMirrorClick:(UIMenuItem*)menuItem{
    [self horizontalMirrorEditArea:(CPDFEditImageArea*)self.editingArea];
}

- (void)verticalMirrorClick:(UIMenuItem*)menuItem{
    [self verticalMirrorEditArea:(CPDFEditImageArea*)self.editingArea];
}


- (void)enterCropActionClick:(UIMenuItem*)menuItem{
    [self beginCropEditArea:(CPDFEditImageArea*)self.editingArea];
}

@end
