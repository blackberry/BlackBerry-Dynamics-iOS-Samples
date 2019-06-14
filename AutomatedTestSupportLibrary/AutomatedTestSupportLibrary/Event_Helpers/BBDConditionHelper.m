/* Copyright (c) 2019 BlackBerry Ltd.
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

#import "BBDConditionHelper.h"
#import "XCTestCase+Expectations.h"
#import "BBDUITestUtilities.h"
#import "BBDUITestCaseRef.h"
#import "BBDPublicConstans.h"

static const NSTimeInterval NO_TIMEOUT = 0.f;

@implementation BBDConditionHelper

//Helper method to determine if a screen (Either GD screen or App UI screen) containing specified ResourceID is shown (with default timeout and default current app)
+ (BOOL)isScreenShown:(NSString *)accessID forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self isScreenShown: accessID timeout:NO_TIMEOUT forTestCaseRef:testCaseRef];
}

//Helper method to determine if a screen in the provided app (Either GD screen or App UI screen) containing specified ResourceID is shown waiting a certain timeout
+ (BOOL)isScreenShown:(NSString *)accessID timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    NSLog(@"%@ - accessId = %@, timeout = %f", NSStringFromSelector(_cmd), accessID, timeout);
    
    BOOL isSuccess = NO;
    
    isSuccess = [self isElementShownWithIdentifier:accessID
                                            ofType:XCUIElementTypeAny
                                           timeout:timeout
                                    forTestCaseRef:testCaseRef];
    
    return isSuccess;
}

//Helper method to determine if specific text is shown on screen
+ (BOOL)isTextShown:(NSString *)text forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self isTextShown:text timeout:NO_TIMEOUT forTestCaseRef:testCaseRef];
}

//Helper method to determine if specific text is shown on screen with default timeout
+ (BOOL)isTextShown:(NSString *)text timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    NSLog(@"%@ - text = %@, timeout = %f", NSStringFromSelector(_cmd), text, timeout);
    
    BOOL isSuccess = NO;
    
    isSuccess = [self isElementShownWithIdentifier:text
                                            ofType:XCUIElementTypeAny
                                           timeout:timeout
                                    forTestCaseRef:testCaseRef];
    
    return isSuccess;
}

+ (BOOL)isAlertShownWithAccessID:(NSString *)accessID
                         timeout:(NSTimeInterval)timeout
                  forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self isAlertShownWithStaticText:accessID
                                    timeout:timeout
                             forTestCaseRef:testCaseRef];
}

//works only with title of alert (does not find static text in alert message)
+ (BOOL)isAlertShownWithStaticText:(NSString *)staticText
                           timeout:(NSTimeInterval)timeout
                    forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    NSLog(
          @"%@ - staticText = %@, timeout = %f",
          NSStringFromSelector(_cmd),
          staticText,
          timeout
          );
    
    XCUIElement *alert = [BBDUITestUtilities findElementOfType:XCUIElementTypeAlert
                                               withIndentifier:staticText
                                                   inContainer:testCaseRef.application];
    
    if (alert.exists)
    {
        NSLog(@"Found alert with title: %@\nmessage: %@", [[alert.staticTexts elementBoundByIndex:0] label], [[alert.staticTexts elementBoundByIndex:1] label]);
        return YES;
    }
    
    if (timeout > 0)
    {
        NSLog(@"Target element is not on screen. Wait for appearance...");
        [testCaseRef.testCase waitForElementAppearance:alert
                                               timeout:timeout
                                     failTestOnTimeout:NO
                                               handler:nil];
        if (alert.exists)
        {
            NSLog(@"Found alert with title: %@\nmessage: %@", [[alert.staticTexts elementBoundByIndex:0] label], [[alert.staticTexts elementBoundByIndex:1] label]);
            return YES;
        }
    }
    
    NSLog(@"Alert not found");
    return NO;
}

+ (BOOL)isKeyboardElementHittable:(XCUIElement *)element
                   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL exists = element.exists;
    if (!exists)
    {
        return NO;
    }
    BOOL isHittable = element.hittable;
    if (!isHittable)
    {
        return NO;
    }
    else
    {
        CGRect elFrame = element.frame;
        CGRect appFrame = testCaseRef.application.frame;
        return elFrame.origin.x > 0 && elFrame.origin.y > 0 && elFrame.origin.y <= appFrame.size.height;
    }
}

+ (BOOL)isKeyboardShown:(BBDUITestCaseRef *)testCaseRef
{
    XCUIApplication *app = testCaseRef.application;

    XCUIElementQuery *hideButtons = [app.keyboards.buttons matchingIdentifier:BBDKeyboardHideButton];
    if (hideButtons.count > 0)
    {
        XCUIElement *hideButton = hideButtons.firstMatch;
        BOOL isHideHittable = [self isKeyboardElementHittable:hideButton forTestCaseRef:testCaseRef];
        if (isHideHittable)
        {
            return YES;
        }
    }
    
    XCUIElementQuery *dismissButtons = [app.keyboards.buttons matchingIdentifier:BBDKeyboardDismissButton];
    if (dismissButtons.count > 0)
    {
        XCUIElement *dismissButton = dismissButtons.firstMatch;
        BOOL isDismissHittable = [self isKeyboardElementHittable:dismissButton forTestCaseRef:testCaseRef];
        if (isDismissHittable)
        {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isElementShownWithIdentifier:(NSString *)identifier
                              ofType:(XCUIElementType)type
                             timeout:(NSTimeInterval)timeout
                      forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    NSLog(
          @"%@ - identifier = %@, type = %lu, timeout = %f",
          NSStringFromSelector(_cmd),
          identifier,
          (unsigned long)type,
          timeout
          );
    
    XCUIElement *targetUIObject = [BBDUITestUtilities findElementOfType:type
                                                       withIndentifier:identifier
                                                           inContainer:testCaseRef.application];

    if (targetUIObject.exists)
    {
        return YES;
    }
    
    if (timeout > 0)
    {
        NSLog(@"Target element is not on screen. Wait for appearance...");
        [testCaseRef.testCase waitForElementAppearance:targetUIObject
                                               timeout:timeout
                                     failTestOnTimeout:NO
                                               handler:nil];
    }
    
    return targetUIObject.exists;
}

@end
