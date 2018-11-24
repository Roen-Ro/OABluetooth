//
//  OABTCentralManager+DiscoverAndDataTransfer.h
//  OABluetooth
//
//  Created by 罗亮富 on 2018/11/24.
//

#import "OABTCentralManager.h"

@interface OABTCentralManager ()


-(void)discoverService:(nullable NSArray <NSString *> *)serviceIDs
         forPeripheral:(nonnull CBPeripheral *)peripheral
            completion:(nullable void (^)(NSError *error))block;

-(void)discoverCharacteristics:(nullable NSArray <NSString *> *)charaterIDs
                     ofService:(nonnull NSString *)serviceID
                 forPeripheral:(nonnull CBPeripheral *)peripheral
                    completion:(nullable void (^)(NSError *error))block;

-(void)discoverDescriptorsForCharacteristic:(nonnull NSString *)charaterID
                                  ofService:(nonnull NSString *)serviceID
                              forPeripheral:(nonnull CBPeripheral *)peripheral
                                 completion:(nullable void (^)(NSError *error))block;


#pragma mark- read/ write

-(void)readRSSIForPeripheral:(nonnull CBPeripheral *)peripheral
                  completion:(nullable void (^)(int rssi, NSError *error))block;

//write data for writeWithoutResponseCharacteristic
-(void)writeData:(nonnull NSData *)data forCharacteristic:(nonnull CBCharacteristic *)chara;

//write data for writeCharacteristic
-(void)writeData:(nonnull NSData *)data forCharacteristic:(nonnull CBCharacteristic *)chara  response:(void(^)(NSError *error))response;

//read data from readCharacteristic
-(void)readDataforCharacteristic:(nonnull CBCharacteristic *)chara completion:(void(^)(NSError *))completionBlock;

//set data notify block for given CBCharacteristic
-(void)setDataNotifyBlock:(void(^)(NSData *data))block forCharacteristic:(CBCharacteristic *)chara;

//enable/disable data notify for characteristic, block will be invokded on completion to indicate success or failure
-(void)enableNotify:(BOOL)enable
  forCharacteristic:(CBCharacteristic *)chara
         completion:(void(^)(NSError *))block;


-(void)writeData:(nonnull NSData *)data
   forDescriptor:(nonnull CBDescriptor *)descriptor
        response:(void(^)(NSError *error))response;

-(void)readDataForDescriptor:(nonnull CBDescriptor *)descriptor
                  completion:(void(^)(NSError *))completionBlock;


@end

