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
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zbl35"]];
            [_itemViews addObject:imageView];
            
            imageView.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
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
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillRect(context, delegateBounds);
            
            CGContextSetFillColorWithColor(context, [UIColor yellowColor].CGColor);
            CGContextFillRect(context, imageRect);
            
            CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
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

- (void)userTapGestureDetected:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self];
//    if (_state == CTDisplayViewStateNormal) {
//        for (CoreTextImageData * imageData in self.data.imageArray) {
//            // 翻转坐标系，因为imageData中的坐标是CoreText的坐标系
//            CGRect imageRect = imageData.imagePosition;
//            CGPoint imagePosition = imageRect.origin;
//            imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height;
//            CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
//            // 检测点击位置 Point 是否在rect之内
//            if (CGRectContainsPoint(rect, point)) {
//                NSLog(@"hint image");
//                // 在这里处理点击后的逻辑
//                NSDictionary *userInfo = @{ @"imageData": imageData };
//                [[NSNotificationCenter defaultCenter] postNotificationName:CTDisplayViewImagePressedNotification
//                                                                    object:self userInfo:userInfo];
//                return;
//            }
//        }
//        
//        CoreTextLinkData *linkData = [CoreTextUtils touchLinkInView:self atPoint:point data:self.data];
//        if (linkData) {
//            NSLog(@"hint link!");
//            NSDictionary *userInfo = @{ @"linkData": linkData };
//            [[NSNotificationCenter defaultCenter] postNotificationName:CTDisplayViewLinkPressedNotification
//                                                                object:self userInfo:userInfo];
//            return;
//        }
//    } else {
//        self.state = CTDisplayViewStateNormal;
//    }
}

@end
