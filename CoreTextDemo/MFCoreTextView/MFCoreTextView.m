//
//  MFCoreTextView.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "MFCoreTextView.h"
#import <CoreText/CoreText.h>

static dispatch_queue_t MFCoreTextViewGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

@implementation MFCoreTextView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _itemViews = [NSMutableArray array];
        for (int i = 0; i < 15; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [_itemViews addObject:imageView];
        }
    }
    
    return self;
}

- (void)_clearContents {
    CGImageRef image = (__bridge_retained CGImageRef)(self.layer.contents);
    self.layer.contents = nil;
    if (image) {
        dispatch_async(MFCoreTextViewGetReleaseQueue(), ^{
            CFRelease(image);
        });
    }
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
    
    CTFrameDraw(self.data.ctFrame, context);
    
    
    
    //[self drawExample];
}



-(void)drawExample
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"测试富文本,完成小目标!"];
    
    CTRunDelegateCallbacks callBacks;
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks));
    callBacks.version = kCTRunDelegateVersion1;
    callBacks.getWidth = widthCallBacks;
    callBacks.getAscent = ascentCallBacks;
    callBacks.getDescent = descentCallBacks;
    
    NSDictionary *dicPic = @{@"width":@400,@"height":@100};
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callBacks, (__bridge void *)(dicPic));
    
    unichar placeHolder = 0xFFFC;
    NSString *placeHolderStr = [NSString stringWithCharacters:&placeHolder length:1];
    NSMutableAttributedString *placeHolderAttrStr = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];
    
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeHolderAttrStr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    
    [attributeStr insertAttributedString:placeHolderAttrStr atIndex:2];
    
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(0, attributeStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributeStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributeStr.length), path, NULL);
    
    CTFrameDraw(frameRef, context);
    
    //TODO:draw Image
    UIImage * image = [UIImage imageNamed:@"logo"];
    CGRect imageFrame = [self calculateImageRectWithFrame:frameRef];
    CGContextDrawImage(context, imageFrame, image.CGImage);
    
    CFRelease(frameSetter);
    CFRelease(path);
    CFRelease(frameRef);
}

-(CGRect)calculateImageRectWithFrame:(CTFrameRef)frame
{
    NSArray *arrLines = (NSArray *)CTFrameGetLines(frame);
    NSInteger count = arrLines.count;
    
    CGPoint points[count];
    
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
    
    for (int i = 0; i < count; i++) {
        CTLineRef lineRef = (__bridge CTLineRef)arrLines[i];
        
        NSArray *arrGlyphRun = (NSArray *)CTLineGetGlyphRuns(lineRef);
        
        for (int j = 0; j < arrGlyphRun.count; i++) {
            CTRunRef run = (__bridge CTRunRef)arrGlyphRun[j];
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];
            
            if (!delegate) {
                NSLog(@"11111");
                break;
            }
            
            NSDictionary *dic = CTRunDelegateGetRefCon(delegate);
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGPoint point = points[i];
            
            CGFloat ascent;
            CGFloat descent;
            CGRect boundsRun;
            
            boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
            boundsRun.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(run).location, NULL);
            
            boundsRun.origin.x = point.x + xOffset;
            boundsRun.origin.y = point.y - descent;
            
            CGPathRef path = CTFrameGetPath(frame);
            CGRect colRect = CGPathGetBoundingBox(path);
            
            CGRect imageBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);
            return imageBounds;
            
            
        }
    }
    
    
    
    return CGRectZero;
}


static CGFloat ascentCallBacks(void *ref)
{
    return ((NSNumber *)(((__bridge NSDictionary *)ref)[@"height"])).floatValue/2;
}

static CGFloat descentCallBacks(void *ref)
{
    return ((NSNumber *)(((__bridge NSDictionary *)ref)[@"height"])).floatValue/2;;
}

static CGFloat widthCallBacks(void *ref)
{
    return ((NSNumber *)(((__bridge NSDictionary *)ref)[@"width"])).floatValue;
}

@end
