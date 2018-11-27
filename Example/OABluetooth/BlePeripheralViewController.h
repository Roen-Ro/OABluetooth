//
//  BlePeripheralViewController.h
//  OABluetooth_Example
//
//  Created by 罗亮富 on 2018/11/26.
//  Copyright © 2018年 zxllf23@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OABTCentralManager.h"
#import "CBPeripheral+OABLE.h"

@interface BlePeripheralViewController : UITableViewController<OABlePeripheralManagerDelegate>

-(instancetype)initWithPeripheral:(CBPeripheral *)per andManager:(OABTCentralManager *)manager;


@end


