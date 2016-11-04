//
//  ParagraphStyleTextView.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/4.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "ParagraphStyleTextView.h"

@implementation ParagraphStyleTextView

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"测试段落样式测试段落样式测试段落样式测试段落样式测试段落样式测试段落样式\n测试段落样式测试段落样\n式测试段落样式测试段落样式"];
    
    
    //首行缩进
    CGFloat firstLineIndentSize = 100.0f;
    CTParagraphStyleSetting firstLineIndent;
    firstLineIndent.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
    firstLineIndent.valueSize = sizeof(CGFloat);
    firstLineIndent.value = &firstLineIndentSize;
    
    //段前缩进
    CGFloat headIndentSize = 100.0f;
    CTParagraphStyleSetting headIndent;
    headIndent.spec = kCTParagraphStyleSpecifierHeadIndent;
    headIndent.valueSize = sizeof(CGFloat);
    headIndent.value = &headIndentSize;
    
    //段前间隔
    CGFloat beforeSpace = 50.0f;
    CTParagraphStyleSetting spacingBefore;
    spacingBefore.spec = kCTParagraphStyleSpecifierParagraphSpacingBefore;
    spacingBefore.valueSize = sizeof(CGFloat);
    spacingBefore.value = &beforeSpace;
    
    //段前间隔
    CGFloat paragraghSpace = 30.0f;
    CTParagraphStyleSetting paragraghInterval;
    paragraghInterval.spec = kCTParagraphStyleSpecifierParagraphSpacing;
    paragraghInterval.valueSize = sizeof(CGFloat);
    paragraghInterval.value = &paragraghSpace;
    
    //换行模式
    CTLineBreakMode lineBreak = kCTLineBreakByClipping;
    CTParagraphStyleSetting lineBreakMode;
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    
    
    const CFIndex kNumberOfSettings = 5;
    CTParagraphStyleSetting theSettings[] = {
        firstLineIndent,headIndent,paragraghInterval,spacingBefore,lineBreakMode
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    NSMutableDictionary *exAttributes = [NSMutableDictionary dictionaryWithObject:(id)theParagraphRef forKey:(id)kCTParagraphStyleAttributeName];
    
    [attString addAttributes:exAttributes range:NSMakeRange(0, attString.length)];
    
    long number = 40;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [attString addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, attString.length)];
    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CGSize restrictSize = CGSizeMake(400, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat titleHeight = coreTextSize.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    
    CTFrameDraw(frame, context);
    CFRelease(path);

}


@end