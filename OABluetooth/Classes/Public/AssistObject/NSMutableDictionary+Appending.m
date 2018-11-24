//
//  NSMutableDictionary+Appending.m
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/18.
//

#import "NSMutableDictionary+Appending.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (Appending)


- (void)addObject:(nullable id)anObject forKey:(nonnull id <NSCopying>)aKey
{
    if(!anObject || !aKey)
        return;
    
    NSMutableArray *ma = [self objectForKey:aKey];
    if(![ma isKindOfClass:[NSMutableArray class]])
    {
        id preObj = ma;
        ma = [NSMutableArray arrayWithCapacity:5];
        [self setObject:ma forKey:aKey];
        if(preObj)
            [ma addObject:preObj];
    }
    
    [ma addObject:anObject];
}

-(void)addUniqueObject:(nullable id)anObject forKey:(nonnull id <NSCopying>)aKey
{
    if(!anObject || !aKey)
        return;
    
    NSMutableArray *ma = [self objectForKey:aKey];
    if(![ma isKindOfClass:[NSMutableArray class]])
    {
        id preObj = ma;
        ma = [NSMutableArray arrayWithCapacity:5];
        [self setObject:ma forKey:aKey];
        if(preObj)
            [ma addObject:preObj];
    }
    
    BOOL add = YES;
    for(id obj in ma)
    {
        if([obj isEqual:anObject])
        {
            add = NO;
            break;
        }
    }
    if(add)
        [ma addObject:anObject];
}

- (void)removeObject:(nonnull id)anObject forKey:(nonnull id <NSCopying>)aKey
{
    NSMutableArray *ma = [self objectForKey:aKey];
    if([ma isKindOfClass:[NSMutableArray class]])
    {
        [ma removeObject:anObject];
        if(ma.count == 0)
            [self removeObjectForKey:aKey];
    }
}

- (void)removeAllObjectsForKey:(nonnull id <NSCopying>)aKey
{
    [self removeObjectForKey:aKey];
}

- (nullable NSArray *)objectsForKey:(nonnull id <NSCopying>)aKey
{
    NSMutableArray *ma = [self objectForKey:aKey];
    if(!ma)
        return nil;
    
    if([ma isKindOfClass:[NSMutableArray class]])
        return [NSArray arrayWithArray:ma];
    else
        return [NSArray arrayWithObject:ma];
}

@end
