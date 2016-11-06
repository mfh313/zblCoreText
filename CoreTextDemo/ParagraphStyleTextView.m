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
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"测试段落样式测试段落样式测试段落样式测试段落样式测试段落样式测试123\n456测试段落样式测试段落样78\n910式测试段落样式测试段落样式"];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.firstLineHeadIndent = 40.0f;       //首行缩进
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;     //换行模式
    paragraphStyle.headIndent = 60.0f;     //每行缩进
    paragraphStyle.lineSpacing = 30.0f;    //行距
    
    [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attString.length)];
    
    
//    //首行缩进
//    CGFloat firstLineIndentSize = 40.0f;
//    CTParagraphStyleSetting firstLineIndent;
//    firstLineIndent.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
//    firstLineIndent.valueSize = sizeof(CGFloat);
//    firstLineIndent.value = &firstLineIndentSize;
//    
//    
//    const CFIndex kNumberOfSettings = 1;
//    CTParagraphStyleSetting theSettings[] = {
//        firstLineIndent
//    };
//    
//    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
//    NSMutableDictionary *exAttributes = [NSMutableDictionary dictionaryWithObject:(id)theParagraphRef forKey:(id)kCTParagraphStyleAttributeName];
//    
//    [attString addAttributes:exAttributes range:NSMakeRange(0, attString.length)];
    
//    long number = 40;
//    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
//    [attString addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, attString.length)];
    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CGSize restrictSize = CGSizeMake(400, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
//    CGFloat titleHeight = coreTextSize.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    
    CTFrameDraw(frame, context);
    CFRelease(path);

}


@end
