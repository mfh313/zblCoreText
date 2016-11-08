//
//  MMTableViewCell.h
//  YJCustom
//
//  Created by EEKA on 16/9/22.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MMTableViewCell : UITableViewCell
{
    UIView *m_subContentView;
}

@property (nonatomic,strong) UIView *m_subContentView;

@end
