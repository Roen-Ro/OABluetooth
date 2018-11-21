//
//  NSObject+MultiDelegates.h
//  2buluInterview
//
//  Created by 罗亮富 on 2018/11/16.
//  Copyright © 2018年 深圳市两步路信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>




@interface NSObject (MultiDelegates)


//the delegate object will be added to a weak NSHashTable
-(void)addDelegate:(id)delegate;
-(void)removeDelegate:(id)delegate;
-(NSArray *)delegates;
-(void)emunateDelegatesWithBlock:(void (^)(id delegate, BOOL *stop))block;

@end


