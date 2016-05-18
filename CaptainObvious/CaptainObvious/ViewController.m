//
//  ViewController.m
//  CaptainObvious
//
//  Created by Steven Masini on 5/18/16.
//  Copyright © 2016 Steven Masini. All rights reserved.
//

#import "ViewController.h"
#import "Reflection+NSObject.h"
#import "objc/runtime.h"

@interface ViewController ()
@property (nonatomic, strong) NSObject *object;
@property (nonatomic, strong) NSMutableDictionary *allKeys;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_queue_t queue = dispatch_queue_create("LIST_CLASSES_IN_FRAMEWORK", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSArray *classNames = [NSObject allClassKeyPath];

        Class higherClass;
        unsigned i = 0;
        for (NSString * className in classNames) {
            
            if (![className hasPrefix:@"_"]) {
                Class class = NSClassFromString(className);
                size_t size = class_getInstanceSize(class);
                
                if (size > 4 && [class isSubclassOfClass:[NSObject class]]) {
                    NSLog(@"CLASS: %@ - %@ bytes", className, @(size));
                    if ([class instancesRespondToSelector:@selector(init)]) {
                        @try {
                            NSObject *obj = [[class alloc] init];
                            if (obj) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"CLASS CAN BE INSTANTIATE: %@ - %@ bytes", className, @(size));
                                });
                            }
                            
                            if (size > class_getInstanceSize(higherClass)) {
                                higherClass = class;
                            }
                        }
                        @catch (NSException *exception) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"INSTANTIATE EXCEPTION: %@", exception);
                            });
                        }
                    }
                }
                
                i++;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"");
            NSLog(@"CLASS COUNT: %@", @(i));
            NSLog(@"HIGHER CLASS: %@ - %@ bytes", NSStringFromClass(higherClass), @(class_getInstanceSize(higherClass)));
        });
    });
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        dispatch_queue_t queue2 = dispatch_queue_create("TEST_UINAVIGATIONCONTROLLER", DISPATCH_QUEUE_CONCURRENT);
//        dispatch_async(queue2, ^{
//            self.allKeys  = [NSMutableDictionary dictionary];
//            self.object = [[UINavigationController alloc] init];
//            for (NSString *keyPath in [self.object allPropertyKeyPath]) {
//                @try {
//                    id value = [self.object valueForKey:keyPath];
//                    if (value && ![value isKindOfClass:[NSNull class]]) {
//                        // setup the key info for the property
//                        NSDictionary *keyInfo = @{@"keyPath"        : keyPath,
//                                                  @"className"      : NSStringFromClass([value class]),
//                                                  @"isObservable"   : @NO};
//                        [self.allKeys setObject:keyInfo forKey:keyPath];
//                        
//                        // add property observer
//                        [self.object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionInitial context:nil];
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            //                        NSLog(@"%p NAME: %@ VALUE: %@ CLASS: %@", value, keyPath, value, [value class]);
//                        });
//                    } else {
//                        NSLog(@"%@ PROPERTY IS NULL: %@", keyPath, [value class]);
//                    }
//                }
//                @catch (NSException *exception) {
//                    NSLog(@"EXCEPTION: %@", exception);
//                }
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"%@ ALL KEYS: %@", @(self.allKeys.count), self.allKeys);
//                NSLog(@"%@ TOTAL ALL KEYS IN %@ : %@ ", @([self.object allPropertyKeyPath].count), ((NSObject *)self.object).class, [self.object allPropertyKeyPath]);
//            });
//        });
//    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    id value = [self.object valueForKey:keyPath];
//    NSLog(@"KEY PATH NOTIFY: %@ - %p", keyPath, value);
    
    NSMutableDictionary *keyInfo = [NSMutableDictionary dictionaryWithDictionary:self.allKeys[keyPath]];
    keyInfo[@"isObservable"] = @YES;
    [self.allKeys setObject:keyInfo forKey:keyPath];
    
//    [self.object removeObserver:self forKeyPath:keyPath];
}

@end
