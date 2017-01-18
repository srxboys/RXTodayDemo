//
//  RXTodayCollectionViewCell.m
//  RXTodayDemo
//
//  Created by srx on 2017/1/18.
//  Copyright © 2017年 https://github.com/srxboys. All rights reserved.
//

#import "RXTodayCollectionViewCell.h"

@interface RXTodayCollectionViewCell ()

@end

@implementation RXTodayCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel.text = @"";
        _nameLabel.text = @"";
        _avasteImgView.backgroundColor = [UIColor redColor];
    }
    return self;
}
@end
