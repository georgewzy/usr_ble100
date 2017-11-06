

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DevicesTableViewCell : UITableViewCell

-(void)setDiscoveredPeripheralDataFromPeripheral:(CBPeripheral*) discoveredPeripheral ;

-(void)updateRSSIWithValue:(NSString*) newRSSI;

@end
