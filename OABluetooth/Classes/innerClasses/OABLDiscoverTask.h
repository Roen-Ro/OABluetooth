//
//  OABleDiscoverServiceTask.h
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/17.
//

#import <Foundation/Foundation.h>

@interface OABLDiscoverTask : NSObject

@property (nonatomic, copy) void (^block)(NSError *error);
@property (nonatomic, copy) NSArray <NSString *> *discoverIDs;

@end

