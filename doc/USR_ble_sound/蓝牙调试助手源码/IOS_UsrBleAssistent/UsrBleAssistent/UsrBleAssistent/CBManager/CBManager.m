

#import <UIKit/UIKit.h>
#import "CBManager.h"
#import "CBPeripheralExt.h"
#import "ResourceHandler.h"
#import "Utilities.h"

/*!
 *  @class CBManager
 *
 *  @discussion Class to co-ordinate all the peripheral related operations
 *
 */

@interface CBManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager    *centralManager;
    NSMutableArray *peripheralListArray;
    
    void (^cbCommunicationHandler)(BOOL success, NSError *error);
    BOOL isTimeOutAlert;
}
@end

@implementation CBManager

@synthesize cbCharacteristicDelegate;
@synthesize myPeripheral;
@synthesize myService;
@synthesize myCharacteristic;
@synthesize myCharacteristic2;
@synthesize serviceUUIDDict;
@synthesize cbDiscoveryDelegate;
@synthesize foundPeripherals;
@synthesize foundServices;
@synthesize characteristicDescriptors;
@synthesize characteristicProperties;
@synthesize bootLoaderFilesArray;


#define k_SERVICE_UUID_PLIST_NAME @"ServiceUUIDPList"

#pragma mark - Singleton Methods

+ (id)sharedManager {
    static CBManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init])
    {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        foundPeripherals = [[NSMutableArray alloc] init];
        foundServices = [[NSMutableArray alloc] init];
        peripheralListArray = [[NSMutableArray alloc] init];
        serviceUUIDDict = [NSMutableDictionary dictionaryWithDictionary:[ResourceHandler getItemsFromPropertyList:k_SERVICE_UUID_PLIST_NAME]];
        bootLoaderFilesArray = nil;
    }
    return self;
}


#pragma mark - Discovery
/*								Discovery                                   */
/****************************************************************************/

/*!
 *  @method startScanning
 *
 *  @discussion  To scans for peripherals that are advertising services.
 *
 */

- (void) startScanning
{
    NSLog(@"-------------------->startScanning");
    
    if((NSInteger)[centralManager state] == CBCentralManagerStatePoweredOn)
    {
        [cbDiscoveryDelegate bluetoothStateUpdatedToState:YES];
        NSDictionary *options=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [centralManager scanForPeripheralsWithServices:nil options:options];
    }
    else if ([centralManager state] == CBCentralManagerStateUnsupported)
    {
        [Utilities alert:@"CySmart" Message:@"This device does not support Bluetooth Low Energy"];
    }
}


/*!
 *  @method stopScanning
 *
 *  @discussion  To stop scanning for peripherals.
 *
 */

- (void) stopScanning
{
    [centralManager stopScan];
}


/*!
 *  @method peripheralWithPeripheral:advertisementData:RSSI
 *
 *  @param peripheral           A <code>CBPeripheral</code> object.
 *  @param advertisementData    A dictionary containing any advertisement and scan response data.
 *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
 *								was not available.
 *
 *  @discussion  The methods handles the peripherals are to be displayed or not in the BLE Device List.
 Each time a new peripheral dicover will invoke [discoveryDidRefresh] method.
 *
 */

-(void)peripheralWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    
    if (![peripheralListArray containsObject:peripheral])
    {
        if(peripheral.state == CBPeripheralStateConnected)
        {
        }
        else
        {
            CBPeripheralExt *newPeriPheral = [[CBPeripheralExt alloc] init];
            newPeriPheral.mPeripheral = [peripheral copy];
            newPeriPheral.mAdvertisementData = [advertisementData copy];
            newPeriPheral.mRSSI = [RSSI copy];
            [peripheralListArray addObject:peripheral];
            [foundPeripherals addObject:newPeriPheral];
            [cbDiscoveryDelegate discoveryDidRefresh];
        }
    }
    
}

//  - This is called with the CBPeripheral class as its main input parameter. This contains the information about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    [self peripheralWithPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

#pragma mark - Connection/Disconnection

/*!
 *  @method cancelTimeOutAlert
 *
 *  @discussion Method to cancel timeout alert
 *
 */
-(void)cancelTimeOutAlert
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutMethodForConnect) object:nil];
}

/*!
 *  @method timeOutMethodForConnect
 *
 *  @discussion The methods invoke to cancel the connection request Because connection attempts do not time out,
 *
 */
-(void)timeOutMethodForConnect
{
    isTimeOutAlert = YES;
    [self cancelTimeOutAlert];
    [self disconnectPeripheral:myPeripheral];
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:@"The Connection has Timed Out unexpectedly" forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:@"myDomain" code:100 userInfo:errorDetail];
    [self refreshPeripherals];
    cbCommunicationHandler(NO,error);
}

/*						Connection/Disconnection                            */
/****************************************************************************/


/*!
 *  @method connectPeripheral:CompletionBlock
 *
 *  @param peripheral	The peripheral to which the central is attempting to connect.
 *
 *  @discussion	 Establishes a local connection to a peripheral.
 *
 */
- (void) connectPeripheral:(CBPeripheral*)peripheral CompletionBlock:(void (^)(BOOL success, NSError *error))completionHandler
{
    
      if((NSInteger)[centralManager state] == CBCentralManagerStatePoweredOn)
      {
          cbCommunicationHandler = completionHandler ;
         
          if ([peripheral state] == CBPeripheralStateDisconnected)
          {
              [centralManager connectPeripheral:peripheral options:nil];
              [[LoggerHandler LogManager] LogData:[NSString stringWithFormat:@"[%@] %@",peripheral.name,CONNECTION_REQUEST]];
          }
          else
          {
              [centralManager cancelPeripheralConnection:peripheral];
          }
          
          [self performSelector:@selector(timeOutMethodForConnect) withObject:nil afterDelay:DEVICE_CONNECTION_TIMEOUT];

      }
    

}

/*!
 *  @method disconnectPeripheral:
 *
 *  @param peripheral	The peripheral which needs to be disconnected from central.
 *
 *  @discussion	 Cancels an active or pending local connection to a peripheral.
 *
 */

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    if(peripheral)
    {
        [centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    myPeripheral =  nil;
    myPeripheral = [peripheral copy];
    myPeripheral.delegate = self ;
    [myPeripheral discoverServices:nil];
    
    [[LoggerHandler LogManager] LogData:[NSString stringWithFormat:@"[%@] %@",peripheral.name,CONNECTION_ESTABLISH]];
    [[LoggerHandler LogManager] LogData:[NSString stringWithFormat:@"[%@] %@",peripheral.name,SERVICE_DISCOVERY_REQUEST]];
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
     [self cancelTimeOutAlert];
     cbCommunicationHandler(NO,error);
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cancelTimeOutAlert];

    /*  Check whether the disconnection is done by the device */
    if (error == nil && !isTimeOutAlert)
    {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"The BLE device is disconnected" forKey:NSLocalizedDescriptionKey];
        NSError *disconnectError = [NSError errorWithDomain:@"myDomain" code:100 userInfo:errorDetail];
        [[LoggerHandler LogManager] LogData:[NSString stringWithFormat:@"[%@] %@",peripheral.name,DISCONNECTION_REQUEST]];

        cbCommunicationHandler(NO,disconnectError);
    }
    else
    {
        isTimeOutAlert = NO;
        
        // Checking whether the disconnected device has pending firmware upgrade
        if ([[CBManager sharedManager] bootLoaderFilesArray] != nil && error != nil)
        {
            NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
            [errorDict setValue:[NSString stringWithFormat:@"%@%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey],FIRMWARE_DISCONNECTION_ERROR] forKey:NSLocalizedDescriptionKey];
            
            NSError *disconnectionError = [NSError errorWithDomain:@"myDomain" code:100 userInfo:errorDict];
            cbCommunicationHandler(NO,disconnectionError);
        }
        else
            cbCommunicationHandler(NO,error);
    }

    [self redirectToRootviewcontroller];
    [[LoggerHandler LogManager] LogData:[NSString stringWithFormat:@"[%@] %@",peripheral.name,DISCONNECTED]];
    [self clearDevices];
}

/*!
 *  @method redirectToRootviewcontroller
 *
 *  @discussion	 Pops all the view controllers on the stack except the root view controller and updates the display. This will redirect to BLE Devices Page which list all discovered peripherals,
 *
 */

-(void)redirectToRootviewcontroller
{
    if(cbDiscoveryDelegate)
    {
        [[(UIViewController*)cbDiscoveryDelegate navigationController] popToRootViewControllerAnimated:YES];
    }
    else if(cbCharacteristicDelegate)
    {
        [[(UIViewController*)cbCharacteristicDelegate navigationController] popToRootViewControllerAnimated:YES];
    }
}



#pragma mark - Disc Services

/*	Represents the current state of a CBCentralManager.                     */
/****************************************************************************/



// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [self cancelTimeOutAlert];
    if(error == nil)
    {
        [[LoggerHandler LogManager] LogData:[NSString stringWithFormat:@"[%@] %@- %@",peripheral.name,SERVICE_DISCOVERY_STATUS,SERVICE_DISCOVERED]];
        BOOL isCapsenseExist = NO;
        for (CBService *service in peripheral.services)
        {

            if (![foundServices containsObject:service]) {
                [foundServices addObject:service];
                if([service.UUID isEqual:CAPSENSE_SERVICE_UUID])
                {
                    isCapsenseExist = YES;
                    cbCharacteristicDelegate = nil;  
                     [myPeripheral discoverCharacteristics:nil forService:service];
                }
            }
        }
        if(isCapsenseExist == NO )
            cbCommunicationHandler(YES,nil);
    }
    else
    {
        [[LoggerHandler LogManager] LogData:[NSString stringWithFormat:@"[%@] %@- %@%@]",peripheral.name,SERVICE_DISCOVERY_STATUS,SERVICE_DISCOVERY_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];

        cbCommunicationHandler(NO,error);
        
    }

}




/*	Represents the current state of a CBCentralManager.                     */
/****************************************************************************/

#pragma mark - characteristic/

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    if([cbCharacteristicDelegate isKindOfClass:[CBManager class]] || cbCharacteristicDelegate == nil)
    {
        cbCommunicationHandler(YES,nil);
    }
    else
    {
        [cbCharacteristicDelegate peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
    }
    
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        if (!characteristic.isNotifying)
        {
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@- %@%@",READ_RESPONSE,READ_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
        }
    }
    
    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)])
        [cbCharacteristicDelegate peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)])
    [cbCharacteristicDelegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)])
    [cbCharacteristicDelegate peripheral:peripheral didDiscoverDescriptorsForCharacteristic:characteristic error:error];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (error)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:descriptor.characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:descriptor.characteristic.UUID] descriptor:[Utilities getDiscriptorNameForUUID:descriptor.UUID] operation:[NSString stringWithFormat:@"%@- %@%@",READ_RESPONSE,READ_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
    }
    [cbCharacteristicDelegate peripheral:peripheral didUpdateValueForDescriptor:descriptor error:error];
}


#pragma mark - BLE State

/*	Represents the current state of a CBCentralManager.                     */
/****************************************************************************/

/*!
 *  @method clearDevices
 *
 *  @discussion	 Clear all listed peripherals and services,
 *
 */
- (void) clearDevices
{
    [peripheralListArray removeAllObjects];
    [foundPeripherals removeAllObjects];
    [foundServices removeAllObjects];
}

/*
 Invoked when the central manager’s state is updated. (required)

 If the state is On then app start scanning for peripherals that are advertising services.
 If the state is Off then call method [clearDevices] and redirect to Home screen.
 
 */


- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    switch ((NSInteger)[centralManager state])
    {
        case CBCentralManagerStatePoweredOff:
        {
            [self clearDevices];
            /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            //Show Alert
            [self redirectToRootviewcontroller];
            [cbDiscoveryDelegate bluetoothStateUpdatedToState:NO];
            break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            [Utilities alert:@"CySmart" Message:@"The app is not authorized  to use bluetooth low energy"];
            break;
        }
            
        case CBCentralManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            [Utilities alert:@"CySmart" Message:@"The state of central manager is unknown."];
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
            [cbDiscoveryDelegate bluetoothStateUpdatedToState:YES];
            [self startScanning];
            break;
        }
            
        case CBCentralManagerStateResetting:
        {
            [self clearDevices];
            break;
        }
    }
    
}

/*!
 *  @method refreshPeripherals
 *
 *  @discussion	  Clear all listed peripherals and services.
 Device scanning will add  peripherals that are advertising services.
 And check the status of Bluetooth and alert the user if Off,
 *
 */

- (void) refreshPeripherals
{
    [self clearDevices];
    if([centralManager state] == CBCentralManagerStatePoweredOff)
    {
        [Utilities alert:WARNING Message:@"Turn On Bluetooth to Allow App to Connect to Accessories"];
    }
//    [[CBManager sharedManager] stopScanning];
    [[CBManager sharedManager] startScanning];
}




@end
