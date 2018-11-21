#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CBCharacteristic+OABLE.h"
#import "CBPeripheral+OABLE.h"
#import "OABLDiscoverTask.h"
#import "OABleDataWriteTask.h"
#import "OABLPeripheralInterExtension.h"
#import "NSMutableDictionary+Appending.h"
#import "NSObject+MultiDelegates.h"
#import "OABleCentralManager.h"

FOUNDATION_EXPORT double OABluetoothVersionNumber;
FOUNDATION_EXPORT const unsigned char OABluetoothVersionString[];

