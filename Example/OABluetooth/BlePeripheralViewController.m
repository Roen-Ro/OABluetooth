  //
//  BlePeripheralViewController.m
//  OABluetooth_Example
//
//  Created by 罗亮富 on 2018/11/26.
//  Copyright © 2018年 zxllf23@163.com. All rights reserved.
//

#import "BlePeripheralViewController.h"
#import "ProgressButton.h"

@interface BlePeripheralViewController ()

@property (nonatomic, strong) OABTCentralManager *centalManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (strong, nonatomic) IBOutlet ProgressButton *connectBtn;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@end

@implementation BlePeripheralViewController

-(instancetype)initWithPeripheral:(CBPeripheral *)per andManager:(OABTCentralManager *)manager
{
    self = [super init];
    self.centalManager = manager;
    self.peripheral = per;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.centalManager addDelegate:self];
    
    self.connectBtn = [[ProgressButton alloc] initWithFrame:CGRectMake(0, 0, 96, 30)];
    [self.connectBtn addTarget:self action:@selector(connectSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectBtn setTitle:@"Disconnect" forState:UIControlStateSelected];
    [self.connectBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.connectBtn setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [self updateConnectionBtn];
    
    UIBarButtonItem *rigtItem = [[UIBarButtonItem alloc] initWithCustomView:self.connectBtn];
    self.navigationItem.rightBarButtonItem = rigtItem;
    
    if(self.peripheral.state == CBPeripheralStateConnected)
        [self discoverAll];

}

-(void)updateConnectionBtn
{
    self.connectBtn.inProgress = (self.peripheral.state == CBPeripheralStateConnecting || self.peripheral.state == CBPeripheralStateDisconnecting);
    
    self.connectBtn.enabled = YES;
    if(self.peripheral.state == CBPeripheralStateConnected)
        self.connectBtn.selected = YES;
    else
        self.connectBtn.selected = NO;
}

-(void)discoverAll {
    
    self.connectBtn.inProgress = YES;
    [self.peripheral discoverAllServicesCharacteristicsAndDescriptorsWithCompletion:^(NSError *error) {
        [self.tableView reloadData];
        self.connectBtn.inProgress = NO;
    }];
}

- (IBAction)connectSwitch:(ProgressButton *)sender
{
    self.connectBtn.inProgress = YES;
    if(self.peripheral.state == CBPeripheralStateConnected){
        [self.centalManager disConnectperipheral:self.peripheral];
        [self.centalManager removeperipheralFromAutoReconnection:self.peripheral];
    }
    else
        [self.centalManager connectPeripheral:self.peripheral completion:^(NSError * _Nonnull error) {
            [self updateConnectionBtn];
            [self.centalManager addPeripheralToAutoReconnection:self.peripheral];
            [self discoverAll];
        }];
    
    self.connectBtn.enabled = NO;
}

-(void)centralManager:(OABTCentralManager *)manager didChangeStateForPeripheral:(CBPeripheral *)peripheral
{
    [self updateConnectionBtn];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.peripheral.services.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    CBService *service = [self.peripheral.services objectAtIndex:section];
    return service.characteristics.count;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    CBService *service = [self.peripheral.services objectAtIndex:section];
//    return service.UUID.UUIDString;
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 24, tableView.frame.size.width-5)];
    lb.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.88];
    lb.font = [UIFont systemFontOfSize:16.0];
    lb.minimumScaleFactor = 0.5;
    lb.textColor = [UIColor blueColor];
    lb.numberOfLines = 2;
    CBService *service = [self.peripheral.services objectAtIndex:section];
    lb.text = [NSString stringWithFormat:@"Service uuid:\n%@", service.UUID.UUIDString];
    return lb;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 102;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"C"];
    if(!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"C"];
        cell.textLabel.numberOfLines = 3;
        cell.detailTextLabel.numberOfLines = 3;
        cell.detailTextLabel.minimumScaleFactor = 0.5;
        cell.textLabel.minimumScaleFactor = 0.5;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    CBService *service = [self.peripheral.services objectAtIndex:indexPath.section];
    CBCharacteristic *charac = [service.characteristics objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Characteristic uuid:\n%@",charac.UUID.UUIDString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"properties:%@",charac.propertiesDescription];
    

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBService *service = [self.peripheral.services objectAtIndex:indexPath.section];
    CBCharacteristic *charac = [service.characteristics objectAtIndex:indexPath.row];
    
    //Note: in your project code, you don't need to get the serviceID and characteristicID from a discovered service and characteristic,\
    you just need to write code like:\
    *port = [OABTPort portWithServiceID:@"180A" characteristicID:@"2A23"];
     OABTPort *port = [OABTPort portWithServiceID:service.UUID.UUIDString characteristicID:charac.UUID.UUIDString];
    
    char *s = "hello this is OABluetooth, welcome to use! hello this is OABluetooth, welcome to use! hello this is OABluetooth, welcome to use! hello this is OABluetooth, welcome to use! hello this is OABluetooth, welcome to use! hello this is OABluetooth, welcome to use! hello this is OABluetooth, welcome to use! hello this is OABluetooth, welcome to use!";
    
    UIAlertController *alc = [UIAlertController alertControllerWithTitle:nil message:@"Choose the operation" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"Read" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        [self.peripheral readDataFromPort:port completion:^(id value, NSError *error) {
            NSLog(@"Read data %@ error:%@",value,error);
        }];
    }];
    
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"Write with Response" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.peripheral writeData:[NSData dataWithBytes:s length:strlen(s)] toPort:port completion:^(NSError *error) {
            NSLog(@"Write with response error:%@",error);
        }];
    }];
    
    UIAlertAction *act3 = [UIAlertAction actionWithTitle:@"Write without Response" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.peripheral writeData:[NSData dataWithBytes:s length:strlen(s)] toPort:port];
    }];
    
    [alc addAction:act1];
    [alc addAction:act2];
    [alc addAction:act3];
    
    [self presentViewController:alc animated:YES completion:nil];
}

@end
