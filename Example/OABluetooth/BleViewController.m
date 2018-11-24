//
//  BleViewController.m
//  2buluInterview
//
//  Created by 罗亮富 on 2018/11/9.
//  Copyright © 2018年 深圳市两步路信息技术有限公司. All rights reserved.
//

#import "BleViewController.h"
#import "OABTCentralManager.h"
#import "CBPeripheral+OABLE.h"
#import "ProgressButton.h"

@interface BleViewController ()<OABlePeripheralManagerDelegate>

@property (nonatomic, strong) OABTCentralManager *centalManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (weak, nonatomic) IBOutlet ProgressButton *connectBtn;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@end

@implementation BleViewController

-(instancetype)initWithPeripheral:(CBPeripheral *)per andManager:(OABTCentralManager *)manager
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
    
    OABTPort *port = [OABTPort portWithServiceID:@"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2" characteristicID:@"BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"];
    NSUInteger len = strlen(s);
    NSData *d = [NSData dataWithBytes:s length:len];
    [self.peripheral writeData:d toPort:port completion:^(NSError *error) {
        NSLog(@"writeData:-------error:%@-----",error);
    }];
    
}


- (IBAction)connectSwitch:(UIButton *)sender
{
    if(self.peripheral.state == CBPeripheralStateConnected)
        [self.centalManager disConnectperipheral:self.peripheral];
    else
        [self.centalManager connectPeripheral:self.peripheral completion:^(NSError * _Nonnull error) {
            [self updateConnectionBtn];
            [self.centalManager addPeripheralToAutoReconnection:self.peripheral];
        }];
    
    self.connectBtn.enabled = NO;
}

- (IBAction)discoverService:(id)sender {
    
    [self.peripheral discoverAllServicesCharacteristicsAndDescriptorsWithCompletion:^(NSError *error) {
        NSLog(@"discoverAllServicesCharacteristicsAndDescriptorsWithCompletion--error:%@ ",error);
    }];

}


- (IBAction)readRssi:(id)sender {
//    
//    [self performSelector:@selector(readRssi:) withObject:nil afterDelay:1];
//    [self.centalManager readRSSIForPeripheral:self.peripheral completion:^(int value, NSError * error) {
//        if(error)
//            self.rssiLabel.text = error.description;
//        else
//            self.rssiLabel.text = [NSString stringWithFormat:@"rssi:%d",value];
//    }];
}



-(void)centralManager:(OABTCentralManager *)manager didChangeStateForPeripheral:(CBPeripheral *)peripheral
{
    [self updateConnectionBtn];
}



@end
