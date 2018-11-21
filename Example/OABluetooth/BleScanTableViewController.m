//
//  BleScanTableViewController.m
//  2buluInterview
//
//  Created by 罗亮富 on 2018/11/15.
//  Copyright © 2018年 深圳市两步路信息技术有限公司. All rights reserved.
//

#import "BleScanTableViewController.h"
#import "OABleCentralManager.h"
#import "BleViewController.h"
#import "ProgressButton.h"

@interface BleScanTableViewController ()<OABlePeripheralManagerDelegate>
@property (nonatomic, strong) OABleCentralManager *centralManager;
@property (nonatomic, strong) NSArray<CBPeripheral *> *deviceList;
@end

@implementation BleScanTableViewController
{
    ProgressButton *_prgBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Scan peripherals";
    
    __weak typeof(self) weakSelf = self;
    
    _prgBtn = [[ProgressButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [_prgBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_prgBtn setTintColor:[UIColor blueColor]];
    [_prgBtn addTarget:self action:@selector(startScan:) forControlEvents:UIControlEventTouchUpInside];
    [_prgBtn setTitle:@"Scan" forState:UIControlStateNormal];
    [_prgBtn setTitle:@"Scaning..." forState:UIControlStateInProgress];
    self.tableView.tableFooterView = _prgBtn;
    
    
    self.centralManager = [[OABleCentralManager alloc] initWitPeripheralAdvertiseID:nil];
    
    //use block or delegate
    
   // [self.centralManager addDelegate:self];
    
    [self.centralManager setOnBluetoothStateChange:^(OABlePeripheralServiceState state) {
        [weakSelf updateState];
    }];
    
    [self.centralManager setOnPeripheralStateChange:^(CBPeripheral * _Nonnull peripheral) {
        [weakSelf updateList];
    }];
    
    [self.centralManager setOnNewPeripheralsDiscovered:^(NSArray<CBPeripheral *> * _Nonnull peripherals) {
        [weakSelf updateList];
    }];
    
    [self.centralManager setOnNewDataNotify:^(CBCharacteristic * _Nonnull characteristic) {
        //handle received data
    }];
    
    [self.centralManager scanPeripherals];
    
    [self updateState];
    [self updateList];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.centralManager.autoScanInterval = 5;
    self.centralManager.scanDuration = 5;
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.centralManager.autoScanInterval = 300000;
    [super viewDidDisappear:animated];
}

-(void)startScan:(ProgressButton *)btn
{
    if(btn.inProgress)
        [self.centralManager stopScanPeripherals];
    else
        [self.centralManager scanPeripherals];
    
}

-(void)updateList
{
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateList) object:nil];
    self.deviceList = self.centralManager.discoveredPeripherals;
    [self.tableView reloadData];
    
}

-(void)updateState
{
    BOOL p = self.centralManager.state == OABLEStateSearching;
    _prgBtn.inProgress = p;
    _prgBtn.enabled = (self.centralManager.state >= OABLEStatePoweredOn );
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"C"];
   if(!cell)
       cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"C"];
   
    CBPeripheral *per = [self.deviceList objectAtIndex:indexPath.row];
    cell.textLabel.text = per.name;
    cell.detailTextLabel.text = per.identifier.UUIDString;
    if(!cell.detailTextLabel.text)
        cell.detailTextLabel.text = @"(null)";
    
    if(per.state == CBPeripheralStateConnected)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *per = [self.deviceList objectAtIndex:indexPath.row];
    BleViewController *vc = [[BleViewController alloc] initWithPeripheral:per andManager:self.centralManager];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

@end
