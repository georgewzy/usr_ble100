//
//  ViewController.m
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-3.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import "DevicesViewController.h"
#import "MJRefresh.h"
#import "DevicesTableViewCell.h"
#import "ProgressHandler.h"
#import "Utilities.h"
#import "UIView+Toast.h"
#import "MMSheetView.h"
#import "MMPopupItem.h"
#import "MMPopupWindow.h"


@interface DevicesViewController (){
    BOOL isBluetoothON;
}

@end

@implementation DevicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(pullToRefresh)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[CBManager sharedManager] disconnectPeripheral:[[CBManager sharedManager] myPeripheral]];
    [[CBManager sharedManager] setCbDiscoveryDelegate:self];
    
    // Start scanning for devices
    [[CBManager sharedManager] startScanning];
    [self performSelector:@selector(stopScanning) withObject:nil afterDelay:2.0f];
}


-(void)viewDidDisappear:(BOOL)animated{
    [[CBManager sharedManager]stopScanning];
}

-(void)pullToRefresh{
    [[CBManager sharedManager] refreshPeripherals];
    [self performSelector:@selector(stopScanning) withObject:nil afterDelay:2.0f];
}


-(void)stopScanning{
    [[CBManager sharedManager]stopScanning];
    [self.tableView.header endRefreshing];
}


#pragma mark-----UITableDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio{
    if (isBluetoothON) {
        return [[[CBManager sharedManager] foundPeripherals] count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 81.0f;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DevicesTableViewCell *currentCell=[tableView dequeueReusableCellWithIdentifier:@"dev_cell"];
    
    [currentCell setDiscoveredPeripheralDataFromPeripheral:[[[CBManager sharedManager] foundPeripherals] objectAtIndex:indexPath.row] ];
    
    return currentCell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isBluetoothON) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self connectPeripheral:indexPath.row];
    }
}


/**
 *This method invoke after a new peripheral found.
 */
-(void)discoveryDidRefresh
{
    [self.tableView reloadData];
}


- (IBAction)btnMorePressed:(UIBarButtonItem *)sender {
    [self showMoreMenuView];
}


-(void)showMoreMenuView{
    
    MMPopupItemHandler block = ^(NSInteger index){
        switch (index) {
            case 0:{
                [[UIApplication sharedApplication] openURL: [ NSURL URLWithString:@"http://www.usr.cn" ]];
                }
                
                break;
            case 1:{
                [[UIApplication sharedApplication] openURL: [ NSURL URLWithString:@"http://www.usr.cn/Product/cat-86.html" ]];
            }
                
                break;
            case 2:{
                [[UIApplication sharedApplication] openURL: [ NSURL URLWithString:@"http://h.usr.cn" ]];
            }
                
                break;
        }
    };
    
    MMPopupBlock completeBlock = ^(MMPopupView *popupView){
        NSLog(@"animation complete");
    };
    
    
    NSArray *items =
    @[MMItemMake(@"USR official website", MMItemTypeNormal, block),
      MMItemMake(@"BLE Data", MMItemTypeNormal, block),
      MMItemMake(@"Technical Support", MMItemTypeHighlight, block)];
    
    [[[MMSheetView alloc] initWithTitle:@"About BLE"
                                  items:items] showWithBlock:completeBlock];
}








#pragma mark - BlueTooth Turned Off Delegate

/*!
 *  @method bluetoothStateUpdatedToState:
 *
 *  @discussion Method to be called when state of Bluetooth changes
 *
 */

-(void)bluetoothStateUpdatedToState:(BOOL)state
{
    
    isBluetoothON = state;
    [self.tableView reloadData];
    isBluetoothON ? [self.tableView setScrollEnabled:YES] : [self.tableView setScrollEnabled:NO];
}



#pragma mark - Connect

/*!
 *  @method connectPeripheral:
 *
 *  @discussion Method to connect the selected peripheral
 *
 */

-(void)connectPeripheral:(NSInteger)index
{
    
    if ([[CBManager sharedManager] foundPeripherals].count != 0)
    {
        CBPeripheralExt *selectedBLE = [[[CBManager sharedManager] foundPeripherals] objectAtIndex:index];
        [[ProgressHandler sharedInstance] showWithDetailsLabel:@"Connecting.." Detail:selectedBLE.mPeripheral.name];

        [[CBManager sharedManager] connectPeripheral:selectedBLE.mPeripheral CompletionBlock:^(BOOL success, NSError *error) {
            [[ProgressHandler sharedInstance] hideProgressView];
            if(success)
                [self performSegueWithIdentifier:@"segue_service" sender:self];
            else
            {
                if(error)
                {
                    NSString *errorString = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
                    
                    if(errorString.length)
                    {
                        [self.view makeToast:errorString];
                    }
                    else
                    {
                        [self.view makeToast:UNKNOWN_ERROR];
                    }
                }
            }
            
        }];
        
    }
    else
    {
        NSLog(@"Array is nil");
        [[CBManager sharedManager] refreshPeripherals];
    }
    
    
}

@end
