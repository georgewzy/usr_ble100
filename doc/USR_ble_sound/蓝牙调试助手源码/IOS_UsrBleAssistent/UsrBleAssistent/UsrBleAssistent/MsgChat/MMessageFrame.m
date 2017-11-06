//
//  MMessageFrame.m
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-9.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//



#import "MMessageFrame.h"
#import "MMessage.h"

@implementation MMessageFrame

-(void)setMessage:(MMessage *)message{
    _message = message;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    //计算内容的位置
    CGFloat contentX = ChatMargin;
    CGFloat contentY = ChatMargin;
    
    NSDictionary *attribute = @{NSFontAttributeName: ChatContentFont};
    CGSize contentSize = [_message.msg boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:attribute context:nil].size;
    
    if (_message.type == TYPE_SEND) {
        contentX = screenW - ChatMargin -ChatContentLeft- contentSize.width-ChatContentRight;
    }
    
    _contentF = CGRectMake(contentX, contentY, contentSize.width+ChatContentLeft+ChatContentRight, contentSize.height+ChatMargin);
    
    CGFloat lineY = CGRectGetMaxY(_contentF)+5.0f;
    CGFloat lineHeight = ChatLineBottomHeight;
    _lineF = CGRectMake(contentX, lineY, _contentF.size.width,lineHeight);
    
    _cellHeight = CGRectGetMaxY(_contentF)+ChatMargin;
}

@end
