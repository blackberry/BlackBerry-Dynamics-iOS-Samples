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

#import "GDUIApplication.h"
#import "BBDTouchEventHelper.h"
#import "BBDUITestUtilities.h"
#import "XCTestCase+Expectations.h"
#import "BBDUITestCaseRef.h"
#import "BBDConditionHelper.h"
#import "XCUIApplication+State.h"

static const NSTimeInterval NO_TIMEOUT = 0.f;

@implementation BBDTouchEventHelper

#pragma mark - Public Methods

//Helper method which presses HOME
+ (void)pressHome
{
    [[XCUIDevice sharedDevice] pressButton:XCUIDeviceButtonHome];
}

//Helper method to click on specific item, specified by resourceID, with a default timeout
+ (BOOL)tapOnItemOfType:(XCUIElementType)type withAccessID:(NSString *)accessID forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self tapOnItemOfType:type
                    withAccessID:accessID
                         timeout:NO_TIMEOUT
                  forTestCaseRef:testCaseRef];
}

+ (BOOL)tapOnItemOfType:(XCUIElementType)type withAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    WAIT_FOR_TESTCASE_USABLE_STATE_WITH_TIMEOUT
    
    NSLog(
          @"%@ - type = %lu, accessID = %@, type = %f",
          NSStringFromSelector(_cmd),
          (unsigned long)type,
          accessID,
          timeout
          );
    
    XCUIElement *element = [BBDUITestUtilities findElementOfType:type
                                                withIndentifier:accessID
                                                    inContainer:testCaseRef.application];
    NSLog(
          @"Button found");
    BOOL tapped = [self tapOnElement:element
                      forTestCaseRef:testCaseRef
                             timeout:timeout];
    NSLog(
          @"Attempt to tap on button");
    if (!tapped && testCaseRef.potentialDelegateApplication)
    {
        NSLog(
              @"Attempt to tap on delegate app");
        
        element = [BBDUITestUtilities findElementOfType:type
                                        withIndentifier:accessID
                                            inContainer:testCaseRef.potentialDelegateApplication];
        
        tapped = [self tapOnElement:element
                     forTestCaseRef:testCaseRef
                            timeout:timeout];
    }
    
    return tapped;
}

+ (BOOL)tapOnItemOfType:(XCUIElementType)type containingText:(NSString *)text forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self tapOnItemOfType:type
                  containingText:text
                         timeout:NO_TIMEOUT
                  forTestCaseRef:testCaseRef];
}

+ (BOOL)tapOnItemOfType:(XCUIElementType)type containingText:(NSString *)text timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    WAIT_FOR_TESTCASE_USABLE_STATE_WITH_TIMEOUT
    
    NSLog(
          @"%@ - type = %lu, accessID = %@, type = %f",
          NSStringFromSelector(_cmd),
          (unsigned long)type,
          text,
          timeout
          );
    
    XCUIElement *element = [BBDUITestUtilities findElementOfType:type
                                                withIndentifier:text
                                                    inContainer:testCaseRef.application];
    
    return [self tapOnElement:element
               forTestCaseRef:testCaseRef
                      timeout:timeout];
}

+ (BOOL)tapOnRowWithStaticText:(NSString *)staticText forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self tapOnRowWithStaticText:staticText
                                timeout:NO_TIMEOUT
                         forTestCaseRef:testCaseRef];
}

+ (BOOL)tapOnRowWithStaticText:(NSString *)staticText timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    WAIT_FOR_TESTCASE_USABLE_STATE_WITH_TIMEOUT
    
    NSLog(
          @"%@, accessID = %@, type = %f",
          NSStringFromSelector(_cmd),
          staticText,
          timeout
          );
    
    XCUIElement *element = [BBDUITestUtilities findRowWithStaticText:staticText
                                                         inContainer:testCaseRef.application];
    
    
    return [self tapOnElement:element
               forTestCaseRef:testCaseRef
                      timeout:timeout];
}

+ (BOOL)tapOnRowWithAccessID:(NSString *)accessID forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self tapOnRowWithAccessID:accessID
                              timeout:NO_TIMEOUT
                       forTestCaseRef:testCaseRef];
}

+ (BOOL)tapOnRowWithAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    WAIT_FOR_TESTCASE_USABLE_STATE_WITH_TIMEOUT
    
    NSLog(
          @"%@, accessID = %@, type = %f",
          NSStringFromSelector(_cmd),
          accessID,
          timeout
          );
    
    XCUIElement *element = [BBDUITestUtilities findRowWithAccessID:accessID
                                                       inContainer:testCaseRef.application];
    
    
    return [self tapOnElement:element
               forTestCaseRef:testCaseRef
                      timeout:timeout];
}

+ (BOOL)tapOnRowByIndex:(NSInteger)indexRow forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self tapOnRowByIndex:indexRow
                         timeout:NO_TIMEOUT
                  forTestCaseRef:testCaseRef];
}

+ (BOOL)tapOnRowByIndex:(NSInteger)indexRow timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    WAIT_FOR_TESTCASE_USABLE_STATE_WITH_TIMEOUT
    
    NSLog(
          @"%@ - type = %lu, type = %f",
          NSStringFromSelector(_cmd),
          (unsigned long)index,
          timeout
          );
    
    XCUIElement *element = [BBDUITestUtilities findRowByIndex:indexRow
                                                  inContainer:testCaseRef.application];
    
    return [self tapOnElement:element
               forTestCaseRef:testCaseRef
                      timeout:timeout];
    
}

+ (BOOL)scrollContainerWithAccessID:(NSString*) accessID toText:(NSString *)text timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    WAIT_FOR_TESTCASE_USABLE_STATE_WITH_TIMEOUT
    
    NSLog(
          @"%@ - accessID = %@, text = %@, timeout = %f",
          NSStringFromSelector(_cmd),
          accessID,
          text,
          timeout
          );
    
    XCUIElement *keyElement = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                   withIndentifier:accessID
                                                       inContainer:testCaseRef.application];
    
    return [self scrollToRow:text collectionViewElement:keyElement scrollUp:NO];
}

#pragma mark - Utilities

+ (BOOL)tapOnElement:(XCUIElement *)element forTestCaseRef:(BBDUITestCaseRef *)testCaseRef timeout:(NSTimeInterval)timeout
{
    BOOL success = NO;
    
    if (element.exists)
    {
        return [self tapOnElementOrCoordiante:element];
    }
    
    if (timeout > 0)
    {
        NSLog(@"Target element is not on screen. Wait for appearance...");
        [testCaseRef.testCase waitForElementAppearance:element
                                               timeout:timeout
                                     failTestOnTimeout:NO
                                               handler:nil];
        
        return [self tapOnElementOrCoordiante:element];
    }
    
    NSLog(@"Target element not found!\nHierarchy: %@", [testCaseRef.application debugDescription]);
    return success;
}

+ (BOOL)tapOnElementOrCoordiante:(XCUIElement *)element
{
    if (!element.exists)
        return NO;
    
    if (element.hittable)
    {
        [element tap];
        return YES;
    }
    
    XCUICoordinate *elementCoordinate = [element coordinateWithNormalizedOffset:CGVectorMake(0.0, 0.0)];
    [elementCoordinate tap];
    return YES;
}

+ (BOOL) isVisible:(XCUIElement *)element
{
    if(element.exists && !CGRectIsEmpty([element accessibilityFrame]))
    {
        return NO;
    }
    else
    {
        return CGRectContainsRect([[[[XCUIApplication new] windows] elementBoundByIndex:0] frame], [element accessibilityFrame]);
    }
}

+ (BOOL)scrollToRow:(NSString *)textRow collectionViewElement:(XCUIElement *)collectionElement scrollUp:(BOOL)isScrollUp
{
    WAIT_FOR_APPLICATION_USABLE_STATE
     
    BOOL success = NO;
    NSString *lastMidCellID = @"";
    CGRect lastMidCellRect = CGRectZero;
    
    XCUIElement *currentMidCell = [collectionElement.cells elementBoundByIndex:(collectionElement.cells.count / 2)];
    
    while (lastMidCellID != currentMidCell.identifier || !CGRectEqualToRect(lastMidCellRect, currentMidCell.frame)) {
        
        if ([[collectionElement.cells matchingIdentifier:textRow] count] > 0 && [[collectionElement.cells objectForKeyedSubscript:textRow] exists] && [[collectionElement.cells objectForKeyedSubscript:textRow] isHittable]) {
            success = YES;
            break;
        }
        
        lastMidCellID = currentMidCell.identifier;
        lastMidCellRect = currentMidCell.frame;    // Need to capture this before the scroll
        
        if (isScrollUp) {
            [[collectionElement coordinateWithNormalizedOffset:CGVectorMake(0.99, 0.4)] pressForDuration:0.01 thenDragToCoordinate: [collectionElement coordinateWithNormalizedOffset:CGVectorMake(0.99, 0.9)]];
        }
        else {
            [[collectionElement coordinateWithNormalizedOffset:CGVectorMake(0.99, 0.9)] pressForDuration:0.01 thenDragToCoordinate: [collectionElement coordinateWithNormalizedOffset:CGVectorMake(0.99, 0.4)]];
        }
        
        currentMidCell = [collectionElement.cells elementBoundByIndex:(collectionElement.cells.count / 2) ];
    }
    
    return success;
}

+ (BOOL)hideKeyboard:(BBDUITestCaseRef *)testCaseRef
{
    if (![BBDConditionHelper isKeyboardShown:testCaseRef ])
    {
        NSLog(@"Keyboard is not shown - nothing to hide");
        return YES;
    }
    
    XCUIApplication *app = testCaseRef.application;
    
    BOOL isHideTapped = NO;
    
    XCUIElement *hideButton = app.keyboards.buttons[BBDKeyboardHideButton];
    if ([BBDConditionHelper isKeyboardElementHittable:hideButton forTestCaseRef:testCaseRef])
    {
        [hideButton tap];
        isHideTapped = YES;
    }
    
    XCUIElement *dismissButton = app.keyboards.buttons[BBDKeyboardDismissButton];
    if ([BBDConditionHelper isKeyboardElementHittable:dismissButton forTestCaseRef:testCaseRef])
    {
        [dismissButton tap];
        isHideTapped = YES;
    }
    
    return isHideTapped;
}

@end
