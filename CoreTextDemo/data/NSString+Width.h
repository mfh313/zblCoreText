//
//  NSString+Width.h
//  BloomBeauty
//
//  Created by Administrator on 15/12/17.
//  Copyright © 2015年 EEKA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

@interface NSString (Width)
/**
 *返回值是该字符串所占的大小(width, height)
 *font : 该字符串所用的字体(字体大小不一样,显示出来的面积也不同)
 *maxSize : 为限制改字体的最大宽和高(如果显示一行,则宽高都设置为MAXFLOAT, 如果显示为多行,只需将宽设置一个有限定长值,高设置为MAXFLOAT)
 */
-(CGSize)MFSizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

@end
