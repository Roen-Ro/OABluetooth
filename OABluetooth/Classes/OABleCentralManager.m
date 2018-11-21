//
//  OABleCentralManager.m
//  OutdoorAssistantApplication
//
//  Created by 罗亮富 on 2018/11/10.
//  Copyright © 2018年 Lolaage. All rights reserved.
//

#import <objc/runtime.h>
#import "OABleCentralManager.h"
#import "OABleDataWriteTask.h"
#import "OABLDiscoverTask.h"
#import "NSMutableDictionary+Appending.h"
#import "OABLPeripheralInterExtension.h"
#import "CBPeripheral+OABLE.h"

#define PERIPHERAL_DISCONNECTED_ERROR [NSError errorWithDomain:@"peripheral not connected" code:-102 userInfo:nil]
#define WEAK_SELF __weak typeof(self) weakSelf = self

#define  DEFAULT_WRITE_LEN 125

#pragma mark- OABlePeripheralManager

@implementation OABleCentralManager
{
@private
    CBCentralManager *_centralManager;
    
    NSMutableArray *_discoveredPeripherals;
    NSMutableArray *_connectedPeripherals;//more than connected, also discovered services and characteristics
    
    NSMapTable *_streamMap;
    
    NSInteger _scanCountDown;
    NSInteger _scanIntervalCountDown;
    NSInteger _autoReconnectionCountDown;
    
    NSTimer *_countTimer;
    
    NSString *_pehAdvertiseID;
}

@synthesize state = _state;


#pragma mark- initial

-(instancetype)initWitPeripheralAdvertiseID:(nullable NSString *)advertiseID
{
    self = [super init];
    if(self)
    {
        _pehAdvertiseID = [advertiseID copy];
        
        self.autoReconnection = YES;
        self.autoScanInterval = 5;
        self.scanDuration = 3;
        self.autoReconnectionInterval = 5;
        _discoveredPeripherals = [NSMutableArray arrayWithCapacity:5];
        _connectedPeripherals = [NSMutableArray arrayWithCapacity:5];   
        
        _streamMap = [NSMapTable weakToWeakObjectsMapTable];
        
        NSString *k = _pehAdvertiseID;
        if(!k)
            k = @"AllPeripherals";
            
        if(!_centralManager)
        {
            NSDictionary *options = @{
                                        CBCentralManagerOptionRestoreIdentifierKey : k,
                                        CBCentralManagerOptionShowPowerAlertKey    : NSLocalizedString(@"Bluetooth is powered off", nil)
                                       
                                       };
            _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil
                                                                 options:options];
            
            [self mapState];
        }
        
        [self inter_startTimer];
    }
    return self;
}

#pragma mark- lazy getters

__GETTER_LAZY(NSMutableDictionary, connectBlockMap, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, discoverServiceTaskkQueue, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, discoverCharateristicTaskkQueueMap, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, discoverDescriptorBlockQueueMap, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, writeCharcWithResponseTaskQueueMap, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, dataNotifyBlockMap, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, charcDataReadBlockMap, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, notifySettingBlockMap, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, descriptorReadBlockMapQueue, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, descriptorWriteBlockMapQueue, [NSMutableDictionary dictionaryWithCapacity:3])

__GETTER_LAZY(NSMutableDictionary, characteristicDataWriteKeyRecords, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, characteristicDataReadKeyRecords, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, characteristicDiscoverKeyRecords, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, descriptorsDiscoverKeyRecords, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, descriptorsReadKeyRecords, [NSMutableDictionary dictionaryWithCapacity:3])
__GETTER_LAZY(NSMutableDictionary, descriptorsWriteKeyRecords, [NSMutableDictionary dictionaryWithCapacity:3])

-(void)mapState
{
#if DEBUG
    NSLog(@"_centralManager.state %ld",(long)_centralManager.state);
#endif
    switch (_centralManager.state) {
        case CBManagerStateUnknown:
        case CBManagerStateResetting:
        case CBManagerStateUnsupported:
        case CBManagerStateUnauthorized:
           _state = OABLEStateUnavailable;
            break;
        case CBManagerStatePoweredOff:
            _state = OABLEStatePoweredOff;
            break;
        case CBManagerStatePoweredOn:
            _state = OABLEStatePoweredOn;
            break;
        default:
             _state = OABLEStateUnavailable;
            break;
    }
}



#pragma mark- timer
-(void)inter_startTimer
{
    if(!_countTimer)
    {
        _countTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(secTimerBeat) userInfo:nil repeats:YES];
        NSRunLoop *mainloop = [NSRunLoop mainRunLoop];
        [mainloop addTimer:_countTimer forMode:NSRunLoopCommonModes];
    }
}

-(void)inter_stopTimer
{
    [_countTimer invalidate];
    _countTimer = nil;
}

-(void)secTimerBeat
{
  //  NSLog(@"_scanCountDown:%ld _scanIntervalCountDown:%ld",(long)_scanCountDown,(long)_scanIntervalCountDown);
    if(_scanCountDown <= 0)
    {
        _scanCountDown = NSIntegerMax;
        [self stopScanPeripherals];
    }
    else
        _scanCountDown--;
    
    if(_scanIntervalCountDown <= 0)
    {
        _scanIntervalCountDown = NSIntegerMax;
        [self scanPeripherals];
    }
    else
        _scanIntervalCountDown--;
    
    if(_autoReconnectionCountDown <= 0)
    {
        _autoReconnectionCountDown = self.autoReconnectionInterval;
        [self inter_autoReconnection];
    }
    else
        _autoReconnectionCountDown--;
    
    CFIndex cnt =  CFGetRetainCount((__bridge CFTypeRef)(self));
  //  NSLog(@"SELF retainCount %ld",(long)cnt);
    if(cnt <= 2)
    {
        [self inter_stopTimer];
    }
}

-(void)setAutoScanInterval:(unsigned int)autoScanInterval
{
    _autoScanInterval = autoScanInterval;
    _scanIntervalCountDown = autoScanInterval;
}

-(void)setAutoReconnectionInterval:(unsigned int)autoReconnectionInterval
{
    _autoReconnectionInterval = autoReconnectionInterval;
    _autoReconnectionCountDown = autoReconnectionInterval;
}

-(void)setScanDuration:(unsigned int)scanDuration
{
    _scanDuration = scanDuration;
    _scanCountDown = scanDuration;
}

#pragma mark- auto connection list
-(NSString *)savePath
{
    static NSURL *docUrl;
    if(!docUrl)
        docUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [docUrl.path stringByAppendingFormat:@"/autoConnection-%@.arc",_pehAdvertiseID];
}

-(NSSet<NSString *> *)autoConnectPeripheralIDs {
    NSString *path = [self savePath];
    NSMutableSet *set = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if(set.count > 0)
        return [NSSet setWithSet:set];
    else
        return nil;
}

-(void)addAutoConnectedPeripheral:(CBPeripheral *)perl
{
    NSString *path = [self savePath];
    NSMutableSet *set = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if(!set)
        set = [NSMutableSet setWithCapacity:3];
    
    [set addObject:perl.identifier.UUIDString];
    
    [NSKeyedArchiver archiveRootObject:set toFile:path];
}

-(void)removeAutoConnectedPeripheral:(CBPeripheral *)perl
{
    NSString *path = [self savePath];
    NSMutableSet *set = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if(set)
    {
        [set removeObject:perl.identifier.UUIDString];
        [NSKeyedArchiver archiveRootObject:set toFile:path];
    }
}

#pragma mark- scan
-(NSString *)scanPeripherals
{
    _scanCountDown = self.scanDuration;
    
    NSString *errorStr = nil;
    if(_state == OABLEStateUnavailable)
        errorStr = NSLocalizedString(@"Bluetooth service unavailable", nil);
    else if(_state == OABLEStatePoweredOff)
        errorStr = NSLocalizedString(@"Bluetooth service is powered off", nil);
        
    if(errorStr)
        return errorStr;

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    //  CBCentralManagerScanOptionSolicitedServiceUUIDsKey

    NSArray *services = nil;
    if(_pehAdvertiseID)
        services = @[[CBUUID UUIDWithString:_pehAdvertiseID]];
    
    _state = OABLEStateSearching;
    //services 包含的uuid值是设备advertise的ID 可以通过查看 centralManager:didDiscoverPeripheral:advertisementData:RSSI:
    //回调中的 advertisementData 然后读取其中的key值: kCBAdvDataServiceUUIDs
    [_centralManager scanForPeripheralsWithServices:services options:options];
    
    [self inter_invokeStateChangeBlock];
    
    return nil;
    
}

-(void)stopScanPeripherals
{
    _scanIntervalCountDown = self.autoScanInterval;
    
    [_centralManager stopScan];
    
    if(_state == OABLEStateSearching)
        _state = OABLEStatePoweredOn;
    
    [self inter_invokeStateChangeBlock];
}

-(NSArray <CBPeripheral *> *)discoveredPeripherals
{
    if(_discoveredPeripherals.count > 0)
        return [NSArray arrayWithArray:_discoveredPeripherals];
    else
        return nil;
}

-(void)inter_invokeStateChangeBlock
{
    WEAK_SELF;
    [self emunateDelegatesWithBlock:^(id delegate, BOOL *stop) {
        if([delegate respondsToSelector:@selector(centralManagerDidChangeState:)])
            [delegate centralManagerDidChangeState:weakSelf];
    }];
    
    if(self.onBluetoothStateChange)
        self.onBluetoothStateChange(self.state);
}

-(void)inter_invokePeripheralsDiscoveredDelegate:(NSArray <CBPeripheral *> *)peripherals
{
    WEAK_SELF;
    [self emunateDelegatesWithBlock:^(id<OABlePeripheralManagerDelegate> delegate, BOOL *stop) {
        if([delegate respondsToSelector:@selector(centralManager:didDiscoveredNewPeripherals:)])
            [delegate centralManager:weakSelf didDiscoveredNewPeripherals:peripherals];
    }];
    
    if(self.onNewPeripheralsDiscovered)
        self.onNewPeripheralsDiscovered(peripherals);
}

#pragma mark- peripheral connection/disconnection

-(NSArray <CBPeripheral *> *)connectedPeripherals
{
    if(_connectedPeripherals.count > 0)
        return [NSArray arrayWithArray:_connectedPeripherals];
    else
        return nil;
}

//for internal calls
-(void)inter_connectPeripheral:(CBPeripheral *)peripheral
{
#if DEBUG
    NSLog(@"inter_connectPeripheral :%@",peripheral.name);
#endif
    
    [_centralManager connectPeripheral:peripheral options:nil];
    [self inter_invokeConnectionStatusChangeForPeripheral:peripheral];
}

//for external calls
-(void)disConnectperipheral:(CBPeripheral *)peripheral
{
    [self removeAutoConnectedPeripheral:peripheral];
    [self inter_disConnectperipheral:peripheral];
}

//for internal calls
-(void)inter_disConnectperipheral:(CBPeripheral *)peripheral
{
#if DEBUG
    NSLog(@"inter_disConnectperipheral :%@",peripheral.name);
#endif
    
    [_centralManager cancelPeripheralConnection:peripheral];
    [self inter_invokeConnectionStatusChangeForPeripheral:peripheral];
}

-(void)inter_autoReconnection
{
    if(self.autoReconnection)
    {
        for(CBPeripheral *peripheral in self.discoveredPeripherals)
        {
            NSSet *autoConnectSet = self.autoConnectPeripheralIDs;
            if([autoConnectSet containsObject:peripheral.identifier.UUIDString])
            {
                if(peripheral.state == CBPeripheralStateDisconnected)
                    [self inter_connectPeripheral:peripheral];
            }
        }
    }
}


-(void)inter_invokeConnectionStatusChangeForPeripheral:(CBPeripheral *)peripheral
{
    if(peripheral.state == CBPeripheralStateConnected)
    {
        if(![self.connectedPeripherals containsObject:peripheral])
            [_connectedPeripherals addObject:peripheral];
    }
    else if(peripheral.state == CBPeripheralStateDisconnected)
    {
        if([self.connectedPeripherals containsObject:peripheral])
            [_connectedPeripherals removeObject:peripheral];
    }
    WEAK_SELF;
    [self emunateDelegatesWithBlock:^(id delegate, BOOL *stop) {
        if([delegate respondsToSelector:@selector(centralManager:didChangeStateForPeripheral:)])
            [delegate centralManager:weakSelf didChangeStateForPeripheral:peripheral];
    }];
    
    if(self.onPeripheralStateChange)
        self.onPeripheralStateChange(peripheral);
}


-(void)inter_invokeConnectionResultBlockForPeripheral:(CBPeripheral *)peripheral withError:(NSError *)er {
    
    NSArray *blocks = [self.connectBlockMap objectsForKey:peripheral.identifier.UUIDString];
    for(void (^blk)(NSError *e) in blocks)
    {
        blk(er);
    }
    [self.connectBlockMap removeAllObjectsForKey:peripheral.identifier.UUIDString];
    
}

-(void)connectPeripheral:(CBPeripheral *)peripheral completion:(void (^)(NSError *error))block
{
    if(peripheral.state == CBPeripheralStateConnected)
    {
        if(block)
            block(nil);
    }
    else if(peripheral.state == CBPeripheralStateDisconnecting)
    {
        if(block)
            block([NSError errorWithDomain:@"peripheral is disconnecting" code:-101 userInfo:nil]);
    }
    else
    {
        if(block)
            [self.connectBlockMap addObject:block forKey:peripheral.identifier.UUIDString];
        
     //   if(peripheral.state == CBPeripheralStateDisconnected) //no need
            [self inter_connectPeripheral:peripheral];
    }
}

#pragma mark- discover service

-(void)inter_failAllServiceDiscoverBlocks:(nonnull NSError *)error forPeripheral:(CBPeripheral *)peripheral
{
    NSString *key = peripheral.identifier.UUIDString;
    NSArray *allTasks = [self.discoverServiceTaskkQueue objectsForKey:key];
    for( OABLDiscoverTask *task in allTasks)
    {
        if(task.block)
            task.block(error);
    }
    
    [self.discoverServiceTaskkQueue removeAllObjectsForKey:key];
}

-(void)inter_invokeServiceDiscoverBlockForPeripheral:(CBPeripheral *)peripheral withError:(NSError *)error {
    
    NSString *key = peripheral.identifier.UUIDString;
    NSArray *allTasks = [self.discoverServiceTaskkQueue objectsForKey:key];
    if(allTasks.count > 0)
    {
        OABLDiscoverTask *task = allTasks.firstObject;
        if(task.block)
            task.block(error);
        
        [self.discoverServiceTaskkQueue removeObject:task forKey:key];
    }
    
    if(allTasks.count > 1)
        [self inter_discoverServiceWtihTask:[allTasks objectAtIndex:1] forPeripheral:peripheral];
}

-(void)inter_discoverServiceWtihTask:(nullable OABLDiscoverTask *)task forPeripheral:(CBPeripheral *)peripheral
{
    NSMutableArray *svs = [NSMutableArray arrayWithCapacity:task.discoverIDs.count];
    for(NSString *s in task.discoverIDs)
    {
        [svs addObject:[CBUUID UUIDWithString:s]];
    }
    
    [peripheral discoverServices:svs];
}

-(void)discoverService:(nullable NSArray <NSString *> *)serviceIDs forPeripheral:(CBPeripheral *)peripheral completion:(void (^)(NSError *error))block
{
    OABLDiscoverTask *task = [[OABLDiscoverTask alloc] init];
    task.block = block;
    task.discoverIDs = serviceIDs;
    [self.discoverServiceTaskkQueue addObject:task forKey:peripheral.identifier.UUIDString];
    
    NSArray *tasks = [self.discoverServiceTaskkQueue objectsForKey:peripheral.identifier.UUIDString];
    
    if(peripheral.state == CBPeripheralStateConnected)
    {
        if(tasks.count <= 1)
            [self inter_discoverServiceWtihTask:task forPeripheral:peripheral];
    }
    else
    {
        [self inter_failAllServiceDiscoverBlocks:PERIPHERAL_DISCONNECTED_ERROR forPeripheral:peripheral];
    }
}

#pragma mark- discover characteristics
-(void)discoverCharacteristics:(nullable NSArray <NSString *> *)charaterIDs
                     ofService:(nonnull NSString *)serviceID
                 forPeripheral:(CBPeripheral *)peripheral
                    completion:(void (^)(NSError *error))block
{
    CBService *tService = [peripheral discoveredServiceWithUUID:serviceID];
    if(tService)
    {
       NSString *k = [self inter_discoverCharacteristics:charaterIDs ofService:tService completion:block];
        [self.characteristicDiscoverKeyRecords addUniqueObject:k forKey:peripheral.identifier.UUIDString];
    }
    else
    {
        WEAK_SELF;
        [self discoverService:@[serviceID] forPeripheral:peripheral completion:^(NSError * _Nonnull error) {
            if(!error)
            {
                CBService *tService1 = [peripheral discoveredServiceWithUUID:serviceID];
                [weakSelf inter_discoverCharacteristics:charaterIDs ofService:tService1 completion:block];
            }
            else {
                if(block)
                    block(error);
            }
        }];
    }
}

//return the key in self.discoverCharateristicTaskkQueueMap
-(NSString *)inter_discoverCharacteristics:(nullable NSArray <NSString *> *)charaterIDs
                     ofService:(nonnull CBService *)service
                    completion:(void (^)( NSError *error))block
{
    //self.discoverCharateristicTaskkQueueMap
    OABLDiscoverTask *task = [[OABLDiscoverTask alloc] init];
    task.block = block;
    task.discoverIDs = charaterIDs;
    NSString *key = [self keyForServiceID:service.UUID.UUIDString ofPeripheral:service.peripheral];
    [self.discoverCharateristicTaskkQueueMap addObject:task forKey:key];
    NSArray *tasks = [self.discoverCharateristicTaskkQueueMap objectsForKey:key];
   
    if(tasks.count <= 1)
        [self inter_discoverCharacteristicTask:task ofService:service];
    
    return key;
}

-(void)inter_discoverCharacteristicTask:(OABLDiscoverTask *)task ofService:(nonnull CBService *)service
{
    NSMutableArray *charaIds = [NSMutableArray arrayWithCapacity:task.discoverIDs.count];
    for(NSString *s in task.discoverIDs)
    {
        [charaIds addObject:[CBUUID UUIDWithString:s]];
    }
    
    [service.peripheral discoverCharacteristics:charaIds forService:service];
}

-(void)inter_failAllCharacteristicsDiscoverBlocksForPeripheral:(nonnull CBPeripheral *)perpheral
{
    NSArray *taskKeys = [self.characteristicDiscoverKeyRecords objectsForKey:perpheral.identifier.UUIDString];
    for(NSString *key in taskKeys)
    {
        NSArray *tasks = [self.discoverCharateristicTaskkQueueMap objectsForKey:key];
        for(OABLDiscoverTask *task in tasks)
        {
            if(task.block)
                task.block(PERIPHERAL_DISCONNECTED_ERROR);
        }
        [self.discoverCharateristicTaskkQueueMap removeAllObjectsForKey:key];
    }
    
    [self.characteristicDiscoverKeyRecords removeAllObjectsForKey:perpheral.identifier.UUIDString];
}

#pragma mark- discover descriptor

-(void)discoverDescriptorsForCharacteristic:(nonnull NSString *)charaterID
                                  ofService:(nonnull NSString *)serviceID
                              forPeripheral:(nonnull CBPeripheral *)peripheral
                                 completion:(nullable void (^)(NSError *error))block
{
    CBCharacteristic *charc = [peripheral discoveredCharacteristicWithUUID:charaterID ofService:serviceID];
    if(charc.finishedSubArributeDiscover)
    {
        if(block)
            block(nil);
    }
    else
    {
        CBService *service = [peripheral discoveredServiceWithUUID:serviceID];
        if(service)
        {
            [self inter_discoverDescriptorsForCharacteristic:charaterID ofService:service forPeripheral:peripheral completion:block];
        }
        else
        {
            WEAK_SELF;
            [self discoverService:@[serviceID] forPeripheral:peripheral completion:^(NSError * _Nonnull error) {
                if(!error)
                {
                    CBService *sv = [peripheral discoveredServiceWithUUID:serviceID];
                    [weakSelf inter_discoverDescriptorsForCharacteristic:charaterID ofService:sv forPeripheral:peripheral completion:block];
                }
                else if(block)
                    block(error);
            }];
        }
    }
}

-(void)inter_discoverDescriptorsForCharacteristic:(nonnull NSString *)charaterID
                                  ofService:(nonnull CBService *)service
                              forPeripheral:(nonnull CBPeripheral *)peripheral
                                 completion:(nullable void (^)(NSError *error))block
{
    WEAK_SELF;
    [self inter_discoverCharacteristics:@[charaterID] ofService:service completion:^(NSError *error) {
        if(!error)
        {
            CBCharacteristic *charc = nil;
            for( CBCharacteristic *charc1 in service.characteristics)
            {
                if([charaterID isEqualToString:charc1.UUID.UUIDString])
                {
                    charc = charc1;
                    break;
                }
            }
            if(charc)
            {
                [weakSelf inter_AddBlock:block RecordForCharateristic:charc];
                [peripheral discoverDescriptorsForCharacteristic:charc];
            }
            else if(block)
                block([NSError errorWithDomain:@"Characteristic not found" code:-101 userInfo:nil]);
        }
        else if(block)
        {
            block(error);
        }
    }];
}

-(void)inter_AddBlock:(void (^)(NSError *error))blk RecordForCharateristic:(CBCharacteristic *)characteristic
{
    if(!blk)
        return;
    
    NSString *key = [self keyForCharacteristic:characteristic];
    [self.discoverDescriptorBlockQueueMap addObject:blk forKey:key];
    [self.descriptorsDiscoverKeyRecords addUniqueObject:key forKey:characteristic.service.peripheral.identifier.UUIDString];
}

-(void)inter_failAllDescriptorDiscoverBlocksForPeripheral:(CBPeripheral *)peripheral
{
    NSArray *taskKeys = [self.descriptorsDiscoverKeyRecords objectsForKey:peripheral.identifier.UUIDString];
    for(NSString *key in taskKeys)
    {
        NSArray *blocks = [self.discoverDescriptorBlockQueueMap objectsForKey:key];
        for(void (^blk)(NSError *) in blocks)
        {
            blk(PERIPHERAL_DISCONNECTED_ERROR);
        }
        [self.discoverDescriptorBlockQueueMap removeAllObjectsForKey:key];
    }
    
    [self.descriptorsDiscoverKeyRecords removeAllObjectsForKey:peripheral.identifier.UUIDString];
}

#pragma mark- read rssi

__GETTER_LAZY(NSMutableDictionary, readRssiBlockMap, [NSMutableDictionary dictionaryWithCapacity:2])

-(void)readRSSIForPeripheral:(nonnull CBPeripheral *)peripheral
                  completion:(nullable void (^)(int rssi, NSError *error))block
{
    if(peripheral.state == CBPeripheralStateConnected)
    {
        if(block)
            [self.readRssiBlockMap addObject:block forKey:peripheral.identifier.UUIDString];
        
        [peripheral readRSSI];
    }
    else if(block) {
        block(0,PERIPHERAL_DISCONNECTED_ERROR);
    }
}

-(void)inter_invokeAllRssiReadBlocksForPeripheral:(CBPeripheral *)peripheral value:(int)rssi withError:(NSError *)error
{
    NSString *k = peripheral.identifier.UUIDString;
    NSArray *blocks = [self.readRssiBlockMap objectsForKey:k];
    for(void (^blk)(int,NSError*) in blocks) {
        blk(rssi,error);
    }
    [self.readRssiBlockMap removeAllObjectsForKey:k];
}

#pragma mark- CBCentralManagerDelegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if(!peripheral.name)
        return;
    
    peripheral.interRssiValue = RSSI.intValue;
    _state = OABLEStatePoweredOn;
    peripheral.delegate = self;
    
    //情况比较复杂，有时候发现的相同的设备是同一个对象实例，有的时候是identifier相同，但是不同的对象实例
    if(![_discoveredPeripherals containsObject:peripheral])
    {
        CBPeripheral *substitutePeripheral = nil;
        for(CBPeripheral *pe in _discoveredPeripherals)
        {
            if([pe.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])
            {
                substitutePeripheral = pe;
                break;
            }
        }
        
#if DEBUG
        NSLog(@"\n\n****detected NEW device*******\nuuid:%@\n name:%@ advertisementData:%@\n********\n\n",peripheral.identifier.UUIDString,peripheral.name,advertisementData);
#endif
        
        if(substitutePeripheral)
            [_discoveredPeripherals replaceObjectAtIndex:[_discoveredPeripherals indexOfObject:substitutePeripheral] withObject:peripheral];
        else
            [_discoveredPeripherals addObject:peripheral];
    }
    
    [self inter_invokePeripheralsDiscoveredDelegate:@[peripheral]];
    
    if(self.autoReconnection) //make auto connections
    {
        NSSet *autoConnectSet = self.autoConnectPeripheralIDs;
        if([autoConnectSet containsObject:peripheral.identifier.UUIDString])
            [self inter_connectPeripheral:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)state
{
#if DEBUG
    NSLog(@"willRestoreState: %@",state);
#endif
    
    NSArray *restores = [state objectForKey:@"kCBRestoredPeripherals"];
    
    for(CBPeripheral *per in restores)
    {
        per.delegate = self;
        
        if(per.state == CBPeripheralStateConnected)
        {
            [_connectedPeripherals addObject:per];
        }
        else
        {
            if(self.autoReconnection) //make auto connections
            {
                NSSet *autoConnectSet = self.autoConnectPeripheralIDs;
                if([autoConnectSet containsObject:per.identifier.UUIDString])
                    [self inter_connectPeripheral:per];
            }
        }
      
        [_discoveredPeripherals addObject:per];
    }
    
    [self inter_invokePeripheralsDiscoveredDelegate:restores];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self mapState];
    if (@available(iOS 10.0, *)) {
        if(_centralManager.state == CBManagerStatePoweredOn)
            [self scanPeripherals];
        else
            [self stopScanPeripherals];
    } else {
        // Fallback on earlier versions
        if(_centralManager.state == CBCentralManagerStatePoweredOn)
            [self scanPeripherals];
        else
            [self stopScanPeripherals];
    }
    
    [self inter_invokeStateChangeBlock];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
#if DEBUG
    NSLog(@"%s %@ ",__PRETTY_FUNCTION__,peripheral.name);
#endif
    
    [self inter_invokeConnectionStatusChangeForPeripheral:peripheral];
    [self inter_invokeConnectionResultBlockForPeripheral:peripheral withError:nil];
    
    if(self.autoReconnection)
        [self addAutoConnectedPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
#if DEBUG
    NSLog(@"%s %@ error:%@",__PRETTY_FUNCTION__,peripheral.name,error.localizedDescription);
#endif
    
    [self inter_invokeConnectionStatusChangeForPeripheral:peripheral];
    [self inter_invokeConnectionResultBlockForPeripheral:peripheral withError:error];
    [self inter_failAllServiceDiscoverBlocks:error forPeripheral:peripheral];
    [self inter_failAllCharacteristicsDiscoverBlocksForPeripheral:peripheral];
    [self inter_failAllDescriptorDiscoverBlocksForPeripheral:peripheral];
    [self inter_failAllReadBlocksForPeripheral:peripheral];
    [self inter_failAllWriteBlocksForPeripheral:peripheral];
    [self inter_failAllDescriptorReadBlocksForPeripheral:peripheral];
    [self inter_failAllDescriptorWriteBlocksForPeripheral:peripheral];
    [self inter_invokeAllRssiReadBlocksForPeripheral:peripheral value:0 withError:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
#if DEBUG
    NSLog(@"%s %@ error:%@",__PRETTY_FUNCTION__,peripheral.name,error.localizedDescription);
#endif
    //分主动和被动断开两种情况 主动断开error为nil，被动断开errocode = 6
    if(error)
    {
      //  被动断开，失去连接的情况 将其移除
        if([_discoveredPeripherals containsObject:peripheral])
            [_discoveredPeripherals removeObject:peripheral];
        else
        {
            CBPeripheral *perToRemove = nil;
            for(CBPeripheral *per in _discoveredPeripherals)
            {
                if([peripheral.identifier.UUIDString isEqualToString:per.identifier.UUIDString])
                {
                    perToRemove = per;
                    break;
                }
            }

            [_discoveredPeripherals removeObject:perToRemove];
        }
//
    }
    
    [self inter_invokeConnectionStatusChangeForPeripheral:peripheral];
    [self inter_invokeConnectionResultBlockForPeripheral:peripheral withError:error];
    [self inter_failAllServiceDiscoverBlocks:error forPeripheral:peripheral];
    [self inter_failAllCharacteristicsDiscoverBlocksForPeripheral:peripheral];
    [self inter_failAllDescriptorDiscoverBlocksForPeripheral:peripheral];
    [self inter_failAllReadBlocksForPeripheral:peripheral];
    [self inter_failAllWriteBlocksForPeripheral:peripheral];
    [self inter_failAllDescriptorReadBlocksForPeripheral:peripheral];
    [self inter_failAllDescriptorWriteBlocksForPeripheral:peripheral];
    [self inter_invokeAllRssiReadBlocksForPeripheral:peripheral value:0 withError:error];
    
}

#pragma mark- CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
#if DEBUG
    NSLog(@"didDiscoverServices: %zu services discovered %@, erro: %@ ",peripheral.services.count,peripheral.services, error.description);
#endif
    
    [self inter_invokeServiceDiscoverBlockForPeripheral:peripheral withError:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
#if DEBUG
    NSMutableString *mStr = [NSMutableString stringWithFormat:@"\ndidDiscoverCharacteristicsForService:%@=================",service.UUID.UUIDString];
#endif
    for (CBCharacteristic *interestingCharacteristic in service.characteristics)
    {
        NSMutableString *mPString = [NSMutableString string];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyBroadcast)
            [mPString appendString:@"Broadcast|"];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyRead)
            [mPString appendString:@"Read|"];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyWriteWithoutResponse)
            [mPString appendString:@"WriteWithoutResponse|"];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyWrite)
            [mPString appendString:@"Write|"];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyNotify)
            [mPString appendString:@"Notify|"];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyIndicate)
            [mPString appendString:@"Indicate|"];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyAuthenticatedSignedWrites)
            [mPString appendString:@"AuthenticatedSignedWrites|"];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyExtendedProperties)
            [mPString appendString:@"ExtendedProperties|"];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyNotifyEncryptionRequired)
            [mPString appendString:@"NotifyEncryptionRequired|"];
        if(interestingCharacteristic.properties|CBCharacteristicPropertyIndicateEncryptionRequired)
            [mPString appendString:@"IndicateEncryptionRequired|"];
        
        interestingCharacteristic.interPropertiesDescription = [NSString stringWithString:mPString];
#if DEBUG
        [mStr appendFormat:@"\nCharacteristic:%@ \nproperties:%@\n\n",interestingCharacteristic.UUID.UUIDString,mPString];
#endif
    }
#if DEBUG
    NSLog(@"%@",mStr);
#endif

    // service 不能这么做，因为可以指定discover的特征ID
    //service.finishedSubArributeDiscover = YES;
    
    NSString *key = [self keyForServiceID:service.UUID.UUIDString ofPeripheral:service.peripheral];
    NSArray *tasks = [self.discoverCharateristicTaskkQueueMap objectsForKey:key];
    OABLDiscoverTask *task = tasks.firstObject;
    if(task)
    {
        if(task.block)
            task.block(error);
        [self.discoverCharateristicTaskkQueueMap removeObject:task forKey:key];
    }
    if(tasks.count > 1)
    {
        OABLDiscoverTask *task1 = [tasks objectAtIndex:1]; //tasks是拷贝出来的，且有一次对object的移除操作，所以这里index是1
        [self inter_discoverCharacteristicTask:task1 ofService:service];
    }
    else
    {
        [self.discoverCharateristicTaskkQueueMap removeAllObjectsForKey:key];
        [self.characteristicDiscoverKeyRecords removeObject:key forKey:service.peripheral.identifier.UUIDString];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
#if DEBUG
    NSLog(@"didDiscoverDescriptorsForCharacteristic:%@ descroptros:%@ error:%@",characteristic,characteristic.descriptors,error);
#endif
    
    characteristic.finishedSubArributeDiscover = YES;
    
    NSString *key = [self keyForCharacteristic:characteristic];
    NSArray *blocks =  [self.discoverDescriptorBlockQueueMap objectForKey:key];
    for(void (^blk)(NSError *) in blocks) {
        blk(error);
    }
    [self.discoverDescriptorBlockQueueMap removeAllObjectsForKey:key];
    [self.descriptorsDiscoverKeyRecords removeObject:key forKey:peripheral.identifier.UUIDString];
}

// This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
#if DEBUG
    NSLog(@"UPDATE VALUE-> didUpdateValueForCharacteristic:%@ isNotifying:%d error:%@",characteristic.UUID.UUIDString,characteristic.isNotifying,error);
#endif
    
    NSString *aKey = [self keyForCharacteristic:characteristic];
    if(characteristic.isNotifying) // notify value
    {
        void (^blk)(CBCharacteristic *) = [self.dataNotifyBlockMap objectForKey:aKey];
        if(blk)
            blk(characteristic);
        
        WEAK_SELF;
        [self emunateDelegatesWithBlock:^(id<OABlePeripheralManagerDelegate> delegate, BOOL *stop) {
            if([delegate respondsToSelector:@selector(centralManager:didReceiveDatafromCharacteristic:)])
                [delegate centralManager:weakSelf didReceiveDatafromCharacteristic:characteristic];
        }];
        
        if(self.onNewDataNotify)
            self.onNewDataNotify(characteristic);
    }
    else //read value
    {
        NSArray *blcks = [self.charcDataReadBlockMap objectsForKey:aKey];
        for(void (^blk)(BOOL) in blcks)
        {
            if(blk)
                blk(error==nil);
        }
        
        [self.charcDataReadBlockMap removeAllObjectsForKey:aKey];
        [self.characteristicDataReadKeyRecords removeObject:aKey forKey:characteristic.service.peripheral.identifier.UUIDString];
    }
}


//This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
#if DEBUG
    NSLog(@"writeResponse-> didWriteValueForCharacteristic error:%@",error);
#endif
    
    NSString *aKey = [self keyForCharacteristic:characteristic];
    //finish the task
    NSArray *tasks = [self.writeCharcWithResponseTaskQueueMap objectsForKey:aKey];

    if(tasks.count > 0 )
    {
        OABleDataWriteTask *task = tasks.firstObject;
        OABleDataWriteTask *continueTask = nil;

        if(task.pendingData.length == 0 )
        {
            [self inter_finisthWriteTask:task success:YES forCharacteristic:characteristic];
            if(tasks.count > 1)
                continueTask = [tasks objectAtIndex:1];
        }
        else
            continueTask = task;
        
        if(continueTask)
             [self inter_writeCharacTask:continueTask forCharacteristic:characteristic];
    }
}


// This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    NSString *key = [self keyForCharacteristic:characteristic];
    NSArray *blks = [self.notifySettingBlockMap objectsForKey:key];
    for( void(^blk)(BOOL) in blks)
    {
        blk(error == nil);
    }
    [self.notifySettingBlockMap removeAllObjectsForKey:key];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    NSString *k = [self keyForDescriptor:descriptor];

    NSArray *blocks = [self.descriptorReadBlockMapQueue objectsForKey:k];
    for(void(^blk)(BOOL) in blocks)
        blk(YES);
    
    [self.descriptorReadBlockMapQueue removeAllObjectsForKey:k];
    [self.descriptorsReadKeyRecords removeObject:k forKey:peripheral.identifier.UUIDString];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    NSString *k = [self keyForDescriptor:descriptor];
    NSArray <OABleDataWriteTask *> *allTasks = [self.descriptorWriteBlockMapQueue objectsForKey:k];
    if(allTasks.count > 0 )
    {
        OABleDataWriteTask *taskToContinue = nil;
        OABleDataWriteTask *task = allTasks.firstObject;
        if(task.pendingData.length == 0 )
        {
            [self inter_finishWriteOfTask:task forDescriptor:descriptor withError:error];
            if(allTasks.count > 1)
                taskToContinue = [allTasks objectAtIndex:1];
        }
        else
            taskToContinue = task;

        if(taskToContinue)
            [self inter_writeDescriptorTask:taskToContinue forDescriptor:descriptor];
    
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error {
    
    [self inter_invokeAllRssiReadBlocksForPeripheral:peripheral value:RSSI.intValue withError:error];
}


#pragma mark- data transfer(read write & notify)


-(void)writeData:(NSData *)data
forCharacteristic:(CBCharacteristic *)chara
{
    if(data.length == 0 || !chara)
        return;
    
    CBPeripheral *pe = chara.service.peripheral;
    if(chara.properties|CBCharacteristicPropertyWriteWithoutResponse)
    {
        if(pe.canSendWriteWithoutResponse)
        {
            WEAK_SELF;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
            dispatch_async(queue, ^{
                
                CBPeripheral *pe = chara.service.peripheral;
                NSUInteger len = chara.service.peripheral.dataWritePakcetMaxLengthLimit;
                
                if(len == 0)
                    len = DEFAULT_WRITE_LEN;
                
                if(data.length <= len)
                    [pe writeValue:data forCharacteristic:chara type:CBCharacteristicWriteWithoutResponse];
                else
                {
                    [pe writeValue:[data subdataWithRange:NSMakeRange(0, len)] forCharacteristic:chara type:CBCharacteristicWriteWithoutResponse];
                    NSData *remainData = [data subdataWithRange:NSMakeRange(len, data.length-len)];
                    NSTimeInterval after = [weakSelf extimateTimeForWriteDataOflength:len];
                    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC);
                    dispatch_after(time, queue, ^{
                        [weakSelf writeData:remainData forCharacteristic:chara];
                    });
                }
            });
        }
    }
    else
    {
#if DEBUG
        NSLog(@"%@ does not support CBCharacteristicPropertyWriteWithoutResponse",chara);
#endif
    }
}

-(void)writeData:(nonnull NSData *)data forCharacteristic:(nonnull CBCharacteristic *)chara response:(void(^)(BOOL success))response
{
    if(data.length == 0 || !chara)
    {
        if(response)
            response(NO);
        
        return;
    }
    
    OABleDataWriteTask *task = [[OABleDataWriteTask alloc] init];
    task.pendingData = data;
    task.responseBlock = response;
    task.isWritting = NO;
    task.maxLen = chara.service.peripheral.dataWritePakcetMaxLengthLimit;
    if(task.maxLen == 0)
        task.maxLen = DEFAULT_WRITE_LEN;

    NSString *k = [self keyForCharacteristic:chara];
    [self.writeCharcWithResponseTaskQueueMap addObject:task forKey:k];
    
    if(response)
        [self.characteristicDataWriteKeyRecords addUniqueObject:k forKey:chara.service.peripheral.identifier.UUIDString];
    
    NSArray *tasks = [self.writeCharcWithResponseTaskQueueMap objectsForKey:k];
    if(tasks.count == 1)
        [self inter_writeCharacTask:task forCharacteristic:chara];
}


-(void)readDataforCharacteristic:(CBCharacteristic *)chara completion:(void(^)(BOOL))completionBlock
{
    if(completionBlock)
    {
        NSString *k = [self keyForCharacteristic:chara];
        [self.charcDataReadBlockMap addObject:completionBlock forKey:k];
        [self.characteristicDataReadKeyRecords addUniqueObject:k forKey:chara.service.peripheral.identifier.UUIDString];
    }
    
    if(chara.isNotifying)
    {
        [self enableNotify:NO forCharacteristic:chara completion:^(BOOL success) {
            if(success)
            {
                [chara.service.peripheral readValueForCharacteristic:chara];
            }
            else
            {
                if(completionBlock)
                    completionBlock(NO);
            }
        }];
    }
    else
        [chara.service.peripheral readValueForCharacteristic:chara];
}


-(void)setDataNotifyBlock:(void(^)(NSData *data))block forCharacteristic:(CBCharacteristic *)chara
{
    if(block)
        [self.dataNotifyBlockMap setObject:block forKey:[self keyForCharacteristic:chara]];
    
    [chara.service.peripheral setNotifyValue:YES forCharacteristic:chara];
}

-(void)enableNotify:(BOOL)enable forCharacteristic:(CBCharacteristic *)chara completion:(void(^)(BOOL success))block
{
    [chara.service.peripheral setNotifyValue:enable forCharacteristic:chara];
    
    if(block)
        [self.notifySettingBlockMap addObject:block forKey:[self keyForCharacteristic:chara]];
}


-(BOOL)inter_writeCharacTask:(OABleDataWriteTask *)task forCharacteristic:(CBCharacteristic *)characteristic
{
    CBPeripheral *pe = characteristic.service.peripheral;
    NSData *wData = [self extracNextPaketDataFromTask:task];
    if(wData.length > 0)
    {
        task.isWritting = YES;
        [pe writeValue:wData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
    }
    else
        task.isWritting = NO;
    
    return task.isWritting;
}



-(void)inter_finisthWriteTask:(OABleDataWriteTask *)task success:(BOOL)success forCharacteristic:(CBCharacteristic *)characteristic
{
    task.isWritting = NO;
    
    if(task.responseBlock)
        task.responseBlock(success);
    
    NSString *aKey = [self keyForCharacteristic:characteristic];
    [self.writeCharcWithResponseTaskQueueMap removeObject:task forKey:aKey];
    [self.characteristicDataWriteKeyRecords removeObject:aKey forKey:characteristic.service.peripheral.identifier.UUIDString];
    
}
                       
-(void)inter_failAllWriteBlocksForPeripheral:(CBPeripheral *)peripheral
{
    NSArray *allKeys = [self.characteristicDataWriteKeyRecords objectsForKey:peripheral.identifier.UUIDString];
    for(NSString *key in allKeys)
    {
         NSArray *tasks = [self.writeCharcWithResponseTaskQueueMap objectsForKey:key];
        for(OABleDataWriteTask *tsk in tasks)
        {
            if(tsk.responseBlock)
                tsk.responseBlock(NO);
        }
        [self.writeCharcWithResponseTaskQueueMap removeAllObjectsForKey:key];
    }
    
    [self.characteristicDataWriteKeyRecords removeAllObjectsForKey:peripheral.identifier.UUIDString];
}

-(void)inter_failAllReadBlocksForPeripheral:(CBPeripheral *)peripheral {
    
    NSArray *allKeys = [self.characteristicDataReadKeyRecords objectsForKey:peripheral.identifier.UUIDString];
    for(NSString *key in allKeys)
    {
        NSArray *blocks = [self.charcDataReadBlockMap objectsForKey:key];
        for(void (^blk)(BOOL) in blocks)
        {
            if(blk)
                blk(NO);
        }
        [self.charcDataReadBlockMap removeAllObjectsForKey:key];
    }
    
    [self.characteristicDataReadKeyRecords removeAllObjectsForKey:peripheral.identifier.UUIDString];
}


-(void)writeData:(nonnull NSData *)data
   forDescriptor:(nonnull CBDescriptor *)descriptor
        response:(void(^)(BOOL success))response
{
    if(data.length == 0  || !descriptor)
    {
        if(response)
            response(NO);
        return;
    }
    
    OABleDataWriteTask *task = [[OABleDataWriteTask alloc] init];
    task.pendingData = data;
    task.responseBlock = response;
    task.isWritting = NO;
    task.maxLen = descriptor.characteristic.service.peripheral.dataWritePakcetMaxLengthLimit;
    if(task.maxLen == 0)
        task.maxLen = DEFAULT_WRITE_LEN;
    
    NSString *k = [self keyForDescriptor:descriptor];
    [self.descriptorWriteBlockMapQueue addObject:task forKey:k];
    
    if(response)
        [self.descriptorsWriteKeyRecords addUniqueObject:k forKey:descriptor.characteristic.service.peripheral.identifier.UUIDString];
    
    NSArray *tasks = [self.descriptorWriteBlockMapQueue objectsForKey:k];
    if(tasks.count == 1)
        [self inter_writeDescriptorTask:task forDescriptor:descriptor];

}

-(void)inter_writeDescriptorTask:(OABleDataWriteTask *)task forDescriptor:(nonnull CBDescriptor *)descriptor
{
    CBPeripheral *pe = descriptor.characteristic.service.peripheral;
    NSData *wData = [self extracNextPaketDataFromTask:task];
    task.isWritting = YES;
    [pe writeValue:wData forDescriptor:descriptor];
}

-(void)inter_finishWriteOfTask:(OABleDataWriteTask *)task forDescriptor:(nonnull CBDescriptor *)descriptor withError:(NSError *)error
{
    task.isWritting = NO;
    if(task.responseBlock)
        task.responseBlock(error==nil);
    
    NSString *k = [self keyForDescriptor:descriptor];
    [self.descriptorWriteBlockMapQueue removeObject:task forKey:k];
    [self.descriptorsWriteKeyRecords removeObject:k forKey:descriptor.characteristic.service.peripheral.identifier.UUIDString];
}

-(void)inter_failAllDescriptorWriteBlocksForPeripheral:(CBPeripheral *)peripheral
{
    NSArray *allKeys = [self.descriptorsWriteKeyRecords objectsForKey:peripheral.identifier.UUIDString];
    for(NSString *k in allKeys)
    {
        NSArray *allTasks = [self.descriptorWriteBlockMapQueue objectsForKey:k];
        for(OABleDataWriteTask *task in allTasks)
        {
            if(task.responseBlock)
                task.responseBlock(NO);
        }
        
        [self.descriptorWriteBlockMapQueue removeAllObjectsForKey:k];
    }
    
    [self.descriptorsWriteKeyRecords removeAllObjectsForKey:peripheral.identifier.UUIDString];
}


-(void)readDataForDescriptor:(nonnull CBDescriptor *)descriptor completion:(void(^)(BOOL))completionBlock
{
    NSString *k = [self keyForDescriptor:descriptor];
    if(completionBlock)
    {
        [self.descriptorReadBlockMapQueue addObject:completionBlock forKey:k];
        [self.descriptorsReadKeyRecords addUniqueObject:k forKey:descriptor.characteristic.service.peripheral.identifier.UUIDString];
    }
    
    [descriptor.characteristic.service.peripheral readValueForDescriptor:descriptor];
}

-(void)inter_failAllDescriptorReadBlocksForPeripheral:(CBPeripheral *)peripheral
{
    NSArray *allKeys = [self.descriptorsReadKeyRecords objectsForKey:peripheral.identifier.UUIDString];
    for(NSString *k in allKeys)
    {
        NSArray *blocks = [self.descriptorReadBlockMapQueue objectsForKey:k];
        for(void(^blk)(BOOL) in blocks)
        {
            blk(NO);
        }
        
        [self.descriptorReadBlockMapQueue removeAllObjectsForKey:k];
    }
    [self.descriptorsReadKeyRecords removeAllObjectsForKey:peripheral.identifier.UUIDString];
}

#pragma mark-


-(NSString *)keyForDescriptor:(CBDescriptor *)descriptor
{
    CBCharacteristic *chara = descriptor.characteristic;
    return [NSString stringWithFormat:@"desc:%@cha:%@-sv:%@-per:%@",descriptor.UUID.UUIDString,chara.UUID.UUIDString,chara.service.UUID.UUIDString,chara.service.peripheral.identifier.UUIDString];
}

-(NSString *)keyForCharacteristic:(CBCharacteristic *)chara
{
    return [NSString stringWithFormat:@"cha:%@-sv:%@-per:%@",chara.UUID.UUIDString,chara.service.UUID.UUIDString,chara.service.peripheral.identifier.UUIDString];
}

-(NSString *)keyForServiceID:(NSString *)serviceID ofPeripheral:(CBPeripheral *)peripheral
{
    return [NSString stringWithFormat:@"K-sv:%@-phe:%@",serviceID,peripheral.identifier.UUIDString];
}

//extimate how long will be taken to send len of bytes data
-(NSTimeInterval)extimateTimeForWriteDataOflength:(NSUInteger)len
{
    NSTimeInterval intv;
    if(len<=70)
        intv = 1.5;
    else
        intv = (1+((float)len-70.0)/(float)(206-70))*1.5;
    return intv;
}

-(NSData *)extracNextPaketDataFromTask:(OABleDataWriteTask *)task
{
    NSUInteger len = task.maxLen;
    NSData *wData = task.pendingData;
    if(wData.length <= len)
        task.pendingData = nil;
    else
    {
        NSUInteger orLen = task.pendingData.length;
        wData = [task.pendingData subdataWithRange:NSMakeRange(0, len)];
        task.pendingData = [task.pendingData subdataWithRange:NSMakeRange(len, orLen-len)];
    }
    return wData;
}

#pragma mark-

-(void)dealloc
{
#if DEBUG
    NSLog(@"DEALLOC --> %@",NSStringFromClass([self class]));
#endif
}

@end
