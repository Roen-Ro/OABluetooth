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


#define WEAK_SELF __weak typeof(self) weakSelf = self

typedef enum {
    OABTCentralStateUnknow = 0,
    OABTCentralStateResetting,
    OABTCentralStateUnsupported,
    OABTCentralStateUnauthorized,
    OABTCentralStatePoweredOff,
    OABTCentralStatePoweredOn,
    OABLECentralStateScanning
    
}OABTCentralState;


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


/**
 designated initializer
 @param advertiseID 需要扫描的外设广播id,只有带此广播id的外设才会被扫描到，如果传入nil的话，表示扫描所有类型的外设
 */
-(instancetype)initWitPeripheralAdvertiseID:(nullable NSString *)advertiseID;

@property (nonatomic, readonly)  OABTCentralState state;


#pragma mark- auto connection 自动重连

 //defualt YES,whether to automatically reconnect to passively disconnected peripherals 是否在被动断开后自动重连
@property (nonatomic, getter = isAutoReconnectionEnabled) BOOL enableAutoReconnection;
@property (nonatomic) unsigned int autoReconnectionInterval; //default is 5 second

-(void)addPeripheralToAutoReconnection:(nonnull CBPeripheral *)peripheral;
-(void)removeperipheralFromAutoReconnection:(nonnull CBPeripheral *)peripheral;

#pragma mark- auto scan 自动扫描

//自动搜索时间间隔,the time in second to start a auto scan since last scan finished, defautl is 5 seconds
@property (nonatomic) unsigned int autoScanInterval;
//每一次搜索持续时间，the scan last duration each time, default is 3 seconds
@property (nonatomic) unsigned int scanDuration;

#pragma mark- delegates/blocks

//用delegates的好处是可以多处同时监听，但代码分散
//implemented in NSObject category,
// 添加delegate
-(void)addDelegate:(id<OABlePeripheralManagerDelegate>)delegate;
//移除deletate
-(void)removeDelegate:(id<OABlePeripheralManagerDelegate>)delegate;

//block的好处是代码集中，但同时只能有一处监听，如果要多处同时监听这些事件的话，用-addDelegate:方法添加多个delegate
//Alternatively you can implement OABlePeripheralManagerDelegate's methods by -addDelegate:
@property (nonatomic, copy) void (^onBluetoothStateChange)(OABTCentralState state);
@property (nonatomic, copy) void (^onNewPeripheralsDiscovered)(NSArray <CBPeripheral *> *peripherals);
@property (nonatomic, copy) void (^onPeripheralStateChange)(CBPeripheral *peripheral);
@property (nonatomic, copy) void (^onNewDataNotify)(CBCharacteristic *characteristic);

#pragma mark- scan and connection
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


@end




//===================================================================

NS_ASSUME_NONNULL_END

