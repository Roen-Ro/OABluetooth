//
//  CBPeripheral+OABLE.m
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/17.
//

#import "CBPeripheral+OABLE.h"
#import "OABTCentralManager.h"
#import "OABLPeripheralInterExtension.h"
#import <ObjcExtensionProperty/ObjcExtensionProperty.h>


@implementation CBPeripheral (OABLE)


__SETTER_PRIMITIVE(unsigned int, dataWritePakcetMaxLengthLimit,setDataWritePakcetMaxLengthLimit:,numberWithInt:)
__GETTER_PRIMITIVE_DEFAULT(unsigned int,dataWritePakcetMaxLengthLimit,125,intValue)

-(int)rssiValue
{
    return self.interRssiValue;
}

#pragma mark- data transfer
/**
 write data to a OABTPort no need to response, this is only available for CBCharacteristic port (correspoding writeWithoutResponseCharacteristic)
 向一个OABTPort端口发送数据, 发送成功与否都不需要响应，对应writeWithoutResponseCharacteristic类型,只针对代表CBCharacteristic类型的端口有效
 */
-(void)writeData:(nonnull NSData *)data toPort:(OABTPort *)port
{
    
}


/**
 write data to a OABTPort with response
 向一个OABTPort端口发送数据, 发送成功与否都在block回调得到结果
 */
-(void)writeData:(nonnull NSData *)data
          toPort:(OABTPort *)port
        response:(nullable void(^)(NSError *error))response
{
    
}


/**
 Read data from a OABTPort
 读取端口数据
 */
-(void)readDataFromPort:(OABTPort *)pot completion:(nullable void(^)(NSData *data, NSError *error))completionBlock
{
    
}


/**
 Set the data notify block on port, this is only available for CBCharacteristic port
 设置外设端口消息通知block，当外设指定端口有主动向主机发送数据的时候，设定的block会得到回调，只对代表CBCharacteristic类型的端口有效
 */
-(void)setOnDataNotifyBlock:(void(^)(NSData *data))block forPort:(OABTPort *)pot
{
    
}


/**
 Enable/disable data notify for a CBCharacteristic port (not available for CBDescription port)
 开启/关闭端口监听功能，只针对CBCharacteristic类型端口有效
 */
-(void)enableNotify:(BOOL)enable forPort:(OABTPort *)pot completion:(void(^)(BOOL success))block
{
    
}

#pragma mark-

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


@implementation CBCharacteristic (OABLE)

-(NSString *)propertiesDescription
{
    return self.interPropertiesDescription;
}

@end
