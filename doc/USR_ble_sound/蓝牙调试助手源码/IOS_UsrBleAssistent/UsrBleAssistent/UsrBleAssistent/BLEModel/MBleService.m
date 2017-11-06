//
//  MBleService.m
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-8.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import "MBleService.h"

@implementation MBleService
-(id)initWithName:(NSString *)name Service:(CBService *)service uuid:(CBUUID *)uuid{
    if (self == [super init]) {
        self.name = name;
        self.service = service;
        self.uuid = uuid;
    }
    return self;
}
@end
