//
//  NSMutableDictionary+Appending.h
//  OABLECentralManager
//
//  Created by 罗亮富 on 2018/11/18.
//

#import <Foundation/Foundation.h>



@interface NSMutableDictionary (Appending)


- (void)addObject:(nullable id)anObject forKey:(id <NSCopying>)aKey;
-(void)addUniqueObject:(nullable id)anObject forKey:(id <NSCopying>)aKey;

- (void)removeObject:(nonnull id)anObject forKey:(id <NSCopying>)aKey;
- (void)removeAllObjectsForKey:(id <NSCopying>)aKey;

- (nullable NSArray *)objectsForKey:(id <NSCopying>)aKey;

@end

