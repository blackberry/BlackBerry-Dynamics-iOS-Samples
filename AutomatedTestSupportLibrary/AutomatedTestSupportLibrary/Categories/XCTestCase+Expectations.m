/*
 * (c) 2017 BlackBerry Limited. All rights reserved.
 *
 */

#import "XCTestCase+Expectations.h"
#import "XCTestExpectation+DetachExpectation.h"

@import ObjectiveC.runtime;

@implementation XCTestCase(Expectations)

#pragma mark - Public Methods

- (void)waitForElementAppearance:(nonnull XCUIElement *)targetUIObject
                          timeout:(NSTimeInterval)timeout
                failTestOnTimeout:(BOOL)failTestOnTimeout
                          handler:(nullable XCWaitCompletionHandler)handler
{
    [self waitForElement:targetUIObject
      elementShouldExist:YES
                 timeout:timeout
       failTestOnTimeout:failTestOnTimeout
                 handler:handler];
}

- (void)waitForElementDisappearance:(nonnull XCUIElement *)targetUIObject
                             timeout:(NSTimeInterval)timeout
                   failTestOnTimeout:(BOOL)failTestOnTimeout
                             handler:(nullable XCWaitCompletionHandler)handler
{
    [self waitForElement:targetUIObject
      elementShouldExist:NO
                 timeout:timeout
       failTestOnTimeout:failTestOnTimeout
                 handler:handler];
}

- (void)waitForElement:(nonnull XCUIElement *)targetUIObject
     elementShouldExist:(BOOL)exists
                timeout:(NSTimeInterval)timeout
      failTestOnTimeout:(BOOL)failTestOnTimeout
                handler:(nullable XCWaitCompletionHandler)handler
{
    NSAssert(targetUIObject, @"Method expects non-null XCUIElement for expectation evaluation");
    
    if (targetUIObject.exists == exists)
    {
        // element exist, no need to wait
        return;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exists == %d", exists];
    
    NSLog(@"Creating expectation using predicate: %@", predicate.description);
    // perform async loop, waiting for the object specified to appear
    XCTestExpectation *te = [self expectationForPredicate:predicate
                                      evaluatedWithObject:targetUIObject
                                                  handler:nil];
    
    [self waitForExpectation:te
                 withTimeout:timeout
           failTestOnTimeout:failTestOnTimeout
                     handler:handler];
}

- (void)waitForElementGetHittable:(nonnull XCUIElement *)targetUIObject
                          timeout:(NSTimeInterval)timeout
                failTestOnTimeout:(BOOL)failTestOnTimeout
                          handler:(nullable XCWaitCompletionHandler)handler {

    NSAssert(targetUIObject, @"Method expects non-null XCUIElement for expectation evaluation");

    if (targetUIObject.hittable)
    {
        // element hittable, no need to wait
        return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hittable == %d", YES];
    NSLog(@"Creating expectation using predicate: %@", predicate.description);

    XCTestExpectation *expectation = [self expectationForPredicate:predicate evaluatedWithObject:targetUIObject handler:nil];
    [self waitForExpectation:expectation withTimeout:timeout failTestOnTimeout:failTestOnTimeout handler:handler];
}

- (void)waitForExpectation:(XCTestExpectation *)expectation
                withTimeout:(NSTimeInterval)timeout
          failTestOnTimeout:(BOOL)failTestOnTimeout
                    handler:(nullable XCWaitCompletionHandler)handler
{
    NSLog(@"%@ - timeout = %f, failTestOnTimeout = %@", NSStringFromSelector(_cmd), timeout, failTestOnTimeout ? @"YES" : @"NO");
    
    NSLog(@"Adding expectation to queue...");
    [[self expectations] addObject:expectation];
    
    if (!failTestOnTimeout)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if ([[weakSelf expectations] containsObject:expectation])
            {
                NSLog(@"Expectation fulfilled manualy to avoid test failing");
                [expectation fulfill];
                [[weakSelf expectations] removeObject:expectation];
            }
        });
    }
    // wait no longer than 'timeout + 1' seconds for the request to go through
    __weak typeof(self) weakSelf = self;
    [self waitForExpectationsWithTimeout:timeout+1 handler:^(NSError *error) {
        
        // remove expectation only if its inside expectations array
        [[weakSelf expectations] removeObject:expectation];
        
        if (error) {
            NSLog(@"expectation failed");
        }
        
        if (handler)
            handler(error);
    }];
}

- (nonnull XCTestExpectation *)detachedExpectationForPredicate:(nonnull NSPredicate *)predicate
                                           evaluatedWithObject:(nonnull id)object handler:(nullable XCPredicateExpectationHandler)handler
{
    XCTestExpectation *detachExpectation = [self expectationForPredicate:predicate
                                                     evaluatedWithObject:object
                                                                 handler:^BOOL
    {
        if (handler) {
            [self setSignaled:handler()];
        } else {
            [self setSignaled:YES];
        }
        return [self isSignaled];
    }];
    [detachExpectation setDetached:YES];
    return  detachExpectation;
}

- (void)waitForAnyDetachedExpectation:(nonnull NSArray<XCTestExpectation*> *)expectations
                          withTimeout:(NSTimeInterval)timeout
                    failTestOnTimeout:(BOOL)failTestOnTimeout
                              handler:(nullable XCWaitCompletionHandler)handler; {
    NSLog(@"%@ - timeout = %f, failTestOnTimeout = %@", NSStringFromSelector(_cmd), timeout, failTestOnTimeout ? @"YES" : @"NO");
    NSLog(@"Adding expectations to queue...");
    
    [self setSignaled:NO];
    
    for (XCTestExpectation *exp in expectations) {
        if (![exp isDetached]) {
            NSLog(@"Expected detached expectation");
            if (handler) {
                //TODO: create page with errors we can pass to end user or end app
                //here is fake error
                handler([NSError errorWithDomain:@"BBDTestCaseErrorDomain" code:-1 userInfo:nil]);
                return;
            }
        }
    }
    
    [[self expectations] addObject:expectations];
    
    if (!failTestOnTimeout)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf setSignaled:YES];
            NSLog(@"Expectations fulfilled manualy to avoid test failing");
            [[weakSelf expectations] removeObjectsInArray:expectations];
        });
    }
    
    //code below might be separated in method to make it
    //be more suitable to waitForExpectationsWithTimeout signature
    const double sleepTime = 0.010; //10 miliseconds
    for ( int t = (int) (timeout+1 / sleepTime); ![self isSignaled] && t >= 0; --t )
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:sleepTime]];
    }
    
    [[self expectations] removeObjectsInArray:expectations];
    
    if (![self isSignaled]) {
        NSLog(@"expectation failed");
    }
    
    if (handler) {
        //TODO: requires custome error
        handler([NSError errorWithDomain:@"BBDTestCaseErrorDomain" code:-1 userInfo:nil]);
    }
}

#pragma mark - Adding runtime property

- (NSMutableArray*)expectations {
    
    NSMutableArray *array = objc_getAssociatedObject(self, @selector(expectations));
    
    if (!array)
    {
        array = [NSMutableArray array];
        [self setExpectations:array];
    }
    
    return array;
}

- (void)setExpectations: (NSMutableArray*)expectations {
    objc_setAssociatedObject(self, @selector(expectations), expectations, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isSignaled {
    NSNumber *isSignaled = objc_getAssociatedObject(self, @selector(isSignaled));
    if (!isSignaled) {
        isSignaled = [NSNumber numberWithBool:NO];
    }
    return [isSignaled boolValue];
}

- (void)setSignaled:(BOOL)isSignaled {
    objc_setAssociatedObject(self, @selector(isSignaled), [NSNumber numberWithBool:isSignaled], OBJC_ASSOCIATION_RETAIN);
}


@end
