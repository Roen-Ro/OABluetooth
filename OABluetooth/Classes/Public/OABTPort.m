//
//  OABTPort.m
//  OABluetooth
//
//  Created by 罗亮富 on 2018/11/23.
//

#import "OABTPort.h"

@implementation OABTPort

-(instancetype)initWithServiceID:(nonnull NSString *)serviceID
                characteristicID:(nonnull NSString *)charateristicID
                   descriptionID:(nullable NSString *)descriptionID {
    self = [super init];
    _serviceID = [serviceID copy];
    _charateristicID = [charateristicID copy];
    _descriptionID = [descriptionID copy];
    return self;
    
}

+(instancetype)portWithServiceID:(nonnull NSString *)serviceID
                characteristicID:(nonnull NSString *)charateristicID
                   descriptionID:(nullable NSString *)descriptionID {
    return [[OABTPort alloc] initWithServiceID:serviceID characteristicID:charateristicID descriptionID:descriptionID];
}

+(instancetype)portWithServiceID:(nonnull NSString *)serviceID
                characteristicID:(nonnull NSString *)charateristicID {
    return [[OABTPort alloc] initWithServiceID:serviceID characteristicID:charateristicID descriptionID:nil];
}

@end
