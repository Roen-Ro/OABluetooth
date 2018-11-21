//
//  BleViewController.m
//  2buluInterview
//
//  Created by 罗亮富 on 2018/11/9.
//  Copyright © 2018年 深圳市两步路信息技术有限公司. All rights reserved.
//

#import "BleViewController.h"
#import "OABleCentralManager.h"
#import "CBPeripheral+OABLE.h"
#import "ProgressButton.h"

@interface BleViewController ()<OABlePeripheralManagerDelegate>

@property (nonatomic, strong) OABleCentralManager *centalManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (weak, nonatomic) IBOutlet ProgressButton *connectBtn;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@end

@implementation BleViewController

-(instancetype)initWithPeripheral:(CBPeripheral *)per andManager:(OABleCentralManager *)manager
{
    self = [super init];
    self.centalManager = manager;
    self.peripheral = per;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.connectBtn setTitle:@"连接" forState:UIControlStateNormal];
    [self.connectBtn setTitle:@"断开" forState:UIControlStateSelected];
    [self.centalManager addDelegate:self];
    
    [self updateConnectionBtn];
    
}

-(void)updateConnectionBtn
{
    self.connectBtn.enabled = YES;
    if(self.peripheral.state == CBPeripheralStateConnected)
        self.connectBtn.selected = YES;
    else
        self.connectBtn.selected = NO;
}

- (IBAction)writeData:(id)sender {
    
    char *s = "Hello world, this is BLE data data data Hello world, this is BLE data data data Hello world, this is BLE data data data  this is BLE data data data  this is BLE data data data Hello world, this is BLE data data data Hello world, this is BLE data data data Hello world, this is BLE data data data  this is BLE data data data  this is BLE data data data  Hello world, this is BLE data data data Hello world bling bling bling hahhahhah hohoi how wndn da";
    
    int len  = strlen(s);
    
    CBCharacteristic *chr = [self.peripheral discoveredCharacteristicWithUUID:@"BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F" ofService:@"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"];
    if(chr)
        [self.centalManager writeData:[NSData dataWithBytes:s length:len] forCharacteristic:chr response:^(BOOL success) {
            NSLog(@"---------------Write sucuceess %d",success);
        }];
    else
    {
        [self.centalManager discoverCharacteristics:@[@"BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"] ofService:@"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2" forPeripheral:self.peripheral completion:^(NSError * _Nonnull error) {
            
            CBCharacteristic *c = [self.peripheral discoveredCharacteristicWithUUID:@"BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F" ofService:@"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"];
            [self.centalManager writeData:[NSData dataWithBytes:s length:len] forCharacteristic:c response:^(BOOL success) {
                NSLog(@"--IN BLOCK Write sucuceess %d error:%@",success,error);
            }];
        }];
    }
}


- (IBAction)connectSwitch:(UIButton *)sender
{
    if(self.peripheral.state == CBPeripheralStateConnected)
        [self.centalManager disConnectperipheral:self.peripheral];
    else
        [self.centalManager connectPeripheral:self.peripheral completion:^(NSError * _Nonnull error) {
            [self updateConnectionBtn];
        }];
    
    self.connectBtn.enabled = NO;
}

- (IBAction)discoverService:(id)sender {
    
    
    for(int i=0; i<1; i++)
    {
        NSLog(@"to discover %d",i);
        [self.centalManager discoverService:@[@"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"] forPeripheral:self.peripheral completion:^(NSError * _Nonnull error) {
            
            NSLog(@"%d discoverService: error %@",i,error);
        }];
    }

}


- (IBAction)readRssi:(id)sender {
    
    [self performSelector:@selector(readRssi:) withObject:nil afterDelay:1];
    [self.centalManager readRSSIForPeripheral:self.peripheral completion:^(int value, NSError * error) {
        if(error)
            self.rssiLabel.text = error.description;
        else
            self.rssiLabel.text = [NSString stringWithFormat:@"rssi:%d",value];
    }];
}



-(void)centralManager:(OABleCentralManager *)manager didChangeStateForPeripheral:(CBPeripheral *)peripheral
{
    [self updateConnectionBtn];
}



@end