//
//  CPDFListView+UndoManager.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "CPDFListView+UndoManager.h"
#import "CPDFAnnotationHeader.h"
#import "CPDFListView+Private.h"

static NSString *CPDFAnnotationPropertiesObservationContext = @"CPDFAnnotationPropertiesObservationContext";

@implementation CPDFListView (UndoManager)

#pragma mark - Public method

- (void)registerAsObserver {
    self.undoPDFManager = [[NSUndoManager alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFPageDidLoadAnnotationNotification:) name:CPDFPageDidLoadAnnotationNotification object:self.document];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFPageDidAddAnnotationNotification:) name:CPDFPageDidAddAnnotationNotification object:self.document];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PDFPageDidRemoveAnnotationNotification:) name:CPDFPageDidRemoveAnnotationNotification object:self.document];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redoChangeNotification:)
                                                 name:NSUndoManagerDidUndoChangeNotification object:[self undoPDFManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redoChangeNotification:)
                                                 name:NSUndoManagerDidRedoChangeNotification object:[self undoPDFManager]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redoChangeNotification:)
                                                 name:NSUndoManagerWillCloseUndoGroupNotification object:[self undoPDFManager]];
}

- (BOOL)canUndo {
    return [[self undoPDFManager] canUndo];
}

- (BOOL)canRedo {
    return [[self undoPDFManager] canRedo];
}

#pragma mark - Private method

- (void)startObservingNotes:(NSArray *)newNotes {
    if (!self.notes) {
        self.notes = [NSMutableArray array];
    }
    for (CPDFAnnotation *note in newNotes) {
        if (![self.notes containsObject:note]) {
            [self.notes addObject:note];
        }
        for (NSString *key in [note keysForValuesToObserveForUndo]) {
            [note addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&CPDFAnnotationPropertiesObservationContext];
        }
    }
}

- (void)stopObservingNotes:(NSArray *)oldNotes {
    for (CPDFAnnotation *note in oldNotes) {
        for (NSString *key in [note keysForValuesToObserveForUndo])
            [note removeObserver:self forKeyPath:key];
    }
}

- (void)undoAddAnnotation:(CPDFAnnotation *)annotation {
    [[[self undoPDFManager] prepareWithInvocationTarget:self] removeAnnotation:annotation];
}

- (void)removeAnnotation:(CPDFAnnotation *)annotation {
    CPDFPage *page = annotation.page;
    
    if (self.activeAnnotation == annotation)
        [self updateActiveAnnotations:@[]];
    
    [page removeAnnotation:annotation];

    [self setNeedsDisplayForPage:page];
}

- (void)undoRemoveAnnotation:(CPDFAnnotation *)annotation {
    [[[self undoPDFManager] prepareWithInvocationTarget:self] undoAddAnnotation:annotation forPage:annotation.page];
}

- (void)undoAddAnnotation:(CPDFAnnotation *)annotation forPage:(CPDFPage *)page {
    if (!annotation || !page) {
        return;
    }
    NSString *annotationUserName;
    if([annotation isKindOfClass:[CPDFWidgetAnnotation class]]){
        CPDFWidgetAnnotation * widgetAnnotation = (CPDFWidgetAnnotation *)annotation;
        annotationUserName = widgetAnnotation.fieldName;
    }else{
        annotationUserName = CPDFKitShareConfig.annotationAuthor;
        if (!annotationUserName || [annotationUserName length] <= 0) {
            annotationUserName = [[UIDevice currentDevice] name];
        }
    }

    
    [annotation setModificationDate:[NSDate date]];
    [annotation setUserName:annotationUserName];
    [page addAnnotation:annotation];
    
    [self setNeedsDisplayForPage:page];
    
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

- (void)setNoteProperties:(NSMapTable *)propertiesPerNote {
    for (CPDFAnnotation *note in propertiesPerNote) {
        NSDictionary *noteProperties = [propertiesPerNote objectForKey:note];
        [note setValuesForKeysWithDictionary:noteProperties];
        if([note isKindOfClass:[CPDFWidgetAnnotation class]]) {
            [note updateAppearanceStream];
        }
        [self setNeedsDisplayForPage:note.page];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &CPDFAnnotationPropertiesObservationContext) {
        CPDFAnnotation *note = (CPDFAnnotation *)object;
        id newValue = [change objectForKey:NSKeyValueChangeNewKey] ?: [NSNull null];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey] ?: [NSNull null];
        if ([newValue isEqual:oldValue] == NO) {
            NSUndoManager *undoManager = [self undoPDFManager];
            BOOL isUndoOrRedo = ([undoManager isUndoing] || [undoManager isRedoing]);
            if ([keyPath isEqual:CPDFAnnotationStateKey] ||
                [keyPath isEqual:CPDFAnnotationSelectItemAtIndexKey]) {
                if (isUndoOrRedo == NO)
                    [undoManager setActionName:NSLocalizedString(@"Edit Note", @"Undo action name")];
            } else {
                self.undoGroupOldPropertiesPerNote = [[NSMapTable alloc] initWithKeyOptions:  NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory | NSMapTableObjectPointerPersonality capacity:0];
                [undoManager registerUndoWithTarget:self selector:@selector(setNoteProperties:) object:self.undoGroupOldPropertiesPerNote];
                if (isUndoOrRedo == NO)
                    [undoManager setActionName:NSLocalizedString(@"Edit Note", @"Undo action name")];
                
                NSMutableDictionary *oldNoteProperties = [self.undoGroupOldPropertiesPerNote objectForKey:note];
                if (oldNoteProperties == nil) {
                    oldNoteProperties = [[NSMutableDictionary alloc] init];
                    [self.undoGroupOldPropertiesPerNote setObject:oldNoteProperties forKey:note];
                    if (isUndoOrRedo == NO && [keyPath isEqualToString:CPDFAnnotationModificationDateKey] == NO)
                        [note setModificationDate:[NSDate date]];
                }
                
                if ([oldNoteProperties objectForKey:keyPath] == nil)
                    [oldNoteProperties setObject:oldValue forKey:keyPath];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSNotification

- (void)PDFPageDidLoadAnnotationNotification:(NSNotification *)notification
{
    CPDFAnnotation *annotation = [notification object];
    if (annotation.page &&
        [annotation isKindOfClass:[CPDFAnnotation class]] &&
        ![annotation isKindOfClass:[CPDFLinkAnnotation class]]) {
        [self startObservingNotes:@[annotation]];
    }
}

- (void)PDFPageDidAddAnnotationNotification:(NSNotification *)notification
{
    CPDFAnnotation *annotation = [notification object];
    if (annotation.page &&
        [annotation isKindOfClass:[CPDFAnnotation class]] &&
        ![annotation isKindOfClass:[CPDFLinkAnnotation class]]) {
        [self startObservingNotes:@[annotation]];
        
        [self undoAddAnnotation:annotation];

    }
}

- (void)PDFPageDidRemoveAnnotationNotification:(NSNotification *)notification
{
    CPDFAnnotation *annotation = [notification object];
    if (annotation.page &&
        [annotation isKindOfClass:[CPDFAnnotation class]] &&
        ![annotation isKindOfClass:[CPDFLinkAnnotation class]]) {
        [self undoRemoveAnnotation:annotation];

        [self stopObservingNotes:@[annotation]];
        
        if ([self.notes containsObject:annotation]) {
            [self.notes removeObject:annotation];
        }
    }
}

- (void)redoChangeNotification:(NSNotification *)notification {
    if([self canUndo] || [self canRedo]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CPDFListViewAnnotationsOperationChangeNotification object:self];
            
            if([self.performDelegate respondsToSelector:@selector(PDFListViewAnnotationsOperationChange:)]) {
                [self.performDelegate PDFListViewAnnotationsOperationChange:self];
            }
        });
    }
}
@end
