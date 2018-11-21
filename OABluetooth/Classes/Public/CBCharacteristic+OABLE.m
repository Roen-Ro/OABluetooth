//
//  CBCharacteristic+OABLE.m
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/20.
//

#import "CBCharacteristic+OABLE.h"
#import "OABLPeripheralInterExtension.h"

@implementation CBCharacteristic (OABLE)

-(NSString *)propertiesDescription
{
    return self.interPropertiesDescription;
}

@end
