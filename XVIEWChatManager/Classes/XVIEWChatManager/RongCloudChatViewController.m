//
//  RongCloudChatViewController.m
//  XVIEWDemo
//
//  Created by njxh on 17/7/4.
//  Copyright © 2017年 LianghaoAn. All rights reserved.
//

#import "RongCloudChatViewController.h"
@interface RongCloudChatViewController ()

@end

@implementation RongCloudChatViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.title = _infoDict[@"title"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSString *bundlepath = [[NSBundle mainBundle]pathForResource:@"RongCloud" ofType:@"bundle"];
    NSString *str = [[NSBundle bundleWithPath:bundlepath]pathForResource:@"navigator_btn_back" ofType:@"png"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:str] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
//获取定位信息
-(void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
    [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
}
@end
