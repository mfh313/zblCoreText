//
//  MFCustomerDiagnosticLogic.h
//  BloomBeauty
//
//  Created by Administrator on 15/12/14.
//  Copyright © 2015年 EEKA. All rights reserved.
//

#import "MFDiagnosticModel.h"
#import <Foundation/Foundation.h>

@interface MFCustomerDiagnosticLogic : NSObject
{
    NSMutableArray *_diagnosticDataItemArray;
}

+(MFCustomerDiagnosticLogic *)sharedLogic;

-(NSMutableArray *)diagnosticQuestions;


@end
