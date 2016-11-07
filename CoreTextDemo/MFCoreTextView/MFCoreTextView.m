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
            CGRect converFrame = CGRectMake(0, 0, coverImage.size.width, coverImage.size.height);
            UIImageView *converView = [[UIImageView alloc] initWithFrame:converFrame];
            converView.image = [coverImage stretchableImageWithLeftCapWidth:coverImage.size.width/2 topCapHeight:coverImage.size.height/2];
            [_itemViews addObject:converView];
            
            UIImage *tipImage = [UIImage imageNamed:@"zbl23"];
            UIImageView *tipImageView = [[UIImageView alloc] initWithImage:tipImage];
            CGRect tipsFrame = CGRectMake(CGRectGetWidth(converView.frame) - 10 - tipImage.size.width, CGRectGetHeight(converView.frame) - 10 - tipImage.size.height, tipImage.size.width, tipImage.size.height);
            tipImageView.frame = tipsFrame;
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
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextFillRect(context, delegateBounds);
            
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
            CGContextFillRect(context, imageRect);
            
            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
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
    
    CFIndex touchIndex = [[self class] touchContentOffsetInView:self atPoint:point frame:self.data.ctFrame];

    CGRect touchFrame = [[self class] touchInViewIndex:touchIndex frame:self.data.ctFrame];
    
    //翻转坐标系
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    CGRect filpRect = CGRectApplyAffineTransform(touchFrame, transform);
    UIView *tipsView = _itemViews[0];
    tipsView.frame = filpRect;
    [self addSubview:tipsView];
}

+(CGRect)touchInViewIndex:(CFIndex)touchIndex frame:(CTFrameRef)frame
{
    NSLog(@"touchIndex=%ld",touchIndex);
    
    CFArrayRef lines = CTFrameGetLines(frame);
    if (!lines) {
        return CGRectZero;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    for (int i = 0; i < count; i++) {
        
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
        
        for (int j = 0; j < runs.count; j++) {
            CTRunRef run = (__bridge CTRunRef)runs[j];
            
            CFRange range = CTRunGetStringRange(run);
            
            //找到点中的富文本
            if (range.location <= touchIndex
                && range.location + range.length >= touchIndex)
            {
                NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
                CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
                if (delegate == nil) {
                    continue;
                }
                
                if (![runAttributes[MFTextAttachmentAttributeName] isKindOfClass:[MFTextAttachment class]]) {
                    continue;
                }
                
                MFTextAttachment *attach = (MFTextAttachment *)runAttributes[MFTextAttachmentAttributeName];
                MFDiagnosticQuestionDataItem *dataItem = (MFDiagnosticQuestionDataItem *)attach.layoutData;
                
                MFDiagnosticQuestionContentDataItem *contentItem = (MFDiagnosticQuestionContentDataItem *)attach.attachData;
                
                NSLog(@"contentItem=%@",contentItem);
                contentItem.isSelected = !contentItem.isSelected;
                
                CGRect runBounds;
                CGFloat ascent;
                CGFloat descent;
                CGFloat leading;
                runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
                runBounds.size.height = ascent + descent;
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                runBounds.origin.x = origins[i].x + xOffset;
                runBounds.origin.y = origins[i].y;
                runBounds.origin.y -= descent;
                
                CGPathRef pathRef = CTFrameGetPath(frame);
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                
                CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                
                return delegateBounds;
            }
            
        }
    }
    
    return CGRectZero;
    
}

+(CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point frame:(CTFrameRef)frame
{
    CFArrayRef lines = CTFrameGetLines(frame);
    if (!lines) {
        return -1;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    
    CGPoint origins[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    //翻转坐标系
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    
    CFIndex idx = -1;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        //获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if (CGRectContainsPoint(rect, point)) {
            // 将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(rect),
                                                point.y-CGRectGetMinY(rect));
            // 获得当前点击坐标对应的字符串偏移
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
        }
    }
    
    return idx;
}

+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

@end
