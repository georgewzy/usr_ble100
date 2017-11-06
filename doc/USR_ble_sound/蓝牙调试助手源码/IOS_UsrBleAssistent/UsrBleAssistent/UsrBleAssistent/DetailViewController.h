//
//  DetailViewController.h
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-9.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CBManager.h"


@interface DetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,cbCharacteristicManagerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *propertiesLabel;
@property (weak, nonatomic) IBOutlet UITableView *msgTableView;

@property (weak, nonatomic) IBOutlet UIView *viewBottom;

@property (weak, nonatomic) IBOutlet UIButton *btnOptions;

@property (weak, nonatomic) IBOutlet UIButton *btnOption;

@property (weak, nonatomic) IBOutlet UITextView *textViewInput;

@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@property (nonatomic,copy) NSString *isUsrDebugModeStr;
@end
