//
//  MFTextRunDelegate.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "MFTextRunDelegate.h"

static void DeallocCallback(void *ref) {
    MFTextRunDelegate *self = (__bridge_transfer MFTextRunDelegate *)(ref);
    self = nil; // release
}

static CGFloat GetAscentCallback(void *ref) {
    MFTextRunDelegate *self = (__bridge MFTextRunDelegate *)(ref);
    return self.ascent;
}

static CGFloat GetDecentCallback(void *ref) {
    MFTextRunDelegate *self = (__bridge MFTextRunDelegate *)(ref);
    return self.descent;
}

static CGFloat GetWidthCallback(void *ref) {
    MFTextRunDelegate *self = (__bridge MFTextRunDelegate *)(ref);
    return self.width;
}

@implementation MFTextRunDelegate

- (CTRunDelegateRef)CTRunDelegate CF_RETURNS_RETAINED {
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.dealloc = DeallocCallback;
    callbacks.getAscent = GetAscentCallback;
    callbacks.getDescent = GetDecentCallback;
    callbacks.getWidth = GetWidthCallback;
    return CTRunDelegateCreate(&callbacks, (__bridge_retained void *)(self.copy));
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_ascent) forKey:@"ascent"];
    [aCoder encodeObject:@(_descent) forKey:@"descent"];
    [aCoder encodeObject:@(_width) forKey:@"width"];
    [aCoder encodeObject:_userInfo forKey:@"userInfo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _ascent = ((NSNumber *)[aDecoder decodeObjectForKey:@"ascent"]).floatValue;
    _descent = ((NSNumber *)[aDecoder decodeObjectForKey:@"descent"]).floatValue;
    _width = ((NSNumber *)[aDecoder decodeObjectForKey:@"width"]).floatValue;
    _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    one.ascent = self.ascent;
    one.descent = self.descent;
    one.width = self.width;
    one.userInfo = self.userInfo;
    return one;
}

@end


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
