//
//  RCDCustomerServiceViewController.m
//  RCloudMessage
//
//  Created by litao on 16/2/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCustomerServiceViewController.h"

//#import "RCDSettingBaseViewController.h"
@interface RCDCustomerServiceViewController ()
//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始1＊＊＊＊＊＊＊＊＊＊＊＊＊
//@property (nonatomic, strong)NSString *commentId;
//@property (nonatomic)RCCustomerServiceStatus serviceStatus;
//@property (nonatomic)BOOL quitAfterComment;
//＊＊＊＊＊＊＊＊＊应用自定义评价界面结束1＊＊＊＊＊＊＊＊＊＊＊＊＊

@end

@implementation RCDCustomerServiceViewController
- (void)viewDidLoad {
  [super viewDidLoad];
    self.title = @"在线客服";
  [self notifyUpdateUnreadMessageCount];
    self.navigationItem.rightBarButtonItem = nil;
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

//客服VC左按键注册的selector是customerServiceLeftCurrentViewController，
//这个函数是基类的函数，他会根据当前服务时间来决定是否弹出评价，根据服务的类型来决定弹出评价类型。
//弹出评价的函数是commentCustomerServiceAndQuit，应用可以根据这个函数内的注释来自定义评价界面。
//等待用户评价结束后调用如下函数离开当前VC。
- (void)leftBarButtonItemPressed:(id)sender {
  //需要调用super的实现
  [super leftBarButtonItemPressed:sender];

  [self.navigationController popToRootViewControllerAnimated:YES];
}

//评价客服，并离开当前会话
//如果您需要自定义客服评价界面，请把本函数注释掉，并打开“应用自定义评价界面开始1/2”到“应用自定义评价界面结束”部分的代码，然后根据您的需求进行修改。
//如果您需要去掉客服评价界面，请把本函数注释掉，并打开下面“应用去掉评价界面开始”到“应用去掉评价界面结束”部分的代码，然后根据您的需求进行修改。
- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
                               commentId:(NSString *)commentId
                        quitAfterComment:(BOOL)isQuit {
  [super commentCustomerServiceWithStatus:serviceStatus
                                commentId:commentId
                         quitAfterComment:isQuit];
}


//＊＊＊＊＊＊＊＊＊应用自定义评价界面结束2＊＊＊＊＊＊＊＊＊＊＊＊＊

- (void)notifyUpdateUnreadMessageCount {
  __weak typeof(&*self) __weakself = self;
  int count = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
    @(ConversationType_PRIVATE),
    @(ConversationType_DISCUSSION),
    @(ConversationType_APPSERVICE),
    @(ConversationType_PUBLICSERVICE),
    @(ConversationType_CUSTOMERSERVICE),
    @(ConversationType_GROUP)
  ]];
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *backString = nil;
    if (count > 0 && count < 1000) {
      backString = [NSString stringWithFormat:@"返回(%d)", count];
    } else if (count >= 1000) {
      backString = @"返回(...)";
    } else {
      backString = @"返回";
    }
      
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.frame = CGRectMake(0, 6, 87, 23);
//    UIImageView *backImg = [[UIImageView alloc]
//        initWithImage:[UIImage imageNamed:@"navigator_btn_back"]];
//    backImg.frame = CGRectMake(-6, 4, 10, 17);
//    [backBtn addSubview:backImg];
//    UILabel *backText =
//        [[UILabel alloc] initWithFrame:CGRectMake(9, 4, 85, 17)];
//    backText.text = backString;
//      UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((Screen_WIDTH/2)- 60, 0, 100, 30)];
//      label.text = @"美美尚客服";
//      label.textAlignment = NSTextAlignmentCenter;
//      label.textColor = [UIColor whiteColor];
//      [backBtn addSubview:label];
//      // NSLocalizedStringFromTable(@"Back",
//                                // @"RongCloudKit", nil);
//    //   backText.font = [UIFont systemFontOfSize:17];
//    [backText setBackgroundColor:[UIColor clearColor]];
//    [backText setTextColor:[UIColor whiteColor]];
//    [backBtn addSubview:backText];
//    [backBtn addTarget:__weakself
//                  action:@selector(customerServiceLeftCurrentViewController)
//        forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *leftButton =
//        [[UIBarButtonItem alloc] initWithCustomView:backBtn];
//    [__weakself.navigationItem setLeftBarButtonItem:leftButton];
  });
}

- (void)customerServiceLeftCurrentViewController
{
    NSLog(@"返回");
     [self.navigationController popViewControllerAnimated:YES];
}
@end
