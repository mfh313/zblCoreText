//
//  MFDiagnosticDataParser.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "MFDiagnosticDataParser.h"
#import "MFCustomerDiagnosticLogic.h"
#import "MFFrameParserConfig.h"
#import "MFTextAttachment.h"
#import "MFTextRunDelegate.h"


@implementation MFDiagnosticDataParser

+ (UIFont *)uifontFromCTFontRef:(CTFontRef)ctFont {
    CGFloat pointSize = CTFontGetSize(ctFont);
    NSString *fontPostScriptName = (NSString *)CFBridgingRelease(CTFontCopyPostScriptName(ctFont));
    UIFont *fontFromCTFont = [UIFont fontWithName:fontPostScriptName size:pointSize];
    return fontFromCTFont;
}

+ (CTFontRef)ctFontRefFromUIFont:(UIFont *)font {
    CTFontRef ctfont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    return CFAutorelease(ctfont);
}

+ (NSMutableDictionary *)attributesWithConfig:(MFFrameParserConfig *)config {
    CGFloat fontSize = config.fontSize;
//    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CTFontRef fontRef = [self ctFontRefFromUIFont:[UIFont systemFontOfSize:fontSize]];
    CGFloat lineSpacing = config.lineSpace;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor * textColor = config.textColor;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    return dict;
}

+ (MFDiagnosticCoreTextData *)parseContent:(MFDiagnosticQuestionDataItem *)dataItem
                                    config:(MFFrameParserConfig*)config
{
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithAttributedString:dataItem.showingTitleDescription ];
    [content setAttributes:attributes range:NSMakeRange(0, content.length)];
    
    [content appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
    
    NSMutableAttributedString *contentAttributeString = [self parseContent:dataItem
                                                               contentItem:dataItem.diagnosticContentArray
                                                                    config:config];
    [content appendAttributedString:contentAttributeString];
    
    // 创建CTFramesetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    //获取要缓存的绘制的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    //生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:textHeight];
    
    MFDiagnosticCoreTextData *coreTextData = [MFDiagnosticCoreTextData new];
    coreTextData.ctFrame = frame;
    coreTextData.height = textHeight;
    coreTextData.content = content;
    
    return coreTextData;
}

+(NSMutableAttributedString *)parseContent:(MFDiagnosticQuestionDataItem *)dataItem
                                contentItem:(NSMutableArray *)contentItem
                                      config:(MFFrameParserConfig*)config
{
    NSInteger columnCount = dataItem.columnCount;
    NSAttributedString *nAttr = [[NSAttributedString alloc] initWithString:@"\n" attributes:nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i < contentItem.count; i++) {
        MFDiagnosticQuestionContentDataItem *item = (MFDiagnosticQuestionContentDataItem *)contentItem[i];
        
        [string appendAttributedString:[self parseImageData:item config:config]];
        
        if ((i + 1) % columnCount == 0) {
            [string appendAttributedString:nAttr];
        }
    }
    
    return string;
}

+(NSMutableAttributedString *)parseImageData:(MFDiagnosticQuestionContentDataItem *)contentItem
                                      config:(MFFrameParserConfig*)config
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:MFTextAttachmentToken];
    

    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"diagnostisImage" withExtension:@"bundle"]];
    NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"%@@2x",contentItem.imageName] ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    CGSize attachmentSize = image.size;
    
    MFTextAttachment *attach = [MFTextAttachment new];
    attach.content = image;
    attach.contentMode = UIViewContentModeCenter;
    
    [attr addAttribute:MFTextAttachmentAttributeName value:attach range:NSMakeRange(0, attr.length)];
    
    MFTextRunDelegate *delegate = [MFTextRunDelegate new];
    delegate.width = attachmentSize.width;
    
    UIFont *font = [UIFont systemFontOfSize:config.fontSize];
    CGFloat fontHeight = font.ascender - font.descender;
    CGFloat yOffset = font.ascender - fontHeight * 0.5;
    
    delegate.ascent = attachmentSize.height * 0.5 + yOffset;
    delegate.descent = attachmentSize.height - delegate.ascent;
    if (delegate.descent < 0) {
        delegate.descent = 0;
        delegate.ascent = attachmentSize.height;
    }
    
    CTRunDelegateRef delegateRef = delegate.CTRunDelegate;
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attr, CFRangeMake(0, attr.length),
                                   kCTRunDelegateAttributeName, delegateRef);
    CFRelease(delegateRef);
    
    return attr;
    
}

+ (CTFrameRef)createFrameWithFramesetter:(CTFramesetterRef)framesetter
                                  config:(MFFrameParserConfig *)config
                                  height:(CGFloat)height {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

@end
