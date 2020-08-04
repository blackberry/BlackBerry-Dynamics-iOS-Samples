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

#import "XCTestCase+Properties.h"
@import ObjectiveC.runtime;

static NSString * const kTestCaseRun               = @"testCaseRun";
static NSString * const kCurrentWaiterObjectKey    = @"currentWaiter";
static NSString * const kInternalImplementationKey = @"internalImplementation";
static NSString * const kExpectationsKey           = @"_expectations";
static NSString * const kShouldIgnoreSubsequentFailuresKey = @"shouldIgnoreSubsequentFailures";
static NSString * const kHasReportedFailuresToTestCaseRunKey = @"_hasReportedFailuresToTestCaseRun";

@implementation XCTestCase (Properties)

- (void)removeAllExpectations
{
    [self resetInternalExpectations];
    [self setExpectations:nil];
    [self resetWaiterObj];
}

- (NSMutableArray*)expectations
{    
    NSMutableArray *array = objc_getAssociatedObject(self, @selector(expectations));
    if (!array)
    {
        array = [NSMutableArray array];
        [self setExpectations:array];
    }
    return array;
}

- (void)setExpectations:(NSMutableArray*)expectations
{
    objc_setAssociatedObject(self, @selector(expectations), expectations, OBJC_ASSOCIATION_RETAIN);
}

- (XCTestCaseRun *)testCaseRun
{
    if ([self respondsToSelector:@selector(testRun)])
    {
        // for Xcode 11.4 and higher
        return [self performSelector:@selector(testRun)];
    }
    else
    {
        return [[self internalImpl] valueForKey:kTestCaseRun];
    }
}

- (BOOL)isSignaled
{
    NSNumber *isSignaled = objc_getAssociatedObject(self, @selector(isSignaled));
    if (!isSignaled)
    {
        isSignaled = [NSNumber numberWithBool:NO];
    }
    return [isSignaled boolValue];
}

- (void)setSignaled:(BOOL)isSignaled
{
    objc_setAssociatedObject(self, @selector(isSignaled), [NSNumber numberWithBool:isSignaled], OBJC_ASSOCIATION_RETAIN);
}

- (XCTWaiter *)currentWaiter
{
    return objc_getAssociatedObject(self, @selector(currentWaiter));
}

- (id)internalImpl
{
    return [self valueForKey:kInternalImplementationKey];
}

- (XCTWaiter *)getWaiterObj
{
    return [[self internalImpl] valueForKey:kCurrentWaiterObjectKey];
}

- (void)resetWaiterObj
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(internalImplementation)])
    {
        [[self internalImpl] setValue:nil forKey:kCurrentWaiterObjectKey];
    }
    else if ([self respondsToSelector:@selector(set_currentWaiter:)])
    {
        // for Xcode 11.4 and higher
        [self performSelector:@selector(set_currentWaiter:) withObject:nil];
    }
    else
    {
        // for Xcode 12 and higher
        [self setValue:nil forKey:kCurrentWaiterObjectKey];
    }
#pragma clang diagnostic pop
}

- (void)resetInternalExpectations
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(internalImplementation)]) {
        [[self internalImpl] performSelector:@selector(resetExpectations)];
    }
    else if ([self respondsToSelector:@selector(_resetExpectations)])
    {
        // for Xcode 11.4 and higher
        [self performSelector:@selector(_resetExpectations)];
        [self setValue:@NO forKey:kShouldIgnoreSubsequentFailuresKey];
    }
    else
    {
        // for Xcode 12 and higher
        [[self valueForKey:kExpectationsKey] removeAllObjects];
        [self setValue:@NO forKey:kHasReportedFailuresToTestCaseRunKey];
    }
#pragma clang diagnostic pop
}

@end
