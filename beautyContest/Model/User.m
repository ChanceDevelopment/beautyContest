//
//  User.m
//  iGangGan
//
//  Created by HeDongMing on 15/12/14.
//  Copyright © 2015年 iMac. All rights reserved.
//

#import "User.h"

@implementation User


- (User *)initUserWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        if (dict) {
            NSString *userId = [dict objectForKey:@"userId"];
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            self.userId = userId;
            
            NSString *userName = [dict objectForKey:@"userName"];
            if ([userName isMemberOfClass:[NSNull class]] || userName == nil) {
                userName = @"";
            }
            self.userName = userName;
            
            
            NSString *userNick = [dict objectForKey:@"userNick"];
            if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                userNick = @"";
            }
            self.userNick = userNick;
            
            NSString *userAddress = [dict objectForKey:@"userAddress"];
            if ([userAddress isMemberOfClass:[NSNull class]] || userAddress == nil) {
                userAddress = @"";
            }
            self.userAddress = userAddress;
            
            id userSexObj = [dict objectForKey:@"userSex"];
            if ([userSexObj isMemberOfClass:[NSNull class]]) {
                userSexObj = @"";
            }
            self.userSex = [userSexObj integerValue];
            
            NSString *userHeader = [dict objectForKey:@"userHeader"];
            if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil) {
                userHeader = @"";
            }
            self.userHeader = userHeader;
            
            
            NSString *userPositionX = [dict objectForKey:@"userPositionX"];
            if ([userPositionX isMemberOfClass:[NSNull class]] || userPositionX == nil) {
                userPositionX = @"";
            }
            self.userPositionX = userPositionX;
            
         
            NSString *userPositionY = [dict objectForKey:@"userPositionY"];
            if ([userPositionY isMemberOfClass:[NSNull class]] || userPositionY == nil) {
                userPositionY = @"";
            }
            self.userPositionY = userPositionY;
            
            
            NSString *userSign = [dict objectForKey:@"userSign"];
            if ([userSign isMemberOfClass:[NSNull class]] || userSign == nil) {
                userSign = @"";
            }
            self.userSign = userSign;
            
            NSString *userEmail = [dict objectForKey:@"userEmail"];
            if ([userEmail isMemberOfClass:[NSNull class]] || userEmail == nil) {
                userEmail = @"";
            }
            self.userEmail = userEmail;
            
            NSString *userPhone = [dict objectForKey:@"userPhone"];
            if ([userPhone isMemberOfClass:[NSNull class]] || userPhone == nil) {
                userPhone = @"";
            }
            self.userPhone = userPhone;
            
            NSString *userPwd = [dict objectForKey:@"userPwd"];
            if ([userPwd isMemberOfClass:[NSNull class]] || userPwd == nil) {
                userPwd = @"";
            }
            self.userPwd = userPwd;
            
            NSString *userPayPwd = [dict objectForKey:@"userPayPwd"];
            if ([userPayPwd isMemberOfClass:[NSNull class]] || userPayPwd == nil) {
                userPayPwd = @"";
            }
            self.userPayPwd = userPayPwd;
            
            id userStateObj = [dict objectForKey:@"userState"];
            if ([userStateObj isMemberOfClass:[NSNull class]]) {
                userStateObj = @"";
            }
            self.userState = [userStateObj integerValue];
            
            NSString *userDisplayid = [dict objectForKey:@"userDisplayid"];
            if ([userDisplayid isMemberOfClass:[NSNull class]] || userDisplayid == nil) {
                userDisplayid = @"";
            }
            self.userDisplayid = userDisplayid;
            
            NSString *userCreatetime = [dict objectForKey:@"userCreatetime"];
            if ([userCreatetime isMemberOfClass:[NSNull class]] || userCreatetime == nil) {
                userCreatetime = @"";
            }
            self.userCreatetime = userCreatetime;
            
            NSString *infoId = [dict objectForKey:@"infoId"];
            if ([infoId isMemberOfClass:[NSNull class]] || infoId == nil) {
                infoId = @"";
            }
            self.infoId = infoId;
            
            id infoUser = [dict objectForKey:@"infoUser"];
            if ([infoUser isMemberOfClass:[NSNull class]] || infoUser == nil) {
                infoUser = @"";
            }
            self.infoUser = infoUser;
            
            NSString *infoProfession = [dict objectForKey:@"infoProfession"];
            if ([infoProfession isMemberOfClass:[NSNull class]] || infoProfession == nil) {
                infoProfession = @"";
            }
            self.infoProfession = infoProfession;
            
            NSString *infoTall = [dict objectForKey:@"infoTall"];
            if ([infoTall isMemberOfClass:[NSNull class]] || infoTall == nil) {
                infoTall = @"";
            }
            self.infoTall = infoTall;
            
            NSString *infoWeight = [dict objectForKey:@"infoWeight"];
            if ([infoWeight isMemberOfClass:[NSNull class]] || infoWeight == nil) {
                infoWeight = @"";
            }
            self.infoWeight = infoWeight;
            
            NSString *infoMeasurements = [dict objectForKey:@"infoMeasurements"];
            if ([infoMeasurements isMemberOfClass:[NSNull class]] || infoMeasurements == nil) {
                infoMeasurements = @"";
            }
            self.infoMeasurements = infoMeasurements;
            
            
            NSString *infoZodiac = [dict objectForKey:@"infoZodiac"];
            if ([infoZodiac isMemberOfClass:[NSNull class]] || infoZodiac == nil) {
                infoZodiac = @"";
            }
            self.infoZodiac = infoZodiac;
            
            NSString *infoBlood = [dict objectForKey:@"infoBlood"];
            if ([infoBlood isMemberOfClass:[NSNull class]] || infoBlood == nil) {
                infoBlood = @"";
            }
            self.infoBlood = infoBlood;
            
            
            NSString *infoBirth = [dict objectForKey:@"infoBirth"];
            if ([infoBirth isMemberOfClass:[NSNull class]] || infoBirth == nil) {
                infoBirth = @"";
            }
            self.infoBirth = infoBirth;
        }
        
    }
    return self;
}

- (User *)initUserWithUser:(User *)user
{
    self = [super init];
    if (self) {
        if (user) {
            
            NSString *userId = user.userId;
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            self.userId = userId;
            
            NSString *userName = user.userName;;
            if ([userName isMemberOfClass:[NSNull class]] || userName == nil) {
                userName = @"";
            }
            self.userName = userName;
            
            
            NSString *userNick = user.userNick;
            if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                userNick = @"";
            }
            self.userNick = userNick;
            
            NSString *userAddress = user.userAddress;;
            if ([userAddress isMemberOfClass:[NSNull class]] || userAddress == nil) {
                userAddress = @"";
            }
            self.userAddress = userAddress;
            
            self.userSex = user.userSex;
            
            NSString *userHeader = user.userHeader;
            if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil) {
                userHeader = @"";
            }
            self.userHeader = userHeader;
            
            
            NSString *userPositionX = user.userPositionX;
            if ([userPositionX isMemberOfClass:[NSNull class]] || userPositionX == nil) {
                userPositionX = @"";
            }
            self.userPositionX = userPositionX;
            
            
            NSString *userPositionY = user.userPositionY;
            if ([userPositionY isMemberOfClass:[NSNull class]] || userPositionY == nil) {
                userPositionY = @"";
            }
            self.userPositionY = userPositionY;
            
            
            NSString *userSign = user.userSign;
            if ([userSign isMemberOfClass:[NSNull class]] || userSign == nil) {
                userSign = @"";
            }
            self.userSign = userSign;
            
            NSString *userEmail = user.userEmail;
            if ([userEmail isMemberOfClass:[NSNull class]] || userEmail == nil) {
                userEmail = @"";
            }
            self.userEmail = userEmail;
            
            NSString *userPhone = user.userPhone;
            if ([userPhone isMemberOfClass:[NSNull class]] || userPhone == nil) {
                userPhone = @"";
            }
            self.userPhone = userPhone;
            
            NSString *userPwd = user.userPwd;
            if ([userPwd isMemberOfClass:[NSNull class]] || userPwd == nil) {
                userPwd = @"";
            }
            self.userPwd = userPwd;
            
            NSString *userPayPwd = user.userPayPwd;
            if ([userPayPwd isMemberOfClass:[NSNull class]] || userPayPwd == nil) {
                userPayPwd = @"";
            }
            self.userPayPwd = userPayPwd;
            
            self.userState = user.userState;;
            
            NSString *userDisplayid = user.userDisplayid;
            if ([userDisplayid isMemberOfClass:[NSNull class]] || userDisplayid == nil) {
                userDisplayid = @"";
            }
            self.userDisplayid = userDisplayid;
            
            NSString *userCreatetime = user.userCreatetime;
            if ([userCreatetime isMemberOfClass:[NSNull class]] || userCreatetime == nil) {
                userCreatetime = @"";
            }
            self.userCreatetime = userCreatetime;
            
//            self.fansNum = user.fansNum;
//            self.followNum = user.followNum;
//            self.ticketNum = user.ticketNum;
//            
//            self.fansArray = [[NSMutableArray alloc] initWithArray:user.fansArray];
//            self.followArray = [[NSMutableArray alloc] initWithArray:user.followArray];
//            self.ticketArray = [[NSMutableArray alloc] initWithArray:user.ticketArray];
}
        
    }
    return self;
}

@end
