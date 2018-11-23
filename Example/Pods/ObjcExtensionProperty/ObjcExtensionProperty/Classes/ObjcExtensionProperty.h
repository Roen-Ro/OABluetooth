//
//  ObjcExtensionProperty.h
//  Pods
//
//  Created by 罗亮富(Roen-Ro) zxllf23@163.com on 2018/11/20.
//  github profile:https://github.com/Roen-Ro

#ifndef DynamicGetterSetter_h
#define DynamicGetterSetter_h

#import <objc/runtime.h>
#import "WeakReference.h"


#define lazy readonly

/*
 All parameters in this file in macro fuctions all have the same meaning
 Class - the property class type
 name - the name of the property
 initializer - method provided to create a new object in for lazy properties
 association - a objc_AssociationPolicy type value
 defaultValue - a default return value for getter
 */


/**
 Instance variable backed lazy getter method macro define

 @param Class the property class type
 @param name the property name (which must have a backed ivar named like _name)
 @param initializer... the property creation code
 @return the property value
 
 @example:
 __GETTER_LAZY(NSArray, members, [NSMutableArray arrayWithObjects:@"Lucy",@"Lily",nil])
 */
#define __GETTER_LAZY_IVAR(Class,name,initializer...) -(Class *)name { \
if(!_##name){             \
_##name = initializer; \
} \
return _##name; \
}

/************
 *getter and setter methods macro defines for dynamic binded varaiables, typically for properties defined in class extensions
 ************/


/**
 dynamic property lazy getter method

 @param Class the property class type
 @param name the property name
 @param initializer... the property creation code
 @return the property value
 
 @example:
 __GETTER_LAZY(NSArray, members, [NSMutableArray arrayWithObjects:@"Lucy",@"Lily",nil])
 */
#define __GETTER_LAZY(Class,name,initializer...) -(Class *)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
id obj = objc_getAssociatedObject(self,key); \
if(!obj){             \
obj = initializer; \
objc_setAssociatedObject(self, key, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
} \
return obj;\
}


/**
 common object type property setter method

 @param name the property name
 @param setter the setter method name
 @param association objc_AssociationPolicy type value
 @return none
 @example
 __SETTER(members, setMembers, OBJC_ASSOCIATION_RETAIN)
 */
#define __SETTER(name,setter,association) -(void)setter (id)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
objc_setAssociatedObject(self, key, name, association);\
}

//common object type property getter method
#define __GETTER(Class,name) -(Class *)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
id obj = objc_getAssociatedObject(self,key); \
return obj;\
}

//

/**
 common object type property setter method with additional costomize code after setting
 
 @param name proerty name
 @param setter peroperty setter method
 @param association objc_AssociationPolicy type value
 @param customizeCode... additional user code after  setting
 
 @example
 __SETTER_CUSTOMIZE(tableView, setTableView, OBJC_ASSOCIATION_RETAIN, {
     UITableView *tbv = tableView;
     tbv.dataSource = self;
     tbv.delegate = self;
 })
 
 */
#define __SETTER_CUSTOMIZE(name,setter,association,customizeCode...) -(void)setter (id)name { \
IMP key = class_getMethodImplementation([self class],@selector(name)); \
objc_setAssociatedObject(self, key, name, association); \
customizeCode \
}


//common object type property getter method provide a default return value
#define __GETTER_DEFAULT(Class,name,defaultValue) -(Class *)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
id obj = objc_getAssociatedObject(self,key); \
if(obj) \
return obj; \
else \
return defaultValue; \
}

//common weak object type property setter method
#define __SETTER_WEAK(name,setter) -(void)setter (id)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
if(name) { \
WeakReference *p = objc_getAssociatedObject(self, key);\
if(!p) { \
p = [WeakReference alloc]; \
objc_setAssociatedObject(self, key, p, OBJC_ASSOCIATION_RETAIN);\
} \
p.weakObj = name; \
} \
else \
objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN); \
}

//common weak object type property setter method with additional costomize code after setting
#define __SETTER_WEAK_CUSTOMIZE(name,setter,customizeCode...) -(void)setter (id)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
if(name) { \
WeakReference *p = objc_getAssociatedObject(self, key);\
if(!p) { \
p = [WeakReference alloc]; \
objc_setAssociatedObject(self, key, p, OBJC_ASSOCIATION_RETAIN);\
} \
p.weakObj = name; \
} \
else \
objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN); \
customizeCode \
}

//common weak object type property getter method
#define __GETTER_WEAK(Class,name) -(Class *)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
WeakReference *p = objc_getAssociatedObject(self, key); \
return p.weakObj; \
}

//primitive type property setter method
#define __SETTER_PRIMITIVE(type,name,setter,NSNumberMethod) -(void)setter (type)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
objc_setAssociatedObject(self, key, [NSNumber NSNumberMethod name], OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}

//primitive type property getter method
#define __GETTER_PRIMITIVE(type,name,NSNumberMethod) -(type)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
NSNumber *num = objc_getAssociatedObject(self,key); \
return num.NSNumberMethod;\
}

//primitive type property setter method
#define __SETTER_PRIMITIVE_CUSTOMIZE(type,name,setter,NSNumberMethod,customizeCode...) -(void)setter (type)name { \
IMP key = class_getMethodImplementation([self class],@selector(name)); \
objc_setAssociatedObject(self, key, [NSNumber NSNumberMethod name], OBJC_ASSOCIATION_RETAIN_NONATOMIC); \
customizeCode \
}

//primitive type property getter method with a default return value
#define __GETTER_PRIMITIVE_DEFAULT(type,name,defaultValue,NSNumberMethod) -(type)name { \
IMP key = class_getMethodImplementation([self class],@selector(name));\
NSNumber *num = objc_getAssociatedObject(self,key); \
if(num) \
return num.NSNumberMethod;\
else \
return defaultValue;\
}


#endif /* DynamicGetterSetter_h */


