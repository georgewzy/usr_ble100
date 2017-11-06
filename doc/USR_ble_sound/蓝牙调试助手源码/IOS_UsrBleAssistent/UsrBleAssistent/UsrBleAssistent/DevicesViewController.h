//
//  ViewController.h
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-3.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBManager.h"
#import "CBPeripheralExt.h"
@interface DevicesViewController : UITableViewController<cbDiscoveryManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *devicesTableView;

@end

