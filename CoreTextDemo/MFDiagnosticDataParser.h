//
//  MFDiagnosticDataParser.h
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFDiagnosticCoreTextData.h"

@class MFDiagnosticQuestionDataItem,MFFrameParserConfig,MFDiagnosticQuestionContentDataItem;

@interface MFDiagnosticDataParser : NSObject


+ (NSMutableDictionary *)attributesWithConfig:(MFFrameParserConfig *)config;

+ (MFDiagnosticCoreTextData *)parseContent:(MFDiagnosticQuestionDataItem *)dataItem
                                    config:(MFFrameParserConfig*)config;

+ (MFDiagnosticCoreTextData *)parseContentDescription:(MFDiagnosticQuestionContentDataItem *)dataItem
                                               config:(MFFrameParserConfig*)config
                                             fillRect:(CGRect)fillRect
                                            alignment:(CTTextAlignment)alignment;

@end
