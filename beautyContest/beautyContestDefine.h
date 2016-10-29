//
//  beautyContestDefine.h
//  beautyContest
//
//  Created by Tony on 16/7/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#ifndef beautyContestDefine_h
#define beautyContestDefine_h

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double ) 568 ) < DBL_EPSILON )
#define ALBUMNAME @"BeautyContestDocument"
//#define ALBUMNAMEDOCUMENT @"FuYangDocument"
#define NAVTINTCOLOR [UIColor whiteColor]
#define SCREENWIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREENHEIGH ([UIScreen mainScreen].bounds.size.height)
#define ISIOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.9)
#define ISIOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.9)
#define ISIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] > 7.9)
#define ISIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.9)
#define ISIOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.9)
#define IOS7OFFSET        64


//百度地图的appKey
#define BAIDUMAPKEY @"6R0tNr84gr1qwQxrZByKSjzGpkNco4kv"
//自己服务器的通信模块
#define EASEMOBKEY @"godchance#aishangfuyang"
//parse
#define PARSEID @"0UMEqqvx8ykfdxtmlGjOmpEmALI6P3htEFG36wbl"
#define PARSEKEY @"eniHIEQDWZxmPlBRRF71105eoaioEGUotgUK2ryS"

//1105788632
#define QQKEY @"Wzq98Z10dKYLfToe"
#define SINAWEIBOKEY @"568898243"
#define TENCENTKEY @"8VsUOu0ZTKHo2aEp"
#define WECHATKEY @"wx3f1b3c1d58c8cad7"

#define QQAPPSECRET @"566d0e00e0f55a9c1c00a604"
#define SINAWEIBOAPPSECRET @"38a4f8204cc784f81f9f0daaf31e02e3"
#define TENCENTAPPSECRET @"ae36f4ee3946e1cbb98d6965b0b2ff5c"
#define WECHATAPPSECRET @"515c6776cdf755627de32f122b81cb23"

#define WECHATREDURECTURI @"http://www.sharesdk.cn"
#define QQREDURECTURI @"http://www.sharesdk.cn"
#define SINAWEIBOREDURECTURI @"http://www.sharesdk.cn"
#define TENCENTREDURECTURI @"http://www.sharesdk.cn"
#define WECHATREDURECTURI @"http://www.sharesdk.cn"

#define RONGCLOUDAPPSECRET @"3ziF82PRCob"
#define RONGCLOUDAPPKEY @"25wehl3uwoytw"
//激光推送的key
#define JPUSHAPPKEY @"31c72d8929b7054604ba6d35"
//shareSDK的key
#define SHARESDKKEY @"1878518ee2b58"
#define SHARESDKAPPSECRET @"d7a3a7e8f2c0ffe5646ebeb06f490ba0"

#define SHARESDKSMSKEY @"1708ac6e7ce17"
#define SHARESDKSMSAPPSECRET @"ae4cc04991a8c6bd16d07522498f14ea"
//友盟iPhone的key
#define UMANALYSISKEY @"5814191175ca353f95003344"
//友盟iPad的key
#define UMANALYSISKEY_HD @"5814191175ca353f95003344"


//登录状态发生变化的通知
#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"

#define UPDATEUSER_NOTIFICATION @"updateUser"

#define RECEIVEBUDDYINVITE_NOTIFICATION @"receiveBuddyInvite"

//图片上传成功发出的通知
#define UPLOADIMAGESUCCEED_NOTIFICATION @"uploadImageSucceed"

//用户的签名 sign
#define USERSIGNKEY @"userSignKey"
//用户的ID userid
#define USERIDKEY @"userIDKey"
#define USERTOKENKEY @"userTokenKey"
#define USERACCOUNTKEY @"userAccountKey"
#define USERPASSWORDKEY @"userPasswordKey"
#define USERHAVELOGINKEY @"userHaveLogin"
#define FRIENDLISTDOWNLOADSUCCEED @"friendDownloadSucceed"

#define USERLATITUDEKEY @"latitude"
#define USERLONGITUDEKEY @"longitude"

#define ERRORREQUESTTIP @"网络出错，请稍后再试!"
#define MODIFYPASSWORDKEY @"modifyPasswordKey"

#define RGB(r,g,b,a)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

//Link notificaiton点击label的某种链接的通知
#define LinkNOTIFICATION @"LinkNotification"
//Label的vaule的key
#define LINKVALUEKey @"linkValue"
//Label的Type的key
#define LINKTypeKey @"linkType"

#define TOPNAVIHEIGHT 44
//请求成功的状态码
#define REQUESTCODE_SUCCEED 200
//活动的图标空位符号
#define EMPTYSTRING @"     : "
//默认橙色的RGB
#define APPDEFAULTORANGE ([UIColor colorWithRed:34.0 / 255.0 green:157.0 / 255.0 blue:187.0 / 255.0 alpha:1.0])
//默认标题颜色
#define APPDEFAULTTITLECOLOR ([UIColor whiteColor])
//默认标题的字体
#define APPDEFAULTTITLETEXTFONT ([UIFont fontWithName:@"Helvetica" size:20.0])
//默认table的背景颜色
#define APPDEFAULTTABLEBACKGROUNDCOLOR ([UIColor colorWithWhite:245.0 / 255.0 alpha:1.0])
//默认table的分割线颜色
#define APPTABLESEPARATORCOLOR ([UIColor colorWithWhite:237.0 / 255.0 alpha:1.0])
//默认view的背景颜色
#define APPDEFAULTVIEWCOLOR ([UIColor whiteColor])
//图片加载出错的时候默认图
#define DEFAULTERRORIMAGE @"errorImage"

//登录的广播
#define LOGINSTATEKEY @"loginStateKey"
#define LOGINOUTKEY   @"loginOut"       //退出登录
#define LOGINKEY   @"login"       //登录
#define UPDATEUSER @"updateUser"

//黄金比例
#define BESTSCALE (0.618)
//系统的设置
#define NEWSNOTIFY        @"newsNotify"         //消息通知
#define PLAYSOUND         @"playSound"          //声音
#define VIBRATION         @"vibration"          //震动
#define IOS7OFFSET        64
#define SHAREACTIVITYAUTO @"shareActivityAuto" //活动自动分享
#define ACTIVITYRECOMMEND @"activityRecommend" //活动推荐
#define FRIENDNEWSREMIND  @"friendNewsRemind"  //好友消息提醒
#define ACTIVITYREMIND    @"activityRemind"    //活动开始提醒
#define CIRCLEREPLY       @"circleReply"       //圈子回复
#define SYSTEMNOTIFY      @"systemNotify"      //系统通知
#define LOUDSPEAKER       @"loudSpeaker"       //扬声器

typedef enum {
    ENUM_SEX_Boy=1,//男
    ENUM_SEX_Girl //女
} ENUM_SEXType;

#endif /* beautyContestDefine_h */
