//
//  CBPeripheral+OABLE.h
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/17.
//

#import <CoreBluetooth/CoreBluetooth.h>


@class OABleCentralManager;
@interface CBPeripheral (OABLE)

//the max data bytes length limit for writing to characteristics and descriptors, default is 125(bytes), all data with length greater than this value will be splitted into smaller pakcetes for writing tasks.\
Note: Although a -[CBPeripheral maximumWriteValueLengthForType:] method is provided, but i found that the value returned from this method sometimes donesn't reliable. so you should check and set this value for defferent type of peripherals by veryfing your self, or according to the parameter given from the manufacturer. only data packet length no greater than the peripherals actual written length limit can be written scucessfully.
//向蓝牙外设写数据的最大长度限制，如果要向外设写入的数据大于这个长度的话，数据将会分成一个个小的数据包再发送，虽然-[CBPeripheral maximumWriteValueLengthForType:] 方法会返回一个值，但这个值我发现并不可靠， 程序员需要自己针对不同类型的外设，自己去调试这个参数，或者从设备制造商那里获得，数据包的大小如果超过外设的最大限制，数据将无法发送成功。
@property (nonatomic) unsigned int dataWritePakcetMaxLengthLimit;

@property (nonatomic, readonly) int rssiValue;

//write data with writeWithoutResponseCharacteristic type,
//charaID and serviceID are uuid strings represent corresponding charateristic and service
-(void)writeData:(nonnull NSData *)data
forCharacterisct:(nonnull NSString *)charaID
       ofService:(nonnull NSString *)serviceID;

//write data with CBCharacteristicWriteWithResponse type,
//charaID and serviceID are uuid strings represent corresponding charateristic and service
-(void)writeData:(nonnull NSData *)data
forCharacterisct:(nonnull NSString *)charaID
       ofService:(nonnull NSString *)serviceID
        response:(nullable void(^)(BOOL success))response;

//read data from characteristic,
//charaID and serviceID are uuid strings represent corresponding charateristic and service
-(void)readDataForCharacterisct:(nonnull NSString *)charaID
                      ofService:(nonnull NSString *)serviceID
                     completion:(nullable void(^)(CBCharacteristic *charateristic, BOOL success))completionBlock;

//set data notify block for sepcialfied characteristic,
//charaID and serviceID are uuid strings represent corresponding charateristic and service
-(void)setDataNotifyBlock:(void(^)(NSData *data))block
         forCharacterisct:(nonnull NSString *)charaID
                ofService:(nonnull NSString *)serviceID;

//enable/disable data notify for characteristic
////charaID and serviceID are uuid strings represent corresponding charateristic and service
-(void)enableNotify:(BOOL)enable
   forCharacterisct:(nonnull NSString *)charaID
          ofService:(nonnull NSString *)serviceID
         completion:(void(^)(BOOL success))block;



-(nullable CBDescriptor *)discoveredDescriptorWithUUID:(nonnull NSString *)descriptorUUIDString
                                characteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                             ofService:(nonnull NSString *)serviceUUIDString;

-(nullable CBCharacteristic *)discoveredCharacteristicWithUUID:(nonnull NSString *)characteristicUUIDString
                                                     ofService:(nonnull NSString *)serviceUUIDString;

-(nullable CBService *)discoveredServiceWithUUID:(nonnull NSString *)serviceUUIDString;

@end


