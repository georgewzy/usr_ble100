//
//  ServicesViewController.m
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-7.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import "ServicesViewController.h"
#import "CBManager.h"
#import "Constants.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "MBleService.h"

@interface ServicesViewController (){
    NSMutableArray *serviceArray;
}

@end

@implementation ServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    serviceArray = [[NSMutableArray alloc]init];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self prepareServiceList];
    [self.tableView reloadData];
}



- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*!
 *  @method UUIDArray:
 *
 *  @discussion Return all UUID as CBUUID
 *
 */

-(NSArray*)UUIDArray:(NSArray *)allService
{
    NSMutableArray *UUIDArray = [NSMutableArray array];
    for(NSString *string in allService)
    {
        [UUIDArray addObject:[CBUUID UUIDWithString:string]];
    }
    return (NSArray *)UUIDArray;
}


-(void)prepareServiceList{
    NSArray *allService = [self UUIDArray:[[[CBManager sharedManager] serviceUUIDDict] allKeys]];
    if (serviceArray) {
        [serviceArray removeAllObjects];
    }
    
    for(CBService *service in [[CBManager sharedManager] foundServices])
    {
        if([allService containsObject:service.UUID])
        {
            NSInteger ServiceKeyIndex = [allService indexOfObject:service.UUID];
            CBUUID *keyID = [allService objectAtIndex:ServiceKeyIndex];
            
            NSString *name = [[[[CBManager sharedManager] serviceUUIDDict] valueForKey:[keyID.UUIDString lowercaseString]] objectForKey:k_SERVICE_NAME_KEY];
            MBleService *mbleService = [[MBleService alloc]initWithName:name Service:service uuid:keyID];
            [serviceArray addObject:mbleService];
        }
        else
        {
            CBUUID *unknowCBUUID = service.UUID;
            MBleService *mbleService = [[MBleService alloc]initWithName:@"Unknow Service" Service:service uuid:unknowCBUUID];
            [serviceArray addObject:mbleService];
        }
    }
    
    
}

//#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 81.0f;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return serviceArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"service_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SimpleTableIdentifier];
    }

    UILabel *serviceLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *uuidLabel = (UILabel *)[cell viewWithTag:102];
    
    MBleService *service = [serviceArray objectAtIndex:indexPath.row];
    [serviceLabel setText:service.name];
    [uuidLabel setText:service.uuid.UUIDString];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MBleService *mlservice =[serviceArray objectAtIndex:[indexPath row]];
    [[CBManager sharedManager] setMyService:mlservice.service];
    [self performSegueWithIdentifier:@"characteritics_segue" sender:self];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
