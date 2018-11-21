//
//  CBPeripheral+OABLE.m
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/17.
//

#import "CBPeripheral+OABLE.h"
#import "OABleCentralManager.h"
#import "OABLPeripheralInterExtension.h"
#import <ObjcExtensionProperty/ObjcExtensionProperty.h>


@implementation CBPeripheral (OABLE)


__SETTER_PRIMITIVE(unsigned int, dataWritePakcetMaxLengthLimit,setDataWritePakcetMaxLengthLimit,numberWithInt:)
__GETTER_PRIMITIVE_DEFAULT(unsigned int,dataWritePakcetMaxLengthLimit,125,intValue)

-(int)rssiValue
{
    return self.interRssiValue;
}




-(nullable CBDescriptor *)discoveredDescriptorWithUUID:(nonnull NSString *)descriptorUUIDString
                                characteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                             ofService:(nonnull NSString *)serviceUUIDString
{
    CBDescriptor *retDesc = nil;
    CBCharacteristic *charc = [self discoveredCharacteristicWithUUID:characteristicUUIDString ofService:serviceUUIDString];
    if(charc)
    {
        for(CBDescriptor *desc in charc.descriptors)
        {
            if([desc.UUID.UUIDString isEqualToString:descriptorUUIDString])
            {
                retDesc = desc;
                break;
            }
        }
    }
    
    return retDesc;
}

-(nullable CBCharacteristic *)discoveredCharacteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                                     ofService:(nonnull NSString *)serviceUUIDString
{
    CBCharacteristic *chara = nil;
    CBService *service = [self discoveredServiceWithUUID:serviceUUIDString];
    if(service)
    {
        if([service.UUID.UUIDString isEqualToString:serviceUUIDString])
        {
            for (CBCharacteristic *chra in service.characteristics)
            {
                if([chra.UUID.UUIDString isEqualToString:characteristicUUIDString])
                {
                    chara = chra;
                    break;
                }
            }
        }
    }
    
    return chara;
}

-(nullable CBService *)discoveredServiceWithUUID:(NSString *)serviceUUID
{
    CBService *tService = nil;
    for(CBService *s in self.services)
    {
        if([s.UUID.UUIDString isEqualToString:serviceUUID])
        {
            tService = s;
            break;
        }
    }
    return tService;
}




@end
