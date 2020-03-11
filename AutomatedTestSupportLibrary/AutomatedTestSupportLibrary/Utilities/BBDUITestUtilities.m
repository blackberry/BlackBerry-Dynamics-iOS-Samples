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

#import "BBDUITestUtilities.h"
#import "XCUIApplication+State.h"

@implementation BBDUITestUtilities

+ (XCUIElement *)findElementOfType:(XCUIElementType)type withIndentifier:(nonnull NSString *)indentifier inContainer:(XCUIElement *)containerElement
{
    [self waitForContainerUsableState:containerElement];
    NSLog(@"%@ - type = %lu, indentifier = %@", NSStringFromSelector(_cmd), (unsigned long)type, indentifier);
    NSAssert(indentifier, @"%@ : Identifier parameter cannot be nil", NSStringFromSelector(_cmd));
    return [[containerElement descendantsMatchingType:type] objectForKeyedSubscript:indentifier];
}

+ (XCUIElement *)findRowWithStaticText:(nonnull NSString *)staticText inContainer:(XCUIElement *)containerElement
{
    [self waitForContainerUsableState:containerElement];
    NSLog(@"%@, staticText = %@", NSStringFromSelector(_cmd), staticText);
    NSAssert(staticText, @"%@ : staticText parameter cannot be nil", NSStringFromSelector(_cmd));
    return [containerElement.tables.cells containingType:XCUIElementTypeStaticText identifier:staticText].element;
}

+ (XCUIElement *)findRowWithAccessID:(nonnull NSString *)accessID inContainer:(XCUIElement *)containerElement
{
    [self waitForContainerUsableState:containerElement];
    NSLog(@"%@, indentifier = %@", NSStringFromSelector(_cmd), accessID);
    NSAssert(accessID, @"%@ : Identifier parameter cannot be nil", NSStringFromSelector(_cmd));
    return [containerElement.tables containingType:XCUIElementTypeCell identifier:accessID].element;
}

+ (XCUIElement *)findRowByIndex:(NSInteger)index inContainer:(XCUIElement *)containerElement
{
    [self waitForContainerUsableState:containerElement];
    NSLog(@"%@, index = %li", NSStringFromSelector(_cmd), (long)index);
    NSAssert(index, @"%@ : Identifier parameter cannot be nil", NSStringFromSelector(_cmd));
    return [containerElement.tables.cells elementBoundByIndex:index];
}

+ (void)waitForContainerUsableState:(XCUIElement *)container
{
    if ([container isKindOfClass:[XCUIApplication class]])
    {
        [(XCUIApplication *)container waitForUsableState];
    }
    else
    {
        [[[BBDAutomatedTestSupport sharedInstance] getCurrentSetupApplication] waitForUsableState];
    }
}

@end
