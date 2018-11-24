//
//  OABleDataWriteTask.h
//  2buluInterview
//
//  Created by 罗亮富 on 2018/11/16.
//  Copyright © 2018年 深圳市两步路信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OABTDataWriteTask : NSObject

@property (nullable, nonatomic, strong) NSData *pendingData; // data pending, need to be wrote
@property (nullable, nonatomic, copy) void(^responseBlock)(NSError *error);
@property (nonatomic) BOOL isWritting;
@property (nonatomic) NSUInteger maxLen;

@end
