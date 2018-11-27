//
//  CBPeripheral+OABLE.h
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/17.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "OABTPort.h"

@class OABTCentralManager;
@interface CBPeripheral (OABLE)


/**
 the max data bytes length limit for writing to characteristics and descriptors, default is 125(bytes), all data with length greater than this value will be splitted into smaller pakcetes for writing tasks.
 Note: Although a -[CBPeripheral maximumWriteValueLengthForType:] method is provided, but i found that the value returned from this method sometimes donesn't reliable. so you should check and set this value for defferent type of peripherals by veryfing your self, or according to the parameter given from the manufacturer. only data packet length no greater than the peripherals actual written length limit can be written scucessfully.
 
 向蓝牙外设写数据的最大长度限制，如果要向外设写入的数据大于这个长度的话，数据将会分成一个个小的数据包再发送，虽然-[CBPeripheral maximumWriteValueLengthForType:] 方法会返回一个值，但这个值我发现并不可靠， 程序员需要自己针对不同类型的外设，自己去调试这个参数，或者从设备制造商那里获得，数据包的大小如果超过外设的最大限制，数据将无法发送成功。
 */
@property (nonatomic) unsigned int dataWritePakcetMaxLengthLimit;

@property (nonatomic, readonly) int rssiValue;

@property (nonatomic, readonly) NSDictionary *advertisementData;

#pragma mark- discover
//======================discover services/characteristics/descriptions======================
// typically you don't need to use those discover methods in your business code,\
the -writeData:xxx -readData:xxx etc methods will automatically do the discover work for you.
//一般在读写数的情况下你不需要调用这些discoverXXX：的方法，下面的 -writeData:xxx -readData:xxx 等方法会在自动去完成这些发现服务/特征/描述的工作

/**
 Discover services in peripheral 发现外设中包含的服务

 @param serviceIDs     A list of uuid strings representing the service types to be discovered. If nil, all services with in ther periperal will be discovered
 @param completion      a call back block indicate the discover results.
 */
-(void)discoverService:(nullable NSArray <NSString *> *)serviceIDs
            completion:(nullable void (^)(NSError *error))completion;

/**
 Discover specialfied charateristics for peripheral. 发现外设的指定服务的 特征
 
 @param charaterIDs     A list of uuid strings representing the characteristic types in a service to be discovered. If nil,
 *                                all characteristics with in the service represented by serviceID will be discovered.
 @param serviceID       the service uuid string that represent a speciafied service type
 @param completion      a call back block indicate the discover results.
 */
-(void)discoverCharacteristics:(nullable NSArray <NSString *> *)charaterIDs
                     ofService:(nonnull NSString *)serviceID
                    completion:(nullable void (^)(NSError *error))completion;

/**
 Discover descriptors 发现外设中的描述信息

 @param charaterID  the characteristic type represented by the uuid string in which the descriptor(s) need to be discovered
 @param serviceID   the service uuid string that represent a speciafied service type
 @completion        block a call back block indicate the discover results.
 */
-(void)discoverDescriptorsForCharacteristic:(nonnull NSString *)charaterID
                                  ofService:(nonnull NSString *)serviceID
                                 completion:(nullable void (^)(NSError *error))completion;

//for debug purpose, to find out all the services, characteristics and descriptors for the periphral.
-(void)discoverAllServicesCharacteristicsAndDescriptorsWithCompletion:(nullable void (^)(NSError *error))completion;

#pragma mark- data write/read/notify/read rssi
//=======================================data read/write/notify=============================

/**
 write data to a OABTPort no need to response, this is only available for CBCharacteristic port (correspoding writeWithoutResponseCharacteristic)
 向一个OABTPort端口发送数据, 发送成功与否都不需要响应，对应writeWithoutResponseCharacteristic类型,只针对代表CBCharacteristic类型的端口有效
 
 Note: If data provided exceeds the max write length limit (defined by property dataWritePakcetMaxLengthLimit), it will be splited into small packets whose length will meet the max write length limit for writting, then all packtes will be written in sequence.
 
 注意：如果传的数据超过了写入外设数据的最大长度（dataWritePakcetMaxLengthLimit的设定值），这些数据将会自动拆分成一个个不超过这个长度限制的小数据包，然后再按照顺序依次向外设写入，直到所有的小的数据包都写入完成。
 
 */
-(void)writeData:(nonnull NSData *)data toPort:(OABTPort *)port;


/**
 write data to a OABTPort with response
 向一个OABTPort端口发送数据, 发送成功与否都在block回调得到结果
 
 Note: If data provided exceeds the max write length limit (defined by property dataWritePakcetMaxLengthLimit), it will be splited into small packets whose length will meet the max write length limit for writting, then all packtes will be written in sequence. the completion block will be invoked on all packets' writting are finished, or on an error with any packet's writting.
 
 注意：如果传的数据超过了写入外设数据的最大长度（dataWritePakcetMaxLengthLimit的设定值），这些数据将会自动拆分成一个个不超过这个长度限制的小数据包，然后再按照顺序依次向外设写入，直到所有的小的数据包都写入完成后，或者中途某个小数据包写入出），completion block才会回调。
 */
-(void)writeData:(nonnull NSData *)data
          toPort:(OABTPort *)port
        completion:(nullable void(^)(NSError *error))completion;


/**
 Read data from a OABTPort,
 读取端口数据
 
 @param port        see OABTPort
 @param completionBlock     the read result call back block, the returned value's type is NSData for characteristic typ port. The corresponding value types for the various descriptors are detailed in @link CBUUID.h @/link. A non null error will be returned on failure. 读取结果回调，如果port代表的是一个CBCharacteristic,辣么value的类型是NSData，如果port代表的是CBDescriptor，辣么value的值是什么请参考@link CBUUID.h @/link.
 */
-(void)readDataFromPort:(OABTPort *)port completion:(nullable void(^)(id value, NSError *error))completionBlock;


/**
 Set the data notify block on port, this is only available for CBCharacteristic type port
 设置外设端口消息通知block，当外设指定端口有主动向主机发送数据的时候，设定的block会得到回调，只对代表CBCharacteristic类型的端口有效
 */
-(void)setOnDataNotifyBlock:(void(^)(NSData *data))block forPort:(OABTPort *)port;


/**
 Enable/disable data notify for a CBCharacteristic port (not available for CBDescription port)
 开启/关闭端口监听功能，只针对CBCharacteristic类型端口有效
 */
-(void)enableNotify:(BOOL)enable forPort:(OABTPort *)port completion:(void(^)(NSError *))completion;


-(void)readRssiWithCompletion:(nullable void (^)(int rssi, NSError *error))completion;

#pragma mark- retrieve
//==============================retrive=====================================================

-(nullable CBDescriptor *)discoveredDescriptorWithUUID:(nonnull NSString *)descriptorUUIDString
                                characteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                             ofService:(nonnull NSString *)serviceUUIDString;

-(nullable CBCharacteristic *)discoveredCharacteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                                     ofService:(nonnull NSString *)serviceUUIDString;

-(nullable CBService *)discoveredServiceWithUUID:(nonnull NSString *)serviceUUIDString;

@end

@interface CBCharacteristic (OABLE)

@property (nonatomic, copy, readonly) NSString *propertiesDescription;

@end


