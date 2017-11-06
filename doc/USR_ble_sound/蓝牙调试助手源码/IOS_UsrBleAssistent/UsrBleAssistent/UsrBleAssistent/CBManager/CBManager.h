

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Constants.h"
#import "LoggerHandler.h"
#import "ResourceHandler.h"
#import "Utilities.h"


/*!
 *  @property CBDiscoveryDelegate
 *
 *  @discussion The delegate object that will receive events which use for UI updation.
 *
 */
@protocol cbDiscoveryManagerDelegate <NSObject>

/*!
 *  @method discoveryDidRefresh
 *
 *  @discussion			This method invoke after a new peripheral found.
 */
- (void) discoveryDidRefresh;

/*!
 *  @method bluetoothStateUpdatedToState:
 *
 *  @discussion	 This will be invoked when the Bluetooth state changes.
 */

- (void) bluetoothStateUpdatedToState:(BOOL)state;
@end

@protocol cbCharacteristicManagerDelegate <NSObject>

@optional
/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;

/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
 *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

/*!
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error;

@end


@interface CBManager : NSObject 
{
    
}

@property (strong,nonatomic)  id<cbCharacteristicManagerDelegate> cbCharacteristicDelegate;
@property (nonatomic, assign) id<cbDiscoveryManagerDelegate>           cbDiscoveryDelegate;


/*!
 *  @property myPeripheral
 *
 *  @discussion Current Connected Peripheral.
 *
 */
@property (nonatomic, retain)CBPeripheral		*myPeripheral;

/*!
 *  @property myService
 *
 *  @discussion  The selected Service.
 *
 */
@property (nonatomic, retain)CBService			*myService;

/*!
 *  @property myCharacteristic
 *
 *  @discussion  The selected Characteristic.
 *
 */
@property (nonatomic, retain)CBCharacteristic   *myCharacteristic;


/*!
 *  @property myCharacteristic2
 *
 *  @discussion Is just for USR Debug Mode.
 *
 */
@property (nonatomic,retain)CBCharacteristic *myCharacteristic2;

/*!
 *  @property foundPeripherals
 *
 *  @discussion  All discovered peripherals while scanning.
 *
 */
@property (retain, nonatomic) NSMutableArray    *foundPeripherals;

/*!
 *  @property foundServices
 *
 *  @discussion All available services of connected peripheral..
 *
 */
@property (retain, nonatomic) NSMutableArray    *foundServices;

/*!
 *  @property serviceUUIDDict
 *
 *  @discussion  Dictionary contains all listed Known services from pList (ServiceUUIDPlist).
 *
 */
@property (retain, nonatomic) NSMutableDictionary      *serviceUUIDDict;

/*!
 *  @property characteristicProperties
 *
 *  @discussion  Properties of characteristic .
 *
 */
@property (retain,nonatomic) NSMutableArray *characteristicProperties;

/*!
 *  @property characteristicDescriptors
 *
 *  @discussion  Descriptors of characteristic .
 *
 */
@property (retain,nonatomic) NSArray  *characteristicDescriptors;

/*!
 *  @property bootLoaderFilesArray
 *
 *  @discussion  Firmware files selected for device upgrade.
 *
 */

@property (retain, nonatomic) NSArray *bootLoaderFilesArray;

+ (id)sharedManager;


/*								Actions										*/
/****************************************************************************/
- (void) startScanning;
- (void) stopScanning;
- (void) refreshPeripherals;

- (void) connectPeripheral:(CBPeripheral*)peripheral CompletionBlock:(void (^)(BOOL success, NSError *error))completionHandler;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;


@end
