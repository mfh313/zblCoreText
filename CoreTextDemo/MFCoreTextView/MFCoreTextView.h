//
//  MFCoreTextView.h
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDiagnosticCoreTextData.h"


@class MFDiagnosticQuestionDataItem;
@interface MFCoreTextView : UIView
{
    NSMutableArray *_itemViews;
}

@property (strong, nonatomic) MFDiagnosticCoreTextData * data;

@end
