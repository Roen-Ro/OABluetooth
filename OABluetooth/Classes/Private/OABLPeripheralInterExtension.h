//
//  CBAttribute+OABLInternal.h
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/19.
//

#import <CoreBluetooth/CoreBluetooth.h>

@class OABTCentralManager;

@interface CBAttribute (OABLInternal)

@property (nonatomic) BOOL finishedSubArributeDiscover;

@property (nonatomic, copy) NSString *interPropertiesDescription;

@end

@interface CBPeripheral (OABLInternal)

@property (nullable, nonatomic, weak) OABTCentralManager *centralManager;

@property (nonatomic) int interRssiValue;

@end
