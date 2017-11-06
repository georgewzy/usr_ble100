//
//  Option.h
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-10.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, MMessageType) {
    PROPERTY_READ = 0,
    PROPERTY_WRITE = 1,
    PROPERTY_NOTIFY = 2,
    PROPERTY_INDICATE=3
};


@interface Option : NSObject

@end
