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

#import "BBDInputEventHelper.h"
#import "XCTestCase+Expectations.h"
#import "BBDUITestUtilities.h"
#import "BBDUITestCaseRef.h"
#import "BBDPublicConstans.h"

static const NSTimeInterval NO_TIMEOUT = 0.f;
static const NSTimeInterval TIMEOUT_5 = 5.f;

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
    NSLog(
          @"%@ - text = %@, accessID = %@, type = %lu, timeout = %f",
          NSStringFromSelector(_cmd),
          text,
          accessID,
          (unsigned long)type,
          timeout
          );
    
    BOOL success = NO;
    
    XCUIElement *element = [BBDUITestUtilities findElementOfType:type
                                                withIndentifier:accessID
                                                    inContainer:testCaseRef.application];
    
    success = [self typeInElement:element text:text timeout:timeout forTestCaseRef:testCaseRef];
    
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
    if ([self isTextEmpty:el])
    {
        return YES;
    }
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
        {
            return [self clearTextField:el forTestCaseRef:testCaseRef];
        }
            break;
        case XCUIElementTypeTextView:
        {
            return [self clearTextView:el forTestCaseRef:testCaseRef];
        }
            break;
        default:
            break;
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

#pragma mark - Utilities

+ (BOOL)isTextEmpty:(XCUIElement *)el
{
    NSString *value = el.value;
    if (!value || [value isEqualToString:@""])
    {
        return YES;
    }
    
    return NO;
}

+ (void)waitForTextClearing:(XCUIElement *)element
             forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(value == %@) OR (value == %@)", nil, @""];
    
    XCTestExpectation *te = [testCaseRef.testCase expectationForPredicate:predicate
                                                      evaluatedWithObject:element
                                                                  handler:nil];
    
    [testCaseRef.testCase waitForExpectation:te
                                 withTimeout:TIMEOUT_5
                           failTestOnTimeout:NO
                                     handler:nil];
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

+ (BOOL)clearTextView:(XCUIElement *)textView
       forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    CGVector textFieldVector = CGVectorMake(20, 15);
    XCUICoordinate *p1 = [[textView coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:textFieldVector];
    [p1 pressForDuration:4];
    
    XCUIElement *selectAllEl = testCaseRef.application.menuItems[BBDTextMenuItemSelectAll];
    [testCaseRef.testCase waitForElementAppearance:selectAllEl timeout:TIMEOUT_5 failTestOnTimeout:NO handler:nil];
    if (!selectAllEl.exists)
    {
        NSLog(@"Unable to clear text in text view - select all option has not appeared");
        return NO;
    }
    
    [selectAllEl tap];
    
    XCUIElement *cutEl = testCaseRef.application.menuItems[BBDTextMenuItemCut];
    [testCaseRef.testCase waitForElementAppearance:cutEl timeout:TIMEOUT_5 failTestOnTimeout:NO handler:nil];
    if (!cutEl.exists)
    {
        NSLog(@"Unable to clear text in text view - cut option has not appeared");
        return NO;
    }
    
    [cutEl tap];
    
    [testCaseRef.testCase waitForElementDisappearance:cutEl timeout:TIMEOUT_5 failTestOnTimeout:NO handler:nil];
    
    [self waitForTextClearing:textView forTestCaseRef:testCaseRef];
    
    return [self isTextEmpty:textView];
}

+ (BOOL)clearTextField:(XCUIElement *)elText
        forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    [elText tap];
    
    NSString *value = (NSString *)elText.value;
    
    NSString *stringForClear = [self stringForTextCleaning:value];
    
    [self enterLongText:stringForClear element:elText];
    
    // Sometimes it may happen that cursor is put in incorrect place after tap action.
    // Then we may try another approach with coordinate.
    // We tap at the right bottom corner of text field.
    // But text field should be focused to make it work,
    // so the previous approach is also needed.
    
    if (![self isTextEmpty:elText])
    {
        XCUICoordinate *coordinate = [elText coordinateWithNormalizedOffset:CGVectorMake(0.9, 0.9)];
        [coordinate tap];
        
        [self enterLongText:stringForClear element:elText];
    }
    
    [self waitForTextClearing:elText forTestCaseRef:testCaseRef];
    
    return [self isTextEmpty:elText];
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

@end

