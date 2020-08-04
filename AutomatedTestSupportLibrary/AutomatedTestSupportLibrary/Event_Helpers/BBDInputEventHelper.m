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

#import "BBDInputEventHelper.h"
#import "XCTestCase+Expectations.h"
#import "BBDUITestUtilities.h"
#import "BBDUITestCaseRef.h"
#import "BBDPublicConstans.h"
#import "XCUIApplication+State.h"
#import "BBDConditionHelper.h"

static const NSTimeInterval NO_TIMEOUT = 0.f;
static const NSTimeInterval TIMEOUT_5 = 5.f;
static const NSTimeInterval TIMEOUT_1 = 1.f;
static const NSTimeInterval PRESS_DURATION = 2.f;

static const CGFloat FOCUS_COORD_OFFSET = 0.4f;
static const CGFloat LONG_PRESS_COORD_OFFSET = 0.5f;

@implementation BBDInputEventHelper

#pragma mark - Public Methods

+ (BOOL)enterText:(NSString *)text
     inViewOfType:(XCUIElementType)type
     withAccessID:(NSString *)accessID
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self enterText:text
              inViewOfType:type
              withAccessID:accessID
                   timeout:NO_TIMEOUT
            forTestCaseRef:testCaseRef];
}

//Helper method to enter text into screen element with specific timeout
+ (BOOL)enterText:(NSString *)text
     inViewOfType:(XCUIElementType)type
     withAccessID:(NSString *)accessID
          timeout:(NSTimeInterval)timeout
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    WAIT_FOR_TESTCASE_USABLE_STATE_WITH_TIMEOUT
    
    NSLog(
          @"%@ - text = %@, accessID = %@, type = %lu, timeout = %f",
          NSStringFromSelector(_cmd),
          text,
          accessID,
          (unsigned long)type,
          timeout
          );
    
    XCUIElement *element = testCaseRef.application.textFields[accessID].firstMatch;
    
    if (![self isElementAppeared:element withTimeout:10.f])
    {
        return NO;
    }
    
    BOOL success = [self typeInElement:element text:text timeout:timeout forTestCaseRef:testCaseRef];
    
    return success;
}

+ (BOOL)isElementAppeared:(XCUIElement *)element withTimeout:(NSTimeInterval)timeout
{
    NSLog(@"start searching for element with accessibility identifier - %@", element.identifier);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exists == true"];
    XCTNSPredicateExpectation *expectation = [[XCTNSPredicateExpectation alloc] initWithPredicate:predicate object:element];
    
    XCTWaiterResult res = [[XCTWaiter new] waitForExpectations:@[expectation] timeout:timeout];
    
    BOOL success = res == XCTWaiterResultCompleted;
    
    NSLog(@"element with accessibility identifier - %@, XCTWaiterResult - %ld", element.identifier, (long)res);
    NSLog(@"element with accessibility identifier - %@ is appeared on screen - %@", element.identifier, success == YES ? @"yes" : @"no");
    return success;
}

+ (BOOL)enterText:(NSString *)text
     inViewOfType:(XCUIElementType)type
   containingText:(NSString *)staticText
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self enterText:text inViewOfType:type containingText:text timeout:NO_TIMEOUT forTestCaseRef:testCaseRef];
}

+ (BOOL)enterText:(NSString *)text
     inViewOfType:(XCUIElementType)type
   containingText:(NSString *)staticText
          timeout:(NSTimeInterval)timeout
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    WAIT_FOR_TESTCASE_USABLE_STATE_WITH_TIMEOUT
    
    NSLog(
          @"%@ - text = %@, staticText = %@, type = %lu, timeout = %f",
          NSStringFromSelector(_cmd),
          text,
          staticText,
          (unsigned long)type,
          timeout
          );
    
    BOOL success = NO;
    
    XCUIElement *element = [BBDUITestUtilities findElementOfType:type
                                                withIndentifier:staticText
                                                    inContainer:testCaseRef.application];
    
    success = [self typeInElement:element text:text timeout:timeout forTestCaseRef:testCaseRef];
    
    return success;
}


+ (BOOL)clearTextAndPaste:(NSString *)text
                  element:(XCUIElement *)el
           forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isCleaned = [self clearText:el forTestCaseRef:testCaseRef];
    if (!isCleaned)
    {
        return NO;
    }
    return [self tapAndTypeText:text forElement:el];
}

+ (BOOL)clearText:(XCUIElement *)el
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    WAIT_FOR_TESTCASE_USABLE_STATE
    
    if (![self canTypeInElement:el])
    {
        NSLog(@"Can not clear text - element can not be tapped");
        return NO;
    }
    switch (el.elementType)
    {
        case XCUIElementTypeSearchField:
        case XCUIElementTypeTextField:
        case XCUIElementTypeSecureTextField:
        case XCUIElementTypeWebView:
        case XCUIElementTypeTextView:
        {
            return [self clearTextInContainer:el forTestCaseRef:testCaseRef];
        }
        default:
        {
            break;
        }
    }
    return NO;
}

+ (NSString *)stringForTextCleaning:(NSString *)textValue;
{
    NSMutableString *resString = [NSMutableString new];
    for (int i = 0; i < textValue.length; i++)
    {
        [resString appendString:XCUIKeyboardKeyDelete];
    }
    return resString;
}

+ (BOOL)typeInElement:(XCUIElement *)element
                 text:(NSString *)text
              timeout:(NSTimeInterval)timeout
       forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    if (element.exists)
    {
        return [self tapAndTypeText:text forElement:element];
    }
    
    if (timeout > 0)
    {
        NSLog(@"Target element is not on screen. Wait for appearance...");
        [testCaseRef.testCase waitForElementAppearance:element
                                               timeout:timeout
                                     failTestOnTimeout:NO
                                               handler:nil];
        if (element.exists)
        {
            return [self tapAndTypeText:text forElement:element];
        }
    }
    NSLog(@"Typing in element failed!\nHierarchy: %@", [testCaseRef.application  debugDescription]);
    return NO;
}

#pragma mark - Utilities

+ (BOOL)tapAndTypeText:(NSString *)text forElement:(XCUIElement *) element
{
    if ([self canTypeInElement:element] && element.exists) {
        [element tap];
        [element typeText:text];
        return YES;
    }
    return NO;
}

+(BOOL)canTypeInElement:(XCUIElement *)element
{
    switch (element.elementType) {
        case XCUIElementTypeSearchField:
        case XCUIElementTypeTextField:
        case XCUIElementTypeSecureTextField:
        case XCUIElementTypeTextView:
        case XCUIElementTypeWebView:
            return YES;
            break;
        default:
            return NO;
            break;
    }
}

+ (BOOL)clearTextInContainer:(XCUIElement *)container forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    // [GD-46641] Since Xcode 11 the 'value' property of the XCUIelement is always nil
    // That is why we anyway should firstly clear TextField before entering the text.
    [self bringContainerToFocus:container forTestCaseRef:testCaseRef];
    XCUIElement *selectAllButton = testCaseRef.application.menuItems[BBDTextMenuItemSelectAll].firstMatch;
    if (!selectAllButton.exists) {
        [[container coordinateWithNormalizedOffset:CGVectorMake(LONG_PRESS_COORD_OFFSET, LONG_PRESS_COORD_OFFSET)] pressForDuration:PRESS_DURATION];
        [testCaseRef.testCase waitForElementAppearance:selectAllButton timeout:TIMEOUT_1 failTestOnTimeout:NO handler:nil];
    }
    
    if (selectAllButton.exists) {
        // In this case the text field isn't empty and we need to clear it
        [selectAllButton tap];
        [testCaseRef.testCase waitForElementDisappearance:selectAllButton timeout:TIMEOUT_1 failTestOnTimeout:NO handler:nil];
        [container typeText:XCUIKeyboardKeyDelete];
    } else {
        [container typeText:XCUIKeyboardKeyDelete];
    }
    return !selectAllButton.exists;
}

+ (void)enterLongText:(NSString *)string
              element:(XCUIElement *)el
{
    // If the text is being typed for too long(more then 20 seconds), Apple may give an error.
    // This method is intented to type long string by typing each 200 symbols.
    int kTypeLength = 200;
    for (int i = 0; i < string.length; i+=kTypeLength)
    {
        NSUInteger typeNum = string.length - i > kTypeLength ? kTypeLength : string.length - i;
        NSRange typeRange = NSMakeRange(i, typeNum);
        [el typeText:[string substringWithRange:typeRange]];
    }
}

// Before the cleaning a text the TextContainer should be in a focus
// Single tap doesn't work properly for changing a focus between the
// TextContainers (BBDActivationUI is an example), so double tap is used instead
+ (void)bringContainerToFocus:(XCUIElement *)container forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    XCUIElement *keyBoard = testCaseRef.application.keyboards.firstMatch;
    [[container coordinateWithNormalizedOffset:CGVectorMake(FOCUS_COORD_OFFSET, FOCUS_COORD_OFFSET)] doubleTap];
    [testCaseRef.testCase waitForElementAppearance:keyBoard timeout:PRESS_DURATION failTestOnTimeout:NO handler:nil];
}

@end

