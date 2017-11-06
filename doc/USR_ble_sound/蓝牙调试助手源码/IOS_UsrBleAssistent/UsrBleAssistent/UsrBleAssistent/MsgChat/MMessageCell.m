//
//  MMessageCellTableViewCell.m
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-9.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import "MMessageCell.h"
#import "MMessage.h"
#import "MMessageFrame.h"

@implementation MMessageCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.labelMsg = [[UILabel alloc]init];
        self.labelMsg.userInteractionEnabled = NO;
        self.viewLine = [[UIView alloc]init];
        [self.labelMsg setNumberOfLines:0];
        [self.labelMsg setLineBreakMode:NSLineBreakByCharWrapping];
        [self.labelMsg setFont:[UIFont systemFontOfSize:14]];
        
        [self.contentView addSubview:self.labelMsg];
        [self.contentView addSubview:self.viewLine];
    }
    
    return self;
}


//设置内容及Frame
-(void)setMessageFrame:(MMessageFrame *)messageFrame{
    _messageFrame = messageFrame;
    MMessage *msg = messageFrame.message;
    //设置内容
    self.labelMsg.text = msg.msg;
    self.labelMsg.frame = messageFrame.contentF;
    self.viewLine.frame = messageFrame.lineF;
    
    if (msg.type == TYPE_RECEIVE) {
        self.labelMsg.textColor = [UIColor grayColor];
        self.viewLine.backgroundColor = [UIColor grayColor];
    }else{
//        
//        if (msg.isDone) {
//            self.labelMsg.textColor = [UIColor greenColor];
//        }else{
            self.labelMsg.textColor = [UIColor blueColor];
//        }
        self.viewLine.backgroundColor = [UIColor blueColor];
    }
}

@end
