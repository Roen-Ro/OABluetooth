//
//  WeakReference.h
//  OABLECentralManager
//
//  Created by 罗亮富(Roen-Ro) zxllf23@163.com on 2018/11/20.
//  github profile:https://github.com/Roen-Ro

#import <UIKit/UIKit.h>


@interface WeakReference : NSProxy
@property (nonatomic, weak) id weakObj;
@end

