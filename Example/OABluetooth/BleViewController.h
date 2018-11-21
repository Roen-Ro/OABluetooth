//
//  BleViewController.h
//  2buluInterview
//
//  Created by 罗亮富 on 2018/11/9.
//  Copyright © 2018年 深圳市两步路信息技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OABTCentralManager.h"



@interface BleViewController : UIViewController

-(instancetype)initWithPeripheral:(CBPeripheral *)per andManager:(OABTCentralManager *)manager;

@end

