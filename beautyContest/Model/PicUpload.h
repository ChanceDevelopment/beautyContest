//
//  PicUpload.h
//  beautyContest
//
//  Created by Tony on 2016/12/28.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PicUpload : NSObject

+ (NSString *)postRequestWithURL: (NSString *)url  // IN
                      postParems: (NSMutableDictionary *)postParems // IN
                     picFilePath: (NSMutableArray *)picFilePath  // IN
                     picFileName: (NSMutableArray *)picFileName ;


@end
