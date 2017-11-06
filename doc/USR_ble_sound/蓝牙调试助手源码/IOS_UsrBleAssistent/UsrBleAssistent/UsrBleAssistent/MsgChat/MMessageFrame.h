//
//  MMessageFrame.h
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-9.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#define ChatMargin 10 //间隔
#define ChatContentW 180 //内容宽度
#define ChatContentFont [UIFont systemFontOfSize:14]//内容字体
#define ChatLineBottomHeight 1;

#define ChatContentTop 15   //文本内容与按钮上边缘间隔
#define ChatContentLeft 10  //文本内容与按钮左边缘间隔
#define ChatContentBottom 5 //文本内容与按钮下边缘间隔
#define ChatContentRight 10 //文本内容与按钮右边缘间隔


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MMessage;

@interface MMessageFrame : NSObject

@property (nonatomic, assign, readonly) CGRect contentF;
@property (nonatomic,assign,readonly) CGRect lineF;
@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, strong) MMessage *message;

@end
