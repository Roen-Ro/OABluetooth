//
//  CBAttribute+OABLInternal.m
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/19.
//

#import "OABLPeripheralInterExtension.h"
#import <ObjcExtensionProperty/ObjcExtensionProperty.h>

@class OABTCentralManager;
@implementation CBAttribute (OABLInternal)

__SETTER_PRIMITIVE(BOOL, finishedSubArributeDiscover, setFinishedSubArributeDiscover:, numberWithBool:)
__GETTER_PRIMITIVE(BOOL, finishedSubArributeDiscover, boolValue)

__SETTER(interPropertiesDescription, setInterPropertiesDescription:, OBJC_ASSOCIATION_COPY)
__GETTER(NSString, interPropertiesDescription)

@end


@implementation CBPeripheral (OABLInternal)


__SETTER_PRIMITIVE(int, interRssiValue, setInterRssiValue:, numberWithInt:)
__GETTER_PRIMITIVE(int, interRssiValue, intValue)

__SETTER_WEAK_CUSTOMIZE(centralManager, setCentralManager:)
__GETTER_WEAK(OABTCentralManager, centralManager)


__SETTER(interAdertisementData, setInterAdertisementData:, OBJC_ASSOCIATION_RETAIN)
__GETTER(NSDictionary, interAdertisementData)

@end


