//
//  MFDiagnosticModel.m
//  BloomBeauty
//
//  Created by Administrator on 15/12/14.
//  Copyright © 2015年 EEKA. All rights reserved.
//

#import "MFDiagnosticModel.h"


#pragma mark - MFDiagnosticQuestionDataItem
@implementation MFDiagnosticQuestionDataItem

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"diagnosticContentArray" : @"contents"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"diagnosticContentArray" : [MFDiagnosticQuestionContentDataItem class]};
}

@end

#pragma mark - MFDiagnosticQuestionContentDataItem
@implementation MFDiagnosticQuestionContentDataItem


@end

