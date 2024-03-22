//
//  CPDFListView+Annotation.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFListView+Annotation.h"

#import "CPDFListView+Private.h"
#import "CAnnotStyle.h"

#import <MobileCoreServices/UTCoreTypes.h>

@implementation CPDFListView (Annotation)

#pragma mark - Private method

- (UIImage *)compressImage:(UIImage *)image size:(CGSize)size {
    CGFloat imageScale = 1.0;
    if (image.size.width > size.width || image.size.height > size.height) {
        imageScale = MIN(size.width / image.size.width, size.height / image.size.height);
    }
    CGSize newSize = CGSizeMake(image.size.width * imageScale, image.size.height * imageScale);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)updateScrollEnabled {
    if (self.activeAnnotation) {
        self.scrollEnabled = NO;
    } else {
        if (CPDFViewAnnotationModeLink == self.annotationMode) {
            self.scrollEnabled = NO;
        } else {
            self.scrollEnabled = YES;
        }
    }
}

- (BOOL)isPasteboardValid {
    NSString *textType = (NSString *)kUTTypeText;
    NSString *urlType  = (NSString*)kUTTypeURL;
    NSString *urlFileType  = (NSString*)kUTTypeFileURL;
    NSString *jpegImageType = (NSString *)kUTTypeJPEG;
    NSString *pngImageType = (NSString *)kUTTypePNG;
    NSString *rawImageType = @"com.apple.uikit.image";
    return [[UIPasteboard generalPasteboard] containsPasteboardTypes:[NSArray arrayWithObjects:textType, urlType, urlFileType, jpegImageType, pngImageType, rawImageType, nil]];
}

- (void)showMenuForAnnotation:(CPDFAnnotation *)annotation {
    if (!annotation) {
        [UIMenuController sharedMenuController].menuItems = nil;
        if (@available(iOS 13.0, *)) {
            [[UIMenuController sharedMenuController] hideMenuFromView:self];
        } else {
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        }
        return;
    }
    
    UIMenuItem *editNoteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil)
                                                       action:@selector(menuItemClick_Edit:)];
    
    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil)
                                                        action:@selector(menuItemClick_Delete:)];
    
    UIMenuItem *propertiesItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Properties", nil)
                                                        action:@selector(menuItemClick_Properties:)];
    
    UIMenuItem *noteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Note", nil)
                                                        action:@selector(menuItemClick_Note:)];
    
    NSMutableArray *menuItems = [NSMutableArray array];
    if([annotation isKindOfClass:[CPDFTextAnnotation class]]) {
        
    } else if([annotation isKindOfClass:[CPDFMarkupAnnotation class]] ||
              [annotation isKindOfClass:[CPDFInkAnnotation class]] ||
              [annotation isKindOfClass:[CPDFCircleAnnotation class]] ||
              [annotation isKindOfClass:[CPDFSquareAnnotation class]] ||
              [annotation isKindOfClass:[CPDFLineAnnotation class]]) {
        [menuItems addObject:propertiesItem];
        [menuItems addObject:noteItem];
        [menuItems addObject:deleteItem];
    } else if ([annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
        [menuItems addObject:propertiesItem];
        [menuItems addObject:editNoteItem];
        [menuItems addObject:deleteItem];
    } else if ([annotation isKindOfClass:[CPDFStampAnnotation class]]) {
        [menuItems addObject:noteItem];
        [menuItems addObject:deleteItem];
    } else if ([annotation isKindOfClass:[CPDFSoundAnnotation class]] ||
               [annotation isKindOfClass:[CPDFMovieAnnotation  class]]) {
        if ([annotation isKindOfClass:[CPDFSoundAnnotation class]]) {
            UIMenuItem *playItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Play", nil)
                                                              action:@selector(menuItemClick_Play:)];
            [menuItems addObject:playItem];
        }
        [menuItems addObject:deleteItem];
    }  else if ([annotation isKindOfClass:[CPDFLinkAnnotation class]]) {
        [menuItems addObject:editNoteItem];
        [menuItems addObject:deleteItem];
    } else if ([annotation isKindOfClass:[CPDFSignatureAnnotation class]]) {
        UIMenuItem *addHereItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Sign", nil)
                                                             action:@selector(menuItemClick_Signature:)];

        [menuItems addObject:addHereItem];
        [menuItems addObject:deleteItem];
    }
    
    if (menuItems.count <= 0) {
        return;
    }
    
    CGRect bounds = annotation.bounds;
    if([self.performDelegate respondsToSelector:@selector(PDFListView:customizeMenuItems:forPage:forPagePoint:)]) {
        NSArray *customizeMenuItems = [self.performDelegate PDFListView:self customizeMenuItems:menuItems forPage:annotation.page forPagePoint:bounds.origin];
        if(customizeMenuItems && customizeMenuItems > 0) {
            menuItems = [NSMutableArray arrayWithArray:customizeMenuItems];
        } else {
            [menuItems removeAllObjects];
        }
    }
    
    if(annotation && annotation.page) {
        bounds = CGRectInset(bounds, -15, -15);
        CGRect rect = [self convertRect:bounds fromPage:annotation.page];
        [UIMenuController sharedMenuController].menuItems = menuItems;
        [self becomeFirstResponder];
        if (@available(iOS 13.0, *)) {
            [[UIMenuController sharedMenuController] showMenuFromView:self rect:rect];
        } else {
            [[UIMenuController sharedMenuController] setTargetRect:rect inView:self];
            [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
        }
    }
}

- (void)showMenuForMediaAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    NSMutableArray *menuItems = [NSMutableArray array];
    UIMenuItem *cancelItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil)
                                                        action:@selector(menuItemClick_MediaDelete:)];
    
    UIMenuItem *mediaRecordItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Record", nil)
                                                         action:@selector(menuItemClick_MediaRecord:)];
    [menuItems addObject:mediaRecordItem];
    [menuItems addObject:cancelItem];
    
    CGRect bounds = CGRectMake(point.x-18, point.y-18, 37, 37);
    CGRect rect = [self convertRect:bounds fromPage:page];
    
    if([self.performDelegate respondsToSelector:@selector(PDFListView:customizeMenuItems:forPage:forPagePoint:)]) {
        NSArray *customizeMenuItems = [self.performDelegate PDFListView:self customizeMenuItems:menuItems forPage:page forPagePoint:bounds.origin];
        if(customizeMenuItems && customizeMenuItems > 0) {
            menuItems = [NSMutableArray arrayWithArray:customizeMenuItems];
        } else {
            [menuItems removeAllObjects];
        }
    }
    
    [self becomeFirstResponder];
    [UIMenuController sharedMenuController].menuItems = menuItems;
    if (@available(iOS 13.0, *)) {
        [[UIMenuController sharedMenuController] showMenuFromView:self rect:rect];
    } else {
        [[UIMenuController sharedMenuController] setTargetRect:rect inView:self];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}

#pragma mark - Action

- (void)menuItemClick_Edit:(UIMenuItem *)menuItem {
    if([self.activeAnnotation isKindOfClass:[CPDFTextAnnotation class]] || [self.activeAnnotation isKindOfClass:[CPDFLinkAnnotation class]]) {
        if ([self.performDelegate respondsToSelector:@selector(PDFListViewEditNote:forAnnotation:)]) {
            [self.performDelegate PDFListViewEditNote:self forAnnotation:self.activeAnnotation];
        }
    } else if([self.activeAnnotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
        [self editAnnotationFreeText:(CPDFFreeTextAnnotation *)self.activeAnnotation];
        [self updateActiveAnnotations:@[]];
    }
}

- (void)menuItemClick_Delete:(UIMenuItem *)menuItem {
    [self.activeAnnotation.page removeAnnotation:self.activeAnnotation];
    [self setNeedsDisplayForPage:self.activeAnnotation.page];
    [self updateActiveAnnotations:@[]];
    [self updateScrollEnabled];
}

- (void)menuItemClick_Note:(UIMenuItem *)menuItem {
    if ([self.performDelegate respondsToSelector:@selector(PDFListViewEditNote:forAnnotation:)]) {
        [self.performDelegate PDFListViewEditNote:self forAnnotation:self.activeAnnotation];
    }
}

- (void)menuItemClick_Properties:(UIMenuItem *)menuItem {
    if ([self.performDelegate respondsToSelector:@selector(PDFListViewEditProperties:forAnnotation:)]) {
        [self.performDelegate PDFListViewEditProperties:self forAnnotation:self.activeAnnotation];
    }
}

- (void)menuItemClick_Signature:(UIMenuItem *)menuItem {
    if ([self.activeAnnotation isKindOfClass:[CPDFSignatureAnnotation class]]) {
        [(CPDFSignatureAnnotation *)self.activeAnnotation signature];
        
        [self setNeedsDisplayForPage:self.activeAnnotation.page];
        [self updateActiveAnnotations:@[]];
        [self updateScrollEnabled];
    }
}

- (void)menuItemClick_Paste:(UIMenuItem *)menuItem {
    NSString *textType = (NSString *)kUTTypeText;
    NSString *utf8TextType = (NSString *)kUTTypeUTF8PlainText;
    NSString *urlType  = (NSString*)kUTTypeURL;
    NSString *urlFileType  = (NSString*)kUTTypeFileURL;
    NSString *jpegImageType = (NSString *)kUTTypeJPEG;
    NSString *pngImageType = (NSString *)kUTTypePNG;
    NSString *rawImageType = @"com.apple.uikit.image";
    
    NSArray *pasteArray = [UIPasteboard generalPasteboard].items;
    for (NSDictionary* dic in pasteArray) {
        if ([dic objectForKey:textType] ||
            [dic objectForKey:utf8TextType] ||
            [dic objectForKey:urlType] ||
            [dic objectForKey:urlFileType]) {
            NSString *contents = nil;
            if ([dic objectForKey:textType] ||
                [dic objectForKey:utf8TextType]) {
                contents = [UIPasteboard generalPasteboard].string;
            } else {
                contents = [[UIPasteboard generalPasteboard].URL absoluteString];
            }
            UIFont *font = [UIFont systemFontOfSize:12.0];
            NSDictionary *attributes = @{NSFontAttributeName : font};
            CGRect bounds = [contents boundingRectWithSize:CGSizeMake(280, MAXFLOAT)
                                                   options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                attributes:attributes
                                                   context:nil];
            
            CPDFFreeTextAnnotation *annotation = [[CPDFFreeTextAnnotation alloc] initWithDocument:self.document];
            [annotation setContents:contents];
            [annotation setModificationDate:[NSDate date]];
            [annotation setUserName:[self annotationUserName]];
            annotation.bounds = CGRectMake(self.menuPoint.x-bounds.size.width/2.0,
                                           self.menuPoint.y-bounds.size.height/2.0,
                                           bounds.size.width, bounds.size.height);
            [self.menuPage addAnnotation:annotation];
            [self setNeedsDisplayForPage:self.menuPage];
        } else if ([dic objectForKey:jpegImageType] ||
                   [dic objectForKey:pngImageType] ||
                   [dic objectForKey:rawImageType]) {
            UIImage *image = [UIPasteboard generalPasteboard].image;
            UIImage *compressImage = [self compressImage:image size:CGSizeMake(240.0, 240.0)];
            
            CPDFStampAnnotation *annotation = [[CPDFStampAnnotation alloc] initWithDocument:self.document image:compressImage];
            [annotation setModificationDate:[NSDate date]];
            [annotation setUserName:[self annotationUserName]];
            annotation.bounds = CGRectMake(self.menuPoint.x-compressImage.size.width/2.0,
                                           self.menuPoint.y-compressImage.size.height/2.0,
                                           compressImage.size.width, compressImage.size.height);
            [self.menuPage addAnnotation:annotation];
            [self setNeedsDisplayForPage:self.menuPage];
        }
    }
}

- (void)menuItemClick_TextNote:(UIMenuItem *)menuItem {
    if (self.currentSelection) {
        NSMutableArray *quadrilateralPoints = [NSMutableArray array];
        CPDFMarkupAnnotation *annotation = [[CPDFMarkupAnnotation alloc] initWithDocument:self.document markupType:CPDFMarkupTypeHighlight];
        for (CPDFSelection *selection in self.currentSelection.selectionsByLine) {
            CGRect bounds = selection.bounds;
            [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds))]];
            [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))]];
            [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds))]];
            [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds))]];
        }
        [annotation setQuadrilateralPoints:quadrilateralPoints];
        [annotation setMarkupText:self.currentSelection.string];
        [annotation setModificationDate:[NSDate date]];
        [annotation setUserName:[self annotationUserName]];
        [self.currentSelection.page addAnnotation:annotation];
        [annotation createPopup];
        
        [self clearSelection];
        [self setNeedsDisplayForPage:annotation.page];
    } else {
        [self addAnnotation:CPDFViewAnnotationModeNote atPoint:self.menuPoint forPage:self.menuPage];
    }
}

- (void)menuItemClick_FreeText:(UIMenuItem *)menuItem {
    [self addAnnotationFreeTextAtPoint:self.menuPoint forPage:self.menuPage];
}

- (void)menuItemClick_Stamp:(UIMenuItem *)menuItem {
    if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformAddStamp:atPoint:forPage:)]) {
        [self.performDelegate PDFListViewPerformAddStamp:self atPoint:self.menuPoint forPage:self.menuPage];
    }
}

- (void)menuItemClick_Image:(UIMenuItem *)menuItem {
    if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformAddImage:atPoint:forPage:)]) {
        [self.performDelegate PDFListViewPerformAddImage:self atPoint:self.menuPoint forPage:self.menuPage];
    }
}

- (void)menuItemClick_Play:(UIMenuItem *)menuItem {
    if ([self.activeAnnotation isKindOfClass:[CPDFSoundAnnotation class]]) {
        if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformPlay:forAnnotation:)]) {
            [self.performDelegate PDFListViewPerformPlay:self forAnnotation:(CPDFSoundAnnotation *)self.activeAnnotation];
        }
    }
}

- (void)menuItemClick_MediaDelete:(UIMenuItem *)menuItem  {
    CGPoint point = CGPointMake(CGRectGetMidX(self.mediaSelectionRect), CGRectGetMidY(self.mediaSelectionRect));
    CPDFPage *page = self.mediaSelectionPage;
    if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformCancelMedia:atPoint:forPage:)]) {
        [self.performDelegate PDFListViewPerformCancelMedia:self atPoint:point forPage:page];
    }
    
    self.mediaSelectionPage = nil;
    [self setNeedsDisplayForPage:page];
}

- (void)menuItemClick_MediaRecord:(UIMenuItem *)menuItem {
    CGPoint point = CGPointMake(CGRectGetMidX(self.mediaSelectionRect), CGRectGetMidY(self.mediaSelectionRect));
    CPDFPage *page = self.mediaSelectionPage;
    if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformRecordMedia:atPoint:forPage:)]) {
        [self.performDelegate PDFListViewPerformRecordMedia:self atPoint:point forPage:page];
    }
}

#pragma mark - Menu

- (NSArray<UIMenuItem *> *)annotationMenuItemsAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    self.menuPoint = point;
    self.menuPage = page;
    NSMutableArray *menuItems = [NSMutableArray array];

    if(self.currentSelection) {
        NSArray * menus = [super menuItemsAtPoint:point forPage:page];
        if(menus && menus.count > 0)
             menuItems = [NSMutableArray arrayWithArray:menus];
    } else  {
        UIMenuItem *pasteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Paste", nil)
                                                           action:@selector(menuItemClick_Paste:)];
        if ([self isPasteboardValid]) {
            [menuItems addObject:pasteItem];
        }
        UIMenuItem *textNoteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Note", nil)
                                                              action:@selector(menuItemClick_TextNote:)];
        UIMenuItem *textItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Text", nil)
                                                          action:@selector(menuItemClick_FreeText:)];
        UIMenuItem *stampItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Stamp", nil)
                                                           action:@selector(menuItemClick_Stamp:)];
        UIMenuItem *imageItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Image", nil)
                                                           action:@selector(menuItemClick_Image:)];
        [menuItems addObject:textNoteItem];
        [menuItems addObject:textItem];
        [menuItems addObject:stampItem];
        [menuItems addObject:imageItem];
    }
        
    return menuItems;
}

#pragma mark - Touch

- (void)annotationTouchBeganAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if (self.textSelectionMode) {
    } else {
        self.addAnnotationPoint = point;
        self.addAnnotationRect = CGRectZero;
        
        self.draggingType = CPDFAnnotationDraggingNone;
        if (!self.activeAnnotation || self.activeAnnotation.page != page) {
            return;
        }
        CGRect topLeftRect = CGRectInset(self.topLeftRect, -5, -5);
        CGRect bottomLeftRect = CGRectInset(self.bottomLeftRect, -5, -5);
        CGRect topRightRect = CGRectInset(self.topRightRect, -5, -5);
        CGRect bottomRightRect = CGRectInset(self.bottomRightRect, -5, -5);
        CGRect startPointRect = CGRectInset(self.startPointRect, -5, -5);
        CGRect endPointRect = CGRectInset(self.endPointRect, -5, -5);
        if (CGRectContainsPoint(topLeftRect, point)) {
            self.draggingType = CPDFAnnotationDraggingTopLeft;
        } else if (CGRectContainsPoint(bottomLeftRect, point)) {
            self.draggingType = CPDFAnnotationDraggingBottomLeft;
        } else if (CGRectContainsPoint(topRightRect, point)) {
            self.draggingType = CPDFAnnotationDraggingTopRight;
        } else if (CGRectContainsPoint(bottomRightRect, point)) {
            self.draggingType = CPDFAnnotationDraggingBottomRight;
        } else if (CGRectContainsPoint(startPointRect, point)) {
            self.draggingType = CPDFAnnotationDraggingStart;
        } else if (CGRectContainsPoint(endPointRect, point)) {
            self.draggingType = CPDFAnnotationDraggingEnd;
        } else if ([page annotation:self.activeAnnotation atPoint:point]) {
            self.draggingType = CPDFAnnotationDraggingCenter;
        }
        self.draggingPoint = point;
    }
}

- (void)annotationTouchMovedAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if (self.textSelectionMode) {
    } else if (CPDFAnnotationDraggingNone != self.draggingType) {
        if(!self.undoMove) {
            [[self undoPDFManager] beginUndoGrouping];
            self.undoMove = YES;
        }
        [self moveAnnotation:self.activeAnnotation fromPoint:self.draggingPoint toPoint:point forType:self.draggingType];
        [self setNeedsDisplayForPage:page];
        self.draggingPoint = point;
        
    } else if (CPDFViewAnnotationModeLink == self.annotationMode) {
        CGRect rect = CGRectZero;
        if (point.x > self.addAnnotationPoint.x) {
            rect.origin.x = self.addAnnotationPoint.x;
            rect.size.width = point.x-self.addAnnotationPoint.x;
        } else {
            rect.origin.x = point.x;
            rect.size.width = self.addAnnotationPoint.x-point.x;
        }
        if (point.y > self.addAnnotationPoint.y) {
            rect.origin.y = self.addAnnotationPoint.y;
            rect.size.height = point.y-self.addAnnotationPoint.y;
        } else {
            rect.origin.y = point.y;
            rect.size.height = self.addAnnotationPoint.y-point.y;
        }
        self.addAnnotationRect = rect;
        [self setNeedsDisplayForPage:page];
    }
}

- (void)annotationTouchEndedAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if (self.textSelectionMode) {
        if (self.currentSelection) {
            [self addAnnotation:self.annotationMode atPoint:point forPage:page];
        } else {
            CPDFAnnotation *annotation = [page annotationAtPoint:point];
            if(annotation && !annotation.isHidden) {
                if ([annotation isKindOfClass:[CPDFMarkupAnnotation class]]) {
                    if (![self.activeAnnotations containsObject:annotation]) {
                        [self updateActiveAnnotations:@[annotation]];
                        [self setNeedsDisplayForPage:page];
                    }
                    [self showMenuForAnnotation:annotation];
                }
            } else {
                if(self.activeAnnotation) {
                    [self updateActiveAnnotations:@[]];
                    [self setNeedsDisplayForPage:page];
                } else {
                    if(!(CPDFViewAnnotationModeHighlight == self.annotationMode ||
                         CPDFViewAnnotationModeUnderline == self.annotationMode ||
                         CPDFViewAnnotationModeSquiggly == self.annotationMode ||
                         CPDFViewAnnotationModeStrikeout == self.annotationMode))
                    if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformTouchEnded:)]) {
                        [self.performDelegate PDFListViewPerformTouchEnded:self];
                    }
                }
            }
        }
    } else if (CPDFAnnotationDraggingNone == self.draggingType) {
        if (self.activeAnnotation && !(CPDFViewAnnotationModeLink == self.annotationMode && !CGRectIsEmpty(self.addAnnotationRect))) {
            CPDFPage *previousPage = self.activeAnnotation.page;
            [self updateActiveAnnotations:@[]];
            [self setNeedsDisplayForPage:previousPage];
            [self updateScrollEnabled];
        } else {
            if (CPDFViewAnnotationModeNone == self.annotationMode) {
                CPDFAnnotation *annotation = [page annotationAtPoint:point];
                if(annotation && [annotation isHidden]) {
                    annotation = nil;
                }
                if ([annotation isKindOfClass:[CPDFTextAnnotation class]]) {
                    if (![self.activeAnnotations containsObject:annotation]) {
                        [self updateActiveAnnotations:@[annotation]];
                        [self setNeedsDisplayForPage:page];
                        [self updateScrollEnabled];
                    }
                    if ([self.performDelegate respondsToSelector:@selector(PDFListViewEditNote:forAnnotation:)]) {
                        [self.performDelegate PDFListViewEditNote:self forAnnotation:annotation];
                    }
                    [self showMenuForAnnotation:annotation];
                } else if ([annotation isKindOfClass:[CPDFMarkupAnnotation class]]) {
                    if (![self.activeAnnotations containsObject:annotation]) {
                        [self updateActiveAnnotations:@[annotation]];
                        [self setNeedsDisplayForPage:page];
                    }
                    [self showMenuForAnnotation:annotation];
                } else if ([annotation isKindOfClass:[CPDFLinkAnnotation class]]) {
                    [super touchEndedAtPoint:point forPage:page];
                } else if ([annotation isKindOfClass:[CPDFMovieAnnotation class]]) {
                    [super touchEndedAtPoint:point forPage:page];
                } else if ([annotation isKindOfClass:[CPDFWidgetAnnotation class]]) {
                    if ([annotation isKindOfClass:[CPDFSignatureWidgetAnnotation class]]) {
                        if ([(CPDFSignatureWidgetAnnotation *)annotation isSigned]) {
                            [self showMenuForAnnotation:annotation];
                        } else {
                            if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformSignatureWidget:forAnnotation:)]) {
                                [self.performDelegate PDFListViewPerformSignatureWidget:self forAnnotation:(CPDFSignatureWidgetAnnotation *)annotation];
                            }
                        }
                    } else {
                        [super touchEndedAtPoint:point forPage:page];
                    }
                } else {
                    if(annotation) {
                        if (![self.activeAnnotations containsObject:annotation])
                            [self updateActiveAnnotations:@[annotation]];
                    } else {
                        [self updateActiveAnnotations:@[]];

                    }
                    [self setNeedsDisplayForPage:page];
                    [self updateScrollEnabled];
                    
                    [self showMenuForAnnotation:annotation];
                    
                    if (!self.activeAnnotation) {
                        if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformTouchEnded:)]) {
                            [self.performDelegate PDFListViewPerformTouchEnded:self];
                        }
                    }
                }
            } else if (CPDFViewAnnotationModeLink == self.annotationMode) {
                if (CGRectIsEmpty(self.addAnnotationRect)) {
                    CPDFAnnotation *annotation = [page annotationAtPoint:point];
                    if(annotation && [annotation isHidden]) {
                        annotation = nil;
                    }
                    if ([annotation isKindOfClass:[CPDFLinkAnnotation class]]) {
                        if(annotation) {
                            [self updateActiveAnnotations:@[annotation]];
                            [self setNeedsDisplayForPage:page];
                        }
                        [self updateScrollEnabled];
                        
                        [self showMenuForAnnotation:annotation];
                    }
                } else {
                    [self addAnnotationLinkAtPoint:point forPage:page];
                }
            } else if (CPDFViewAnnotationModeFreeText == self.annotationMode) {
                [self addAnnotationFreeTextAtPoint:point forPage:page];
            } else if (CPDFViewAnnotationModeSound == self.annotationMode) {
                BOOL isAudioRecord = NO;
                if ([self.performDelegate respondsToSelector:@selector(PDFListViewerTouchEndedIsAudioRecordMedia:)]) {
                    isAudioRecord = [self.performDelegate PDFListViewerTouchEndedIsAudioRecordMedia:self];
                }
                if (!isAudioRecord) {
                    [self addAnnotationMediaAtPoint:point forPage:page];
                }
            } else if (CPDFViewAnnotationModeStamp == self.annotationMode || CPDFViewAnnotationModeSignature == self.annotationMode) {
                self.annotationMode = CPDFViewAnnotationModeNone;
                [self addAnnotationAtPoint:point forPage:page];
            } else if (CPDFViewAnnotationModeImage == self.annotationMode) {
                self.annotationMode = CPDFViewAnnotationModeNone;
                [self addAnnotationAtPoint:point forPage:page];
            } else {
                [self addAnnotation:self.annotationMode atPoint:point forPage:page];
            }
        }
    } else {
        if (CPDFAnnotationDraggingCenter != self.draggingType) {
            if ([self.activeAnnotation isKindOfClass:[CPDFFreeTextAnnotation class]] ||
                [self.activeAnnotation isKindOfClass:[CPDFStampAnnotation class]] ||
                [self.activeAnnotation isKindOfClass:[CPDFSignatureAnnotation class]]) {
                [self.activeAnnotation updateAppearanceStream];
                [self setNeedsDisplayForPage:page];
            }
        }
        
        if(self.undoMove) {
            [[self undoPDFManager] endUndoGrouping];
            self.undoMove = NO;
        }
        
        self.draggingType = CPDFAnnotationDraggingNone;
        
        [self showMenuForAnnotation:self.activeAnnotation];
    }
}

- (void)annotationTouchCancelledAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    self.draggingType = CPDFAnnotationDraggingNone;
    
    if(self.undoMove) {
        [[self undoPDFManager] endUndoGrouping];
        self.undoMove = NO;
    }
}

- (void)longPressAnnotation:(CPDFAnnotation *)annotation atPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if(annotation && ![self.activeAnnotations containsObject:annotation]) {
        [self updateActiveAnnotations:@[annotation]];
        [self setNeedsDisplayForPage:page];
        [self updateScrollEnabled];
    }
}

- (void)annotationDrawPage:(CPDFPage *)page toContext:(CGContextRef)context {
    if (CPDFViewAnnotationModeLink == self.annotationMode) {
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:255.0/255.f green:255.0/255.f blue:255.0/255.f alpha:0.8].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:100.0/255.f green:149.0/255.f blue:237.0/255.f alpha:0.4].CGColor);
        CGContextAddRect(context, self.addAnnotationRect);
        CGContextDrawPath(context, kCGPathFillStroke);
    }

    if (self.mediaSelectionPage && self.mediaSelectionPage == page) {
        UIImage *image = [UIImage imageNamed:@"CPDFListViewImageNameSoundRecoding" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        CGContextDrawImage(context, self.mediaSelectionRect, image.CGImage);
    }
    
    if (self.activeAnnotation.page != page) {
        return;
    }
    CGSize dragDotSize = CGSizeMake(30, 30);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:72.0/255.0 green:183.0/255.0 blue:247.0/255.0 alpha:1.0].CGColor);
    
    for (CPDFAnnotation *annotation in self.activeAnnotations) {
        if ([annotation isKindOfClass:[CPDFLineAnnotation class]]) {
            CPDFLineAnnotation *line = (CPDFLineAnnotation *)annotation;
            CGPoint startPoint = line.startPoint;
            CGPoint endPoint   = line.endPoint;
            
            CGPoint tStartPoint = startPoint;
            CGPoint tEndPoint   = endPoint;
            
            float final = 40;
            if (fabs(tStartPoint.x - tEndPoint.x) < 0.00001) {
                if (tStartPoint.y > tEndPoint.y) {
                    tStartPoint.y += final;
                    tEndPoint.y -= final;
                } else {
                    tStartPoint.y -= final;
                    tEndPoint.y += final;
                }
            } else if (fabs(tStartPoint.y - tEndPoint.y) < 0.00001) {
                if (tStartPoint.x > tEndPoint.x) {
                    tStartPoint.x += final;
                    tEndPoint.x -= final;
                } else {
                    tStartPoint.x -= final;
                    tEndPoint.x += final;
                }
            } else {
                double k = (tEndPoint.y - tStartPoint.y)/(tEndPoint.x - tStartPoint.x);
                double atank = atan(k);
                if (endPoint.x > startPoint.x) {
                    tEndPoint.x += cos(atank) * final;
                    tEndPoint.y += sin(atank) * final;
                    tStartPoint.x -= cos(atank) * final;
                    tStartPoint.y -= sin(atank) * final;
                } else {
                    tEndPoint.x -= cos(atank) * final;
                    tEndPoint.y -= sin(atank) * final;
                    tStartPoint.x += cos(atank) * final;
                    tStartPoint.y += sin(atank) * final;
                }
            }
            
            CGContextSetLineWidth(context, 1.0);
            CGFloat dashArray[] = {3,3};
            CGContextSetLineDash(context, 0, dashArray, 2);
            CGContextMoveToPoint(context, tStartPoint.x, tStartPoint.y);
            CGContextAddLineToPoint(context, startPoint.x, startPoint.y);
            CGContextStrokePath(context);
            CGContextMoveToPoint(context, tEndPoint.x, tEndPoint.y);
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            CGContextStrokePath(context);
            
            CGRect startPointRect = CGRectMake(tStartPoint.x - dragDotSize.width/2.0,
                                               tStartPoint.y - dragDotSize.height/2.0,
                                               dragDotSize.width, dragDotSize.height);
            CGRect endPointRect = CGRectMake(tEndPoint.x - dragDotSize.width/2.0,
                                             tEndPoint.y - dragDotSize.height/2.0,
                                             dragDotSize.width, dragDotSize.height);
            
            UIImage *image = [UIImage imageNamed:@"CPDFListViewImageNameAnnotationDragDot" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
            CGImageRef dragDotImage = image.CGImage;
            
            CGContextDrawImage(context, startPointRect, dragDotImage);
            CGContextDrawImage(context, endPointRect, dragDotImage);
            
            self.startPointRect = startPointRect;
            self.endPointRect = endPointRect;
        } else if ([annotation isKindOfClass:[CPDFMarkupAnnotation class]]) {
            if (CGRectEqualToRect(annotation.bounds, CGRectZero))
                continue;
            CPDFMarkupAnnotation *markupAnnotation = (CPDFMarkupAnnotation *)annotation;
            NSArray *points = [markupAnnotation quadrilateralPoints];
            CGFloat lineWidth = 1.0;
            
            CGContextSaveGState(context);
            CGContextSetLineWidth(context, lineWidth);
            
            NSInteger count = 4;
            for (NSUInteger i=0; i+count <= points.count;) {
                CGPoint ptlt = [points[i++] CGPointValue];
                CGPoint ptrt = [points[i++] CGPointValue];
                CGPoint ptlb = [points[i++] CGPointValue];
                CGPoint ptrb = [points[i++] CGPointValue];
                
                CGRect rect = CGRectMake(ptlb.x-3 *lineWidth, ptlb.y-3*lineWidth, ptrt.x - ptlb.x+6*lineWidth, ptrt.y - ptlb.y+6*lineWidth);
                CGContextStrokeRect(context, CGRectInset(rect, lineWidth, lineWidth));
            }
            CGContextRestoreGState(context);
        } else if ([annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
            CGRect rect = CGRectInset(annotation.bounds, -dragDotSize.width/2.0, -dragDotSize.height/2.0);
            CGContextSetLineWidth(context, 1.0);
            CGFloat lengths[] = {6, 6};
            CGContextSetLineDash(context, 0, lengths, 2);
            CGContextStrokeRect(context, rect);
            CGContextStrokePath(context);
            
            CGAffineTransform transform = [page transform];
            if (CPDFKitShareConfig.enableAnnotationNoRotate) {
                rect = CGRectApplyAffineTransform(rect, transform);
            }
            CGRect leftCenterRect = CGRectMake(CGRectGetMinX(rect)-dragDotSize.width/2.0,
                                               CGRectGetMidY(rect)-dragDotSize.height/2.0,
                                               dragDotSize.width, dragDotSize.height);
            CGRect rightCenterRect = CGRectMake(CGRectGetMaxX(rect)-dragDotSize.width/2.0,
                                                CGRectGetMidY(rect)-dragDotSize.height/2.0,
                                                dragDotSize.width, dragDotSize.height);
            if (CPDFKitShareConfig.enableAnnotationNoRotate) {
                leftCenterRect = CGRectApplyAffineTransform(leftCenterRect, CGAffineTransformInvert(transform));
                rightCenterRect = CGRectApplyAffineTransform(rightCenterRect, CGAffineTransformInvert(transform));
            }
            
            UIImage *image = [UIImage imageNamed:@"CPDFListViewImageNameAnnotationDragDot" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
            CGImageRef dragDotImage = image.CGImage;
            
            CGContextDrawImage(context, leftCenterRect, dragDotImage);
            CGContextDrawImage(context, rightCenterRect, dragDotImage);
            
            self.startPointRect = leftCenterRect;
            self.endPointRect = rightCenterRect;
        } else {
            CGRect rect = CGRectInset(annotation.bounds, -dragDotSize.width/2.0, -dragDotSize.height/2.0);
            CGContextSetLineWidth(context, 1.0);
            CGFloat lengths[] = {6, 6};
            CGContextSetLineDash(context, 0, lengths, 2);
            CGContextStrokeRect(context, rect);
            CGContextStrokePath(context);
            
            if ([annotation isKindOfClass:[CPDFSoundAnnotation class]] ||
                [annotation isKindOfClass:[CPDFMovieAnnotation class]]) {
                continue;;
            }
            
            CGRect topLeftRect = CGRectMake(CGRectGetMinX(rect)-dragDotSize.width/2.0,
                                            CGRectGetMaxY(rect)-dragDotSize.height/2.0,
                                            dragDotSize.width, dragDotSize.height);
            CGRect bottomLeftRect = CGRectMake(CGRectGetMinX(rect)-dragDotSize.width/2.0,
                                               CGRectGetMinY(rect)-dragDotSize.height/2.0,
                                               dragDotSize.width, dragDotSize.height);
            CGRect topRightRect = CGRectMake(CGRectGetMaxX(rect)-dragDotSize.width/2.0,
                                             CGRectGetMaxY(rect)-dragDotSize.height/2.0,
                                             dragDotSize.width, dragDotSize.height);
            CGRect bottomRightRect = CGRectMake(CGRectGetMaxX(rect)-dragDotSize.width/2.0,
                                                CGRectGetMinY(rect)-dragDotSize.height/2.0,
                                                dragDotSize.width, dragDotSize.height);
            
            UIImage *image = [UIImage imageNamed:@"CPDFListViewImageNameAnnotationDragDot" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
            CGImageRef dragDotImage = image.CGImage;
            
            CGContextDrawImage(context, topLeftRect, dragDotImage);
            CGContextDrawImage(context, bottomLeftRect, dragDotImage);
            CGContextDrawImage(context, topRightRect, dragDotImage);
            CGContextDrawImage(context, bottomRightRect, dragDotImage);
            
            self.topLeftRect = topLeftRect;
            self.bottomLeftRect = bottomLeftRect;
            self.topRightRect = topRightRect;
            self.bottomRightRect = bottomRightRect;
        }
    }
}

#pragma mark - Annotation

- (void)moveAnnotation:(CPDFAnnotation *)annotation fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint forType:(CPDFAnnotationDraggingType)draggingType {
    CGRect bounds = annotation.bounds;
    CGPoint offsetPoint =  CGPointMake(toPoint.x - fromPoint.x, toPoint.y - fromPoint.y);
    CGFloat scale = bounds.size.height/bounds.size.width;
    if ([annotation isKindOfClass:[CPDFLineAnnotation class]]) {
        CPDFLineAnnotation *line = (CPDFLineAnnotation *)annotation;
        CGPoint startPoint = line.startPoint;
        CGPoint endPoint   = line.endPoint;
        switch (draggingType) {
            case CPDFAnnotationDraggingCenter:
            {
                startPoint.x += offsetPoint.x;
                startPoint.y += offsetPoint.y;
                endPoint.x += offsetPoint.x;
                endPoint.y += offsetPoint.y;
            }
                break;
            case CPDFAnnotationDraggingStart:
            {
                startPoint.x += offsetPoint.x;
                startPoint.y += offsetPoint.y;
            }
                break;
            case CPDFAnnotationDraggingEnd:
            {
                endPoint.x += offsetPoint.x;
                endPoint.y += offsetPoint.y;
            }
                break;
            default:
            break;
        }
        line.startPoint = startPoint;
        line.endPoint = endPoint;
        bounds = line.bounds;
    } else if ([annotation isKindOfClass:[CPDFFreeTextAnnotation class]]) {
        CGAffineTransform transform = [annotation.page transform];
        if (CPDFKitShareConfig.enableAnnotationNoRotate) {
            bounds = CGRectApplyAffineTransform(bounds, transform);
            toPoint = CGPointApplyAffineTransform(toPoint, transform);
            fromPoint = CGPointApplyAffineTransform(fromPoint, transform);
            offsetPoint =  CGPointMake(toPoint.x - fromPoint.x, toPoint.y - fromPoint.y);
        }
        CPDFFreeTextAnnotation *freeText = (CPDFFreeTextAnnotation *)annotation;
        NSDictionary *attributes = @{NSFontAttributeName : freeText.font};
        switch (draggingType) {
            case CPDFAnnotationDraggingCenter:
            {
                bounds.origin.x += offsetPoint.x;
                bounds.origin.y += offsetPoint.y;
            }
                break;
            case CPDFAnnotationDraggingStart:
            {
                CGFloat x = CGRectGetMaxX(bounds);
                bounds.size.width -= offsetPoint.x;
                bounds.size.width = MAX(bounds.size.width, 5.0);
                bounds.origin.x = x - bounds.size.width;
                
                CGRect rect = [freeText.contents boundingRectWithSize:CGSizeMake(bounds.size.width, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:attributes
                                                              context:nil];
                rect.size.height += 6;
                bounds.origin.y = CGRectGetMaxY(bounds) - rect.size.height;
                bounds.size.height = rect.size.height;
            }
                break;
            case CPDFAnnotationDraggingEnd:
            {
                bounds.size.width += offsetPoint.x;
                bounds.size.width = MAX(bounds.size.width, 5.0);
                
                CGRect rect = [freeText.contents boundingRectWithSize:CGSizeMake(bounds.size.width, CGFLOAT_MAX)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:attributes
                                                              context:nil];
                rect.size.height += 6;
                bounds.origin.y = CGRectGetMaxY(bounds) - rect.size.height;
                bounds.size.height = rect.size.height;
            }
                break;
            default:
            break;
        }
        if (CPDFKitShareConfig.enableAnnotationNoRotate) {
            bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformInvert(transform));
        }
    } else {
        switch (draggingType) {
            case CPDFAnnotationDraggingCenter:
            {
                bounds.origin.x += offsetPoint.x;
                bounds.origin.y += offsetPoint.y;
            }
                break;
            case CPDFAnnotationDraggingTopLeft:
            {
                CGFloat x = CGRectGetMaxX(bounds);
                bounds.size.width -= offsetPoint.x;
                bounds.size.height += offsetPoint.y;
                
                if ([annotation isKindOfClass:[CPDFStampAnnotation class]] ||
                    [annotation isKindOfClass:[CPDFSignatureAnnotation class]] ||
                    [annotation isKindOfClass:[CPDFInkAnnotation class]]) {
                    bounds.size.height = bounds.size.width*scale;
                    bounds.size.width = MAX(bounds.size.width, 5.0);
                    bounds.size.height = MAX(bounds.size.height, 5.0*scale);
                } else {
                    bounds.size.width = MAX(bounds.size.width, 5.0);
                    bounds.size.height = MAX(bounds.size.height, 5.0);
                }
                
                bounds.origin.x = x - bounds.size.width;
            }
                break;
            case CPDFAnnotationDraggingBottomLeft:
            {
                CGFloat x = CGRectGetMaxX(bounds);
                CGFloat y = CGRectGetMaxY(bounds);
                bounds.size.width -= offsetPoint.x;
                bounds.size.height -= offsetPoint.y;
                
                if ([annotation isKindOfClass:[CPDFStampAnnotation class]] ||
                    [annotation isKindOfClass:[CPDFSignatureAnnotation class]] ||
                    [annotation isKindOfClass:[CPDFInkAnnotation class]]) {
                    bounds.size.height = bounds.size.width*scale;
                    bounds.size.width = MAX(bounds.size.width, 5.0);
                    bounds.size.height = MAX(bounds.size.height, 5.0*scale);
                } else {
                    bounds.size.width = MAX(bounds.size.width, 5.0);
                    bounds.size.height = MAX(bounds.size.height, 5.0);
                }
                
                bounds.origin.x = x - bounds.size.width;
                bounds.origin.y = y - bounds.size.height;
            }
                break;
            case CPDFAnnotationDraggingTopRight:
            {
                bounds.size.width += offsetPoint.x;
                bounds.size.height += offsetPoint.y;
                
                if ([annotation isKindOfClass:[CPDFStampAnnotation class]] ||
                    [annotation isKindOfClass:[CPDFSignatureAnnotation class]] ||
                    [annotation isKindOfClass:[CPDFInkAnnotation class]]) {
                    bounds.size.height = bounds.size.width*scale;
                    bounds.size.width = MAX(bounds.size.width, 5.0);
                    bounds.size.height = MAX(bounds.size.height, 5.0*scale);
                } else {
                    bounds.size.width = MAX(bounds.size.width, 5.0);
                    bounds.size.height = MAX(bounds.size.height, 5.0);
                }
            }
                break;
            case CPDFAnnotationDraggingBottomRight:
            {
                CGFloat y = CGRectGetMaxY(bounds);
                bounds.size.width += offsetPoint.x;
                bounds.size.height -= offsetPoint.y;
                
                if ([annotation isKindOfClass:[CPDFStampAnnotation class]] ||
                    [annotation isKindOfClass:[CPDFSignatureAnnotation class]] ||
                    [annotation isKindOfClass:[CPDFInkAnnotation class]]) {
                    bounds.size.height = bounds.size.width*scale;
                    bounds.size.width = MAX(bounds.size.width, 5.0);
                    bounds.size.height = MAX(bounds.size.height, 5.0*scale);
                } else {
                    bounds.size.width = MAX(bounds.size.width, 5.0);
                    bounds.size.height = MAX(bounds.size.height, 5.0);
                }
                
                bounds.origin.y = y - bounds.size.height;
            }
                break;
            default:
                break;
        }
        
        if (CGRectGetMinX(bounds) < 0) {
            bounds.origin.x = 0;
        }
        if (CGRectGetMaxX(bounds) > CGRectGetWidth(annotation.page.bounds)) {
            bounds.origin.x = CGRectGetWidth(annotation.page.bounds) - CGRectGetWidth(bounds);
        }
        if (CGRectGetMinY(bounds) < 0) {
            bounds.origin.y = 0;
        }
        if (CGRectGetMaxY(bounds) > CGRectGetHeight(annotation.page.bounds)) {
            bounds.origin.y = CGRectGetHeight(annotation.page.bounds) - CGRectGetHeight(bounds);
        }
    }
    annotation.bounds = bounds;
}

- (void)addAnnotation:(CPDFViewAnnotationMode)mode atPoint:(CGPoint)point forPage:(CPDFPage *)page {
    CPDFAnnotation *annotation = nil;
    CAnnotStyle *annotStyle  = [[CAnnotStyle alloc]initWithAnnotionMode:mode annotations:@[]];

    switch (mode) {
        case CPDFViewAnnotationModeNote: {
            CGFloat width = 57.0/1.5;
            annotation = [[CPDFTextAnnotation alloc] initWithDocument:self.document];
            annotation.color = annotStyle.color;
            annotation.opacity = annotStyle.opacity;
            annotation.bounds = CGRectMake(point.x-width/2.0, point.y-width/2.0, width, width);
        }
            break;
        case CPDFViewAnnotationModeHighlight: {
            if (!self.currentSelection) {
                return;
            }
            NSMutableArray *quadrilateralPoints = [NSMutableArray array];
            annotation = [[CPDFMarkupAnnotation alloc] initWithDocument:self.document markupType:CPDFMarkupTypeHighlight];
            for (CPDFSelection *selection in self.currentSelection.selectionsByLine) {
                CGRect bounds = selection.bounds;
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds))]];
            }
            annotation.color = annotStyle.color;
            annotation.opacity = annotStyle.opacity;
            [(CPDFMarkupAnnotation *)annotation setQuadrilateralPoints:quadrilateralPoints];
            [(CPDFMarkupAnnotation *)annotation setMarkupText:self.currentSelection.string];
            [self clearSelection];
        }
            break;
        case CPDFViewAnnotationModeUnderline: {
            if (!self.currentSelection) {
                return;
            }
            NSMutableArray *quadrilateralPoints = [NSMutableArray array];
            annotation = [[CPDFMarkupAnnotation alloc] initWithDocument:self.document markupType:CPDFMarkupTypeUnderline];
            for (CPDFSelection *selection in self.currentSelection.selectionsByLine) {
                CGRect bounds = selection.bounds;
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds))]];
            }
            [(CPDFMarkupAnnotation *)annotation setQuadrilateralPoints:quadrilateralPoints];
            [(CPDFMarkupAnnotation *)annotation setMarkupText:self.currentSelection.string];
            annotation.color = annotStyle.color;
            annotation.opacity = annotStyle.opacity;
            [self clearSelection];
        }
            break;
        case CPDFViewAnnotationModeStrikeout: {
            if (!self.currentSelection) {
                return;
            }
            NSMutableArray *quadrilateralPoints = [NSMutableArray array];
            annotation = [[CPDFMarkupAnnotation alloc] initWithDocument:self.document markupType:CPDFMarkupTypeStrikeOut];
            for (CPDFSelection *selection in self.currentSelection.selectionsByLine) {
                CGRect bounds = selection.bounds;
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds))]];
            }
            [(CPDFMarkupAnnotation *)annotation setQuadrilateralPoints:quadrilateralPoints];
            [(CPDFMarkupAnnotation *)annotation setMarkupText:self.currentSelection.string];
            annotation.color = annotStyle.color;
            annotation.opacity = annotStyle.opacity;
            [self clearSelection];
        }
            break;
        case CPDFViewAnnotationModeSquiggly: {
            if (!self.currentSelection) {
                return;
            }
            NSMutableArray *quadrilateralPoints = [NSMutableArray array];
            annotation = [[CPDFMarkupAnnotation alloc] initWithDocument:self.document markupType:CPDFMarkupTypeSquiggly];
            for (CPDFSelection *selection in self.currentSelection.selectionsByLine) {
                CGRect bounds = selection.bounds;
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds))]];
                [quadrilateralPoints addObject:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds))]];
            }
            [(CPDFMarkupAnnotation *)annotation setQuadrilateralPoints:quadrilateralPoints];
            [(CPDFMarkupAnnotation *)annotation setMarkupText:self.currentSelection.string];
            annotation.color = annotStyle.color;
            annotation.opacity = annotStyle.opacity;
            [self clearSelection];
        }
            break;
        case CPDFViewAnnotationModeCircle: {
            annotation = [[CPDFCircleAnnotation alloc] initWithDocument:self.document];
            CPDFCircleAnnotation *circleAnnotation = (CPDFCircleAnnotation *)annotation;
            circleAnnotation.bounds = CGRectMake(point.x-50, point.y-50, 100, 100);
            circleAnnotation.color = annotStyle.color;
            circleAnnotation.opacity = annotStyle.opacity;
            circleAnnotation.border = [[CPDFBorder alloc]initWithStyle:annotStyle.style lineWidth:annotStyle.lineWidth dashPattern:annotStyle.dashPattern];
            circleAnnotation.interiorOpacity = annotStyle.interiorOpacity;
            circleAnnotation.interiorColor = annotStyle.interiorColor;
        }
            break;
        case CPDFViewAnnotationModeSquare: {
            annotation = [[CPDFSquareAnnotation alloc] initWithDocument:self.document];
            CPDFSquareAnnotation *squareAnnotation = (CPDFSquareAnnotation *)annotation;
            squareAnnotation.bounds = CGRectMake(point.x-50, point.y-50, 100, 100);
            squareAnnotation.color = annotStyle.color;
            squareAnnotation.opacity = annotStyle.opacity;
            squareAnnotation.border = [[CPDFBorder alloc]initWithStyle:annotStyle.style lineWidth:annotStyle.lineWidth dashPattern:annotStyle.dashPattern];
            squareAnnotation.interiorOpacity = annotStyle.interiorOpacity;
            squareAnnotation.interiorColor = annotStyle.interiorColor;
        }
            break;
        case CPDFViewAnnotationModeArrow: {
            annotation = [[CPDFLineAnnotation alloc] initWithDocument:self.document];
            CPDFLineAnnotation *lineAnnotation = (CPDFLineAnnotation *)annotation;
            [lineAnnotation setStartPoint:CGPointMake(point.x-50, point.y)];
            [lineAnnotation setEndPoint:CGPointMake(point.x+50, point.y)];
            [lineAnnotation setEndLineStyle:annotStyle.endLineStyle];
            [lineAnnotation setStartLineStyle:annotStyle.startLineStyle];
            lineAnnotation.color = annotStyle.color;
            lineAnnotation.opacity = annotStyle.opacity;
            lineAnnotation.border = [[CPDFBorder alloc]initWithStyle:annotStyle.style lineWidth:annotStyle.lineWidth dashPattern:annotStyle.dashPattern];
        }
            break;
        case CPDFViewAnnotationModeLine: {
            annotation = [[CPDFLineAnnotation alloc] initWithDocument:self.document];
            CPDFLineAnnotation *lineAnnotation = (CPDFLineAnnotation *)annotation;
            [lineAnnotation setStartPoint:CGPointMake(point.x-50, point.y)];
            [lineAnnotation setEndPoint:CGPointMake(point.x+50, point.y)];
            [lineAnnotation setEndLineStyle:annotStyle.endLineStyle];
            [lineAnnotation setStartLineStyle:annotStyle.startLineStyle];
            lineAnnotation.color = annotStyle.color;
            lineAnnotation.opacity = annotStyle.opacity;
            lineAnnotation.border = [[CPDFBorder alloc]initWithStyle:annotStyle.style lineWidth:annotStyle.lineWidth dashPattern:annotStyle.dashPattern];
        }
            break;
        default:
            break;
    }
    
    if (!annotation) {
        return;
    }
    [annotation setModificationDate:[NSDate date]];
    [annotation setUserName:[self annotationUserName]];
    [page addAnnotation:annotation];
    
    if ([annotation isKindOfClass:[CPDFTextAnnotation class]]) {
        [self updateActiveAnnotations:@[annotation]];
        [self setNeedsDisplayForPage:page];
        if ([self.performDelegate respondsToSelector:@selector(PDFListViewEditNote:forAnnotation:)]) {
            [self.performDelegate PDFListViewEditNote:self forAnnotation:annotation];
        }
        [self showMenuForAnnotation:annotation];
    } else if ([annotation isKindOfClass:[CPDFMarkupAnnotation class]]) {
        [self updateActiveAnnotations:@[annotation]];
        [self setNeedsDisplayForPage:page];
        
        [self showMenuForAnnotation:annotation];
    } else {
        [self updateActiveAnnotations:@[annotation]];
        [self setNeedsDisplayForPage:page];
        [self updateScrollEnabled];
        
        [self showMenuForAnnotation:annotation];
    }
}

- (void)addAnnotationAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    CPDFAnnotation *annotation = self.addAnnotation;
    if (!annotation) {
        return;
    }
    annotation.bounds = CGRectMake(point.x-annotation.bounds.size.width/2.0,
                                   point.y-annotation.bounds.size.height/2.0,
                                   annotation.bounds.size.width, annotation.bounds.size.height);
    [annotation setModificationDate:[NSDate date]];
    [annotation setUserName:[self annotationUserName]];
    [page addAnnotation:annotation];
    
    [self updateActiveAnnotations:@[annotation]];
    [self setNeedsDisplayForPage:page];
    [self updateScrollEnabled];

    [self showMenuForAnnotation:annotation];
}

- (void)addAnnotationMediaAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if (self.mediaSelectionPage) {
        CPDFPage *selectionPage = self.mediaSelectionPage;
        self.mediaSelectionPage = nil;
        [self setNeedsDisplayForPage:selectionPage];
    }
    
    self.mediaSelectionPage = page;
    self.mediaSelectionRect = CGRectMake(point.x-20, point.y-20, 40, 40);
    [self setNeedsDisplayForPage:page];
    
    [self showMenuForMediaAtPoint:point forPage:page];
}

- (void)addAnnotationLinkAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    CPDFLinkAnnotation *annotation = [[CPDFLinkAnnotation alloc] initWithDocument:self.document]    ;
    annotation.bounds = self.addAnnotationRect;
    [annotation setModificationDate:[NSDate date]];
    [annotation setUserName:[self annotationUserName]];
    [page addAnnotation:annotation];
    
    self.addAnnotationPoint = CGPointZero;
    self.addAnnotationRect = CGRectZero;
    
    if(annotation) {
        [self updateActiveAnnotations:@[annotation]];
        [self setNeedsDisplayForPage:page];
    }
    if ([self.performDelegate respondsToSelector:@selector(PDFListViewEditNote:forAnnotation:)]) {
        [self.performDelegate PDFListViewEditProperties:self forAnnotation:annotation];
    }
}

- (void)addAnnotationFreeTextAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    CAnnotStyle *annotStyle  = [[CAnnotStyle alloc]initWithAnnotionMode:CPDFViewAnnotationModeFreeText annotations:@[]];

    CPDFFreeTextAnnotation *annotation = [[CPDFFreeTextAnnotation alloc] initWithDocument:self.document];
    if (CPDFKitShareConfig.enableAnnotationNoRotate) {
        CGFloat width;
        CGAffineTransform transform = [page transform];
        point = CGPointApplyAffineTransform(point, transform);
        if (page.rotation == 90 ||
            page.rotation == 270) {
            width = CGRectGetMaxY(page.bounds) - point.x - 20;
        } else {
            width = CGRectGetMaxX(page.bounds) - point.x - 20;
        }
        CGRect bounds = CGRectMake(point.x, point.y, width, annotation.font.pointSize);
        bounds = CGRectApplyAffineTransform(bounds, CGAffineTransformInvert(transform));
        annotation.bounds = bounds;
    } else {
        CGFloat width = CGRectGetMaxX(page.bounds) - point.x - 20;
        annotation.bounds = CGRectMake(point.x, point.y, width, annotation.font.pointSize);
    }
    annotation.font = [UIFont fontWithName:annotStyle.fontName size:annotStyle.fontSize];
    annotation.fontColor = annotStyle.fontColor;
    annotation.opacity = annotStyle.opacity;
    
    [annotation setModificationDate:[NSDate date]];
    [annotation setUserName:[self annotationUserName]];
    [page addAnnotation:annotation];
    
    if(annotation) {
        [self editAnnotationFreeText:annotation];
    }
}

@end
