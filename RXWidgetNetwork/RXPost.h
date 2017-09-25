//
//  RXPost.h
//  RXExtenstion
//
//  Created by srx on 16/7/14.
//  Copyright © 2016年 https://github.com/srxboys. All rights reserved.
//
//target -> [RXTodayDemo, RXWidgetNetwork]

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RXPost : NSObject
- (void)postReqeustCompletion:(void (^)(NSArray * array, BOOL isError))completion;
- (NSArray *)getDataFromeLocalPost;
- (void)removeLocalPost;
@end

//这个是成功的案例，但是没有采用共享数据
