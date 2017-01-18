//
//  ViewController.m
//  RXTodayDemo
//
//  Created by srx on 2017/1/18.
//  Copyright © 2017年 https://github.com/srxboys. All rights reserved.
//

#import "ViewController.h"
#import "RXRandom.h"

#pragma mark ---- 宽 高 定义 --------
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
{
    NSDictionary * _returnDict;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avasterImgView;

- (IBAction)shareButtonClick:(id)sender;
- (IBAction)reloadButtonClick:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self congifUI];
}

//初始化页面UI
- (void)congifUI {
    
    [self falshRequestData];
}

//假装去请求网络数据
- (void)falshRequestData {
    
    NSString * title = [RXRandom randomChinasWithinCount:10];
    NSString * name = [RXRandom randomLetterWithInCount:6];
    NSString * avaster = [RXRandom randomImageURL];
    
    //假如: 这就是你请求的结果
    NSMutableArray * array = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < 2; i ++) {
        if(i == 0) {
            NSDictionary * dictionary = @{@"title": title,
                                          @"name" : name,
                                          @"avaster" : avaster};
            [array addObject:dictionary];
        }
        else {
            NSDictionary * dictionary = @{@"title": [RXRandom randomChinasWithinCount:10],
                                          @"name" : [RXRandom randomLetterWithInCount:6],
                                          @"avaster" : [RXRandom randomImageURL]};
            [array addObject:dictionary];
        }
    }
    _returnDict = @{@"returnData": array, @"status": @(YES), @"message": @"success"};
    
    
    _titleLabel.text = title;
    _nameLabel.text = name;

    NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:avaster]];
    _avasterImgView.image = [UIImage imageWithData:imgData];
}


- (IBAction)shareButtonClick:(id)sender {
    [self saveTheDataYouWantToShareWithDict:_returnDict];
}

- (IBAction)reloadButtonClick:(id)sender {
    [self falshRequestData];
}


- (void)saveTheDataYouWantToShareWithDict:(NSDictionary *)dict {
    NSUserDefaults* userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.ghs.RXToday"];
    [userDefault setObject:dict forKey:@"srxboys"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
