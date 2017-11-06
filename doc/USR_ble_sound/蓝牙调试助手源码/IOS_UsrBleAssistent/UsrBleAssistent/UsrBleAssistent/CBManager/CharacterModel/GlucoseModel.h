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

#import <Foundation/Foundation.h>

@interface GlucoseModel : NSObject

-(void)startDiscoverChar:(void (^) (BOOL success, NSError *error))handler;
-(void)updateCharacteristicWithHandler:(void (^) (BOOL success, NSError *error))handler;
-(void)stopUpdate;


/*!
 *  @property timeString
 *
 *  @discussion  time get from the peripheral
 *
 */
@property(nonatomic,retain) NSString *timeString;


/*!
 *  @property concentrationUnitString
 *
 *  @discussion  unit of glucose concentration
 *
 */
@property(nonatomic,retain) NSString *concentrationUnitString;


/*!
 *  @property glucoseConcentrationValue
 *
 *  @discussion Value of Glucose Concentration
 *
 */
@property(nonatomic) float glucoseConcentrationValue;


/*!
 *  @property sensorLocation
 *
 *  @discussion Value of sample location
 *
 */
@property(nonatomic,retain) NSString *sampleLocation;

/*!
 *  @property type
 *
 *  @discussion Value of Sample type
 *
 */
@property(nonatomic,retain) NSString *type;

@end
