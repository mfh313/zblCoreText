//
//  MFDiagnosticDataParser.h
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFDiagnosticCoreTextData.h"

@class MFDiagnosticQuestionDataItem,MFFrameParserConfig;
@interface MFDiagnosticDataParser : NSObject

+ (MFDiagnosticCoreTextData *)parseContent:(MFDiagnosticQuestionDataItem *)dataItem
                                    config:(MFFrameParserConfig*)config;

@end
