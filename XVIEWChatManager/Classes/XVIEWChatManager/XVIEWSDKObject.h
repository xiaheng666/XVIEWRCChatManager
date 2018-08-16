//
//  XVIEWSDKObject.h
//  XVIEW2.0
//
//  Created by njxh on 16/12/14.
//  Copyright © 2016年 南京 夏恒. All rights reserved.
//

#ifndef XVIEWSDKObject_h
#define XVIEWSDKObject_h

typedef NS_ENUM(NSInteger, XVIEWSDKResonseStatusCode)
{
    XVIEWSDKCodeSuccess                = 0,       //成功
    XVIEWSDKCodeFail                   = 1,       //失败
    XVIEWSDKCodeError                  = 2,       //错误
    XVIEWSDKCodeCancel                 = 3,       //用户点击取消
    XVIEWSDKCodeSentFail               = 4,       //发送失败
    XVIEWSDKCodeAuthDeny               = 5,       //授权失败
    XVIEWSDKCodeNetworkError           = 6,       //网络连接出错
    XVIEWSDKCodeInProcess              = 7,       //正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
    XVIEWSDKCodeResultUnknown          = 8,       //支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
    XVIEWSDKCodeOtherErro              = 9,       //其它支付错误
    XVIEWSDKCodeInitError              = 10,      // 支付初始化错误，订单信息有误，签名失败等
    XVIEWSDKCodeInitParamError         = 11,      // 支付订单参数有误，无法进行初始化，未传必要信息等
    XVIEWSDKCodePayRefund              = 12,       //支付单已退款
    XVIEWSDKCodeUnsupport              = 13,      //微信、微博等不支持的请求
    XVIEWSDKCodeNULLWeChat             = 14,      //没有微信客户端
    XVIEWSDKCodeUnknown               = -100,     //其他
};

typedef NS_ENUM(NSInteger, XVIEWSDKPlatfromType)
{
    XVIEWSDKAlipay                      = 0,       //支付宝支付
    
    XVIEWSDKTypeLLpayQuickPay           = 1,       //连连支付快捷支付
    XVIEWSDKTypeLLpayVerifyPay          = 2,       //连连支付认证支付
    
    XVIEWSDKTypeWeChatPay               = 3,       //微信支付
    XVIEWSDKTypeWeChatLogin             = 4,       //微信登陆
    XVIEWSDKTypeWeChatShareFriend       = 5,       //微信分享给好友
    XVIEWSDKTypeWeChatShareCircle       = 6,       //微信分享到朋友圈
    XVIEWSDKTypeWeChatShareFav          = 7,       //微信分享到收藏
    
    XVIEWSDKTypeTencentLogin            = 8,       //QQ登陆
    XVIEWSDKTypeTencentShareFriend      = 9,       //QQ分享给好友
    XVIEWSDKTypeTencentShareQzone       = 10,      //QQ分享到QQ空间
    
    XVIEWSDKTypeWeiboLogin              = 11,      //微博登陆
    XVIEWSDKTypeWeiboShare              = 12,      //微博分享
    
    XVIEWSDKTypeWeChatMiniProgram  = 13 , //微信小程序
    XVIEWSDKTypeWeChatMiniProgramShare  = 14 , //微信小程序分享
    
    XVIEWPlatformPush                          =         15,       //推送
    
    XVIEWPlatformUmAnaly                    =         16,     //友盟统计
    
    XVIEWPlatformMap                           =         17,       //地图
    
    XVIEWPlatformChat                          =         18       //聊天
};

#endif /* XVIEWSDKObject_h */
