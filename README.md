# OABluetooth

[![CI Status](https://img.shields.io/travis/zxllf23@163.com/OABluetooth.svg?style=flat)](https://travis-ci.org/zxllf23@163.com/OABluetooth)
[![Version](https://img.shields.io/cocoapods/v/OABluetooth.svg?style=flat)](https://cocoapods.org/pods/OABluetooth)
[![License](https://img.shields.io/cocoapods/l/OABluetooth.svg?style=flat)](https://cocoapods.org/pods/OABluetooth)
[![Platform](https://img.shields.io/cocoapods/p/OABluetooth.svg?style=flat)](https://cocoapods.org/pods/OABluetooth)

OABluetooth is a lightweight framework based on Apple's [CoreBluetooth](https://developer.apple.com/documentation/corebluetooth) that can be applied both on ios and OSX, It can manage different kind of peripherals independently, peripheral auto reconnection on disconnected. support block call backs for envents and communitations.  
OABluetooth map all type of services,characteristics and descriptors(which are represented by [CBService](https://developer.apple.com/documentation/corebluetooth/cbservice),[CBCharateristic](https://developer.apple.com/documentation/corebluetooth/cbcharacteristic) and [CBDescriptor](https://developer.apple.com/documentation/corebluetooth/cbdescriptor)) in to a `OABTPort`, you will have no more headaches to maintain these things. Comapared to *connection->discover services->discover charateristics->[discover descriptores]->data transfer* communication establish process based on [CoreBluetooth](https://developer.apple.com/documentation/corebluetooth)， OABluetooth simplify it to *connection->data transfer*, all else will be done automatically. more features are listed <a href="##Features">here</a>.  


---
OABluetooth 是基于苹果[CoreBluetooth](https://developer.apple.com/documentation/corebluetooth)开发的轻量级蓝牙外设管理框架,可以同时支持ios和osx系统. OABluetooth 支持对不同类型设备列表的分开管理，断开后自动重连。  
OABluetooth 还将所有的特征、描述都映射为一个通讯端口`OABTPort`，使你不需要再为维护不同的[CBService](https://developer.apple.com/documentation/corebluetooth/cbservice)/[CBCharateristic](https://developer.apple.com/documentation/corebluetooth/cbcharacteristic)/[CBDescriptor](https://developer.apple.com/documentation/corebluetooth/cbdescriptor)而感到头痛, 重要的是！相较于传统的 *连接->发现服务->发现特征->[发现描述]->通讯* 的基于[CoreBluetooth](https://developer.apple.com/documentation/corebluetooth)的通讯建立过程, OABluetooth 为此提供了完美的<font color=red size=3>**"一条龙"**</font>服务, 建立连接后直接通讯就可以了, 其余工作统统都自动完成。更多功能且看<a href="## Features">功能清单</a>。

*由于作者精力有限，目前只支持ios/OSX设备作为中心者工作模式(应该能满足90%以上的应用场景了)，ios/osx设备作为外设工作模式将在今后有时间继添加。*

## Features
 - Support different kind of peripheral list management
 - Auto scan and reconnection for peripherals
 - Block call backs supported for all kinds of events and data communication
 - Greately simplify the communication process
 - Auto divide large data into small packets for writting.
 - Simple to use with [CBPeripheral](https://developer.apple.com/documentation/corebluetooth/cbperipheral) category
 - No need to maintain [CBService](https://developer.apple.com/documentation/corebluetooth/cbservice)/[CBCharateristic](https://developer.apple.com/documentation/corebluetooth/cbcharacteristic)/[CBDescriptor](https://developer.apple.com/documentation/corebluetooth/cbdescriptor) any more  
 ---

 - 支持同时管理多个不同类型的BLE外设列表
 - 支持自动扫描，断开后自动重连
 - 所有事件都支持block回调
 - 提供了完美的通讯<font color=red size=3>**"一条龙"**</font>服务
 - 支持长数据自动分包发送
 - 简单的接口, 所有通讯接口都是基于[CBPeripheral](https://developer.apple.com/documentation/corebluetooth/cbperipheral)分类实现
 - 免去了对服务/特征/描述维护的麻烦, 所有通信都映射为端口
 - 简单易用！简单易用！简单易用! 重要的事情说三遍

## Useage

OABluetooth is very simple to use, all interfaces you nedd to use are defined in the 3 classes(category) below:
- `OABTCentralManager`: a class manage peripheral's scan, connection/disconnection, event notify. All featrues and methods are well commented in `OABTCentralManager.h`
- `CBPeripheral (OABLE)` the [CBPeripheral](https://developer.apple.com/documentation/corebluetooth/cbperipheral) category implements methods for data write/read/notify and some other useful methods, apis in `CBPeripheral+OABLE.h` are well commented
- `OABTPort` represents either a type of [CBCharateristic](https://developer.apple.com/documentation/corebluetooth/cbcharacteristic) or a type of[CBDescriptor](https://developer.apple.com/documentation/corebluetooth/cbdescriptor) used for communication with [CBPeripheral](https://developer.apple.com/documentation/corebluetooth/cbperipheral), see comment in `OABTPort.h` file

---
OABluetooth 用起来非常简单, 要用到的所有的接口都定义在下面的三个类/分类中
- `OABTCentralManager` 是外设管理类, 负责管理外设的扫描、连接、以及状态管理，`OABTCentralManager.h`文件中对每一个接口都有详细说明
- `CBPeripheral (OABLE)` 一个[CBPeripheral](https://developer.apple.com/documentation/corebluetooth/cbperipheral)分类, 实现了所有的数据读/写/通知等一切外设相关的通讯，`CBPeripheral+OABLE.h`文件对接口都有详细注释
- `OABTPort` 通讯端口, 代表[CBCharateristic](https://developer.apple.com/documentation/corebluetooth/cbcharacteristic)或[CBDescriptor](https://developer.apple.com/documentation/corebluetooth/cbdescriptor), `OABTPort.h`中对如何定义一个端口有详细说明


## Requirements
ios 8.0, OSX 10.1

## Installation

OABluetooth is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'OABluetooth'
```

## Author

Roen(罗亮富）, zxllf23@163.com

## License

OABluetooth is available under the MIT license. See the LICENSE file for more info.
