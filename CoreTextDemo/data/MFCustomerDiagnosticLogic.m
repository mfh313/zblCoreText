//
//  MFCustomerDiagnosticLogic.m
//  BloomBeauty
//
//  Created by Administrator on 15/12/14.
//  Copyright © 2015年 EEKA. All rights reserved.
//

#import "MFCustomerDiagnosticLogic.h"
#import "YYModel.h"
#import <CoreGraphics/CGBase.h>
#import "NSString+Width.h"

#pragma mark - MFCustomerDiagnosticLogic
@interface MFCustomerDiagnosticLogic ()
{
    NSMutableArray *_diagnosticQuestions;
}

@end

@implementation MFCustomerDiagnosticLogic

+ (MFCustomerDiagnosticLogic *)sharedLogic
{
    static MFCustomerDiagnosticLogic *_sharedLogic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogic = [[self alloc] init];
    });
    
    return _sharedLogic;
}

-(id)init
{
    self = [super init];
    if (self) {
        
        _diagnosticQuestions = [NSMutableArray array];
        [self readjsonData];
    }
    
    return self;
}

-(void)readjsonData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"diagnosticData_1" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    NSDictionary *jsonDataDic = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:nil];
    
    NSMutableArray *contents = jsonDataDic[@"questions"];
    
    for (int i = 0; i < contents.count; i++) {
        MFDiagnosticQuestionDataItem *dataItem = [MFDiagnosticQuestionDataItem yy_modelWithDictionary:contents[i]];
        
        dataItem.diagnosticResultSelectedArray = [NSMutableArray array];
        NSMutableAttributedString *showingTitleDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d、%@",i+1,dataItem.titleDescription]];
        dataItem.showingTitleDescription = showingTitleDescription;
        
        [_diagnosticQuestions addObject:dataItem];
    }
    
    [self fixDiagnosticQuestions];

}


-(void)fixDiagnosticQuestions
{
    for (int i = 0; i < _diagnosticQuestions.count; i++) {
        MFDiagnosticQuestionDataItem *dataItem = _diagnosticQuestions[i];
        NSMutableAttributedString *showingTitleDescription = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d、%@",i+1,dataItem.titleDescription]];
        dataItem.showingTitleDescription = showingTitleDescription;
        
        dataItem.contentImageWidth = dataItem.contentImageWidth / 2;
        dataItem.contentImageHeight = dataItem.contentImageHeight / 2;
        
        NSArray *contentArray = dataItem.diagnosticContentArray;
        __block CGFloat contentDescriptionWidth = 0;
        __block CGFloat contentDescriptionMaxHeight = 0;
        [contentArray enumerateObjectsUsingBlock:^(MFDiagnosticQuestionContentDataItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat width = [self contentDescriptionWidth:obj.contentDescription];
            if (width > contentDescriptionWidth) {
                contentDescriptionWidth = width;
            }
            
            CGFloat height = [obj.contentDescription MFSizeWithFont:MFDiagnosticFont maxSize:CGSizeMake(dataItem.itemWidth - 10, MAXFLOAT)].height;
            if (height > contentDescriptionMaxHeight) {
                contentDescriptionMaxHeight = height;
            }
        }];
        
        
        if ([dataItem.itemType isEqualToString:MFDiagnosticTypeKeyImage]) {
            dataItem.itemHorizontalSpace = 10;
            dataItem.itemVerticalSpace = 10;
            
            dataItem.itemWidth = MAX(contentDescriptionWidth + 20, dataItem.contentImageWidth + 18);;
            dataItem.itemHeight = dataItem.contentImageHeight + 30 + contentDescriptionMaxHeight;
        }
        else if ([dataItem.itemType isEqualToString:MFDiagnosticTypeKeyString])
        {
            dataItem.itemHorizontalSpace = 0;
            dataItem.itemVerticalSpace = 2;
            dataItem.itemWidth = MAX(contentDescriptionWidth + 50, 200);;
            dataItem.itemHeight = MFDiagnosticStrItemHeight;
        }
    }

}

-(NSMutableArray *)diagnosticQuestions
{
    return _diagnosticQuestions;
}

-(CGFloat)contentDescriptionWidth:(NSString *)contentDescription
{
    CGFloat contentDescriptionWidth = 0;
    UIFont *contentDescriptionFont = MFDiagnosticFont;
    CGSize maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    
    contentDescriptionWidth = [contentDescription MFSizeWithFont:contentDescriptionFont maxSize:maxSize].width;
    return contentDescriptionWidth;
}

-(NSMutableArray *)diagnosticDataItemArray
{
    return _diagnosticDataItemArray;
}




@end
