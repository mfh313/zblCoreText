//
//  MFTextAttachment.h
//  CoreTextDemo
//
//  Created by EEKA on 2016/11/1.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const MFTextAttachmentToken;
UIKIT_EXTERN NSString *const MFTextAttachmentAttributeName;

@interface MFTextAttachment : NSObject<NSCopying,NSCoding>

@property (nullable,nonatomic,strong) id content; ///< Supported type: UIImage, UIView, CALayer
@property (nonatomic,assign) UIViewContentMode contentMode;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nullable,nonatomic,strong) NSDictionary *userInfo;
@property (nullable,nonatomic,strong) id attachData;
@property (nullable,nonatomic,strong) id layoutData;

+ (instancetype)attachmentWithContent:(nullable id)content;

@end
