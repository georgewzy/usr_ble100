//
//  MMessage.m
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-9.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import "MMessage.h"

@implementation MMessage

-(id)initMessageWithString:(NSString *)str Type:(MMessageType)type{
    
    if (self == [super init]) {
        self.msg = str;
        self.type = type;
    }
    
    return self;
}

@end
