//
//  ViewController.m
//  RXTodayDemo
//
//  Created by srx on 2017/1/18.
//  Copyright © 2017年 https://github.com/srxboys. All rights reserved.
//

#import "ViewController.h"
#import "RXPost.h"

#pragma mark ---- 宽 高 定义 --------
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
{
    RXPost * _post;
    NSDictionary * _returnDict;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self congifUI];
}

//初始化页面UI
- (void)congifUI {
    _post = [[RXPost alloc] init];
    
    //删除本地缓存(一般用于，存错误数据时用)
    //    [_post removeLocalPost];
    
    //请求网络数据
    [_post postReqeustCompletion:^(NSArray *array, BOOL isError) {
        NSLog(@"isError=%@\narray=\n=%@", isError?@"YES":@"NO", array);
    }];
}



- (void)saveTheDataYouWantToShareWithDict:(NSDictionary *)dict {
    NSUserDefaults* userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.ghs.RXToday"];
    [userDefault setObject:dict forKey:@"srxboys"];
}

- (void)saveDataToshareFileWidthDict:(NSDictionary *)dict {
    //获取分组的共享目录
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.ghs.RXToday"];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"demo.txt"];
    
    NSData * data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString * objcStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"file share dataStr=%@", objcStr);
    //写入文件
    [objcStr writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
//    //读取文件
//    NSString *str = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
//    NSLog(@"str = %@", str);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
