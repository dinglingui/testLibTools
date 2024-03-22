//
//  CPDFAnnotationListCell.m
//  ComPDFKit_Tools
//
//  Copyright © 2014-2024 PDF Technologies, Inc. All Rights Reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE ComPDFKit LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//

#import "CPDFAnnotationListCell.h"

#import "CPDFAnnotionColorDrawView.h"
#import <ComPDFKit/ComPDFKit.h>

@interface CPDFAnnotationListCell()

@property(nonatomic, strong)CPDFAnnotation *annot;

@end

@implementation CPDFAnnotationListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
                
        _typeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _typeImageView.frame = CGRectMake(15.0, 18.0, 20, 20);
        [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationShapeCircle"
                                            inBundle:[NSBundle bundleForClass:self.class]
                       compatibleWithTraitCollection:nil]];
                
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_dateLabel setFont:[UIFont systemFontOfSize:12.0f]];
        if (@available(iOS 13.0, *)) {
            [_dateLabel setTextColor:[UIColor secondaryLabelColor]];
        } else {
            [_dateLabel setTextColor:[UIColor blackColor]];
        }
        _dateLabel.minimumScaleFactor = 0.5;
        _dateLabel.numberOfLines = 1;
        _dateLabel.adjustsFontSizeToFitWidth = YES;
        [_dateLabel setTextAlignment:NSTextAlignmentLeft];
        [_dateLabel setBackgroundColor:[UIColor clearColor]];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        if (@available(iOS 13.0, *)) {
            [_contentLabel setTextColor:[UIColor secondaryLabelColor]];
        } else {
            [_contentLabel setTextColor:[UIColor blackColor]];
        }
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.numberOfLines = 3;
        _contentLabel.font = [UIFont systemFontOfSize:15.0f];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
                
        [self.contentView addSubview:_typeImageView];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_contentLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    _dateLabel.frame = CGRectMake(43.0, 18, self.contentView.frame.size.width - 43 - 15.0, 20);

    _contentLabel.frame = CGRectMake(15, 51, self.contentView.frame.size.width-30, _contentLabel.frame.size.height);
}

- (void)setPageNumber:(NSInteger)pageNumber {
    _dateLabel.text = NSLocalizedString(@"Loading...", nil);
    
    _contentLabel.text = @"";
    [_typeImageView setImage:nil];
}

- (void)updateCellWithAnnotation:(CPDFAnnotation *)annotation {
    self.annot = annotation;
    
    [self setTypeImage:annotation];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    _dateLabel.text = [formatter stringFromDate:annotation.modificationDate];
    
    if ([annotation isKindOfClass:[CPDFMarkupAnnotation class]]) {
        NSString *text = [(CPDFMarkupAnnotation *)annotation markupText];
        if (text && text.length > 0) {
            _contentLabel.hidden = NO;
            _contentLabel.text = text;
        } else {
            CPDFPage * page = annotation.page;
            NSString * exproString = nil;
            NSArray * points =  [(CPDFMarkupAnnotation*)annotation quadrilateralPoints];
            NSInteger count = 4;
            for (NSUInteger i=0; i+count <= points.count;) {
                CGPoint ptlt = [points[i++] CGPointValue];
                CGPoint ptrt = [points[i++] CGPointValue];
                CGPoint ptlb = [points[i++] CGPointValue];
                CGPoint ptrb = [points[i++] CGPointValue];
                
                CGRect rect = CGRectMake(ptlb.x, ptlb.y, ptrt.x - ptlb.x, ptrt.y - ptlb.y);
                NSString *tString = [page stringForRect:rect];
                if (tString && tString.length >0) {
                    if(exproString) {
                        exproString = [NSString stringWithFormat:@"%@\n%@",exproString,tString];
                    } else {
                        exproString  = tString;
                    }
                }
            }
            
            if (exproString && exproString.length > 0) {
                _contentLabel.hidden = NO;
                _contentLabel.text = exproString;
            } else {
                _contentLabel.hidden = YES;
            }
        }
    } else {
        if ([annotation contents] && ![[annotation contents] isEqualToString:@""]){
            NSArray<NSString *> *contextArray = [[annotation contents] componentsSeparatedByString:@"\n"];
            if (contextArray.count >3) {
                NSString *newContents = @"";
                for (int i = 0; i < 2; i++) {
                    newContents = [newContents stringByAppendingFormat:@"%@\n", contextArray[i]];
                }
                _contentLabel.hidden = NO;
                _contentLabel.text = [newContents stringByAppendingString:@"..."];
            } else {
                _contentLabel.hidden = NO;
                _contentLabel.text = [annotation contents];
            }
        }else{
            _contentLabel.hidden = YES;
        }
    }
    [_contentLabel sizeToFit];
    [_dateLabel sizeToFit];
}

- (void)setTypeImage:(CPDFAnnotation *)annot {
    for (UIView* subView in [_typeImageView subviews]) {
        [subView removeFromSuperview];
    }
    
    if ([annot isKindOfClass:[CPDFCircleAnnotation  class]]) {
        
        [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationShapeCircle"
                                            inBundle:[NSBundle bundleForClass:self.class]
                       compatibleWithTraitCollection:nil]];
    } else if ([annot isKindOfClass:[CPDFFreeTextAnnotation class]]) {
        [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationText"
                                            inBundle:[NSBundle bundleForClass:self.class]
                       compatibleWithTraitCollection:nil]];
    } else if ([annot isKindOfClass:[CPDFInkAnnotation  class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIColor* color = [annot color];
            CPDFAnnotionColorDrawView* drawView = [self getTextMarkColorView:annot size:self.typeImageView.bounds.size color:color];
            [self.typeImageView addSubview:drawView];
            [self.typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationFreehand"
                                                    inBundle:[NSBundle bundleForClass:self.class]
                               compatibleWithTraitCollection:nil]];
        });
    } else if ([annot isKindOfClass:[CPDFLineAnnotation  class]]) {
        if ([(CPDFLineAnnotation  *)annot startLineStyle] == CPDFLineStyleClosedArrow ||
            [(CPDFLineAnnotation  *)annot endLineStyle] == CPDFLineStyleClosedArrow) {
            [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationShapeArrow"
                                                inBundle:[NSBundle bundleForClass:self.class]
                           compatibleWithTraitCollection:nil]];
        } else {
            [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationShapeLine"
                                                inBundle:[NSBundle bundleForClass:self.class]
                           compatibleWithTraitCollection:nil]];
        }
    } else if ([annot isKindOfClass:[CPDFLinkAnnotation class]]){
        //do nothing
    } else if ([annot isKindOfClass:[CPDFSoundAnnotation class]] || [annot isKindOfClass:[CPDFMovieAnnotation  class]]) {
        //add type
        [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationRecord"
                                            inBundle:[NSBundle bundleForClass:self.class]
                       compatibleWithTraitCollection:nil]];
    } else if ([annot isKindOfClass:[CPDFTextAnnotation class]]) {
        [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationNote"
                                            inBundle:[NSBundle bundleForClass:self.class]
                       compatibleWithTraitCollection:nil]];
    } else if ([annot isKindOfClass:[CPDFSquareAnnotation  class]]) {
        [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationShapeRectangle"
                                            inBundle:[NSBundle bundleForClass:self.class]
                       compatibleWithTraitCollection:nil]];
    } else if ([annot isKindOfClass:[CPDFStampAnnotation class]]) {
        if (CPDFStampTypeImage == [(CPDFStampAnnotation *)annot stampType]) {
            [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationPhoto"
                                                inBundle:[NSBundle bundleForClass:self.class]
                           compatibleWithTraitCollection:nil]];
        } else {
            [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationStamp"
                                                inBundle:[NSBundle bundleForClass:self.class]
                           compatibleWithTraitCollection:nil]];
        }
    } else if ([annot isKindOfClass:[CPDFMarkupAnnotation class]]){
        UIColor* color = [annot color];
        CPDFMarkupType markupType = [(CPDFMarkupAnnotation *)annot markupType];
        switch (markupType) {
            case CPDFMarkupTypeHighlight:
                [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationHighlight"
                                                    inBundle:[NSBundle bundleForClass:self.class]
                               compatibleWithTraitCollection:nil]];
                break;
            case CPDFMarkupTypeUnderline:
                [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationUnderline"
                                                    inBundle:[NSBundle bundleForClass:self.class]
                               compatibleWithTraitCollection:nil]];
                break;
            case CPDFMarkupTypeStrikeOut:
                [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationStrikethrough"
                                                    inBundle:[NSBundle bundleForClass:self.class]
                               compatibleWithTraitCollection:nil]];
                break;
            case CPDFMarkupTypeSquiggly:
                [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationUnderline"
                                                    inBundle:[NSBundle bundleForClass:self.class]
                               compatibleWithTraitCollection:nil]];
                break;
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CPDFAnnotionColorDrawView* drawView = [self getTextMarkColorView:annot size:self.typeImageView.bounds.size color:color];
            [self.typeImageView addSubview:drawView];
        });
    } else if ([annot isKindOfClass:[CPDFSignatureAnnotation class]]) {
        [_typeImageView setImage:[UIImage imageNamed:@"CImageNamePDFAnnotationSign"
                                            inBundle:[NSBundle bundleForClass:self.class]
                       compatibleWithTraitCollection:nil]];
    }

}

- (CPDFAnnotionColorDrawView*) getTextMarkColorView:(CPDFAnnotation *)annotation size:(CGSize)size color:(UIColor*)color {
    CPDFAnnotionMarkUpType markupType;
    CPDFAnnotionColorDrawView* drawView = [[CPDFAnnotionColorDrawView alloc] initWithFrame:CGRectZero];
    drawView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
        float tHeight  = 20;
        float tWidth  = 20;
        float tSpaceY   = 16;
        float tOffsetX = (size.width - tWidth)/2;
        
        if ([annotation isKindOfClass:[CPDFMarkupAnnotation class]]) {
            CPDFMarkupType type = [(CPDFMarkupAnnotation *)annotation markupType];
            switch (type) {
                case CPDFMarkupTypeHighlight:
                    markupType = CPDFAnnotionMarkUpTypeHighlight;
                    drawView.frame = CGRectMake(tOffsetX, (size.height - tHeight)/2, tWidth, tHeight);
                    break;
                case CPDFMarkupTypeUnderline:
                    markupType = CPDFAnnotionMarkUpTypeUnderline;
                    tHeight = 2.0;
                    drawView.frame = CGRectMake(tOffsetX, size.height - tHeight, tWidth, tHeight);
                    break;
                case CPDFMarkupTypeStrikeOut:
                    markupType = CPDFAnnotionMarkUpTypeStrikeout;
                    tHeight = 2.0;
                    drawView.frame = CGRectMake(tOffsetX, (size.height - tHeight)/2, tWidth, tHeight);
                    break;
                case CPDFMarkupTypeSquiggly:
                    markupType = CPDFAnnotionMarkUpTypeSquiggly;
                    tHeight = 6.0;
                    drawView.frame = CGRectMake(tOffsetX, size.height-2.0, tWidth, tHeight);
                    break;
                default:
                    break;
            }
        } else if ([annotation isKindOfClass:[CPDFInkAnnotation class]]) {
            markupType = CPDFAnnotionMarkUpTypeFreehand;
            tHeight = 6.0;
            drawView.frame = CGRectMake(tOffsetX, size.height - 2.0, tWidth, tHeight);
        } else {
            markupType = CPDFAnnotionMarkUpTypeFreehand;
            drawView.frame = CGRectZero;
        }
        drawView.markUpType = markupType;
        drawView.lineColor = color;
        [drawView setNeedsDisplay];
    
    return drawView;
}

@end
