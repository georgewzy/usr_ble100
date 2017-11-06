/*
 * Copyright Cypress Semiconductor Corporation, 2014-2015 All rights reserved.
 *
 * This software, associated documentation and materials ("Software") is
 * owned by Cypress Semiconductor Corporation ("Cypress") and is
 * protected by and subject to worldwide patent protection (UnitedStates and foreign), United States copyright laws and international
 * treaty provisions. Therefore, unless otherwise specified in a separate license agreement between you and Cypress, this Software
 * must be treated like any other copyrighted material. Reproduction,
 * modification, translation, compilation, or representation of this
 * Software in any other form (e.g., paper, magnetic, optical, silicon)
 * is prohibited without Cypress's express written permission.
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY
 * KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
 * NONINFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE. Cypress reserves the right to make changes
 * to the Software without notice. Cypress does not assume any liability
 * arising out of the application or use of Software or any product or
 * circuit described in the Software. Cypress does not authorize its
 * products for use as critical components in any products where a
 * malfunction or failure may reasonably be expected to result in
 * significant injury or death ("High Risk Product"). By including
 * Cypress's product in a High Risk Product, the manufacturer of such
 * system or application assumes all risk of such use and in doing so
 * indemnifies Cypress against all liability.
 *
 * Use of this Software may be limited by and subject to the applicable
 * Cypress software license agreement.
 *
 *
 */

#import "GlucoseModel.h"
#import "CBManager.h"
#import "Constants.h"

/*!
 *  @class GlucoseModel
 *
 *  @discussion Class to handle the glucose service related operations
 *
 */

@interface GlucoseModel () <cbCharacteristicManagerDelegate>

@end

@implementation GlucoseModel
{
    void(^cbCharacteristicHandler)(BOOL success, NSError *error);
    void(^cbcharacteristicDiscoverHandler)(BOOL success, NSError *error);
    
    CBCharacteristic *glucoseMeasurementChar;
}


/*!
 *  @method startDiscoverChar:
 *
 *  @discussion Discovers the specified characteristics of a service..
 */
-(void)startDiscoverChar:(void (^) (BOOL success, NSError *error))handler
{
    cbcharacteristicDiscoverHandler = handler;
    
    [[CBManager sharedManager] setCbCharacteristicDelegate:self];
    [[[CBManager sharedManager] myPeripheral] discoverCharacteristics:nil forService:[[CBManager sharedManager] myService]];
}

/*!
 *  @method updateCharacteristicWithHandler:
 *
 *  @discussion Sets notifications or indications for the value of a specified characteristic.
 */

-(void)updateCharacteristicWithHandler:(void (^) (BOOL success, NSError *error))handler
{
    cbCharacteristicHandler = handler;
    
    if (glucoseMeasurementChar)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:START_NOTIFY];

        [[[CBManager sharedManager] myPeripheral] setNotifyValue:YES forCharacteristic:glucoseMeasurementChar];
    }
}

/*!
 *  @method stopUpdate
 *
 *  @discussion Stop notifications or indications for the value of a specified characteristic.
 */


-(void) stopUpdate
{
    if (glucoseMeasurementChar)
    {
        if (glucoseMeasurementChar.isNotifying)
        {
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:STOP_NOTIFY];
            [[[CBManager sharedManager] myPeripheral] setNotifyValue:NO forCharacteristic:glucoseMeasurementChar];
        }
    }
}




#pragma mark - CBCharacteristicManager delegate

/*!
 *  @method peripheral: didDiscoverCharacteristicsForService: error:
 *
 *  @discussion Method invoked when characteristics are discovered for a service
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:GLUCOSE_SERVICE_UUID])
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Check for the required characteristic
            if ([aChar.UUID isEqual:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID])
            {
                glucoseMeasurementChar = aChar;
                cbcharacteristicDiscoverHandler(YES,nil);
            }
        }
    }
    else
    {
        cbcharacteristicDiscoverHandler(NO,error);
    }
}

/*!
 *  @method peripheral: didUpdateValueForCharacteristic: error:
 *
 *  @discussion Method invoked when the characteristic value changes
 *
 */

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID])
    {
        if (error == nil)
        {
            [self getGlucoseData:characteristic];
            cbCharacteristicHandler(YES,nil);
        }
        else
        {
            cbCharacteristicHandler(NO,error);
        }
    }
}

/*!
 *  @method getGlucoseData:
 *
 *  @discussion  Instance method to parse the data received from the peripheral
 */

-(void) getGlucoseData:(CBCharacteristic *)characteristic
{
    NSData *charData = [characteristic value];
    uint8_t *dataPointer = (uint8_t *)[charData bytes];
    uint8_t flags = dataPointer[0];
    
    if (flags & 0x01)
    {
        // Time stamp data is present
        
        dataPointer+=2;
        
        uint16_t timeStamp = (uint16_t)CFSwapInt16LittleToHost(*((uint16_t *) dataPointer));
        dataPointer+=2;
        
        NSLog(@"timestamp = %hu",timeStamp);
    }
    // Checking whether Glucose concentration,type or sample location present

    else if (flags & 0x02)
    {
        // Checking Glucose concentration unit

        uint16_t concentrationValue;
        
        if (!(flags & 0x04))
        {
            // Unit is kg/L
            
            _concentrationUnitString = @"kg/L";
            concentrationValue = (uint16_t )CFSwapInt16LittleToHost(*((uint16_t *) dataPointer));
            
            dataPointer +=4;
        }
        else
        {
            // Unit is mol/L
            
            _concentrationUnitString = @"mol/L";
            dataPointer +=2;
            concentrationValue = (uint16_t )CFSwapInt16LittleToHost(*((uint16_t *) dataPointer));
            dataPointer +=2;
        }
        
        _glucoseConcentrationValue = concentrationValue;
        
        // Get type
        
        uint8_t tempValue = *(uint8_t *)dataPointer;
        uint8_t typeValue = (tempValue >> 4) & 0x0F;
        _type = [self getTypeNameForValue:typeValue];
        
        // Get sample location
        
        uint8_t locationValue = tempValue & 0x0F;
        _sampleLocation = [self getSampleLocationForValue:locationValue];
        
        
        // Get date
       
        dataPointer = (uint8_t *)[charData bytes];
        dataPointer+=3;
        uint16_t year = CFSwapInt16LittleToHost(*(uint16_t*)dataPointer); dataPointer += 2;
        uint8_t month = *(uint8_t*)dataPointer; dataPointer++;
        uint8_t day = *(uint8_t*)dataPointer; dataPointer++;
        uint8_t hour = *(uint8_t*)dataPointer; dataPointer++;
        uint8_t min = *(uint8_t*)dataPointer; dataPointer++;
        uint8_t sec = *(uint8_t*)dataPointer; dataPointer++;
        
        NSString * dateString = [NSString stringWithFormat:@"%d %d %d %d %d %d", year, month, day, hour, min, sec];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat: @"yyyy MM dd HH mm ss"];
        NSDate* date = [dateFormat dateFromString:dateString];
        
        /*EEE for day, yyyy for Year, dd for date, MM for month*/
        
        [dateFormat setDateFormat:@"yyyy MMM dd"];
        NSString* dateFormattedString = [dateFormat stringFromDate:date];
        
        [dateFormat setDateFormat:@"hh:mm:ss"];
        NSString* timeFormattedString = [dateFormat stringFromDate:date];
        
        
        if( dateFormattedString && timeFormattedString )
        {
            _timeString = [NSString stringWithFormat:@"%@ %@", dateFormattedString, timeFormattedString];
            NSLog(@"time string = %@",_timeString);
        }
        
    }
    
    [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:GLUCOSE_SERVICE_UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:GLUCOSE_MEASUREMENT_CHARACTERISTIC_UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@%@ %@",NOTIFY_RESPONSE,DATA_SEPERATOR,[Utilities convertDataToLoggerFormat:charData]]];
}


/*!
 *  @method getTypeNameForValue:
 *
 *  @discussion  Instance method to get the Type Name
 */

-(NSString *) getTypeNameForValue:(uint8_t)value
{
    NSString *typeName = nil;
    
    switch (value)
    {
        case 0x00:
            typeName = @"Reserved for future use";
            break;
            
        case 0x01:
            typeName = @"Capillary Whole blood";
            break;
        case 0x02:
            typeName = @"Capillary Plasma";
            break;
        case 0x03:
            typeName = @"Venous Whole blood";
            break;
        case 0x04:
            typeName = @"Venous Plasma";
            break;
        case 0x05:
            typeName = @"Arterial Whole blood";
            break;
        case 0x06:
            typeName = @"Arterial Plasma";
            break;
        case 0x07:
            typeName = @"Undetermined Whole blood";
            break;
        case 0x08:
            typeName = @"Undetermined Plasma";
            break;
        case 0x09:
            typeName = @"Interstitial Fluid (ISF)";
            break;
        case 0x0A:
            typeName = @"Control Solution";
            break;
        default:
            typeName = @"Reserved for future use";
            break;
    }
    
    return typeName;
}

/*!
 *  @method getSampleLocationForValue:
 *
 *  @discussion  Instance method to get the sample location
 */

-(NSString *) getSampleLocationForValue:(uint8_t)value
{
    NSString *locationName = nil;
    
    switch (value)
    {
        case 0x00:
            locationName = @"Reserved for future use";
            break;
        case 0x01:
            locationName = @"Finger";
            break;
        case 0x02:
            locationName = @"Alternate Site Test (AST)";
            break;
        case 0x03:
            locationName = @"Earlobe";
            break;
        case 0x04:
            locationName = @"Control solution";
            break;
        case 0x0F:
            locationName = @"Sample Location value not available";
            break;
        
        default:
            locationName = @" Reserved for future use ";
            break;
    }
    
    return locationName;
}


@end
