//
//  CBPeripheral+OABLE.m
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/17.
//

#import "CBPeripheral+OABLE.h"
#import "OABTCentralManager.h"
#import "OABLPeripheralInterExtension.h"
#import "OABTCentralManager+Private.h"
#import <ObjcExtensionProperty/ObjcExtensionProperty.h>

#define NO_OABTCENTRAL_ERROR [NSError errorWithDomain:NSLocalizedString(@"The peripheral is not discovered from a OABTCentralManager instance", nil) code:-110 userInfo:nil]

#define ERROR_BLOCK_INVOKE_AND_RETURN(error)     if(!self.centralManager && completion)  { \
                                                        completion(error); \
                                                        return; \
                                                    }

@implementation CBPeripheral (OABLE)


__SETTER_PRIMITIVE(unsigned int, dataWritePakcetMaxLengthLimit,setDataWritePakcetMaxLengthLimit:,numberWithInt:)
__GETTER_PRIMITIVE_DEFAULT(unsigned int,dataWritePakcetMaxLengthLimit,125,intValue)

-(int)rssiValue
{
    return self.interRssiValue;
}
#pragma mark- discover
-(void)discoverService:(nullable NSArray <NSString *> *)serviceIDs
            completion:(nullable void (^)(NSError *error))completion {
    
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_OABTCENTRAL_ERROR);
    [self.centralManager discoverService:serviceIDs forPeripheral:self completion:completion];
}


-(void)discoverCharacteristics:(nullable NSArray <NSString *> *)charaterIDs
                     ofService:(nonnull NSString *)serviceID
                    completion:(nullable void (^)(NSError *error))completion {
    
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_OABTCENTRAL_ERROR);
    [self.centralManager discoverCharacteristics:charaterIDs ofService:serviceID forPeripheral:self completion:completion];
}


-(void)discoverDescriptorsForCharacteristic:(nonnull NSString *)charaterID
                                  ofService:(nonnull NSString *)serviceID
                                 completion:(nullable void (^)(NSError *error))completion {
    
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_OABTCENTRAL_ERROR);
    [self.centralManager discoverDescriptorsForCharacteristic:charaterID ofService:serviceID forPeripheral:self completion:completion];
    
}

-(void)discoverAllServicesCharacteristicsAndDescriptorsWithCompletion:(nullable void (^)(NSError *error))completion {

    ERROR_BLOCK_INVOKE_AND_RETURN(NO_OABTCENTRAL_ERROR);
    WEAK_SELF;
    [self.centralManager discoverService:nil forPeripheral:self completion:^(NSError *error) {
        if(error && completion) {
            completion(error);
        }
        else {
            for(CBService *s in weakSelf.services) {
                [weakSelf.centralManager discoverCharacteristics:nil ofService:s.UUID.UUIDString forPeripheral:weakSelf completion:^(NSError *error) {
                    if(error) {
                        if(completion)
                            completion(error);
                    }
                    else {
                        for(CBCharacteristic *chra in s.characteristics) {
                            [weakSelf.centralManager discoverDescriptorsForCharacteristic:chra.UUID.UUIDString ofService:s.UUID.UUIDString forPeripheral:self completion:^(NSError *error) {

                                if(error && completion) {
                                    completion(error);
                                }
                                else {

                                    BOOL allDiscoverFinished = YES;
                                    for(CBService *tSv in weakSelf.services)
                                    {
                                        if(!tSv.finishedSubArributeDiscover) {
                                            allDiscoverFinished = NO;
                                            break;
                                        }
                                        for(CBCharacteristic *tChara in tSv.characteristics)
                                        {
                                            if(!tChara.finishedSubArributeDiscover) {
                                                allDiscoverFinished = NO;
                                                break;
                                            }
                                        }
                                    }

                                    if(allDiscoverFinished)
                                        if(completion)
                                            completion(nil);

                                }
                            }];
                        }
                    }
                }];
            }
        }
    }];

}

#pragma mark- inter OABTPort map

-(void)inter_findCharacteristicForPort:(OABTPort *)port completion:(void (^)(NSError *error, CBCharacteristic *charateristic))completion {
    
    WEAK_SELF;
    CBCharacteristic *c = [self discoveredCharacteristicWithUUID:port.charateristicID ofService:port.serviceID];
    if(!c) {
        [weakSelf.centralManager discoverCharacteristics:@[port.charateristicID] ofService:port.serviceID forPeripheral:self completion:^(NSError *error) {
            if(completion) {
                
                if(error) {
                    completion(error,nil);
                }
                else {
                    CBCharacteristic *c1 = [self discoveredCharacteristicWithUUID:port.charateristicID ofService:port.serviceID];
                    if(c1) {
                        completion(nil,c1);
                    }
                    else {
                        NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"The characteris with uuid %@ in service %@ not found ", nil),port.charateristicID,port.serviceID];
                        NSError *er = [NSError errorWithDomain:errMsg code:-112 userInfo:nil];
                        completion(er,nil);
                    }
                }
            }
        }];
    } else if(completion)  {
        completion(nil,c);
    }
}

-(void)inter_findDescriptorForPort:(OABTPort *)port completion:(void (^)(NSError *error, CBDescriptor *descriptor))completion {
    
    CBDescriptor *desc = [self discoveredDescriptorWithUUID:port.descriptorID characteristicWithUUID:port.charateristicID ofService:port.serviceID];
    if(desc) {
        [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
            if(completion) {
                if(error) {
                    completion(error,nil);
                } else {
                    CBDescriptor *desc1 = [self discoveredDescriptorWithUUID:port.descriptorID characteristicWithUUID:port.charateristicID ofService:port.serviceID];
                    if(desc1) {
                        completion(nil,desc1);
                    } else {
                        NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"The descriptor with uuid %@ in characteris %@ of service %@ not found ", nil),port.descriptorID,port.charateristicID,port.serviceID];
                        NSError *er = [NSError errorWithDomain:errMsg code:-113 userInfo:nil];
                        completion(er,nil);
                    }
                }
            }
        }];
    } else if(completion) {
        completion(nil,desc);
    }
}

#pragma mark- data transfer

-(void)writeData:(nonnull NSData *)data toPort:(OABTPort *)port
{
    WEAK_SELF;
    [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
        if(charateristic)
            [weakSelf.centralManager writeData:data forCharacteristic:charateristic];
    }];
}


/**
 write data to a OABTPort with response
 向一个OABTPort端口发送数据, 发送成功与否都在block回调得到结果
 */
-(void)writeData:(nonnull NSData *)data
          toPort:(OABTPort *)port
        completion:(nullable void(^)(NSError *error))completion
{
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_OABTCENTRAL_ERROR);
    
    WEAK_SELF;
    if(port.descriptorID) {
        [self inter_findDescriptorForPort:port completion:^(NSError *error, CBDescriptor *descriptor) {
            if(descriptor) {
                [weakSelf.centralManager writeData:data forDescriptor:descriptor response:completion];
            }
            else if(completion)
                completion(error);
        }];
    }
    else {
        [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
            if(charateristic)
                [weakSelf.centralManager writeData:data forCharacteristic:charateristic response:completion];
            else if(completion)
                completion(error);
        }];
    }
}


-(void)readDataFromPort:(OABTPort *)port completion:(nullable void(^)(id value, NSError *error))completion
{
    if(!self.centralManager && completion)
        completion(nil,NO_OABTCENTRAL_ERROR);
        
    WEAK_SELF;
    if(port.descriptorID) {
        [self inter_findDescriptorForPort:port completion:^(NSError *error, CBDescriptor *descriptor) {
            
            if(descriptor) {
                [weakSelf.centralManager readDataForDescriptor:descriptor completion:^(NSError *err) {
                    if(completion) {
                        completion(descriptor.value,err);
                    }
                }];
            }
            else if(completion)
                completion(nil,error);
            
        }];
        
    } else {
        [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
            if(charateristic) {
                [weakSelf.centralManager readDataforCharacteristic:charateristic completion:^(NSError *err) {
                    if(completion) {
                        completion(charateristic.value,err);
                    }
                }];
            } else if(completion)
                completion(nil,error);
        }];
    }
    
}


-(void)setOnDataNotifyBlock:(void(^)(NSData *data))block forPort:(OABTPort *)port
{
    WEAK_SELF;
    [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
        [weakSelf.centralManager setDataNotifyBlock:block forCharacteristic:charateristic];
    }];
}


-(void)enableNotify:(BOOL)enable forPort:(OABTPort *)port completion:(void(^)(NSError *))completion
{
    ERROR_BLOCK_INVOKE_AND_RETURN(NO_OABTCENTRAL_ERROR);
    
    WEAK_SELF;
    [self inter_findCharacteristicForPort:port completion:^(NSError *error, CBCharacteristic *charateristic) {
        if(completion) {
            if(charateristic)
                [weakSelf.centralManager enableNotify:enable forCharacteristic:charateristic completion:completion];
            else
                completion(error);
        }
    }];
}

#pragma mark-
-(void)readRssiWithCompletion:(nullable void (^)(int rssi, NSError *error))completion {
    
    if(completion && !self.centralManager)
        completion(0,NO_OABTCENTRAL_ERROR);
    
    [self.centralManager readRSSIForPeripheral:self completion:completion];
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
