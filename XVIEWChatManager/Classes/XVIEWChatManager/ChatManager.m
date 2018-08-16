//
//  ChatManager.m
//  ChatManager
//
//  Created by yyj on 2018/7/4.
//  Copyright © 2018年 zd. All rights reserved.
//

#import "ChatManager.h"
#import <RongIMKit/RCIM.h>
#import <RongIMLib/RongIMLib.h>
#import "RCDCustomerServiceViewController.h"
#import "RongCloudChatListViewController.h"
#import "RongCloudChatViewController.h"
#import <objc/runtime.h>
#import "XVIEWSDKObject.h"
@interface ChatManager()<RCIMGroupMemberDataSource,RCIMReceiveMessageDelegate,RCIMConnectionStatusDelegate,RCIMUserInfoDataSource>
@property (nonatomic,strong) NSMutableArray *groupMemberList;
@property (nonatomic,strong) void(^chatBlock)(XVIEWSDKResonseStatusCode code,NSDictionary *info) ;
@end
@implementation ChatManager
+ (instancetype)defaultChatManager{
    static ChatManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ChatManager alloc]init];
    });
    return manager;
}
-(instancetype)init{
    if (self = [super init]) {
        //消息接收监听的代理
        [RCIM sharedRCIM].receiveMessageDelegate = self;
        //连接状态监听的代理
        [RCIM sharedRCIM].connectionStatusDelegate = self;
        //用户信息提供者的代理
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
    }
    return self;
}
- (NSMutableArray *)groupMemberList{
    if (!_groupMemberList){
        _groupMemberList = [NSMutableArray array];
    }
    return _groupMemberList;
}
/*
 *  NewXVIEW开发平台注册的appKey
 *  key 密钥
 *  launchOtions app入口
 *  isProduct 是否是生成环境
 *  platform  平台
 */
- (void)initWithDict:(NSDictionary*)dict{
    NSLog(@"initWithDict=============%@",dict);
    [[RCIM sharedRCIM] initWithAppKey:dict[@"key"]];
}
/*
 *  NewXVIEW  登陆
 *  token     用户token
 *  userId    用户userId
 *  username  用户username
 *  portrait  用户头像
 */
- (void)loginInfo:(NSDictionary *)dict chatBlock:(void(^)(XVIEWSDKResonseStatusCode code,NSDictionary* info))loginBlock{
    NSLog(@"loginInfo=============%@",dict);
    [[RCIM sharedRCIM] connectWithToken:dict[@"token"] success:^(NSString *userId) {
        NSLog(@"userId===================%@",userId);
        RCUserInfo *userinfo = [[RCUserInfo alloc] initWithUserId:userId name:dict[@"username"] portrait:dict[@"portrait"]];
        [RCIM sharedRCIM].currentUserInfo = userinfo;
        [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
        [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
        [[RCIM sharedRCIM] refreshUserInfoCache:userinfo withUserId:userId];
        loginBlock(XVIEWSDKCodeSuccess,@{@"code":@"0",
                             @"data":@{@"result":@"登录成功"},
                             @"result":@"success"});
    } error:^(RCConnectErrorCode status) {
        NSLog(@"登陆的错误码为:%ld", (long)status);
        loginBlock(XVIEWSDKCodeFail,@{@"code":@"-1",
                             @"data":@{@"result":[NSString stringWithFormat:@"建立连接返回的错误码:%ld", (long)status]},
                             @"result":@"登录失败"});
    } tokenIncorrect:^{
        NSLog(@"token错误");
        loginBlock(XVIEWSDKCodeError,@{@"code":@"-1",
                             @"data":@{@"result":@"token错误"},
                             @"result":@"登录失败"});
    }];
}
/*
 *  NewXVIEW  更新用户信息
 *  token     用户token
 *  userId    用户userId
 *  username  用户username
 *  portrait  用户头像
 */
- (void)updateInfo:(NSDictionary *)dict chatBlock:(void(^)(XVIEWSDKResonseStatusCode code,NSDictionary* info))updateBlock{
    NSLog(@"updateInfo=============%@",dict);
    RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:dict[@"userId"] name:dict[@"username"] portrait:dict[@"portrait"]];
    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:dict[@"userId"]];
    updateBlock(XVIEWSDKCodeSuccess,@{@"code":@"0",
                                     @"data":@{@"result":@"更新成功"},
                                     @"result":@"success"});
}
/*
 *  NewXVIEW  退出登录
 */
- (void)logout{
    NSLog(@"logout=============");
     [[RCIM sharedRCIM] logout];
}
/*
 *  NewXVIEW  跳转会话页面
 *  sessionType 会话类型
 *  sessionId  会话id
 *  title      会话标题
 *  currentVC  当前vc
 */
- (void)gotoChatViewInfo:(NSDictionary *)dict {
    NSLog(@"gotoChatViewInfo=============%@",dict);
    RongCloudChatViewController  *chatVC =
    [[RongCloudChatViewController alloc] init];
    RCConversationType type = [dict[@"sessionType"] isEqualToString:@"Team"] ? ConversationType_GROUP : ConversationType_PRIVATE;
    chatVC.conversationType = type;
    chatVC.targetId = dict[@"sessionId"];
    chatVC.infoDict = dict;
    UIViewController *vc = (UIViewController*)dict[@"currentVC"];
    [vc.navigationController pushViewController:chatVC animated:YES];
}
/*
 *  NewXVIEW  获取会话消息列表
 */
- (void)currentRecentSessions:(void(^)(XVIEWSDKResonseStatusCode code,NSDictionary* info))chatBlock{
     NSLog(@"currentRecentSessions=============");
    self.chatBlock = chatBlock;
    [self getChatList];
}
- (void)getChatList{
    NSArray *conversationList = [[RCIMClient sharedRCIMClient]
                                 getConversationList:@[@(ConversationType_PRIVATE),
                                                       @(ConversationType_GROUP)]];
    NSMutableArray *sessionInfo = [[NSMutableArray alloc] init];
    for (RCConversation *conversation in conversationList) {
        NSDictionary *dict = @{@"sessionId": conversation.targetId,
                               @"unreadCount": [NSString stringWithFormat:@"%d", conversation.unreadMessageCount],
                               @"sentTime":[self timeStringWithTimeInterval:conversation.sentTime/1000],
                               @"receivedTime":[self timeStringWithTimeInterval:conversation.receivedTime/1000],
                               @"messageType": conversation.objectName,
                               @"text":[self returnStringWithConversation:conversation],
                               @"headerImage":[self returnHeaderImage:conversation.conversationType userId:conversation.targetId],
                               @"nickname":conversation.conversationTitle,
                               @"sessionType":conversation.conversationType == ConversationType_PRIVATE ? @"P2P" : @"Team",
                               };
        [sessionInfo addObject:dict];
    }
    [[RCIM sharedRCIM] getUserInfoCache:@""];
    NSDictionary *sessionDict = @{
                                  @"code":@"0",
                                  @"data":@{
                                          @"list":sessionInfo,
                                          @"allUnreadCount":[NSString stringWithFormat:@"%ld", (long)[self gainunreadMsgCount]]},
                                  @"message":@"success"
                                  };
    NSLog(@"self.chatBlock2=======%@",self.chatBlock);
    self.chatBlock(XVIEWSDKCodeSuccess,sessionDict);
}
//获取某条会话中最后一条消息的类型，如果为文本消息则返回信息，否则返回空
- (NSString *)returnStringWithConversation:(RCConversation *)conversation {
    if ([conversation.objectName isEqualToString:@"RC:TxtMsg"]) {
        return [conversation.lastestMessage valueForKey:@"content"];
    }
    else if ([conversation.objectName isEqualToString:@"RC:VcMsg"]) {
        return @"[语音]";
    }
    else if ([conversation.objectName isEqualToString:@"RC:ImgMsg"]) {
        return @"[图片]";
    }
    else if ([conversation.objectName isEqualToString:@"RC:ImgTextMsg"]) {
        return @"[图文]";
    }
    else if ([conversation.objectName isEqualToString:@"RC:LBSMsg"]) {
        return @"[地理位置]";
    }
    else if ([conversation.objectName isEqualToString:@"RC:FileMsg"]) {
        return @"[文件]";
    }
    else if ([conversation.objectName isEqualToString:@"RC:InfoNtf"]) {
        return @"[通知]";
    }
    else if ([conversation.objectName isEqualToString:@"RC:ContactNtf"]) {
        return @"[联系人通知]";
    }
    else if ([conversation.objectName isEqualToString:@"RC:ProfileNtf"]) {
        return @"[资料]";
    }
    else if ([conversation.objectName isEqualToString:@"RC:CmdNtf"]) {
        return @"[指令通知]";
    }
    else if ([conversation.objectName isEqualToString:@"RC:GrpNtf"]) {
        return @"[群组通知]";
    }
    else {
        return @"[来消息了]";
    }
}
//时间戳转换时间
- (NSString *)timeStringWithTimeInterval:(long long)time {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}
- (NSString *)returnHeaderImage:(RCConversationType)type userId:(NSString *)userId {
    if (type == ConversationType_PRIVATE) {
        RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
        if (userInfo) {
            return userInfo.portraitUri ? userInfo.portraitUri : @"";
        }
    }
    else {
        RCGroup *group = [[RCIM sharedRCIM] getGroupInfoCache:userId];
        if (group) {
            return group.portraitUri ? group.portraitUri : @"";
        }
    }
    return @"";
}
//获取某个(某些)类型的会话中所有的未读消息数
- (NSInteger)gainunreadMsgCount {
    //获取单聊群聊所有的未读消息数
    NSInteger unreadMsgCount = (NSInteger)[[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE), @(ConversationType_GROUP)]];
    return unreadMsgCount ? unreadMsgCount : 0;
}
/*
 *  NewXVIEW  刷新消息列表
 */
- (void)refreshCurrentSessionList:(void(^)(XVIEWSDKResonseStatusCode code,NSDictionary* info))chatBlock{
    NSLog(@"refreshCurrentSessionList=============");
    self.chatBlock = chatBlock;
     [self getChatList];
}
/*
 *  NewXVIEW    删除本地消息
 *  sessionType session类型
 *  sessionId   targetId
 */
- (void)deleteRecentSession:(NSDictionary *)dict{
    NSLog(@"deleteRecentSession=============%@",dict);
    RCConversationType type = [dict[@"sessionType"] isEqualToString:@"Team"] ? ConversationType_GROUP : ConversationType_PRIVATE;
    [[RCIMClient sharedRCIMClient] removeConversation:type targetId:dict[@"sessionId"]];
}
/*
 *  NewXVIEW  跳转会话列表页面
 *  currentVC 当前vc
 */
- (void)gotoChatListViewWithController:(NSDictionary*)dict{
    NSLog(@"gotoChatListViewWithController=============");
    RongCloudChatListViewController *chatService =
    [[RongCloudChatListViewController alloc] init];
    UIViewController *vc = (UIViewController*)dict[@"currentVC"];
    [vc.navigationController pushViewController:chatService animated:YES];
}
/*
 *  NewXVIEW  跳转客服页面
 *  sessionType 会话类型
 *  sessionId  会话id
 *  title      会话标题
 *  currentVC 当前vc
 */
- (void)tuneUpCustomerService:(NSDictionary*)dict{
    NSLog(@"tuneUpCustomerService=============%@",dict);
    RCDCustomerServiceViewController *chatService =
    [[RCDCustomerServiceViewController alloc] init];
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;
    chatService.targetId = dict[@"kfId"];
    UIViewController *vc = (UIViewController*)dict[@"currentVC"];
    [vc.navigationController pushViewController:chatService animated:YES];
}
/*
 *  NewXVIEW  更新群成员信息
 *  sessionId  会话id
 *  members    群成员列表
 */
- (void)updateGroupMemberInfo:(NSDictionary *)dict chatBlock:(void (^)(XVIEWSDKResonseStatusCode code ,NSDictionary* info))updateBlock{
    NSLog(@"updateGroupMemberInfo=============%@",dict);
    self.chatBlock = updateBlock;
     self.groupMemberList = dict[@"members"];
     [RCIM sharedRCIM].groupMemberDataSource = self;
}
#pragma mark - RCIMGroupMemberDataSource
-(void)getAllMembersOfGroup:(NSString *)groupId result:(void (^)(NSArray<NSString *> *))resultBlock{
    [[RCIM sharedRCIM]clearGroupUserInfoCache];
    NSMutableArray *lists = [NSMutableArray array];
    for (NSDictionary *user in self.groupMemberList) {
        [lists addObject:user[@"userId"]];
        RCUserInfo *userInfo = [[RCUserInfo alloc]initWithUserId:user[@"userId"] name:user[@"nickname"] portrait:user[@"portrait"]];
        [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:user[@"userId"]];
        [[RCIM sharedRCIM] refreshGroupUserInfoCache:userInfo withUserId:user[@"userId"] withGroupId:groupId];
    }
    self.chatBlock(XVIEWSDKCodeSuccess, @{@"code":@"0",@"message":@"成功"});
    resultBlock([lists copy]);
}
@end
