//
//  MFCoreTextView.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "MFCoreTextView.h"
#import <CoreText/CoreText.h>
#import "MFTextAttachment.h"
#import "MFTextRunDelegate.h"
#import "MFDiagnosticModel.h"
#import "MFDiagnosticDataParser.h"
#import "MFFrameParserConfig.h"

@implementation MFCoreTextView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _itemViews = [NSMutableArray array];
        for (int i = 0; i < 1; i++) {
            
            UIImage *coverImage = [UIImage imageNamed:@"zbl35"];
            UIImageView *converView = [[UIImageView alloc] initWithImage:coverImage];
            converView.frame = CGRectMake(0, 0, coverImage.size.width, coverImage.size.height);
            [_itemViews addObject:converView];
            
            UIImage *tipImage = [UIImage imageNamed:@"zbl23"];
            UIImageView *tipImageView = [[UIImageView alloc] initWithImage:tipImage];
            converView.frame = CGRectMake(CGRectGetWidth(converView.frame) - 30 - tipImage.size.width, CGRectGetHeight(converView.frame) - 30 - tipImage.size.height, tipImage.size.width, tipImage.size.height);
            tipImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            [converView addSubview:tipImageView];
            
        }
    }
    
    [self setupEvents];
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!self.data) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    [self drawTitle:context];
    [self drawAttachImage:context];
    [self drawContentDescription:context];

}

-(void)drawTitle:(CGContextRef)context
{
    CTFrameDraw(self.data.ctFrame, context);
}

-(void)drawAttachImage:(CGContextRef)context
{
    CTFrameRef frame = self.data.ctFrame;
    NSArray *lines = (NSArray *)CTFrameGetLines(frame);
    NSUInteger lineCount = lines.count;
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    for (int i = 0; i < lineCount; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        
        NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
        
        for (int j = 0; j < runs.count; j++) {
            CTRunRef run = (__bridge CTRunRef)runs[j];
            
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            
            if (![runAttributes[MFTextAttachmentAttributeName] isKindOfClass:[MFTextAttachment class]]) {
                continue;
            }
            
            MFTextAttachment *attach = (MFTextAttachment *)runAttributes[MFTextAttachmentAttributeName];
            UIImage *content = (UIImage *)attach.content;
            
            MFDiagnosticQuestionDataItem *dataItem = (MFDiagnosticQuestionDataItem *)attach.layoutData;
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            CGFloat leading;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(frame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            CGRect imageRect = CGRectMake(delegateBounds.origin.x + (CGRectGetWidth(delegateBounds)-dataItem.contentImageWidth)/2, delegateBounds.origin.y + CGRectGetHeight(delegateBounds) - dataItem.contentImageHeight, dataItem.contentImageWidth, dataItem.contentImageHeight);
            CGRect contentDescriptionRect = CGRectMake(delegateBounds.origin.x + 5, delegateBounds.origin.y, CGRectGetWidth(delegateBounds) - 10, CGRectGetHeight(delegateBounds) - dataItem.contentImageHeight - 10);
        
            //填充颜色
            CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
            CGContextFillRect(context, delegateBounds);
            
            CGContextSetFillColorWithColor(context, [UIColor purpleColor].CGColor);
            CGContextFillRect(context, imageRect);
            
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextFillRect(context, contentDescriptionRect);
            
            CGContextDrawImage(context, imageRect, content.CGImage);
        }
    }
}

-(void)drawContentDescription:(CGContextRef)context
{
    
    CTFrameRef frame = self.data.ctFrame;
    NSArray *lines = (NSArray *)CTFrameGetLines(frame);
    NSUInteger lineCount = lines.count;
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    for (int i = 0; i < lineCount; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        
        NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
        
        for (int j = 0; j < runs.count; j++) {
            CTRunRef run = (__bridge CTRunRef)runs[j];
            
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }
            
            if (![runAttributes[MFTextAttachmentAttributeName] isKindOfClass:[MFTextAttachment class]]) {
                continue;
            }
            
            MFTextAttachment *attach = (MFTextAttachment *)runAttributes[MFTextAttachmentAttributeName];
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            CGFloat leading;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(frame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);

            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            MFDiagnosticQuestionDataItem *dataItem = (MFDiagnosticQuestionDataItem *)attach.layoutData;
            MFDiagnosticQuestionContentDataItem *contentItem = (MFDiagnosticQuestionContentDataItem *)attach.attachData;

            
            CGRect contentDescriptionRect = CGRectMake(delegateBounds.origin.x + 5, delegateBounds.origin.y, CGRectGetWidth(delegateBounds) - 10, CGRectGetHeight(delegateBounds) - dataItem.contentImageHeight - 10);
        
            
            MFFrameParserConfig *config = [[MFFrameParserConfig alloc] init];
            config.fontSize = 16.0;
            config.lineSpace = 0;
            config.textColor = [UIColor blackColor];
            MFDiagnosticCoreTextData *data = [MFDiagnosticDataParser
                                              parseContentDescription:contentItem
                                              config:config
                                              fillRect:contentDescriptionRect];
            CTFrameDraw(data.ctFrame, context);
            
        }
    }
    
}


- (void)setupEvents {
    UIGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(userTapGestureDetected:)];
    [self addGestureRecognizer:tapRecognizer];
    
    self.userInteractionEnabled = YES;
}

- (void)userTapGestureDetected:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    
//    UIView *tipsView = _itemViews[0];
//    CGRect tipsFrame = tipsView.frame;
//    tipsFrame.origin = point;
//    tipsFrame.size = CGSizeMake(85, 85);
//    
//    tipsView.frame = tipsFrame;
//    [self addSubview:tipsView];
    
}

@end
