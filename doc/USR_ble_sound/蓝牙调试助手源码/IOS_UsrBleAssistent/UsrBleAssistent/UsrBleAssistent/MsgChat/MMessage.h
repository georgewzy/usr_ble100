//
//  MMessage.h
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-9.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, MMessageType) {
    TYPE_RECEIVE = 0,//接收的消息
    TYPE_SEND = 1 //发送的消息
};

@interface MMessage : NSObject
@property(nonatomic,copy) NSString *msg;
@property(nonatomic,assign) MMessageType type;
@property(nonatomic,assign) BOOL isDone;

-(id)initMessageWithString:(NSString*)str Type:(MMessageType)type;

@end
