//
//  TodayViewController.m
//  RXWidgetNetwork
//
//  Created by srx on 2017/2/21.
//  Copyright © 2017年 https://github.com/srxboys. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "RXPost.h"
#import "RXTodayCell.h"


@interface TodayViewController () <NCWidgetProviding, UITableViewDelegate, UITableViewDataSource>
{
    CGFloat _tableHeight;
    CGFloat _buttonHeight;
    RXPost * _post;
    
    NSInteger _showRow;
    NSInteger _icrease;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray * sourceArr;

- (IBAction)lookForAppButtonClick:(id)sender;
- (IBAction)lookForNextButtonClick:(id)sender;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%s", __FUNCTION__);
    [self configUI];
}


- (void)configUI {
    
    
    _post = [[RXPost alloc] init];
    //删除本地缓存(一般用于，存错误数据时用)
//    [_post removeLocalPost];
    
    _showRow = 0;
    _icrease = 4;
    
    _tableHeight  = 200;
    _buttonHeight = 40;
    
#ifdef __IPHONE_10_0 //因为是iOS10才有的，还请记得适配
                     //如果需要折叠
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
#endif
    //高度
    self.preferredContentSize = CGSizeMake(0, 110);
    
    _tableView.tableFooterView = [[UIView alloc] init];
    
    self.sourceArr = [_post getDataFromeLocalPost];
    if(self.sourceArr.count > 0) {
        [self.tableView reloadData];
    }
    
    [self reloadData];
}

- (void)setSourceArr:(NSArray *)sourceArr {
    
    if(sourceArr.count <= 0) {
        return;
    }
    
    _sourceArr = sourceArr;
//    [_tableView reloadData];
    
    //    self.extensionContext
    //    [self performSelector:@selector(widgetPerformUpdateWithCompletionHandler:) withObject:nil];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIndetifi = @"RXTodayCell";
    RXTodayCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIndetifi];
    [cell setCellData:_sourceArr[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.extensionContext openURL:[NSURL URLWithString:@"iOSWidgetApp://action=GotoHomePage"] completionHandler:^(BOOL success) {
        NSLog(@"open url result:%d",success);
    }];
    
    
    /*
     在 appDelegate
     - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
     {
     NSString* prefix = @"iOSWidgetApp://action=";
     if ([[url absoluteString] rangeOfString:prefix].location != NSNotFound) {
     NSString* action = [[url absoluteString] substringFromIndex:prefix.length];
     if ([action isEqualToString:@"GotoHomePage"]) {
     
     }
     else if([action isEqualToString:@"GotoOrderPage"]) {
     BasicHomeViewController *vc = (BasicHomeViewController*)self.window.rootViewController;
     [vc.tabbar selectAtIndex:2];
     }
     }
     
     return  YES;
     }
     */
}


//取消widget默认的inset，让应用靠左
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if(activeDisplayMode == NCWidgetDisplayModeCompact) {
        //110
        self.preferredContentSize = CGSizeMake(0, 110);
        _icrease = 1;
    }
    else {
        _icrease = 4;
        //最高，根据设备机型
        self.preferredContentSize = CGSizeMake(0, 400);
    }
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    //执行任何必要的安装程序以更新视图。
    //如果遇到错误，使用NCUpdateresultfailed
    //如果有不需要更新，使用NCUpdateresultnodata
    //如果有更新，使用NCUpdateresultnewdata
    NSLog(@"%s", __FUNCTION__);
    
    if(_post == nil) {
        NSLog(@"completionHandler post=nil");
        if (completionHandler) {
            completionHandler(NCUpdateResultNoData);
        }
        return;
    }
    
    
    NSLog(@"reload = %zd", self.sourceArr.count);
    
    [_post postReqeustCompletion:^(NSArray *array, BOOL isError) {
        if(!isError) {
            self.sourceArr = array;
                        self.preferredContentSize = CGSizeMake(0, 700);
            if (completionHandler) {
                completionHandler(self.sourceArr.count > 0 ? NCUpdateResultNewData : NCUpdateResultNoData);
            }
        }
        else {
            //            self.preferredContentSize = CGSizeMake(0, 0);
            if (completionHandler) {
                completionHandler(NCUpdateResultNoData);
            }
        }
        
        if(_sourceArr.count <= 0) {
            self.preferredContentSize = CGSizeMake(0, 300);
        }
        else {
            self.preferredContentSize = CGSizeMake(0, 700);
        }
        
    }];
    
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    NSLog(@"Today viewDidAppear数据");
//}
//
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Today viewWillwilllllAppear");
}

- (void)reloadData {
    if(_post == nil) {
        NSLog(@"viewWillwilllllAppear post=nil");
        return;
    }
    NSLog(@"开始请求数据");
    __weak typeof(self)weakSelf = self;
    [_post postReqeustCompletion:^(NSArray *array, BOOL isError) {
        
        NSLog(@"进入请求 部分");
        
        if(!isError) {
            weakSelf.sourceArr = array;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
            NSLog(@"Today 刷新数据");
        }
        else {
            NSLog(@"Today 没有数据");
        }
        
    }];
}


- (IBAction)lookForAppButtonClick:(id)sender {
    [self.extensionContext openURL:[NSURL URLWithString:@"iOSWidgetApp://action=GotoOrderPage"] completionHandler:^(BOOL success) {
        NSLog(@"open url result:%d",success);
    }];
}


- (IBAction)lookForNextButtonClick:(id)sender {
    
    if(_sourceArr.count == 0) {
        return;
    }
    
    _showRow += _icrease;
    if(_showRow >= _sourceArr.count) {
        _showRow = 0;
    }
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:_showRow inSection:0];
    //    [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}



#pragma mark ---- 共享
//- (id)getShareDataWithFile {
//    //获取分组的共享目录
//    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.ghs.RXToday"];
//    NSURL *fileURL = [groupURL URLByAppendingPathComponent:@"demo.txt"];
//    //读取文件
//    NSString *jsonString = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
//
//
//    if (jsonString == nil) {
//        return nil;
//    }
//
//    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *err;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                        options:NSJSONReadingMutableContainers
//                                                          error:&err];
//    if(err)
//        {
//        NSLog(@"json解析失败：%@",err);
//        return nil;
//        }
//    else {
//        NSLog(@"file = jsonString = %@", dic);
//    }
//
//
//    return jsonString;
//}



@end
