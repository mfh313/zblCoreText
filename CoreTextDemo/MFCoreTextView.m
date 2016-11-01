//
//  MFCoreTextView.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "MFCoreTextView.h"
#import <CoreText/CoreText.h>

@implementation MFCoreTextView


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
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
    
    [attributeStr insertAttributedString:placeHolderAttrStr atIndex:1];
    
    [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(0, attributeStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef) attributeStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributeStr.length), path, NULL);
    
    CTFrameDraw(frameRef, context);
    
    //TODO:draw Image
    
    CFRelease(frameSetter);
    CFRelease(path);
    CFRelease(frameRef);
    
}


static CGFloat ascentCallBacks(void *ref)
{
    return ((NSNumber *)(((__bridge NSDictionary *)ref)[@"height"])).floatValue;
}

static CGFloat descentCallBacks(void *ref)
{
    return 0;
}

static CGFloat widthCallBacks(void *ref)
{
    return ((NSNumber *)(((__bridge NSDictionary *)ref)[@"width"])).floatValue;
}

@end
