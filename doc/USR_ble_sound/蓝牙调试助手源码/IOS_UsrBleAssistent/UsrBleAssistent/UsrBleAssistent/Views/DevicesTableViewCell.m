

#import "DevicesTableViewCell.h"
#import "CBPeripheralExt.h"
#import "Constants.h"

/*!
 *  @class ScannedPeripheralTableViewCell
 *
 *  @discussion Model class for handling operations related to peripheral table cell
 *
 */

@implementation DevicesTableViewCell
{
    /*  Data fields  */
    __weak IBOutlet UILabel *RSSIValueLabel;
    __weak IBOutlet UILabel *peripheralAdressLabel;
    __weak IBOutlet UILabel *peripheralName;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*!
 *  @method nameForPeripheral:
 *
 *  @discussion Method to get the peripheral name
 *
 */
-(NSString *)nameForPeripheral:(CBPeripheralExt *)ble
{
    NSString *bleName ;
    
    if ([ble.mAdvertisementData valueForKey:CBAdvertisementDataLocalNameKey] != nil)
    {
        bleName = [ble.mAdvertisementData valueForKey:CBAdvertisementDataLocalNameKey];
    }
    
    if(bleName.length < 1 )
        bleName = ble.mPeripheral.name;
    
    if(bleName.length < 1 )
        bleName = UNKNOWN_PERIPHERAL;
    
    return bleName;
}


/*!
 *  @method UUIDStringfromPeripheral:
 *
 *  @discussion Method to get the UUID from the peripheral
 *
 */
-(NSString *)UUIDStringfromPeripheral:(CBPeripheralExt *)ble
{
    
    NSString *bleUUID = ble.mPeripheral.identifier.UUIDString;
    if(bleUUID.length < 1 )
        bleUUID = @"Nil";
    else
        bleUUID = [NSString stringWithFormat:@"UUID: %@",bleUUID];
    
    return bleUUID;
}

/*!
 *  @method ServiceCountfromPeripheral:
 *
 *  @discussion Method to get the number of services present in a device
 *
 */
-(NSString *)ServiceCountfromPeripheral:(CBPeripheralExt *)ble
{
    NSString *bleService =@"";
    NSInteger serViceCount = [[ble.mAdvertisementData valueForKey:CBAdvertisementDataServiceUUIDsKey] count];
    if(serViceCount < 1 )
        bleService = @"No Services";
    else
        bleService = [NSString stringWithFormat:@" %ld Service Advertised ",(long)serViceCount];
    
    return bleService;
}

#define RSSI_UNDEFINED_VALUE 127


/*!
 *  @method RSSIValue:
 *
 *  @discussion Method to get the RSSI value
 *
 */
-(NSString *)RSSIValue:(CBPeripheralExt *)ble
{
    
    NSString *deviceRSSI=[ble.mRSSI stringValue];
    
    if(deviceRSSI.length < 1 )
    {
        if([ble.mPeripheral respondsToSelector:@selector(RSSI)])
            deviceRSSI = ble.mPeripheral.RSSI.stringValue;
    }
    
    if([deviceRSSI intValue]>=RSSI_UNDEFINED_VALUE)
        deviceRSSI = @"Undefined";
    else
        deviceRSSI=[NSString stringWithFormat:@"%@ dBm",deviceRSSI];
    
    return deviceRSSI;
}


/*!
 *  @method setDiscoveredPeripheralDataFromPeripheral:
 *
 *  @discussion Method to display the device details
 *
 */
-(void)setDiscoveredPeripheralDataFromPeripheral:(CBPeripheralExt*) discoveredPeripheral
{
    peripheralName.text         = [self nameForPeripheral:discoveredPeripheral];
    peripheralAdressLabel.text  = [self ServiceCountfromPeripheral:discoveredPeripheral];
    RSSIValueLabel.text         = [self RSSIValue:discoveredPeripheral];

}

/*!
 *  @method updateRSSIWithValue:
 *
 *  @discussion Method to update the RSSI value of a device
 *
 */
-(void)updateRSSIWithValue:(NSString*) newRSSI
{
    RSSIValueLabel.text=newRSSI;
}
@end
