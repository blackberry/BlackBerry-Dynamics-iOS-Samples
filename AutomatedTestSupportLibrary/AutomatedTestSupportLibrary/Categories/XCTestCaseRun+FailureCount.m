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

#import "XCTestCaseRun+FailureCount.h"

static NSString * const kFailureCountKey        = @"failureCount";
static NSString * const kInternalTestRunKey     = @"internalTestRun";

@implementation XCTestCaseRun (FailureCount)

- (id)internalTestRunObject
{
    return [self valueForKey:kInternalTestRunKey];
}

- (void)resetFailureCount
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(setFailureCount:)])
    {
        // for Xcode 11.4 and higher
        [self performSelector:@selector(setFailureCount:) withObject:0];
    }
#pragma clang diagnostic pop
    else
    {
        [[self internalTestRunObject] setValue:@0 forKey:kFailureCountKey];
    }
}

@end
