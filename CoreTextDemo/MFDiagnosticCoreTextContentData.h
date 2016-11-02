//
//  MFDiagnosticCoreTextContentData.h
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/2.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFDiagnosticCoreTextContentData : NSObject

@property (strong, nonatomic) NSString * imageName;
@property (nonatomic) int position;

// 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic) CGRect imagePosition;

@end
