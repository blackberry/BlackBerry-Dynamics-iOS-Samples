/* Copyright (c) 2020 BlackBerry Limited.
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

#import <Foundation/Foundation.h>
#import "LegacyActivationTypeUI.h"
#import "AbstractBBDUI.h"
#import "BBDUIAccessibilityIdentifiers.h"

@implementation LegacyActivationTypeUI

- (instancetype)initWithId:(NSString *)screenId
{
    self = [super initWithId:screenId];
    if (self)
    {
        _emailField = self.testCaseRef.application.textFields[BBDActivationEmailFieldID].firstMatch;
        _accessKeyField1 = self.testCaseRef.application.textFields[BBDAccessKeyField1ID].firstMatch;
        _accessKeyField2 = self.testCaseRef.application.textFields[BBDAccessKeyField2ID].firstMatch;
        _accessKeyField3 = self.testCaseRef.application.textFields[BBDAccessKeyField3ID].firstMatch;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithId:@""];
}
 
- (BOOL)isShown
{
    if (![self.testCaseRef.application waitForState:XCUIApplicationStateRunningForeground timeout:5])
    {
        NSLog(@"ActivationUI::Application was not detected in foreground in 5 seconds.");
        return NO;
    }
    
    return [_emailField exists]
    && [_accessKeyField1 exists]
    && [_accessKeyField2 exists]
    && [_accessKeyField3 exists];
}

@end
