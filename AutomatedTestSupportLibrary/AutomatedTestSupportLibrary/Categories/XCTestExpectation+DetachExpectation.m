/*
 * (c) 2017 BlackBerry Limited. All rights reserved.
 *
 */

#import "XCTestExpectation+DetachExpectation.h"
#import <objc/runtime.h>

@implementation XCTestExpectation (DetachExpectation)

- (BOOL)isDetached {
    NSNumber *isDetached = objc_getAssociatedObject(self, @selector(isDetached));
    if (!isDetached) {
        isDetached = [NSNumber numberWithBool:NO];
    }
    return [isDetached boolValue];
}

- (void)setDetached:(BOOL)isDetached {
    objc_setAssociatedObject(self, @selector(isDetached), [NSNumber numberWithBool:isDetached], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
