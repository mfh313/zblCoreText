//
//  MFFrameParserConfig.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "MFFrameParserConfig.h"

@implementation MFFrameParserConfig

- (id)init {
    self = [super init];
    if (self) {
        _width = 200.0f;
        _fontSize = 16.0f;
        _lineSpace = 8.0f;
        _textColor = [UIColor blackColor];
    }
    return self;
}

@end
