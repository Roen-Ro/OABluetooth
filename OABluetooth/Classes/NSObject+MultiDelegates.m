//
//  NSObject+MultiDelegates.m
//  2buluInterview
//
//  Created by 罗亮富 on 2018/11/16.
//  Copyright © 2018年 深圳市两步路信息技术有限公司. All rights reserved.
//

#import "NSObject+MultiDelegates.h"
#import <ObjcExtensionProperty/ObjcExtensionProperty.h>

@implementation NSObject (MultiDelegates)

const char delegatesKey;

-(void)addDelegate:(id)delegate
{
    NSHashTable *tb = self.delegatesHashTable;
    @synchronized(tb)
    {
        [tb addObject:delegate];
    }
}
-(void)removeDelegate:(id)delegate
{
    NSHashTable *tb = self.delegatesHashTable;
    @synchronized(tb)
    {
        [tb removeObject:delegate];
    }
}
-(NSHashTable *)delegatesHashTable
{
    NSHashTable *hashTable = objc_getAssociatedObject(self, &delegatesKey);
    if(!hashTable)
    {
        hashTable = [NSHashTable weakObjectsHashTable];
        objc_setAssociatedObject(self, &delegatesKey, hashTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return hashTable;
}

-(NSArray *)delegates
{
    NSHashTable *hashTable = objc_getAssociatedObject(self, &delegatesKey);
    return [hashTable allObjects];
}

-(void)emunateDelegatesWithBlock:(void (^)(id delegate, BOOL *stop))emBlock
{
    NSHashTable *tb = self.delegatesHashTable;
    @synchronized(tb)
    {
        @autoreleasepool//放在循环外面是为delegates中的元素在没有其他引用的时候被销毁，主要目的并非为了降低内存峰值
        {
            BOOL shouldBreak = NO;
            for(id d in tb)
            {
                emBlock(d,&shouldBreak);
                if(shouldBreak)
                    break;
            }
        }
    }
}

@end
