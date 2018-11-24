//
//  OABTPort.h
//  OABluetooth
//
//  Created by 罗亮富 on 2018/11/23.
//

#import <Foundation/Foundation.h>



/**
 a OABTPort instance is the a cmmuniatalbe resource on peripheral that can transfer data with the central manager, it represents either a kind of CBCharacteristic or a kind of CBDescription.
 OABTPort代表了一个可通讯的端口(其实就是CBCharacteristic 或者 CBDescription)，通讯的时候预先把端口按照服务id、特征id、和描述id(可选)定义好，然后就可以向这个端口发送或接收数据了
 */
@interface OABTPort : NSObject


/**
  Create a OABTPort with a peripheral's serviceID,charateristicID,and descriptionID(optional), when a nil value is passed to descriptionID, the port represents some kind of CBCharacteristic; when a non null value is passed to descriptionID, the port represents some kind of CBDescription.
 通过BLE蓝牙的服务id，特征id和描述id（描述id可选）创建一个BLE服务端口，当descriptionID为nil的时候，代表的是一个CBCharacteristic端口信息，当descriptionID不为nil的时候，代表的是一个CBDescription端口信息
 */
+(nonnull instancetype)portWithServiceID:(nonnull NSString *)serviceID
                characteristicID:(nonnull NSString *)charateristicID
                   descriptionID:(nullable NSString *)descriptionID;


/**
Create a port represents CBCharacteristic infomation
 创建并返回一个代表CBCharacteristic信息的端口
 */
+(nonnull instancetype)portWithServiceID:(nonnull NSString *)serviceID
                characteristicID:(nonnull NSString *)charateristicID;


@property (nonnull, nonatomic, readonly) NSString *serviceID;
@property (nonnull, nonatomic, readonly) NSString *charateristicID;
@property (nullable, nonatomic, readonly) NSString *descriptorID;

@end

