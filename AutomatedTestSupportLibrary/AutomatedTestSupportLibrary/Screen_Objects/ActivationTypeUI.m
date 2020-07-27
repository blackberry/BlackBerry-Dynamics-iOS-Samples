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
#import "ActivationTypeUI.h"
#import "AbstractBBDUI.h"
#import "BBDUIAccessibilityIdentifiers.h"
#import "BBDInputEventHelper.h"
#import "XCTestCase+Expectations.h"
#import "TimeoutConstants.h"

@implementation ActivationTypeUI

- (instancetype)initWithId:(NSString *)screenId
{
    self = [super initWithId:screenId];
    if (self)
    {
        _emailField = self.testCaseRef.application.textFields[BBDActivationEmailFieldID].firstMatch;
        _activationPasswordField = self.testCaseRef.application.textFields[BBDAccessKeyField1ID].firstMatch;
        _showPasswordButton = self.testCaseRef.application.buttons[SHOW_PASSWORD_ICON_ID];
        _bottomInfoButton = self.testCaseRef.application.buttons[BBDBottomInfoButtonID];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithId:@""];
}

- (BOOL)isShown {
    if (![self.testCaseRef.application waitForState:XCUIApplicationStateRunningForeground timeout:5])
    {
        NSLog(@"ActivationUI::Application was not detected in foreground in 5 seconds.");
        return NO;
    }
    
    return [_emailField exists] && [_activationPasswordField exists];
}

- (BOOL)enterEmail:(NSString *)email
{
    return [self enterEmail:email checkIfUIShown:YES];
}

- (BOOL)enterEmail:(NSString *)email checkIfUIShown:(BOOL)checkIfUIShown
{
    if (checkIfUIShown && ![self isShown])
    {
        NSLog(@"Activation UI is not shown to enter email.\n%@", [self.testCaseRef.application debugDescription]);
        return NO;
    }
    
    return [BBDInputEventHelper typeInElement:self.emailField
                                         text:email
                                      timeout:TIMEOUT_5
                               forTestCaseRef:self.testCaseRef];
}

- (BOOL)enterActivationPassword:(NSString *)activationPassword
{
    return [self enterActivationPassword:activationPassword checkIfUIShown:YES];
}

- (BOOL)enterActivationPassword:(NSString *)activationPassword checkIfUIShown:(BOOL)checkIfUIShown
{
    if (checkIfUIShown && ![self isShown])
    {
        NSLog(@"Activation UI is not shown to enter activation password.\n%@", [self.testCaseRef.application debugDescription]);
        return NO;
    }
    
    return [BBDInputEventHelper typeInElement:self.activationPasswordField
                                         text:activationPassword
                                      timeout:TIMEOUT_5
                               forTestCaseRef:self.testCaseRef];
}

- (BOOL)showPassword
{
    if (![self.showPasswordButton exists]) {
        NSLog(@"Can't click 'Show password'. The button does not exist.");
        return NO;
    }
    [self.showPasswordButton tap];
    return YES;
}

- (BOOL)clickBottomInfoButton
{
    if (![self.bottomInfoButton exists]) {
        NSLog(@"Can't click bottom info button. The button does not exist.");
        return NO;
    }
    [self.bottomInfoButton tap];
    return YES;
}

- (BOOL)startActivationWithEmail:(NSString *)email activationPassword:(NSString *)activationPassword
{
    if (![self isShown])
    {
        NSLog(@"Activation UI is not shown to start activation.\n%@", [self.testCaseRef.application debugDescription]);
        return NO;
    }
    if (![self enterEmail:email checkIfUIShown:NO])
    {
        NSLog(@"Failed to enter email.");
        return NO;
    }
    if (![self enterActivationPassword:activationPassword checkIfUIShown:NO])
    {
        NSLog(@"Failed to enter activation password.");
    }
    
    // Handle a tip on the keyboard swipe option
    if (@available(iOS 13, *))
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat: @"value CONTAINS[c] 'Speed up'"];
        
        XCUIElement* container = [self.testCaseRef.application.otherElements containingPredicate:predicate].firstMatch;
        
        if ([container exists])
        {
            [container.buttons[@"Continue"].firstMatch tap];
        }
    }
    if ([self.testCaseRef.application.buttons[@"Go"] exists])
    {
        [self.testCaseRef.application.buttons[@"Go"] tap];
    }
    else
    {
        [self.testCaseRef.application.buttons[@"go"] tap];
    }
    
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

- (BOOL)clearFields
{
    return [BBDInputEventHelper clearText:self.emailField forTestCaseRef:self.testCaseRef] && [BBDInputEventHelper clearText:self.activationPasswordField forTestCaseRef:self.testCaseRef];
}

@end

