//
//  MFDiagnosticDataParser.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "MFDiagnosticDataParser.h"
#import "MFFrameParserConfig.h"
#import "MFTextAttachment.h"
#import "MFTextRunDelegate.h"
#import "MFDiagnosticModel.h"

#import "MFDiagnosticCoreContentTextData.h"
#import "MFDiagnosticCoreContentImageData.h"

//    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);

@implementation MFDiagnosticDataParser

+(NSMutableAttributedString *)_textWithString:(NSString *)text WithRemarkColor:(UIColor *)remarkColor
{
    NSMutableAttributedString *mText = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSArray *bracketsResults = [[[self class] regexBrackets] matchesInString:mText.string options:kNilOptions range:NSMakeRange(0, mText.length)];
    for (NSTextCheckingResult *brackets in bracketsResults) {
        NSRange bracketsRange = brackets.range;
        [mText addAttribute:NSForegroundColorAttributeName value:remarkColor range:bracketsRange];
    }
    
    return mText;
}

+ (NSRegularExpression *)regexBrackets {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //匹配括号内的内容
        regex = [NSRegularExpression regularExpressionWithPattern:@"\（.*\）" options:kNilOptions error:NULL];
    });
    return regex;
}

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
    CTFontRef fontRef = [self ctFontRefFromUIFont:[UIFont systemFontOfSize:fontSize]];
    
    CGFloat headindent = 50.0f;
    CTParagraphStyleSetting head;
    head.spec = kCTParagraphStyleSpecifierHeadIndent;
    head.value = &headindent;
    head.valueSize = sizeof(float);
    
    
    CGFloat lineSpacing = config.lineSpace;
    const CFIndex kNumberOfSettings = 4;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing },
        head
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor * textColor = config.textColor;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    return dict;
}

+ (NSMutableDictionary *)attributesWithDefaultConfig
{
    MFFrameParserConfig *defaultConfig = [MFFrameParserConfig new];
    return [self attributesWithConfig:defaultConfig];
}

+ (MFDiagnosticCoreTextData *)parseContent:(MFDiagnosticQuestionDataItem *)dataItem
                                    config:(MFFrameParserConfig*)config
{
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:dataItem.showingTitleDescription];
    [string setAttributes:attributes range:NSMakeRange(0, string.length)];
    
    NSAttributedString *nAttr = [[NSAttributedString alloc] initWithString:@"\n" attributes:nil];
    
    NSMutableAttributedString *contentAttributeString = [self parseContent:dataItem
                                                               contentItem:dataItem.diagnosticContentArray
                                                                    config:config];
    
    
    [string appendAttributedString:nAttr];
    [string appendAttributedString:contentAttributeString];
    
    // 创建CTFramesetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    //获取要缓存的绘制的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat titleHeight = coreTextSize.height;
    
    //生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config orignY:0 height:titleHeight];
    
    
    MFDiagnosticCoreTextData *coreTextData = [MFDiagnosticCoreTextData new];
    coreTextData.ctFrame = frame;
    coreTextData.height = titleHeight;
    
    CFRelease(framesetter);
    
    return coreTextData;
}

+(NSMutableAttributedString *)parseContent:(MFDiagnosticQuestionDataItem *)dataItem
                                contentItem:(NSMutableArray *)contentItem
                                      config:(MFFrameParserConfig*)config
{
    NSInteger columnCount = dataItem.columnCount;
    NSAttributedString *nAttr = [[NSAttributedString alloc] initWithString:@"\n" attributes:nil];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:MFTextAttachmentToken];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    for (int i = 0; i < contentItem.count; i++) {
        MFDiagnosticQuestionContentDataItem *item = (MFDiagnosticQuestionContentDataItem *)contentItem[i];
        
        NSMutableAttributedString *attactString = [self parseImageData:item
                                                                config:config
                                                                  info:dataItem];
        
        [string appendAttributedString:attactString];
        
        if (i != contentItem.count - 1) {
            if ((i + 1) % columnCount == 0)
            {
                [string appendAttributedString:nAttr];
//                [string appendAttributedString:space];
            }
            else
            {
//                [string appendAttributedString:space];
            }
        }
    }
    
    //段缩进
    CGFloat headindent = 50.0f;    
    CTParagraphStyleSetting head;
    head.spec = kCTParagraphStyleSpecifierHeadIndent;
    head.value = &headindent;
    head.valueSize = sizeof(float);
    
    const CFIndex kNumberOfSettings = 4;
    CGFloat lineSpacing = 100;
    CTParagraphStyleSetting theSettings[] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing },
        head
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(id)theParagraphRef forKey:(id)kCTParagraphStyleAttributeName];
    
    // set attributes to attributed string
    [string addAttributes:attributes range:NSMakeRange(0, string.length)];
    
    return string;
}


+(NSMutableAttributedString *)parseImageData:(MFDiagnosticQuestionContentDataItem *)contentItem
                                      config:(MFFrameParserConfig*)config
                                        info:(MFDiagnosticQuestionDataItem *)dataItem
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:MFTextAttachmentToken];
    

    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"diagnostisImage" withExtension:@"bundle"]];
    NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"%@@2x",contentItem.imageName] ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    CGSize attachmentSize = CGSizeMake(dataItem.itemWidth, dataItem.itemHeight);
    
    MFTextAttachment *attach = [MFTextAttachment new];
    attach.content = image;
    attach.contentMode = UIViewContentModeCenter;
    attach.attachData = contentItem;
    attach.layoutData = dataItem;
    
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
                                  orignY:(CGFloat)orignY
                                  height:(CGFloat)height {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, orignY, config.width, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

+ (MFDiagnosticCoreTextData *)parseContentDescription:(MFDiagnosticQuestionContentDataItem *)dataItem
                                    config:(MFFrameParserConfig*)config
                                fillRect:(CGRect)fillRect
{
    config.width = fillRect.size.width;
    
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:dataItem.contentDescription attributes:attributes];

    CTTextAlignment alignment = kCTCenterTextAlignment;
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;
    alignmentStyle.valueSize = sizeof(alignment);
    alignmentStyle.value = &alignment;
    const CFIndex kNumberOfSettings = 1;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        alignmentStyle
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    NSMutableDictionary *theParagraphRefattributes = [NSMutableDictionary dictionaryWithObject:(id)theParagraphRef forKey:(id)kCTParagraphStyleAttributeName];
    
    [attr addAttributes:theParagraphRefattributes range:NSMakeRange(0, attr.length)];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attr);
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat titleHeight = coreTextSize.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, fillRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);

    MFDiagnosticCoreTextData *coreTextData = [MFDiagnosticCoreTextData new];
    coreTextData.ctFrame = frame;
    coreTextData.height = titleHeight;
    
    CFRelease(framesetter);
    CFRelease(path);
    
    return coreTextData;
}

@end
