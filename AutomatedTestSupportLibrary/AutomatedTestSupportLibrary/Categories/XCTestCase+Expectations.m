/* Copyright (c) 2017 - 2020 BlackBerry Limited.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
*/

#import "XCUIApplication+State.h"
#import "XCTestCase+Properties.h"
#import "BBDExpectationsHandler.h"
#import "XCTestCase+Expectations.h"
#import "XCTestCaseRun+FailureCount.h"
#import "XCTestExpectation+DetachExpectation.h"


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
    CHECK_FOR_APPLICATION_USABLE_STATE
    
    NSAssert(targetUIObject, @"Method expects non-null XCUIElement for expectation evaluation");
    
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
                          handler:(nullable XCWaitCompletionHandler)handler
{
    WAIT_FOR_APPLICATION_USABLE_STATE
    
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
    [BBDExpectationsHandler addExpectation:expectation forTestCase:self];
    
    if (!failTestOnTimeout)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [BBDExpectationsHandler fullFillExpectation:expectation forTestCase:weakSelf];
        });
    }
    // wait no longer than 'timeout + 1' seconds for the request to go through
    __weak typeof(self) weakSelf = self;
    
    @try {
        [self waitForExpectationsWithTimeout:timeout+1 handler:^(NSError *error) {
            [BBDExpectationsHandler removeExpectation:expectation forTestCase:weakSelf];
            if (error)
            {
                NSLog(@"Expectation failed - %@", error.debugDescription);
            }
            if (handler)
            {
              handler(error);
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"XCTestCase waitForExpectationsWithTimeout exception - %@", exception);
        GDUIApplication *application = [[BBDAutomatedTestSupport sharedInstance] getCurrentSetupApplication];
        if ([application hasUsableState])
        {
            [BBDExpectationsHandler clearExpectationsForTestCase:weakSelf];
            [[weakSelf testCaseRun] resetFailureCount];
        }
        else
        {
            @throw exception;
        }
    }
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
    
    [BBDExpectationsHandler addExpectations:expectations forTestCase:self];
    
    if (!failTestOnTimeout)
    {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf setSignaled:YES];
            NSLog(@"Expectations fulfilled manualy to avoid test failing");
            [BBDExpectationsHandler removeExpectations:expectations forTestCase:weakSelf];
        });
    }
    
    //code below might be separated in method to make it
    //be more suitable to waitForExpectationsWithTimeout signature
    const double sleepTime = 0.010; //10 miliseconds
    for ( int t = (int) (timeout+1 / sleepTime); ![self isSignaled] && t >= 0; --t )
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:sleepTime]];
    }
    
    [BBDExpectationsHandler removeExpectations:expectations forTestCase:self];
    
    if (![self isSignaled]) {
        NSLog(@"expectation failed");
    }
    
    if (handler) {
        //TODO: requires custome error
        handler([NSError errorWithDomain:@"BBDTestCaseErrorDomain" code:-1 userInfo:nil]);
    }
}

@end
