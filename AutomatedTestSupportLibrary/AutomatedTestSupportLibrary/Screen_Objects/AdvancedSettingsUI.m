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
#import "AdvancedSettingsUI.h"
#import "BBDInputEventHelper.h"
#import "TimeoutConstants.h"
#import "XCTestCase+Expectations.h"
#import "BBDUIAccessibilityIdentifiers.h"

@implementation AdvancedSettingsUI

- (instancetype)init
{
    self = [self initWithId:BBDAdvancedSettingsUI];
    if (self) {
        _activationURLField = self.testCaseRef.application.textFields[BBDActivationURLFieldID].firstMatch;
    }
    return self;
}

- (BOOL)enterActivationURL:(NSString *)activationURL
{
    if (![self isShown]){
        NSLog(@"AdvancedSettings UI is not shown to enter activation password.\n%@", [self.testCaseRef.application debugDescription]);
        return NO;
    }
    return [BBDInputEventHelper typeInElement:self.activationURLField
                                         text:activationURL
                                      timeout:TIMEOUT_5
                               forTestCaseRef:self.testCaseRef];
}

- (BOOL)startActivationWithEmail:(NSString *)email activationPassword:(NSString *)activationPassword activationURL:(NSString *)activationURL
{
    if (![self isShown]) {
        NSLog(@"AdvancedSettingsUI UI is not shown to start activation.\n%@", [self.testCaseRef.application debugDescription]);
        return NO;
    }
    
   if (![self enterEmail:email])
    {
        NSLog(@"Failed to enter email.");
        return NO;
    }
    if (![self enterActivationPassword:activationPassword])
    {
        NSLog(@"Failed to enter activation password.");
        return NO;
    }
    
    if (![self enterActivationURL:activationURL])
    {
        NSLog(@"Failed to enter activation password.");
        return NO;
    }
    [self.testCaseRef.application.buttons[@"Go"] tap];
    
    [self.testCaseRef.testCase waitForElementDisappearance:self.uiElement
                                                   timeout:TIMEOUT_5
                                         failTestOnTimeout:NO
                                                   handler:nil];
    
    if ([self isShown])
    {
        NSLog(@"Activation UI has not dissappeared.");
        return NO;
    }

    return YES;
}

- (BOOL)isShown {
    if (![self.testCaseRef.application waitForState:XCUIApplicationStateRunningForeground timeout:5])
    {
        NSLog(@"AdvancedSettingsUI::Application was not detected in foreground in 5 seconds.");
        return NO;
    }
    
    return [self.emailField exists] && [self.activationPasswordField exists] && [_activationURLField exists];
}

@end
