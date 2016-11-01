//
//  MFTextAttachment.m
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "MFTextAttachment.h"

NSString *const MFTextAttachmentToken = @"\uFFFC";

@implementation MFTextAttachment

+ (instancetype)attachmentWithContent:(nullable id)content
{
    MFTextAttachment *one = [self new];
    one.content = content;
    return one;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:[NSValue valueWithUIEdgeInsets:self.contentInsets] forKey:@"contentInsets"];
    [aCoder encodeObject:self.userInfo forKey:@"userInfo"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _content = [aDecoder decodeObjectForKey:@"content"];
    _contentInsets = ((NSValue *)[aDecoder decodeObjectForKey:@"contentInsets"]).UIEdgeInsetsValue;
    _userInfo = [aDecoder decodeObjectForKey:@"userInfo"];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    typeof(self) one = [self.class new];
    if ([self.content respondsToSelector:@selector(copy)]) {
        one.content = [self.content copy];
    } else {
        one.content = self.content;
    }
    one.contentInsets = self.contentInsets;
    one.userInfo = self.userInfo.copy;
    return one;
}

@end
