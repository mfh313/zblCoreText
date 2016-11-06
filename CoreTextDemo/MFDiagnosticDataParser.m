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

+(NSMutableAttributedString *)_textWithString:(NSMutableAttributedString *)text withRemarkColor:(UIColor *)remarkColor
{
    NSMutableAttributedString *mText = text;
    
    NSArray *bracketsResults = [[[self class] regexBrackets] matchesInString:mText.string options:kNilOptions range:NSMakeRange(0, mText.length)];
    for (NSTextCheckingResult *brackets in bracketsResults) {
        NSRange bracketsRange = brackets.range;
        [mText addAttribute:(id)kCTForegroundColorAttributeName value:remarkColor range:bracketsRange];
    }
    
    
    return mText;
}

+ (NSRegularExpression *)regexBrackets {
    static NSRegularExpression *regex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //匹配括号内的内容
        regex = [NSRegularExpression regularExpressionWithPattern:@"\\（.*\\）" options:kNilOptions error:NULL];
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
    return dict;
}

//TODO:整体排版包括间隔需要后期优化，先不管
+ (MFDiagnosticCoreTextData *)parseContent:(MFDiagnosticQuestionDataItem *)dataItem
                                    config:(MFFrameParserConfig*)config
{
    
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    
    NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithAttributedString:string];
    
    [titleAttr setAttributes:attributes range:NSMakeRange(0, titleAttr.length)];
    
    //fix color
    titleAttr = [self _textWithString:titleAttr withRemarkColor:[UIColor redColor]];
    
    
    NSRange titleRange = NSMakeRange(0, titleAttr.length);
    NSMutableParagraphStyle *titleParagraphStyle = [NSMutableParagraphStyle new];
    titleParagraphStyle.firstLineHeadIndent = 15.0f;  //首行缩进
    titleParagraphStyle.headIndent = 0.0f;          //每行缩进
    titleParagraphStyle.lineSpacing = 2.0f;    //行距
    titleParagraphStyle.paragraphSpacing = 20.0f;    //段前间隔,段与段之间的距离
    titleParagraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [titleAttr addAttribute:NSParagraphStyleAttributeName value:titleParagraphStyle range:titleRange];
    [string appendAttributedString:titleAttr];
    
    NSMutableAttributedString *tabAttr = [[NSMutableAttributedString alloc] initWithString:@"\n" attributes:nil];
    [string appendAttributedString:tabAttr];
    
    
    NSMutableAttributedString *contentAttributeString = [self parseContent:dataItem
                                                               contentItem:dataItem.diagnosticContentArray
                                                                    config:config];
    
    [string appendAttributedString:contentAttributeString];
    
    
    NSMutableParagraphStyle *gridParagraphStyle = [NSMutableParagraphStyle new];
    gridParagraphStyle.firstLineHeadIndent = 20.0f;  //首行缩进
    gridParagraphStyle.headIndent = 20.0f;          //每行缩进
    gridParagraphStyle.paragraphSpacing = 20.0f;    //段前间隔,段与段之间的距离
    gridParagraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [string addAttribute:NSParagraphStyleAttributeName value:gridParagraphStyle
                                   range:NSMakeRange(titleAttr.length,string.length - titleAttr.length)];
    
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat height = coreTextSize.height;
    CTFrameRef frame = [self createFrameWithFramesetter:framesetter config:config height:height];
    
    MFDiagnosticCoreTextData *coreTextData = [MFDiagnosticCoreTextData new];
    coreTextData.ctFrame = frame;
    coreTextData.height = height;
    
    CFRelease(framesetter);
    
    return coreTextData;
}

+(NSMutableAttributedString *)parseContent:(MFDiagnosticQuestionDataItem *)dataItem
                               contentItem:(NSMutableArray *)contentItem
                                    config:(MFFrameParserConfig*)config
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    NSAttributedString *nAttr = [[NSAttributedString alloc] initWithString:@"\n" attributes:nil];
    
    NSInteger columnCount = dataItem.columnCount;
    
    for (int i = 0; i < contentItem.count; i++) {
        MFDiagnosticQuestionContentDataItem *item = (MFDiagnosticQuestionContentDataItem *)contentItem[i];
        NSMutableAttributedString *attactString = [self parseImageData:item
                                                                config:config
                                                                  info:dataItem];
        NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:MFTextAttachmentToken];
       
        [string appendAttributedString:space];
        [string appendAttributedString:attactString];
        
        if ((i + 1) % columnCount == 0)
        {
            [string appendAttributedString:nAttr];
        }
    }
    
    //TODO:图片左右间隔，后面存json
    long number = 20;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt8Type,&number);
    [string addAttribute:(id)kCTKernAttributeName value:(__bridge id)num range:NSMakeRange(0, string.length)];
    
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
