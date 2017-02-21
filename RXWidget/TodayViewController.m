//
//  TodayViewController.m
//  RXWidget
//
//  Created by srx on 2017/1/18.
//  Copyright © 2017年 https://github.com/srxboys. All rights reserved.
//
// iOSsystem > iOS8


#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "RXTodayCollectionViewCell.h"

#pragma mark ---- 宽 高 定义 --------
#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface TodayViewController () <NCWidgetProviding, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSArray * _sourceArray;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configUI];
}


- (void)configUI {
    CGFloat width = ScreenWidth - 40;
    CGFloat height = ScreenHeight - 40;
    NSLog(@"width=%f", width);
    
    CGFloat itemWidth = roundf((width - 40)/2.0);
    
    _flowLayout.itemSize = CGSizeMake(itemWidth, height);
    _collectionView.frame = CGRectMake(20, 40, width, height);
    //高度
    self.preferredContentSize = CGSizeMake(ScreenWidth, 150);
    
//    [self getShareDataWithFile];
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets{
    return UIEdgeInsetsZero;//使左侧默认留白区域被填充

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    
    //执行任何必要的安装程序以更新视图。
    //如果遇到错误，使用NCUpdateresultfailed
    //如果有不需要更新，使用NCUpdateresultnodata
    //如果有更新，使用NCUpdateresultnewdata
    
    
//    [self getShareDataWithFile];
    
    NSUserDefaults* userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.ghs.RXToday"];
    NSDictionary* returnDict = [userDefault objectForKey:@"srxboys"];
    if ([returnDict isKindOfClass:[NSDictionary class]] && returnDict.count > 0) {
        NSLog(@"%@", returnDict);
        BOOL status = [returnDict[@"status"] boolValue];
        NSString * message = returnDict[@"message"];
        if(status) {
            _sourceArray = returnDict[@"returnData"];
            [_collectionView reloadData];
        }
        //高度
        self.preferredContentSize = CGSizeMake(ScreenWidth, 150);
        completionHandler(NCUpdateResultNewData);
    }
    else {
        //高度
        self.preferredContentSize = CGSizeMake(ScreenWidth, 10);
        completionHandler(NCUpdateResultNoData);
        
    }
    
}

- (id)getShareDataWithUserdefalt {
    return nil;
}

- (id)getShareDataWithFile {
    //获取分组的共享目录
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.ghs.RXToday"];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"demo.txt"];
    //读取文件
    NSString *jsonString = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
    
    
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    else {
        NSLog(@"file = jsonString = %@", dic);
    }
    
    
    return jsonString;
}



#pragma mark - ~~~~~~~~~~~ UICollection ~~~~~~~~~~~~~~~
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _sourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RXTodayCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary * dict = _sourceArray[indexPath.item];
    //我这里没有处理异常数据。项目中记得处理避免崩溃
    cell.titleLabel.text = [dict objectForKey:@"title"];
    cell.nameLabel.text = [dict objectForKey:@"name"];
    NSString * imgURL = [dict objectForKey:@"avaster"];
    //图片我就简单的处理了
    NSData * imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgURL]];
    cell.avasteImgView.image = [UIImage imageWithData:imgData];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath.item=%zd", indexPath.item);
    
    [self.extensionContext openURL:[NSURL URLWithString:@"RXTodayWidget://action=GotoHomePage"] completionHandler:^(BOOL success) {
        NSLog(@"open url result:%d",success);
    }];
    
}

@end
