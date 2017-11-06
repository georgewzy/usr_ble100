//
//  DetailViewController.m
//  UsrBleAssistent
//
//  Created by USRCN on 15-12-9.
//  Copyright (c) 2015年 usr.cn. All rights reserved.
//

#import "DetailViewController.h"
#import "MMessageFrame.h"
#import "MMessage.h"
#import "MMessageCell.h"
#import "Utilities.h"
#import "ResourceHandler.h"
#import "Constants.h"
#import "LoggerHandler.h"
#import "UIUtil.h"
#import "MMSheetView.h"
#import "MMPopupItem.h"
#import "MMPopupWindow.h"

static int const PROPERTY_READ = 0;
static int const PROPERTY_WRITE = 1;
static int const PROPERTY_NOTIFY = 2;
static int const PROPERTY_INDICATE=3;

static NSString *const OPTION_NOTIFY = @"Notify";
static NSString *const OPTION_STOP_NOTIFY = @"Stop Notify";
static NSString *const OPTION_WRITE = @"Write";
static NSString *const OPTION_READ = @"Read";
static NSString *const OPTION_INDICATE = @"Indicate";
static NSString *const OPTION_STOP_INDICATE = @"Stop Indicate";


@interface DetailViewController (){
    NSMutableArray *msgArray;
    BOOL isUSRDebugMode;
    void(^characteristicWriteCompletionHandler)(BOOL success,NSError *error);
    NSDictionary *optionsDic;
    int currentProperty;
    
    BOOL notifyEnable;
    BOOL indicateEnable;
    
    BOOL hexSend;
    
    CBCharacteristic *notifyCharacteristic;
    CBCharacteristic *writeCharacteristic;
    CBCharacteristic *readCharacteristic;
    CBCharacteristic *indicateCharacteristic;
}
   
@end


@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _msgTableView.separatorStyle = 	UITableViewCellSeparatorStyleNone;
    
    msgArray = [[NSMutableArray alloc]init];
    
    optionsDic = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:PROPERTY_NOTIFY],OPTION_NOTIFY, [NSNumber numberWithInt:PROPERTY_READ],OPTION_READ,[NSNumber numberWithInt:PROPERTY_WRITE],OPTION_WRITE,[NSNumber numberWithInt:PROPERTY_INDICATE],OPTION_INDICATE,nil];
    
    isUSRDebugMode = [self.isUsrDebugModeStr isEqualToString:@"YES"];
    notifyCharacteristic = [[CBManager sharedManager]myCharacteristic];
    readCharacteristic = [[CBManager sharedManager]myCharacteristic];
    indicateCharacteristic = [[CBManager sharedManager]myCharacteristic];
    if (isUSRDebugMode) {
        writeCharacteristic = [[CBManager sharedManager]myCharacteristic2];
    }else{
        writeCharacteristic = [[CBManager sharedManager]myCharacteristic];
    }
    
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
     MMSheetViewConfig *sheetConfig = [MMSheetViewConfig globalConfig];
     sheetConfig.defaultTextCancel = @"Cancel";

}


-(void)viewWillAppear:(BOOL)animated{
    [[CBManager sharedManager] setCbCharacteristicDelegate:self];
    [self initView];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    if (notifyEnable) {
        [[[CBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:notifyCharacteristic];
    }
    
    if (indicateEnable) {
        [[[CBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:indicateCharacteristic];
    }
}


-(void)initView{
    
    NSMutableArray *properties = [[CBManager sharedManager] characteristicProperties];
    
    NSString *propertyText = [self getPropertiesText:properties];
    
    [_propertiesLabel setText:[NSString stringWithFormat:@"   %@",propertyText]];
    
    int propertyCount = (int)properties.count;
    
    if (propertyCount == 1) {
        [_btnOptions setHidden:YES];
        [self setOption:propertyText];
    }else{
        [_btnOptions setHidden:NO];
        NSString *firstProperty = [properties objectAtIndex:0];
        [self setOption:firstProperty];
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





-(void)setOption:(NSString*)property{
    int option = [[optionsDic objectForKey:property]intValue];
    currentProperty = option;
    
    switch (option) {
        case PROPERTY_NOTIFY:
            [_btnOption setTitle:notifyEnable?OPTION_STOP_NOTIFY:OPTION_NOTIFY forState:UIControlStateNormal];
            [self showWriteView:NO];
            break;
        case PROPERTY_READ:
            [_btnOption setTitle:OPTION_READ forState:UIControlStateNormal];
            [self showWriteView:NO];
            break;
        case PROPERTY_WRITE:
            [self showWriteView:YES];
            break;
            
        case PROPERTY_INDICATE:
            [_btnOption setTitle:notifyEnable?OPTION_STOP_INDICATE:OPTION_INDICATE forState:UIControlStateNormal];
            [self showWriteView:NO];
            break;
    }
}


- (IBAction)btnOptionsPressed:(UIButton *)sender {
    [self showOptionsMenuView];
}

-(void)showOptionsMenuView{
    
    NSMutableArray *properties = [[CBManager sharedManager] characteristicProperties];
    
    MMPopupItemHandler block = ^(NSInteger index){
        [self setOption:[properties objectAtIndex:index]];
    };
    
    MMPopupBlock completeBlock = ^(MMPopupView *popupView){
        NSLog(@"animation complete");
    };
    
    
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for (int i=0; i<properties.count; i++) {
        [items addObject:MMItemMake([properties objectAtIndex:i], MMItemTypeNormal, block)];
    }
    
    [[[MMSheetView alloc] initWithTitle:@"PROPERTIES"
                                  items:items] showWithBlock:completeBlock];
    
}


- (IBAction)btnOptionPressed:(UIButton *)sender {
    switch (currentProperty) {
        case PROPERTY_NOTIFY:
            [self notifyOption];
            break;
            
        case PROPERTY_READ:
            [self readOption];
            break;
            
        case PROPERTY_INDICATE:
            [self indicateOption];
            break;
    }
}



- (IBAction)btnSendPressed:(UIButton *)sender {
    [_textViewInput resignFirstResponder];
    [self writeOption];
}




-(void)showWriteView:(BOOL)isShow{
    [_btnOption setHidden:isShow];
    [_textViewInput setHidden:!isShow];
    [_btnSend setHidden:!isShow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreBtnPressed:(id)sender {
    [self showMoreMenuView];
}

-(void)showMoreMenuView{
    
    MMPopupItemHandler block = ^(NSInteger index){
        switch (index) {
            case 0:{
                if (hexSend) {
                    break;
                }
                hexSend = YES;
                NSString *text = _textViewInput.text;
                if (text != nil && text.length != 0) {
                    if ([text rangeOfString:@"AT+"].location != NSNotFound || [text rangeOfString:@"at+"].location != NSNotFound) {
                        text = [text stringByAppendingString:@"\r\n"];
                    }
                    NSData *dataToWrite = [text dataUsingEncoding:NSASCIIStringEncoding];
                    NSString *hexStr = [Utilities bytesToHex:dataToWrite];
                    [_textViewInput setText:hexStr];
                }
              }
                
                break;
                
            case 1:{
                hexSend = NO;
                [_textViewInput setText:@""];
              }
                
                break;
            case 2:{
                [msgArray removeAllObjects];
                [_msgTableView reloadData];
              }
                
                break;
        }
    };
    
    MMPopupBlock completeBlock = ^(MMPopupView *popupView){
        NSLog(@"animation complete");
    };

    
    NSArray *items =
  @[MMItemMake(@"HEX Send", MMItemTypeNormal, block),
    MMItemMake(@"ASSCII Send", MMItemTypeNormal, block),
    MMItemMake(@"Clear Display", MMItemTypeHighlight, block)];
    
    [[[MMSheetView alloc] initWithTitle:@"OPTIONS"
                                  items:items] showWithBlock:completeBlock];
}




-(void)showActionSheetWithTitle:(NSString*)title  Options:(NSArray*)options{
    
}

#pragma mark---------UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}


#pragma mark---------UITableViewDataSource,UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return msgArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((MMessageFrame*)msgArray[indexPath.row]).cellHeight;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[MMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
    }
    [cell setMessageFrame:msgArray[indexPath.row]];
    return cell;
}

#pragma mark---------add msg and display

-(void)displayMsg:(MMessage *)msg{
    MMessageFrame *frame = [[MMessageFrame alloc]init];
    [frame setMessage:msg];
    [msgArray addObject:frame];
    [_msgTableView reloadData];
    [self tableViewScrollToBottom];
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottom{
    if (msgArray.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:msgArray.count-1 inSection:0];
    [_msgTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark---------option method

-(void)readOption{
    MMessage *msg = [[MMessage alloc]initMessageWithString:OPTION_READ Type:TYPE_SEND];
    [self displayMsg:msg];
    [[[CBManager sharedManager] myPeripheral] readValueForCharacteristic:readCharacteristic];
}

/*!
 *  @method writeButtonClicked :
 *
 *  @discussion Method to handle the write button click
 *
 */

- (void)writeOption{
    
    NSString *text = _textViewInput.text;
    if (text == nil || text.length == 0) {
        [UIUtil shakeAction:_textViewInput];
        return;
    }

    
    MMessage *msg = [[MMessage alloc]initMessageWithString:text Type:TYPE_SEND];
    [self displayMsg:msg];
    
    NSData *dataToWrite;
    if (hexSend) {
        dataToWrite = [Utilities dataFromHexString:[text stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }else{
        if ([text rangeOfString:@"AT+"].location != NSNotFound || [text rangeOfString:@"at+"].location != NSNotFound) {
            text = [text stringByAppendingString:@"\r\n"];  
        }
       dataToWrite = [text dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    // Write data to the device
    [self writeDataForCharacteristic:writeCharacteristic  WithData:dataToWrite completionHandler:^(BOOL success, NSError *error) {
        if (success){
//            ((MMessageFrame*)[msgArray objectAtIndex:msgArray.count-1]).message.isDone = YES;
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:msgArray.count-1 inSection:0];
//            [_msgTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
            
        }else{
            NSLog(@"-------------->write text fail");
        }
    }];
    
    
    
}




/*!
 *  @method writeDataForCharacteristic: WithData:
 *
 *  @discussion Method to write data to the device
 *
 */
-(void) writeDataForCharacteristic:(CBCharacteristic *)characteristic WithData:(NSData *)data completionHandler:(void(^) (BOOL success, NSError *error))handler{
    characteristicWriteCompletionHandler = handler;
    if ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) != 0)
    {
        [[[CBManager sharedManager] myPeripheral] writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
        characteristicWriteCompletionHandler (YES,nil);
        
    }else{
        [[[CBManager sharedManager] myPeripheral] writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
}




/*!
 *  @method notifyButtonClicked:
 *
 *  @discussion Method to handle notify button click
 *
 */

- (void)notifyOption{
    if (!notifyEnable){
        notifyEnable = YES;

        MMessage *msg = [[MMessage alloc]initMessageWithString:OPTION_NOTIFY Type:TYPE_SEND];
        [self displayMsg:msg];
        
        [_btnOption setTitle:OPTION_STOP_NOTIFY forState:UIControlStateNormal];
        [[[CBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:notifyCharacteristic];

    }else{
        notifyEnable = NO;
        
        MMessage *msg = [[MMessage alloc]initMessageWithString:OPTION_STOP_NOTIFY Type:TYPE_SEND];
        [self displayMsg:msg];
        
        [_btnOption setTitle:OPTION_NOTIFY forState:UIControlStateNormal];
        [[[CBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:notifyCharacteristic];
    }
}

/*!
 *  @method indicateButtonClicked:
 *
 *  @discussion Method to handle indicate button click
 *
 */
- (void)indicateOption{
    if (!indicateEnable){
        indicateEnable = YES;
        [_btnOption setTitle:OPTION_STOP_INDICATE forState:UIControlStateNormal];
        [[[CBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:indicateCharacteristic];
        MMessage *msg = [[MMessage alloc]initMessageWithString:OPTION_INDICATE Type:TYPE_SEND];
        [self displayMsg:msg];
    }else{
        indicateEnable = NO;
        [_btnOption setTitle:OPTION_INDICATE forState:UIControlStateNormal];
        [[[CBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:indicateCharacteristic];
        MMessage *msg = [[MMessage alloc]initMessageWithString:OPTION_STOP_INDICATE Type:TYPE_SEND];
        [self displayMsg:msg];
    }
}

#pragma mark - CBCharacteristicManagerDelegate


-(void) peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[[CBManager sharedManager] myCharacteristic].UUID])
    {
        // Show descriptor button only when descriptors exist for the characteristic
        if (characteristic.descriptors.count > 0)
        {
            [[CBManager sharedManager] setCharacteristicDescriptors:characteristic.descriptors];
             // do somethis
        }
    }
}

/*!
 *@Method Notify Read Indicate options result return
 *
 */
-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([characteristic.UUID isEqual:[[CBManager sharedManager] myCharacteristic].UUID])
    {
        NSString *hexValue =[Utilities bytesToHex:characteristic.value];
        NSString *ASCIIValue = [[NSString alloc]initWithData:characteristic.value encoding:NSASCIIStringEncoding];
        MMessage *msg = [[MMessage alloc]initMessageWithString:[NSString stringWithFormat:@"%@ [ASCII:%@]",hexValue,ASCIIValue] Type:TYPE_RECEIVE];
//        MMessage *msg = [[MMessage alloc]initMessageWithString:hexValue Type:TYPE_RECEIVE];
        [self displayMsg:msg];
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[[CBManager sharedManager] myCharacteristic].UUID])
    {
        if (error == nil){
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:[[CBManager sharedManager] myService].UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:[[CBManager sharedManager] myCharacteristic].UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@- %@",WRITE_REQUEST_STATUS,WRITE_SUCCESS]];
            characteristicWriteCompletionHandler (YES,error);
            
        }else{
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:[[CBManager sharedManager] myService].UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:[[CBManager sharedManager] myCharacteristic].UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@- %@%@",WRITE_REQUEST_STATUS,WRITE_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
            
            characteristicWriteCompletionHandler(NO,error);
        }
    }
}
@end
