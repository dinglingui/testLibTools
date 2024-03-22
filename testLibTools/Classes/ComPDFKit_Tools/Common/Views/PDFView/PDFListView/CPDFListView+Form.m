//
//  CPDFListView+Form.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
///

#import "CPDFListView+Form.h"

#import "CPDFListView+Private.h"

@implementation CPDFListView (Form)

- (void)formTouchBeganAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
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

- (void)formTouchMovedAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    if (self.textSelectionMode) {
    } else if (CPDFAnnotationDraggingNone != self.draggingType) {
        if(!self.undoMove) {
            [[self undoPDFManager] beginUndoGrouping];
            self.undoMove = YES;
        }
        [self moveFormAnnotation:(CPDFWidgetAnnotation *)self.activeAnnotation fromPoint:self.draggingPoint toPoint:point forType:self.draggingType];
        [self setNeedsDisplayForPage:page];
        self.draggingPoint = point;
        
    } else if (([self isWidgetFormWithMode:self.annotationMode])) {
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

- (void)formTouchEndedAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
 
    if (self.textSelectionMode) {
        if (self.currentSelection) {
        } else {
            CPDFAnnotation *annotation = [page annotationAtPoint:point];
            if(annotation && [annotation isHidden]) {
                annotation = nil;
            }
            if(annotation && [annotation isKindOfClass:[CPDFWidgetAnnotation class]]) {
                if (![self.activeAnnotations containsObject:annotation]) {
                    [self updateActiveAnnotations:@[annotation]];
                    [self setNeedsDisplayForPage:page];
                    [self updateFormScrollEnabled];
                }
            } else {
                if(self.activeAnnotation) {
                    [self updateActiveAnnotations:@[]];
                    [self setNeedsDisplayForPage:page];
                    [self updateFormScrollEnabled];
                } else {
                    if(CPDFViewAnnotationModeNone == self.annotationMode) {
                        if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformTouchEnded:)]) {
                            [self.performDelegate PDFListViewPerformTouchEnded:self];
                        }
                    }
                }
            }
        }
    } else if (CPDFAnnotationDraggingNone == self.draggingType) {
        if (self.activeAnnotation && !([self isWidgetFormWithMode:self.annotationMode] && !CGRectIsEmpty(self.addAnnotationRect))) {
            CPDFPage *previousPage = self.activeAnnotation.page;
            [self updateActiveAnnotations:@[]];
            [self setNeedsDisplayForPage:previousPage];
            [self updateFormScrollEnabled];
        } else {
            if (CPDFViewAnnotationModeNone == self.annotationMode) {
                CPDFAnnotation *annotation = [page annotationAtPoint:point];
                if(annotation && [annotation isHidden]) {
                    annotation = nil;
                }
                if ([annotation isKindOfClass:[CPDFWidgetAnnotation class]]) {
                    if (![self.activeAnnotations containsObject:annotation]) {
                        [self updateActiveAnnotations:@[annotation]];
                        [self setNeedsDisplayForPage:page];
                        [self updateFormScrollEnabled];
                    }
                    [self showMenuForWidgetAnnotation:(CPDFWidgetAnnotation *)annotation];
                } else {
                    if ([self.performDelegate respondsToSelector:@selector(PDFListViewPerformTouchEnded:)]) {
                        [self.performDelegate PDFListViewPerformTouchEnded:self];
                    }
                }
            } else  if ([self isWidgetFormWithMode:self.annotationMode]) {
                if (CGRectIsEmpty(self.addAnnotationRect)) {
                    CPDFAnnotation *annotation = [page annotationAtPoint:point];
                    if(annotation && [annotation isHidden]) {
                        annotation = nil;
                    }
                    if ([annotation isKindOfClass:[CPDFWidgetAnnotation class]]) {
                        if(annotation) {
                            [self updateActiveAnnotations:@[annotation]];
                            [self setNeedsDisplayForPage:page];
                        }
                        [self updateFormScrollEnabled];
                        
                        [self showMenuForWidgetAnnotation:(CPDFWidgetAnnotation *)annotation];
                    }
                } else {
                    [self addWidgetAnnotationAtPoint:point forPage:page];
                }
            }
        }
    } else {
        if (CPDFAnnotationDraggingCenter != self.draggingType) {
            if ([self.activeAnnotation isKindOfClass:[CPDFWidgetAnnotation class]]) {
                [self.activeAnnotation updateAppearanceStream];
                [self setNeedsDisplayForPage:page];
            }
        }
        
        if(self.undoMove) {
            [[self undoPDFManager] endUndoGrouping];
            self.undoMove = NO;
        }
        
        self.draggingType = CPDFAnnotationDraggingNone;
        if([self.activeAnnotation isKindOfClass:[CPDFWidgetAnnotation class]]) {
            [self showMenuForWidgetAnnotation:(CPDFWidgetAnnotation *)self.activeAnnotation];
        }
    }
}

- (void)formTouchCancelledAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    self.draggingType = CPDFAnnotationDraggingNone;
    
    if(self.undoMove) {
        [[self undoPDFManager] endUndoGrouping];
        self.undoMove = NO;
    }
}

- (void)formDrawPage:(CPDFPage *)page toContext:(CGContextRef)context {
    if ([self isWidgetFormWithMode:self.annotationMode]) {
        CGContextSetLineWidth(context, 1.0);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:255.0/255.f green:255.0/255.f blue:255.0/255.f alpha:0.8].CGColor);
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:100.0/255.f green:149.0/255.f blue:237.0/255.f alpha:0.4].CGColor);
        CGContextAddRect(context, self.addAnnotationRect);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
    if (self.activeAnnotation.page != page) {
        return;
    }
    CGSize dragDotSize = CGSizeMake(30, 30);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:72.0/255.0 green:183.0/255.0 blue:247.0/255.0 alpha:1.0].CGColor);
    
    for (CPDFAnnotation *annotation in self.activeAnnotations) {
        CGRect rect = CGRectInset(annotation.bounds, -dragDotSize.width/2.0, -dragDotSize.height/2.0);
        CGContextSetLineWidth(context, 1.0);
        CGFloat lengths[] = {6, 6};
        CGContextSetLineDash(context, 0, lengths, 2);
        CGContextStrokeRect(context, rect);
        CGContextStrokePath(context);
        
        if (![annotation isKindOfClass:[CPDFWidgetAnnotation class]]) {
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

- (NSArray<UIMenuItem *> *)formMenuItemsAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    NSMutableArray *menuItems = [NSMutableArray array];
    NSArray * menus = [super menuItemsAtPoint:point forPage:page];
    if(menus && menus.count > 0)
         menuItems = [NSMutableArray arrayWithArray:menus];
    
    return menuItems;
}

#pragma mark - Annotation

- (void)moveFormAnnotation:(CPDFWidgetAnnotation *)annotation fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint forType:(CPDFAnnotationDraggingType)draggingType {
    if([annotation isKindOfClass:[CPDFWidgetAnnotation class]]) {
        CGRect bounds = annotation.bounds;
        CGPoint offsetPoint =  CGPointMake(toPoint.x - fromPoint.x, toPoint.y - fromPoint.y);
        CGFloat scale = bounds.size.height/bounds.size.width;
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
        annotation.bounds = bounds;
    }
}

- (void)addWidgetAnnotationAtPoint:(CGPoint)point forPage:(CPDFPage *)page {
    CPDFWidgetAnnotation *widgetAnnotation = nil;
    BOOL isPushButton = NO;
    switch (self.annotationMode) {
        case CPDFViewFormModeText:
            widgetAnnotation = [[CPDFTextWidgetAnnotation alloc] initWithDocument:self.document];
            [widgetAnnotation setFieldName:[NSString stringWithFormat:@"%@%@",@"Text Field_",[self tagString]]];
            break;
        case CPDFViewFormModeCheckBox:
            widgetAnnotation = [[CPDFButtonWidgetAnnotation alloc] initWithDocument:self.document controlType:CPDFWidgetCheckBoxControl];
            widgetAnnotation.font = [UIFont fontWithName:@"Helvetica" size:14];
            [widgetAnnotation setFieldName:[NSString stringWithFormat:@"%@%@",@"Check Button_",[self tagString]]];
            break;
        case CPDFViewFormModeRadioButton:
            widgetAnnotation = [[CPDFButtonWidgetAnnotation alloc] initWithDocument:self.document controlType:CPDFWidgetRadioButtonControl];
            [widgetAnnotation setFieldName:[NSString stringWithFormat:@"%@%@",@"Radio Button_",[self tagString]]];
            break;
        case CPDFViewFormModeCombox:
            widgetAnnotation = [[CPDFChoiceWidgetAnnotation alloc] initWithDocument:self.document listChoice:NO];
            [widgetAnnotation setFieldName:[NSString stringWithFormat:@"%@%@",@"Combox Choice_",[self tagString]]];
            break;
        case CPDFViewFormModeList:
            widgetAnnotation = [[CPDFChoiceWidgetAnnotation alloc] initWithDocument:self.document listChoice:YES];
            [widgetAnnotation setFieldName:[NSString stringWithFormat:@"%@%@",@"List Choice_",[self tagString]]];
            break;
        case CPDFViewFormModeButton:{
            isPushButton = YES;
            widgetAnnotation = [[CPDFButtonWidgetAnnotation alloc] initWithDocument:self.document controlType:CPDFWidgetPushButtonControl];
            CPDFButtonWidgetAnnotation *buttonWidgetAnnotationut = widgetAnnotation;
            widgetAnnotation.borderColor = [UIColor blackColor];
            buttonWidgetAnnotationut.caption = @"Push Button";
            [widgetAnnotation setFieldName:[NSString stringWithFormat:@"%@%@",@"Push Button_",[self tagString]]];
        }
            break;
        case CPDFViewFormModeSign:
            widgetAnnotation = [[CPDFSignatureWidgetAnnotation alloc] initWithDocument:self.document];
            [widgetAnnotation setFieldName:[NSString stringWithFormat:@"%@%@",@"Signature_",[self tagString]]];
            break;
        default:
            break;
    }
    widgetAnnotation.borderWidth = 2.0;
    widgetAnnotation.bounds = self.addAnnotationRect;
    [widgetAnnotation setModificationDate:[NSDate date]];
//    [widgetAnnotation setUserName:[self annotationUserName]];
    [page addAnnotation:widgetAnnotation];
    
    self.addAnnotationPoint = CGPointZero;
    self.addAnnotationRect = CGRectZero;
    
    if(widgetAnnotation) {
        [self updateActiveAnnotations:@[widgetAnnotation]];
        [self setNeedsDisplayForPage:page];
    }
    
    [self updateFormScrollEnabled];
    if([widgetAnnotation isKindOfClass:[CPDFChoiceWidgetAnnotation class]] || ([widgetAnnotation isKindOfClass:[CPDFButtonWidgetAnnotation class]] && isPushButton)) {
        if(self.performDelegate && [self.performDelegate respondsToSelector:@selector(PDFListViewEditNote:forAnnotation:)]) {
            [self.performDelegate PDFListViewEditNote:self forAnnotation:self.activeAnnotation];
        }
    } else {
        [self showMenuForWidgetAnnotation:widgetAnnotation];
    }
}

#pragma mark - Private method

- (void)updateFormScrollEnabled {
    if (self.activeAnnotation) {
        self.scrollEnabled = NO;
    } else {
        if ([self isWidgetFormWithMode:self.annotationMode]) {
            self.scrollEnabled = NO;
        } else {
            self.scrollEnabled = YES;
        }
    }
}

- (BOOL)isWidgetFormWithMode:(CPDFViewAnnotationMode)annotationMode {
    if (CPDFViewFormModeText == annotationMode ||
        CPDFViewFormModeCheckBox == annotationMode ||
        CPDFViewFormModeRadioButton == annotationMode ||
        CPDFViewFormModeCombox == annotationMode ||
        CPDFViewFormModeList == annotationMode ||
        CPDFViewFormModeButton == annotationMode ||
        CPDFViewFormModeSign == annotationMode) {
        return YES;
    }
    
    return NO;
}

- (NSString *)tagString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SS"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    return dateString;
}

- (void)showMenuForWidgetAnnotation:(CPDFWidgetAnnotation *)annotation { 
    if (!annotation) {
        [UIMenuController sharedMenuController].menuItems = nil;
        if (@available(iOS 13.0, *)) {
            [[UIMenuController sharedMenuController] hideMenuFromView:self];
        } else {
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        }
        return;
    }
    
    UIMenuItem *propertiesItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Properties", nil)
                                                        action:@selector(menuItemClick_FormProperties:)];
    
    
    UIMenuItem *optionItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Option", nil)
                                                       action:@selector(menuItemClick_Option:)];
    
    UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil)
                                                        action:@selector(menuItemClick_FormDelete:)];
    
    NSMutableArray *menuItems = [NSMutableArray array];
    if([annotation isKindOfClass:[CPDFTextWidgetAnnotation class]]){
        [menuItems addObject:propertiesItem];
        [menuItems addObject:deleteItem];
    }else if([annotation isKindOfClass:[CPDFButtonWidgetAnnotation class]]){
        CPDFButtonWidgetAnnotation * mAnnotation = (CPDFButtonWidgetAnnotation*)annotation;
        if(mAnnotation.controlType == CPDFWidgetPushButtonControl){
            [menuItems addObject:optionItem];
        }
        [menuItems addObject:propertiesItem];
        [menuItems addObject:deleteItem];
    }else if([annotation isKindOfClass:[CPDFChoiceWidgetAnnotation class]]){
        [menuItems addObject:optionItem];
        [menuItems addObject:propertiesItem];
        [menuItems addObject:deleteItem];
    }else if([annotation isKindOfClass:[CPDFSignatureWidgetAnnotation class]]){
        [menuItems addObject:deleteItem];
    }
    
    if (menuItems.count <= 0) {
        return;
    }
    
    CGRect bounds = annotation.bounds;
    bounds = CGRectInset(bounds, -15, -15);
    CGRect rect = [self convertRect:bounds fromPage:annotation.page];
    
    if([self.performDelegate respondsToSelector:@selector(PDFListView:customizeMenuItems:forPage:forPagePoint:)]) {
        NSArray *customizeMenuItems = [self.performDelegate PDFListView:self customizeMenuItems:menuItems forPage:annotation.page forPagePoint:bounds.origin];
        if(customizeMenuItems && customizeMenuItems > 0) {
            menuItems = [NSMutableArray arrayWithArray:customizeMenuItems];
        } else {
            [menuItems removeAllObjects];
        }
    }
    
    [UIMenuController sharedMenuController].menuItems = menuItems;
    [self becomeFirstResponder];
    if (@available(iOS 13.0, *)) {
        [[UIMenuController sharedMenuController] showMenuFromView:self rect:rect];
    } else {
        [[UIMenuController sharedMenuController] setTargetRect:rect inView:self];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}


#pragma mark - Action

- (void)menuItemClick_Option:(UIMenuItem *)menuItem {
    if(self.performDelegate && [self.performDelegate respondsToSelector:@selector(PDFListViewEditNote:forAnnotation:)]) {
        [self.performDelegate PDFListViewEditNote:self forAnnotation:self.activeAnnotation];
    }
}

- (void)menuItemClick_FormEdit:(UIMenuItem *)menuItem {
    if(self.performDelegate && [self.performDelegate respondsToSelector:@selector(PDFListViewEditNote:forAnnotation:)]) {
        [self.performDelegate PDFListViewEditNote:self forAnnotation:self.activeAnnotation];
    }
}

- (void)menuItemClick_FormDelete:(UIMenuItem *)menuItem {
    [self.activeAnnotation.page removeAnnotation:self.activeAnnotation];
    [self setNeedsDisplayForPage:self.activeAnnotation.page];
    [self updateActiveAnnotations:@[]];
}

- (void)menuItemClick_FormProperties:(UIMenuItem *)menuItem {
    if ([self.performDelegate respondsToSelector:@selector(PDFListViewEditProperties:forAnnotation:)]) {
        [self.performDelegate PDFListViewEditProperties:self forAnnotation:self.activeAnnotation];
    }
}

- (void)menuItemClick_FormSignature:(UIMenuItem *)menuItem {
}

- (void)menuItemClick_FormPaste:(UIMenuItem *)menuItem {
   
}
@end
