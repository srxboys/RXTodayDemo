//
//  RXTodayModel.m
//  RXExtenstion
//
//  Created by srx on 16/7/15.
//  Copyright © 2016年 https://github.com/srxboys. All rights reserved.
//
//target -> [RXTodayDemo, RXWidgetNetwork]

#import "RXTodayModel.h"

#pragma mark ----------- [ 参数通用空处理 ] ---------
@implementation NSDictionary (TextNullReplace)

- (id)objectForKeyNotNull:(NSString *)key
{
    if (![[self allKeys] containsObject:key]) return nil;
    
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSArray class]] ||
        [object isKindOfClass:[NSDictionary class]])  {
        
        return object;
    }
    else if([object isKindOfClass:[NSNumber class]]) {
        /*
         * 所有 的 NSNumber 都为字符串
         * 保证了 服务器传回来的数据 不会导致app崩溃
         */
        
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        return [numberFormatter stringFromNumber:object];
    }
    return nil;
}
@end

@implementation NSCoder (txtNullReplace)
- (id)decodeObjectForKeyNotNull:(NSString *)key {
    
    if (![self containsValueForKey:key]) return nil;
    
    id object = [self decodeObjectForKey:key];
    if ([object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSArray class]] ||
        [object isKindOfClass:[NSDictionary class]])  {
        
        return object;
    }
    else if([object isKindOfClass:[NSNumber class]]) {
        /*
         * 所有 的 NSNumber 都为字符串
         * 保证了 服务器传回来的数据 不会导致app崩溃
         */
        
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        return [numberFormatter stringFromNumber:object];
    }
    return nil;
}
@end

#pragma mark ----------- [ RXToday ] ---------
@implementation RXTodayModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        //写这个，会自动到 initWithCoder 方法里去
        self.title = [dict objectForKeyNotNull:@"title"];
        self.type = [[dict objectForKeyNotNull:@"type"] integerValue];
        self.link = [dict objectForKeyNotNull:@"link"];
        self.name = [dict objectForKeyNotNull:@"name"];
        self.price = [dict objectForKeyNotNull:@"price"];
        self.image = [dict objectForKeyNotNull:@"image"];

    }
    return self;
}

+ (instancetype)todayModelWithDictionary:(NSDictionary *)dict {
    return [[RXTodayModel alloc] initWithDict:dict];
}

/// 从coder中读取数据，保存到相应的变量中，即反序列化数据
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.title = [aDecoder decodeObjectForKeyNotNull:@"title"];
        self.type = [[aDecoder decodeObjectForKeyNotNull:@"type"] integerValue];
        self.name = [aDecoder decodeObjectForKeyNotNull:@"name"];
        self.link = [aDecoder decodeObjectForKeyNotNull:@"link"];
        self.image = [aDecoder decodeObjectForKeyNotNull:@"image"];
        self.price = [aDecoder decodeObjectForKeyNotNull:@"price"];
    }
    return self;
}

/// 读取实例变量，并把这些数据写到coder中去。序列化
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:@(_type) forKey:@"type"];
    [aCoder encodeObject:_link forKey:@"link"];
    [aCoder encodeObject:_image forKey:@"image"];
    [aCoder encodeObject:_price forKey:@"price"   ];
}
@end
