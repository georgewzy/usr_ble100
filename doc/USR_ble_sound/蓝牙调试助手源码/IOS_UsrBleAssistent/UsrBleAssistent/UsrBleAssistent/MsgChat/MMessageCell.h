//
//  MMessageCellTableViewCell.h
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-9.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MMessageFrame;

@interface MMessageCell : UITableViewCell

@property (nonatomic,retain)UILabel *labelMsg;
@property (nonatomic,retain)UIView *viewLine;
@property (nonatomic,retain)MMessageFrame *messageFrame;

@end
