//
//  OABLECentralManager.h
//  OutdoorAssistantApplication
//
//  Created by 罗亮富 on 2018/11/10.
//  Copyright © 2018年 Lolaage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "NSObject+MultiDelegates.h"

typedef enum {
    OABLEStateUnavailable,
    OABLEStatePoweredOff,
    OABLEStatePoweredOn,
    OABLEStateSearching
    
}OABlePeripheralServiceState;


NS_ASSUME_NONNULL_BEGIN

@class OABTCentralManager;

//根据你个人喜好，可以选择使用block或delegate方式
@protocol OABlePeripheralManagerDelegate <NSObject>

//this delegate method will be invoked whenever power on/off or authrization status change
-(void)centralManagerDidChangeState:(OABTCentralManager *)manager;

//this delegate method will be invoked on new peripherals were discovered
-(void)centralManager:(OABTCentralManager *)manager didDiscoveredNewPeripherals:(NSArray <CBPeripheral *>*)peripherals;

//连接断开、建立连接、连接完成
//invoked whenever connection state changed.
-(void)centralManager:(OABTCentralManager *)manager didChangeStateForPeripheral:(CBPeripheral *)peripheral;

//when ever notify data received
-(void)centralManager:(OABTCentralManager *)manager didReceiveDatafromCharacteristic:(CBCharacteristic *)charateristic;

@end

/*!
 *  @class OABLECentralManager
 *
 *  @discussion Manage peripherals' connection, discovery and data communications with specialfied OABleDiscoverOption.
 */
@interface OABTCentralManager : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>


-(instancetype)init NS_UNAVAILABLE;

//create a new instance with specialfied `advertiseIDs` of periperals that a central manager will scan for, or pass nil for all kind of peripherals;
-(instancetype)initWitPeripheralAdvertiseID:(nullable NSString *)advertiseID;

@property (nonatomic, readonly)  OABlePeripheralServiceState state;


#pragma mark- auto scan/connection
@property (nonatomic) BOOL autoReconnection; //defualt YES,whether to automatically reconnect to passively disconnected peripherals 是否在被动断开后自动重连
@property (nonatomic) unsigned int autoReconnectionInterval; //default is 5 second
@property (nonatomic) unsigned int autoScanInterval; //自动搜索时间间隔,the time in second to start a auto scan since last scan finished, defautl is 5 seconds
@property (nonatomic) unsigned int scanDuration; //每一次搜索持续时间，the scan last duration each time, default is 3 seconds

@property (nonatomic, copy, readonly) NSSet <NSString *> *autoConnectPeripheralIDs; //自动连接外设UUID列表,一旦搜索到就自动连接，the identifier uuidstring of peripherals which will automatically connected on discovery.

#pragma mark- delegates/blocks

//用delegates的好处是可以多处同时监听，但代码分散
//implemented in NSObject category,
-(void)addDelegate:(id<OABlePeripheralManagerDelegate>)delegate;
-(void)removeDelegate:(id<OABlePeripheralManagerDelegate>)delegate;

//block的好处是代码集中，但同时只能有一处监听，如果要多处同时监听这些事件的话，用-addDelegate:方法添加多个delegate
//Alternatively you can implement OABlePeripheralManagerDelegate's methods by addDelegate(s)
@property (nonatomic, copy) void (^onBluetoothStateChange)(OABlePeripheralServiceState state);
@property (nonatomic, copy) void (^onNewPeripheralsDiscovered)(NSArray <CBPeripheral *> *peripherals);
@property (nonatomic, copy) void (^onPeripheralStateChange)(CBPeripheral *peripheral);
@property (nonatomic, copy) void (^onNewDataNotify)(CBCharacteristic *characteristic);

#pragma mark- scan and connection
//外设搜索
//-centralManager:didDiscoverPeripheral: delegate method will be invoked on every new peripheral discovered
-(NSString *)scanPeripherals;
-(void)stopScanPeripherals;
@property (nonatomic, copy, readonly) NSArray <CBPeripheral *>* discoveredPeripherals;

//外设连接/发现, peripheral connect/discover
@property (nonatomic, copy, readonly) NSArray <CBPeripheral *> *connectedPeripherals;//已经连接的外设

-(void)connectPeripheral:(nonnull CBPeripheral *)peripheral
              completion:(nullable void (^)(NSError *error))block;

//断开连接 没有涉及block回调，是因为还有被动断开的情况，所以集中在delegate方法中处理\
-centralManager:didChangeStateForPeripheral: delegate method will be invoked on every peripheral disconnected
-(void)disConnectperipheral:(nonnull CBPeripheral *)peripheral;

//serviceID the service uuid string, null for all services
-(void)discoverService:(nullable NSArray <NSString *> *)serviceID
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

-(void)readRSSIForPeripheral:(nonnull CBPeripheral *)peripheral
                  completion:(nullable void (^)(int rssi, NSError *error))block;


#pragma mark- data transfer

//write data for writeWithoutResponseCharacteristic
-(void)writeData:(nonnull NSData *)data forCharacteristic:(nonnull CBCharacteristic *)chara;

//write data for writeCharacteristic
-(void)writeData:(nonnull NSData *)data forCharacteristic:(nonnull CBCharacteristic *)chara  response:(void(^)(BOOL success))response;

//read data from readCharacteristic
-(void)readDataforCharacteristic:(nonnull CBCharacteristic *)chara completion:(void(^)(BOOL))completionBlock;

//set data notify block for given CBCharacteristic
-(void)setDataNotifyBlock:(void(^)(NSData *data))block forCharacteristic:(CBCharacteristic *)chara;

//enable/disable data notify for characteristic, block will be invokded on completion to indicate success or failure
-(void)enableNotify:(BOOL)enable
  forCharacteristic:(CBCharacteristic *)chara
         completion:(void(^)(BOOL success))block;


-(void)writeData:(nonnull NSData *)data
   forDescriptor:(nonnull CBDescriptor *)descriptor
        response:(void(^)(BOOL success))response;

-(void)readDataForDescriptor:(nonnull CBDescriptor *)descriptor
                  completion:(void(^)(BOOL))completionBlock;

@end




//===================================================================

NS_ASSUME_NONNULL_END

