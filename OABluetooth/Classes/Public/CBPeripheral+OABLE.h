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


//==========================================================================================
/**
 write data to a OABTPort no need to response, this is only available for CBCharacteristic port (correspoding writeWithoutResponseCharacteristic)
 向一个OABTPort端口发送数据, 发送成功与否都不需要响应，对应writeWithoutResponseCharacteristic类型,只针对代表CBCharacteristic类型的端口有效
 */
-(void)writeData:(nonnull NSData *)data toPort:(OABTPort *)port;


/**
 write data to a OABTPort with response
 向一个OABTPort端口发送数据, 发送成功与否都在block回调得到结果
 */
-(void)writeData:(nonnull NSData *)data
          toPort:(OABTPort *)port
        response:(nullable void(^)(NSError *error))response;


/**
 Read data from a OABTPort
 读取端口数据
 */
-(void)readDataFromPort:(OABTPort *)pot completion:(nullable void(^)(NSData *data, NSError *error))completionBlock;


/**
 Set the data notify block on port, this is only available for CBCharacteristic port
 设置外设端口消息通知block，当外设指定端口有主动向主机发送数据的时候，设定的block会得到回调，只对代表CBCharacteristic类型的端口有效
 */
-(void)setOnDataNotifyBlock:(void(^)(NSData *data))block forPort:(OABTPort *)pot;


/**
 Enable/disable data notify for a CBCharacteristic port (not available for CBDescription port)
 开启/关闭端口监听功能，只针对CBCharacteristic类型端口有效
 */
-(void)enableNotify:(BOOL)enable forPort:(OABTPort *)pot completion:(void(^)(BOOL success))block;



//==========================================================================================

-(nullable CBDescriptor *)discoveredDescriptorWithUUID:(nonnull NSString *)descriptorUUIDString
                                characteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                             ofService:(nonnull NSString *)serviceUUIDString;

-(nullable CBCharacteristic *)discoveredCharacteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                                     ofService:(nonnull NSString *)serviceUUIDString;

-(nullable CBService *)discoveredServiceWithUUID:(nonnull NSString *)serviceUUIDString;

@end

@interface CBCharacteristic (OABLE)

@property (nonatomic, copy) NSString *propertiesDescription;

@end


