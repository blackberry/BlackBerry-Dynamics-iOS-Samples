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

#import "BBDDragAndDropHelper.h"

#import "BBDUITestCaseRef.h"
#import "BBDInputEventHelper.h"
#import "XCTestCase+Expectations.h"
#import "BBDTouchEventHelper.h"
#import "BBDConditionHelper.h"
#import "BBDUITestUtilities.h"
#import "BBDPublicConstans.h"

static const NSTimeInterval TIMEOUT_10 = 10.f;
static const NSTimeInterval TIMEOUT_5 = 5.f;
static const NSTimeInterval TIMEOUT_2 = 2.f;
static NSString* const SYSTEM_SPRINGBOARD_ID = @"com.apple.springboard";

@implementation BBDDragAndDropHelper

+ (BOOL)isSplitScreenShown:(XCUIApplication *)app
{
    CGSize currentAppSize= app.frame.size;

    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:SYSTEM_SPRINGBOARD_ID];
    CGSize springboardSize = springboard.frame.size;
    
    BOOL isSplitScreenShown = !CGSizeEqualToSize(currentAppSize, springboardSize);
    
    return isSplitScreenShown;
}

+ (BOOL)openSplitScreen:(XCUIApplication *)currentApp
              secondApp:(XCUIApplication *)secondApp
          secondAppName:(NSString *)secondAppName
{
    if (currentApp.state != XCUIApplicationStateRunningForeground)
    {
        NSLog(@"SplitScreen can't be opened for existing app, it doesn't run in foreground");
        return NO;
    }
    
    if (secondApp.state == XCUIApplicationStateRunningForeground)
    {
        NSLog(@"App %@ can't be added to a split screen - it already exists", secondAppName);
        return NO;
    }
    
    XCUIApplication *springboard = [[XCUIApplication alloc] initWithBundleIdentifier:SYSTEM_SPRINGBOARD_ID];
    
    BOOL isSplitScreenShown = [self isSplitScreenShown:currentApp];
    
    // swipe from bottom of the screen to top right corner
    [self swipeFrom:CGVectorMake(0.5, 0.9999) toVector:CGVectorMake(0.5, 0.91) duration:0.05 app:currentApp];
    
    XCUIElement *sugEl = [springboard descendantsMatchingType:XCUIElementTypeAny][@"Suggestions"];
    BOOL sugElExists = sugEl.exists;
    if (!sugElExists)
    {
        NSLog(@"App suggestions menu has not appeared");
        return NO;
    }
    
    // explicit wait for a few seconds,this is needed because of the rendering of the menu with suggestion apps
    [NSThread sleepForTimeInterval:TIMEOUT_5];
    XCUIElement *el = springboard.icons[secondAppName].firstMatch;
    sugElExists = sugEl.exists;
    if (!sugElExists)
    {
        NSLog(@"App icon is not shown is suggestion menu");
        return NO;
    }
    
    // Swipe icon from suggestions menu to the top left corner of the screen.
    // In 90% percent cases one attempt should be enough.
    // But lets do some more attempts as it may fail on old machines.
    for (int i = 0; i < 3; i++)
    {
        [self swipeSplitScreenForAppElement:el existingApp:currentApp isSplitScreenShown:isSplitScreenShown];
        
        BOOL isActive = [secondApp waitForState:XCUIApplicationStateRunningForeground timeout:TIMEOUT_10];
        
        if (isActive)
        {
            return YES;
        }
        else
        {
            NSLog(@"App %@ wasn't added added to a split screen - it isn't shown after %zd attempt", secondAppName, i+1);
        }
    }

    return NO;
}

// Drag and drop for simple UITableView or UICollectionView  cell
+ (BBDDragAndDropTestResult)dragAndDropTableCell:(XCUIElement *)cell
                                       destField:(XCUIElement *)field
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase
{
    BBDUITestCaseRef *destTestRef = [[BBDUITestCaseRef alloc] initWithTestCase:testCase forApplication:destApp];
    
    BOOL isCleared = [BBDInputEventHelper clearText:field forTestCaseRef:destTestRef];
    
    if (!isCleared)
    {
        NSLog(@"Drag and Drop cell to field has failed - destination field was not cleared");
        return BBDDragAndDropResultError;
    }
    
    [self dragAndDropElement:cell destinationElement:field];
    
    XCUIElement *textEl = [cell.staticTexts elementBoundByIndex:0];
    
    NSString *sourceText = textEl.label;
    
    BOOL isDragged = [self waitForDragAndDropValueChange:field expectedValue:sourceText testCase:testCase];
    if (isDragged)
    {
        return BBDDragAndDropResultTextDragged;
    }
    else
    {
        return BBDDragAndDropResultTextNotDragged;
    }
}

+ (BBDDragAndDropTestResult)dragAndDropTextField:(XCUIElement *)sourceField
                                         toTable:(XCUIElement *)destTable
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase
{
    NSString *sourceValue = sourceField.value;
    
    XCUIElementQuery *query1 = [[destTable descendantsMatchingType:XCUIElementTypeCell].staticTexts matchingIdentifier:sourceValue];
    
    if (query1.count)
    {
        NSLog(@"Table has some other cells with specified text");
        return BBDDragAndDropResultError;
    }
    
    BOOL isSelected = [self selectTextFieldForDragAndDrop:sourceField app:sourceApp testCase:testCase];
    
    if (!isSelected)
    {
        NSLog(@"Drag and Drop text field to table failed - no able to select text in text field");
        return BBDDragAndDropResultError;
    }
    
    [self dragAndDropElement:sourceField destinationElement:destTable];
    
    if (query1.count == 1)
    {
        return BBDDragAndDropResultTextDragged;
    }
    
    return BBDDragAndDropResultTextNotDragged;
}

+ (BBDDragAndDropTestResult)dragAndDropTextField:(XCUIElement *)sourceField
                                    toAlertField:(XCUIElement *)destEl
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase
{
    [destEl tap];
    
    BBDUITestCaseRef *destTestRef = [[BBDUITestCaseRef alloc] initWithTestCase:testCase forApplication:destApp];
    
    // For alert we need to hide keyboard to count coordinates.
    // This is because an alert may change coordinates during drag and drop operation
    // because of keyboard dismissing.
    BOOL isKeyboardHidden = [BBDTouchEventHelper hideKeyboard:destTestRef];
    if (!isKeyboardHidden)
    {
        NSLog(@"Drag and Drop cell to alert has failed - keyboard was not hidden");
        return BBDDragAndDropResultError;
    }
    
    
    CGRect frame = destEl.frame;
    CGVector resVector = CGVectorMake(frame.origin.x, frame.origin.y);
    XCUICoordinate *destCoord= [[destApp coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:resVector];
    
    BOOL isCleared = [BBDInputEventHelper clearText:destEl forTestCaseRef:destTestRef];
    
    if (!isCleared)
    {
        NSLog(@"Drag and Drop to alert has failed - destination field was not cleaned");
        return BBDDragAndDropResultError;
    }
    
    BOOL isSelected = [self selectTextFieldForDragAndDrop:sourceField app:sourceApp testCase:testCase];
    
    if (!isSelected)
    {
        NSLog(@"Drag and Drop text field to table failed - no able to select text in text field");
        return BBDDragAndDropResultError;
    }
    
    CGVector firstV = [self defaultDragAndDropElementOffset];
    XCUICoordinate *p1 = [[sourceField coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:firstV];
    
    XCUICoordinate *p2Final = [destCoord coordinateWithOffset:firstV];
    [p1 pressForDuration:3 thenDragToCoordinate:p2Final];
    
    NSString *sourceText = (NSString *)sourceField.value;
    
    BOOL isDragged = [self waitForDragAndDropValueChange:destEl expectedValue:sourceText testCase:testCase];
    
    if (isDragged)
    {
        return BBDDragAndDropResultTextDragged;
    }
    else
    {
        return BBDDragAndDropResultTextNotDragged;
    }
}

// for Web Text fields we match text field using its value
// so if the value is being changed an element may change
// that's why we have specific method for DragAndDrop operation into web textfield
+ (BBDDragAndDropTestResult)dragAndDropTextField:(XCUIElement *)sourceTextField
                                      toWebField:(XCUIElement *)destEl
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase
{
    // webview may scroll up when keyboard is shown
    // lets tap on it to show keyboard and properly calculate element coordinate
    [destEl tap];
    
    // wait for keyboard appearance
    // we need to wait full keyboard appearance(when animation is ended)
    // so the easiest and most proven way is explicit wait for a few seconds
    [NSThread sleepForTimeInterval:TIMEOUT_2];
    // here we calculate coordinate against app
    CGRect frame = destEl.frame;
    CGVector resVector = CGVectorMake(frame.origin.x, frame.origin.y);
    XCUICoordinate *destCoord= [[destApp coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:resVector];
    
    BBDUITestCaseRef *destTestRef = [[BBDUITestCaseRef alloc] initWithTestCase:testCase forApplication:destApp];
    if (![BBDConditionHelper isKeyboardShown:destTestRef])
    {
        // keyboard sometimes appears/disappears after tapping
        [destEl tap];
    }
    // clear text field
    [destEl typeText:[BBDInputEventHelper stringForTextCleaning:destEl.value]];
    
    // check if destination app has no other text field with dragging value
    NSString *sourceText = (NSString *)sourceTextField.value;
    XCUIElementQuery *query = [destApp descendantsMatchingType:XCUIElementTypeTextField];
    query = [query matchingPredicate:[NSPredicate predicateWithFormat:@"value == %@", sourceText]];
    if (query.count != 0)
    {
        NSLog(@"Destination app has some other text fields with this value");
        return BBDDragAndDropResultError;
    }
    
    CGVector firstV = [self defaultDragAndDropElementOffset];
    XCUICoordinate *p1 = [self coordinateForDragAndDrop:sourceTextField];
    
    XCUICoordinate *p2Final = [destCoord coordinateWithOffset:firstV];
    
    BOOL isSuccess = query.count;
    // we make two attempts for this operation
    // this is because webview may have not stable ui
    // especially in a case of advertisement
    for (int i = 0; i < 2; i++)
    {
        BOOL isSelected = [self selectTextFieldForDragAndDrop:sourceTextField app:sourceApp testCase:testCase];
        
        if (!isSelected)
        {
            if (i==1)
            {
                return BBDDragAndDropResultError;
            }
            else
            {
                continue;
            }
        }
        
        [p1 pressForDuration:3 thenDragToCoordinate:p2Final];
        
        // wait until query count will be 1
        // it means that the element with dragged value has appeared
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"count == 1"];
        
        XCTestExpectation *te = [testCase expectationForPredicate:predicate
                                          evaluatedWithObject:query
                                                      handler:nil];
        
        [testCase waitForExpectation:te
                     withTimeout:TIMEOUT_5
               failTestOnTimeout:NO
                         handler:nil];
        
        
        isSuccess = query.count == 1;
        
        if (isSuccess)
        {
            return BBDDragAndDropResultTextDragged;
        }
    }
    
    return BBDDragAndDropResultTextNotDragged;
}

+ (BBDDragAndDropTestResult)dragAndDropWebText:(XCUIElement *)webText
                              destinationField:(XCUIElement *)destElement
                                     sourceApp:(XCUIApplication *)sourceApp
                                destinationApp:(XCUIApplication *)destApp
                                   forTestCase:(XCTestCase *)testCase
{
    BBDUITestCaseRef *destTestRef = [[BBDUITestCaseRef alloc] initWithTestCase:testCase forApplication:destApp];
    BOOL isCleared = [BBDInputEventHelper clearText:destElement forTestCaseRef:destTestRef];
    if (!isCleared)
    {
        return BBDDragAndDropResultError;
    }
    
    CGVector vector = [self defaultDragAndDropElementOffset];
    XCUICoordinate *p1 = [[webText coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:vector];
    XCUIElement *el =  [BBDUITestUtilities findElementOfType:XCUIElementTypeAny withIndentifier:BBDTextMenuItemCopy inContainer:sourceApp];
    
    NSString *sourceText = [(NSString *)webText.label componentsSeparatedByString:@" "].firstObject;

    // In a case if webview UI has some rendering(advertisement rendering)
    // text selection may fail.
    // Lets make several attempts to make operation as stable as we can.
    for (int i = 0; i < 5; i++)
    {
        [p1 tap];
        
        [p1 pressForDuration:5];
        
        [testCase waitForElementAppearance:el timeout:TIMEOUT_10 failTestOnTimeout:NO handler:nil];
        
        if (el.exists)
        {
            NSLog(@"Web text was selected after %d try", i);
        }
        else
        {
            NSLog(@"Web text was not selected after %d try", i);
            continue;
        }
        
        [self dragAndDropElement:webText destinationElement:destElement];
        
        
        BOOL isDragged = [self waitForDragAndDropValueChange:destElement expectedValue:sourceText testCase:testCase];
        
        if (isDragged)
        {
            NSLog(@"Web text was dragged after %d try", i);
            return BBDDragAndDropResultTextDragged;
        }
        
        NSLog(@"Web text was not dragged after %d try", i);
    }
    
    NSLog(@"Web text was not dragged");
    
    return BBDDragAndDropResultTextNotDragged;
}

+ (BBDDragAndDropTestResult)dragAndDropTextField:(XCUIElement *)sourceTextField
                            destinationTextField:(XCUIElement *)destElement
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase
{
    BBDUITestCaseRef *destTestRef = [[BBDUITestCaseRef alloc] initWithTestCase:testCase forApplication:destApp];
    
    BOOL isCleared = [BBDInputEventHelper clearText:destElement forTestCaseRef:destTestRef];
    
    if (!isCleared)
    {
        NSLog(@"Drag and Drop to text field has failed - destination field was not cleared");
        return BBDDragAndDropResultError;
    }
    
    BOOL isSelected = [self selectTextFieldForDragAndDrop:sourceTextField app:sourceApp testCase:testCase];
    
    if (!isSelected)
    {
        NSLog(@"Drag and Drop text field to table failed - no able to select text in text field");
        return BBDDragAndDropResultError;
    }
    
    [self dragAndDropElement:sourceTextField destinationElement:destElement];
    
    NSString *sourceText = (NSString *)sourceTextField.value;
    
    BOOL isDragged = [self waitForDragAndDropValueChange:destElement expectedValue:sourceText testCase:testCase];
    
    if (isDragged)
    {
        return BBDDragAndDropResultTextDragged;
    }
    
    return BBDDragAndDropResultTextNotDragged;
}

+ (void)dragAndDropElement:(XCUIElement *)sourceEl
        destinationElement:(XCUIElement *)destElement
{
    XCUICoordinate *p1 = [self coordinateForDragAndDrop:sourceEl];
    
    XCUICoordinate *p2 = [self coordinateForDragAndDrop:destElement];
    [p1 pressForDuration:3 thenDragToCoordinate:p2];
}

#pragma mark - Utilities

+ (void)swipeSplitScreenForAppElement:(XCUIElement *)appElement
                          existingApp:(XCUIApplication *)app
                   isSplitScreenShown:(BOOL)isAlreadyShown
{
    CGRect rect = appElement.frame;
    double duration = 1.5;
    if (!isAlreadyShown)
    {
        CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        CGVector firstVector = CGVectorMake(center.x / app.frame.size.width, center.y / app.frame.size.height);
        CGVector lastVector = CGVectorMake(0.93, 0.4);
        [self swipeFrom:firstVector toVector:lastVector duration:duration app:app];
    }
    else
    {
        NSLog(@"Split screen is already shown, will open app instead the second one");
        
        XCUICoordinate *p1 = [[appElement coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(rect.size.width / 2, rect.size.height / 2)];
        double endDestination = (app.frame.size.width + app.frame.size.width * 0.25);
        double offset = endDestination - rect.origin.x;
        XCUICoordinate *p2 =  [p1 coordinateWithOffset:CGVectorMake(offset, - (app.frame.size.height / 2))];;
        
        [p1 pressForDuration:duration thenDragToCoordinate:p2];
    }
}

+ (void)swipeFrom:(CGVector)vector1 toVector:(CGVector)vector2 duration:(NSTimeInterval)duration app:(XCUIApplication *)app
{
    XCUICoordinate *p1 = [app coordinateWithNormalizedOffset:vector1];
    XCUICoordinate *p2 = [app coordinateWithNormalizedOffset:vector2];
    
    [p1 pressForDuration:duration thenDragToCoordinate:p2];
}


+ (BOOL)waitForDragAndDropValueChange:(XCUIElement *)el
                        expectedValue:(NSString *)expectedValue
                             testCase:(XCTestCase *)testCase
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"value == %@", expectedValue];
    
    XCTestExpectation *te = [testCase expectationForPredicate:predicate
                                      evaluatedWithObject:el
                                                  handler:nil];
    
    [testCase waitForExpectation:te
                 withTimeout:TIMEOUT_5
           failTestOnTimeout:NO
                     handler:nil];
    
    return [expectedValue isEqualToString:el.value];
}

+ (XCUICoordinate *)coordinateForDragAndDrop:(XCUIElement *)el
{
    switch (el.elementType)
    {
        case XCUIElementTypeTable:
        case XCUIElementTypeCollectionView:
        {
            XCUICoordinate *p = [el coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.5)];
            return p;
        }
        case XCUIElementTypeCell:
        case XCUIElementTypeTextField:
        case XCUIElementTypeTextView:
        case XCUIElementTypeStaticText:
        default:
        {
            CGVector defaultV = [self defaultDragAndDropElementOffset];
            XCUICoordinate *p1 = [[el coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:defaultV];
            return p1;
        }
            break;
    }
}

+ (BOOL)selectTextFieldForDragAndDrop:(XCUIElement *)textField
                                  app:(XCUIApplication *)app
                             testCase:(XCTestCase *)testCase
{
    [textField tap];
    
    CGVector textFieldVector = [self defaultDragAndDropElementOffset];
    XCUICoordinate *p1 = [[textField coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:textFieldVector];
    [p1 pressForDuration:4];
    XCUIElement *el = app.menuItems[BBDTextMenuItemSelectAll];
    [testCase waitForElementAppearance:el timeout:TIMEOUT_5 failTestOnTimeout:NO handler:nil];
    BOOL selectAllExists = el.exists;
    if (!selectAllExists)
    {
        return NO;
    }
    
    [el tap];
    
    [testCase waitForElementDisappearance:el timeout:TIMEOUT_5 failTestOnTimeout:NO handler:nil];
    
    return YES;
}

+ (CGVector)defaultDragAndDropElementOffset
{
    return CGVectorMake(30, 15);
}

@end

