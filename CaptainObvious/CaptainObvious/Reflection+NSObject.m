//
//  Reflection+NSObject.m
//  CaptainObvious
//
//  Created by Steven Masini on 5/18/16.
//  Copyright © 2016 Steven Masini. All rights reserved.
//

#import "Reflection+NSObject.h"
#import "objc/runtime.h"

/**
 *  Helps can be found following these links:
 *  https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048-CH1-SW1
 *  https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ObjCRuntimeRef/index.html#//apple_ref/doc/uid/TP40001418
 *
 */

@implementation NSObject (Reflection)

/**
 *  Retrieve all the property key path from a class
 *  http://stackoverflow.com/questions/11774162/list-of-class-properties-in-objective-c
 *
 *  @return An array with all the key path property
 */
- (NSArray *)allPropertyKeyPath {
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    return rv;
}

/**
 *  Return the pointer to one property with the key path property
 *  http://stackoverflow.com/questions/11774162/list-of-class-properties-in-objective-c
 *
 *  @param keyPath the key path of the property
 *
 *  @return the address pointer to the property
 */
- (void *)pointerOfIvarForKeyPath:(NSString *)keyPath {
    objc_property_t property = class_getProperty([self class], [keyPath UTF8String]);
    
    const char *attr = property_getAttributes(property);
    const char *ivarName = strchr(attr, 'V') + 1;
    
    Ivar ivar = object_getInstanceVariable(self, ivarName, NULL);
    
    return (char *)self + ivar_getOffset(ivar);
}

/**
 *  Return all the class name
 *
 *  @return An array of class name
 */
+ (NSArray *)allClassKeyPath {
    unsigned count;
    Class *classes = objc_copyClassList(&count);
    
    NSMutableArray *rv = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        Class class = classes[i];
        [rv addObject:NSStringFromClass(class)];
    }
    free(classes);
    
    // sort alphabeticaly
    [rv sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    return rv;
}

/**
 *  Inspect the class definition, and retrieve all the methods names
 *
 *  @param class The class to inspect
 *
 *  @return An array of methods names
 */
+ (NSArray *)allMethodInClass:(Class)class {
    unsigned count;
    Method *methods = class_copyMethodList(class, &count);
    
    NSMutableArray *rm = [NSMutableArray array];
    for (unsigned i = 0; i < count; i++) {
        SEL selector = method_getName(methods[i]);
        NSString *methodName = [NSString stringWithUTF8String:sel_getName(selector)];
        [rm addObject:methodName];
    }
    free(methods);
    
    // sort alphabeticaly
    [rm sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    return rm;
}

@end