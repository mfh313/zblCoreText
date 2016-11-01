//
//  NSString+Width.m
//  BloomBeauty
//
//  Created by Administrator on 15/12/17.
//  Copyright © 2015年 EEKA. All rights reserved.
//

#import "NSString+Width.h"


@implementation NSString (Width)

//返回字符串所占用的尺寸.
-(CGSize)MFSizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

@end
