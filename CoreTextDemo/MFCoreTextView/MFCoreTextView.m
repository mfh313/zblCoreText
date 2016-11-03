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

static dispatch_queue_t MFCoreTextViewGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

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
            
            [self addSubview:imageView];
        }
    }
    
    [self setupEvents];
    
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
    
    [self drawAttachPart:context];
    
}

-(void)drawAttachPart:(CGContextRef)context
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
            
            if ([runAttributes[MFTextAttachmentAttributeName] isKindOfClass:[MFTextAttachment class]]) {
                MFTextAttachment *attach = (MFTextAttachment *)runAttributes[MFTextAttachmentAttributeName];
                UIImage *content = (UIImage *)attach.content;
                
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
                
                NSLog(@"delegateBounds=%@",NSStringFromCGRect(delegateBounds));
                
                //填充颜色
                CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
                CGContextFillRect(context, delegateBounds);
                
                CGContextDrawImage(context, delegateBounds, content.CGImage);
            }
            
            id runDelegate = CTRunDelegateGetRefCon(delegate);
            if ([runDelegate isKindOfClass:[MFTextRunDelegate class]]) {
                
            }
        }
    }
}


- (void)setupEvents {
    UIGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(userTapGestureDetected:)];
    [self addGestureRecognizer:tapRecognizer];
    
//    UIGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
//                                                                                             action:@selector(userLongPressedGuestureDetected:)];
//    [self addGestureRecognizer:longPressRecognizer];
//    
//    UIGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(userPanGuestureDetected:)];
//    [self addGestureRecognizer:panRecognizer];
    
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

//-(void)drawExample
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//    CGContextTranslateCTM(context, 0, self.bounds.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    
//    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"测试富文本,完成小目标!"];
//    
//    CTRunDelegateCallbacks callBacks;
//    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks));
//    callBacks.version = kCTRunDelegateVersion1;
//    callBacks.getWidth = widthCallBacks;
//    callBacks.getAscent = ascentCallBacks;
//    callBacks.getDescent = descentCallBacks;
//    
//    NSDictionary *dicPic = @{@"width":@400,@"height":@100};
//    CTRunDelegateRef delegate = CTRunDelegateCreate(&callBacks, (__bridge void *)(dicPic));
//    
//    unichar placeHolder = 0xFFFC;
//    NSString *placeHolderStr = [NSString stringWithCharacters:&placeHolder length:1];
//    NSMutableAttributedString *placeHolderAttrStr = [[NSMutableAttributedString alloc] initWithString:placeHolderStr];
//    
//    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)placeHolderAttrStr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
//    CFRelease(delegate);
//    
//    [attributeStr insertAttributedString:placeHolderAttrStr atIndex:2];
//    
//    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(0, attributeStr.length)];
//    
//    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributeStr);
//    
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, self.bounds);
//    
//    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributeStr.length), path, NULL);
//    
//    CTFrameDraw(frameRef, context);
//    
//    //TODO:draw Image
//    UIImage * image = [UIImage imageNamed:@"logo"];
//    CGRect imageFrame = [self calculateImageRectWithFrame:frameRef];
//    CGContextDrawImage(context, imageFrame, image.CGImage);
//    
//    CFRelease(frameSetter);
//    CFRelease(path);
//    CFRelease(frameRef);
//}
//
//-(CGRect)calculateImageRectWithFrame:(CTFrameRef)frame
//{
//    NSArray *arrLines = (NSArray *)CTFrameGetLines(frame);
//    NSInteger count = arrLines.count;
//    
//    CGPoint points[count];
//    
//    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
//    
//    for (int i = 0; i < count; i++) {
//        CTLineRef lineRef = (__bridge CTLineRef)arrLines[i];
//        
//        NSArray *arrGlyphRun = (NSArray *)CTLineGetGlyphRuns(lineRef);
//        
//        for (int j = 0; j < arrGlyphRun.count; i++) {
//            CTRunRef run = (__bridge CTRunRef)arrGlyphRun[j];
//            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
//            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];
//            
//            if (!delegate) {
//                NSLog(@"11111");
//                break;
//            }
//            
//            NSDictionary *dic = CTRunDelegateGetRefCon(delegate);
//            if (![dic isKindOfClass:[NSDictionary class]]) {
//                continue;
//            }
//            
//            CGPoint point = points[i];
//            
//            CGFloat ascent;
//            CGFloat descent;
//            CGRect boundsRun;
//            
//            boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
//            boundsRun.size.height = ascent + descent;
//            
//            CGFloat xOffset = CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(run).location, NULL);
//            
//            boundsRun.origin.x = point.x + xOffset;
//            boundsRun.origin.y = point.y - descent;
//            
//            CGPathRef path = CTFrameGetPath(frame);
//            CGRect colRect = CGPathGetBoundingBox(path);
//            
//            CGRect imageBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);
//            return imageBounds;
//            
//            
//        }
//    }
//    
//    
//    
//    return CGRectZero;
//}
//
//
//static CGFloat ascentCallBacks(void *ref)
//{
//    return ((NSNumber *)(((__bridge NSDictionary *)ref)[@"height"])).floatValue/2;
//}
//
//static CGFloat descentCallBacks(void *ref)
//{
//    return ((NSNumber *)(((__bridge NSDictionary *)ref)[@"height"])).floatValue/2;;
//}
//
//static CGFloat widthCallBacks(void *ref)
//{
//    return ((NSNumber *)(((__bridge NSDictionary *)ref)[@"width"])).floatValue;
//}

@end
