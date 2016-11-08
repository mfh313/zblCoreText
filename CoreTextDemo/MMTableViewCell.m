//
//  MMTableViewCell.m
//  YJCustom
//
//  Created by EEKA on 16/9/22.
//  Copyright © 2016年 EEKA. All rights reserved.
//

#import "MMTableViewCell.h"

@implementation MMTableViewCell
@synthesize m_subContentView;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

-(void)setM_subContentView:(UIView *)subContentView
{
    m_subContentView = subContentView;
    m_subContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    m_subContentView.frame = self.contentView.bounds;
    [self.contentView addSubview:m_subContentView];
}


@end
