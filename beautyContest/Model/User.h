//
//  User.h
//  iGangGan
//
//  Created by HeDongMing on 15/12/14.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsynImageView.h"

@interface User : NSObject

@property(strong,nonatomic)NSString *userId;
@property(strong,nonatomic)NSString *userName;
@property(strong,nonatomic)NSString *userNick;
@property(strong,nonatomic)NSString *userAddress;
@property(assign,nonatomic)NSInteger userSex;
@property(strong,nonatomic)NSString *userHeader;
@property(strong,nonatomic)NSString *userPositionX;
@property(strong,nonatomic)NSString *userPositionY;
@property(strong,nonatomic)NSString *userSign;
@property(strong,nonatomic)NSString *userEmail;
@property(strong,nonatomic)NSString *userPhone;
@property(strong,nonatomic)NSString *userPwd;
@property(strong,nonatomic)NSString *userPayPwd;
@property(assign,nonatomic)NSInteger userState;
@property(strong,nonatomic)NSString *userDisplayid;
@property(strong,nonatomic)NSString *userCreatetime;
@property(strong,nonatomic)NSString *infoId;
@property(strong,nonatomic)id infoUser;
@property(strong,nonatomic)NSString *infoProfession;
@property(strong,nonatomic)NSString *infoTall;
@property(strong,nonatomic)NSString *infoWeight;
@property(strong,nonatomic)NSString *infoMeasurements;
@property(strong,nonatomic)NSString *infoZodiac;
@property(strong,nonatomic)NSString *infoBlood;
@property(strong,nonatomic)NSString *infoBirth;



/*************暂时不用****************/
@property(strong,nonatomic)NSString *schoolName;//学校
@property(strong,nonatomic)NSString *relation;//与小孩关系
@property(strong,nonatomic)NSString *className;//班级


@property(strong,nonatomic)NSString *industry;
@property(strong,nonatomic)NSString *companyname;
@property(assign,nonatomic)NSInteger sex;
@property(strong,nonatomic)NSString *profession;

@property(strong,nonatomic)NSString *idcard;
@property(strong,nonatomic)NSString *workaddress;
@property(strong,nonatomic)AsynImageView *userImage;
@property(strong,nonatomic)NSString *constellation;
@property(strong,nonatomic)NSString *currentaddress;
@property(strong,nonatomic)NSString *homeaddress;
@property(strong,nonatomic)NSString *loginid;
@property(strong,nonatomic)NSString *mail;
@property(strong,nonatomic)NSString *name;
@property(strong,nonatomic)NSString *phoneid;
@property(strong,nonatomic)NSString *signature;
@property(assign,nonatomic)NSInteger state;
@property(strong,nonatomic)NSString *phonenum;
/*************暂时不用****************/

- (User *)initUserWithDict:(NSDictionary *)dict;
- (User *)initUserWithUser:(User *)user;

@end
