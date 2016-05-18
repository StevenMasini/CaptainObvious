//
//  Reflection+NSObject.h
//  CaptainObvious
//
//  Created by Steven Masini on 5/18/16.
//  Copyright © 2016 Steven Masini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Reflection)
- (NSArray *)allPropertyKeyPath;
- (void *)pointerOfIvarForKeyPath:(NSString *)keyPath;

+ (NSArray *)allClassKeyPath;
+ (NSArray *)allMethodInClass:(Class)class;
@end
