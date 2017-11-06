//
//  CharacteriticsViewControllerTableViewController.m
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-8.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import "CharacteriticsViewController.h"
#import "ResourceHandler.h"


#define READ @"Read"
#define WRITE @"Write"
#define NOTIFY @"Notify"
#define INDICATE @"Indicate"
#define UNKNOW_CHARACTERITIC @"Unknown Characteristic"
#define UUID_SERVICE @"0003cdd0-0000-1000-8000-00805f9b0131"

@interface CharacteriticsViewController (){
    NSArray *characteristicArray;
    BOOL isUSRService;
    BOOL isUSRDebugMode;
}

@end

@implementation CharacteriticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc]init];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.separatorInset = UIEdgeInsetsZero;
    CBService *service = [[CBManager sharedManager] myService];
    
    isUSRService = [service.UUID.UUIDString.lowercaseString isEqualToString:UUID_SERVICE];
    
    [self getcharcteristicsForService:service];
}




/*!
 *  @method getcharcteristicsForService:
 *
 *  @discussion Method to initiate discovering characteristics for service
 *
 */

-(void) getcharcteristicsForService:(CBService *)service
{
    [[CBManager sharedManager] setCbCharacteristicDelegate:self];
    [[[CBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:service];
}

/*!
 *  @method getPropertiesForCharacteristic:
 *
 *  @discussion Method to get the properties for characteristic
 *
 */
-(NSMutableArray *) getPropertiesForCharacteristic:(CBCharacteristic *)characteristic
{
    
    NSMutableArray *propertyList = [NSMutableArray array];
    
    if ((characteristic.properties & CBCharacteristicPropertyRead) != 0)
    {
        [propertyList addObject:READ];
    }
    if (((characteristic.properties & CBCharacteristicPropertyWrite) != 0) || ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0) )
    {
        [propertyList addObject:WRITE];;
    }
    if ((characteristic.properties & CBCharacteristicPropertyNotify) != 0)
    {
        [propertyList addObject:NOTIFY];;
    }
    if ((characteristic.properties & CBCharacteristicPropertyIndicate) != 0)
    {
        [propertyList addObject:INDICATE];
    }
    
    return propertyList;
}



-(NSMutableArray *)getUsrDebugModeProperties{
    NSMutableArray *propertyList = [NSMutableArray array];
    [propertyList addObject:NOTIFY];
    [propertyList addObject:WRITE];
    return propertyList;
}

- (IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (isUSRService) {
        return characteristicArray.count+1;
    }else{
        return characteristicArray.count;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 81.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *SimpleTableIdentifier = @"characteritics_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SimpleTableIdentifier];
    }
    
    UILabel *propertiesLabel = (UILabel *)[cell viewWithTag:201];
    UILabel *infoLabel = (UILabel *)[cell viewWithTag:202];
    
    if (isUSRService && indexPath.row == characteristicArray.count) {
        [infoLabel setText:@"This is not a characteristic just for debug"];
        [propertiesLabel setText:@"USR Debug Mode"];
    }else{
        /* Display characteristic name and properties */
        CBCharacteristic *characteristic = [characteristicArray objectAtIndex:[indexPath row]];
        NSString *characteristicName = [ResourceHandler getCharacteristicNameForUUID:characteristic.UUID];
        
        if ([characteristicName isEqualToString:UNKNOW_CHARACTERITIC]) {
            [infoLabel setText:characteristic.UUID.UUIDString];
        }else{
            [infoLabel setText:characteristicName];
        }
        
        [propertiesLabel setText:[self getPropertiesText:[self getPropertiesForCharacteristic:characteristic]]];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isUSRService && indexPath.row == characteristicArray.count) {
        
        isUSRDebugMode = YES;
        
        NSString *property = [self getPropertiesText:[self getPropertiesForCharacteristic:[characteristicArray objectAtIndex:0]]];
        
        if ([property isEqualToString: NOTIFY]) {
            [[CBManager sharedManager] setMyCharacteristic:[characteristicArray objectAtIndex:0]];
            [[CBManager sharedManager] setMyCharacteristic2:[characteristicArray objectAtIndex:1]];
        }else{
            [[CBManager sharedManager] setMyCharacteristic:[characteristicArray objectAtIndex:1]];
            [[CBManager sharedManager] setMyCharacteristic2:[characteristicArray objectAtIndex:0]];
        }
        
        [[CBManager sharedManager] setCharacteristicProperties:[self getUsrDebugModeProperties]];
    }else{
        
        isUSRDebugMode = NO;
        
        [[CBManager sharedManager] setMyCharacteristic:[characteristicArray objectAtIndex:[indexPath row]]];
        
        [[CBManager sharedManager] setCharacteristicProperties:[self getPropertiesForCharacteristic:[characteristicArray objectAtIndex:[indexPath row]]]];
    }
    
    [self performSegueWithIdentifier:@"detail_segue" sender:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"detail_segue"]){
        id page1=segue.destinationViewController;
        [page1 setValue:isUSRDebugMode?@"YES":@"No" forKey:@"isUsrDebugModeStr"];
    }
}


-(NSString *)getPropertiesText:(NSMutableArray *) characteristicProperties{
    NSString *property = @"";
    
    if (characteristicProperties != nil)
    {
        if (characteristicProperties.count > 0)
        {
            property = [characteristicProperties objectAtIndex:0];
        }
        
        for (int i= 1; i < characteristicProperties.count; i++)
        {
            property = [property stringByAppendingString:[NSString stringWithFormat:@" & %@",[characteristicProperties objectAtIndex:i]]];
        }
        
    }
    
    return property;
}


#pragma mark - CBCharacteristicManagerDelegate

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if ([service.UUID isEqual:[[CBManager sharedManager] myService].UUID]){
        characteristicArray = [service.characteristics copy];
        [self.tableView reloadData];
    }
}
@end
