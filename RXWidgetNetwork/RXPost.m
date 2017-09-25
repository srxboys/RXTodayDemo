//
//  RXPost.m
//  RXExtenstion
//
//  Created by srx on 16/7/14.
//  Copyright © 2016年 https://github.com/srxboys. All rights reserved.
//
//target -> [RXTodayDemo, RXWidgetNetwork]
//系统 原生 请求
#import "RXPost.h"

#import "RXTodayModel.h"

//afn 请求用到的
//#import "RXAFNS.h"

//系统原生请求用到的
#import "RXResponse.h"

// 接口
#define Method        @"b2c.advertising2.getad"


//操作系统版本
#define SYSTEMVERSION [UIDevice currentDevice].systemVersion

#define Today_groupID     @"group.ghs.RXToday"
#define Today_userdefault @"todayData"

typedef void(^httpCompletion)(NSArray * array, BOOL isError);


@interface RXPost()
{
    NSURLSessionDataTask * _dataTask;
}
@property (nonatomic, copy) httpCompletion httpCompletion;
@end


@implementation RXPost

#pragma mark - ~~~~~~~~~~~ 请求网络数据 ~~~~~~~~~~~~~~~

- (NSUserDefaults *)usersDefault {
    return [[NSUserDefaults alloc] initWithSuiteName:Today_groupID];
}

- (void)removeLocalPost {
    NSUserDefaults * userDefault = [self usersDefault];
    [userDefault removeObjectForKey:Today_userdefault];
    [userDefault synchronize];
}


//系统原生请求
- (void)postReqeustCompletion:(void (^)(NSArray *, BOOL))completion {
    
    NSURL * url = [NSURL URLWithString:@"http://app.ghs.net/index.php/api"];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    if(request == nil) {
        //NSLog(@"Post invalid request");
        completion (nil, YES);
        return;
    }
    
    [request setHTTPMethod:@"POST"];
    
    //头文件，不好配置啊
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//        [request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    //    [request setAllHTTPHeaderFields:headers];
    
    NSError * error = nil;
    
    //1、body 为 字符串 --> ut8
    NSData * data = [self paramsDataUTF8];
    
    //2、body 为 字典 --> json Data    【4003错误，估计是要转码吧】
    //    NSDictionary * dict = [self network];
    //    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if(error) {
        completion (nil, YES);
        //NSLog(@"Post paramsDict error=%@", error.description);
        return;
    }
    [request setHTTPBody:data];
    
    //    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
    
    __weak typeof(self)weakSelf = self;
    
    NSURLSession * session = [NSURLSession sharedSession];
    
    _dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //NSLog(@"\n\nPost 请求结束\n------\n\n");
        if(error) {
            NSLog(@"Post dataTaskWithReques error =%@", error.description);\
            completion (nil, YES);
            NSArray * array = [weakSelf getDataFromeLocalPost];
            completion(array, ![array arrBOOL]);
            return ;
        }
    
        
        NSError * jsonError = nil;
        NSDictionary * jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        if(jsonError) {
            //NSLog(@"Post jsonError error=%@", jsonError);
            NSArray * array = [weakSelf getDataFromeLocalPost];
            completion(array, ![array arrBOOL]);
        }
        else {
            //NSLog(@"结果为=%@", jsonDict);
            RXResponse * responseObject = [RXResponse responseWithDict:jsonDict];
            if(!responseObject.status) {
                //NSLog(@"error=%@", responseObject.message);
                NSArray * array = [weakSelf getDataFromeLocalPost];
                completion(array, ![array arrBOOL]);
                return ;
            }
            
            //NSLog(@"请求下来的数据=%@", responseObject.returndata);
            
            if([responseObject.returndata arrBOOL]) {
                
                //获取数据
                NSArray * childrenArr = [responseObject.returndata[0] objectForKeyNotNull:@"ad_list"];
                //总分页
//                NSInteger totalePage = [[responseObject.returndata[0] objectForKeyNotNull:@"total_count"] integerValue];
                
                if([childrenArr arrBOOL]) {
                    NSMutableArray * array = [[NSMutableArray alloc] init];
                    for(NSDictionary * dict in childrenArr) {
                        RXTodayModel * coupModel = [RXTodayModel todayModelWithDictionary:dict];
                        [array addObject:coupModel];
                    }
                    NSDate * now = [NSDate date];
                    NSDictionary * dict = @{@"date":[self getDateFormatter:now],@"data":array};
                    [self setArrayToUserDefault:dict];
                    completion(array, NO);
                }
                else {
                    NSArray * array = [weakSelf getDataFromeLocalPost];
                    completion(array, ![array arrBOOL]);
                }
                
            }
            else {
                NSArray * array = [weakSelf getDataFromeLocalPost];
                completion(array, ![array arrBOOL]);
            }
            
        }
    }];

    [_dataTask resume];
    _httpCompletion = completion;
}


- (void)setArrayToUserDefault:(NSDictionary *)tempDict {
    @autoreleasepool {
        if (tempDict == nil)
        {
            [self removeLocalPost];
            return;
        }
        
        //NSKeyedArchiver     把对象写到二进制流中去。
        NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:tempDict];
        
        NSUserDefaults* userDefault = [self usersDefault];
        [userDefault setObject:newData forKey:Today_userdefault];
        [userDefault synchronize];
    }
}


#pragma mark - ~~~~~~~~~~~ 获取本地数据 ~~~~~~~~~~~~~~~
- (NSArray *)getDataFromeLocalPost {
    
    NSData *oldData = [[self usersDefault] objectForKey:Today_userdefault] ;
    NSArray * array = nil;
    NSDictionary * dict = nil;
    if (oldData!=nil)
    {
        dict = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
#if DEBUG
        
        //NSLog(@"Post Have error data num = %lu",(unsigned long)[array count]);
#endif
    }
    
    if(![dict dictBOOL]) return nil;
    NSDate * oldDate = [self getStringFormatter:[dict objectForKeyNotNull:@"date"]];
    NSTimeInterval interval = [oldDate timeIntervalSince1970];
    NSLog(@"getLocalData interval=%zd", interval);
    array = [dict objectForKey:@"data"];
    
    NSMutableArray *errorLogArray = [[NSMutableArray alloc] init];
    if ([array count]>0)
    {
        //确保字典 key 一定是存在，否则崩溃
        for(RXTodayModel * todayModel in array)
        {
            [errorLogArray addObject:todayModel];
        }
    }
    return errorLogArray;
}

- (NSString *)getDateFormatter:(NSDate *)date {
    // 将当前时间以字符串形式输出
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    return strDate;
}

- (NSDate *)getStringFormatter:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

- (NSString *)valueWithNIL:(NSString *)string {
    if(string == nil || [string rangeOfString:@"null"].location != NSNotFound) {
        return @"";
    }
    return string;
}

- (NSData *)paramsDataUTF8{
    NSString * string = @"member_id=0&sign=FC06B36057E41D6411318953F2E5D3A1&pagelist=10&uuid=0c439e09e472f939d8e3a96708aeccff7769a7cc&version=3.0.0&software=11.0&device_type=827384&city_num=110000&pagenext=0&umeng_channel=真机测试&hardware=Simulator&method=b2c.advertising2.getad";
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}


//afn  不行啊
/*
 - (void)postReqeustCompletion:(void (^)(NSArray *, BOOL))completion {
 
 NSDictionary * paramsDict = [self network];
 
 [RXAFNS postReqeustWithParams:paramsDict successBlock:^(Response *responseObject) {
 
 if(!responseObject.status) {
 //NSLog(@"error=%@", responseObject.message);
 completion(nil, YES);
 return ;
 }
 
 if([responseObject.returndata arrBOOL]) {
 
 //获取数据
 NSArray * childrenArr = [responseObject.returndata[0] objectForKeyNotNull:@"children"];
 //总分页
 NSInteger totalePage = [[responseObject.returndata[0] objectForKeyNotNull:@"total_page"] integerValue];
 
 if([childrenArr arrBOOL]) {
 NSMutableArray * array = [[NSMutableArray alloc] init];
 for(NSDictionary * dict in childrenArr) {
 RXTodayModel * coupModel = [RXTodayModel todayModelWithDictionary:dict];
 [array addObject:coupModel];
 }
 [self setArrayToUserDefault:array];
 completion(array, NO);
 }
 else {
 completion(nil, YES);
 }
 
 }
 else {
 completion(nil, YES);
 }
 
 } failureBlock:^(NSError *error) {
 //NSLog(@"error=%@", error.description);
 completion(nil, YES);
 } showHUD:NO loadingInView:nil];
 
 }
 */


@end
