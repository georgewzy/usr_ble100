//
//  MBleService.h
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-8.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface MBleService : NSObject

-(id)initWithName:(NSString *)name Service:(CBService *)service uuid:(CBUUID *)uudi;

@property(nonatomic,retain)NSString* name;
@property(nonatomic,retain)CBService* service;
@property(nonatomic,retain)CBUUID* uuid;

@end
