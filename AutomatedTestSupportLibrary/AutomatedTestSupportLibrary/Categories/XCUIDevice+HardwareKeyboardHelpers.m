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

#import "XCUIDevice+HardwareKeyboardHelpers.h"
#import <objc/message.h>

@implementation XCUIDevice (HardwareKeyboardHelpers)

- (BOOL)isHardwareKeyboardAttached
{
    BOOL hardwareKeyboardAttached = NO;
    
    @try {
        NSString *keyboardClassName = [@[@"UI", @"Keyboard", @"Impl"] componentsJoinedByString:@""];
        Class c = NSClassFromString(keyboardClassName);
        SEL sharedInstanceSEL = NSSelectorFromString(@"sharedInstance");
        if (c == Nil || ![c respondsToSelector:sharedInstanceSEL]) {
            return NO;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id sharedKeyboardInstance = [c performSelector:sharedInstanceSEL];
#pragma clang diagnostic pop
        
        if (![sharedKeyboardInstance isKindOfClass:NSClassFromString(keyboardClassName)]) {
            return NO;
        }
        
        NSString *hardwareKeyboardSelectorName = [@[@"is", @"In", @"Hardware", @"Keyboard", @"Mode"] componentsJoinedByString:@""];
        SEL hardwareKeyboardSEL = NSSelectorFromString(hardwareKeyboardSelectorName);
        if (![sharedKeyboardInstance respondsToSelector:hardwareKeyboardSEL]) {
            return NO;
        }
        
        hardwareKeyboardAttached = ((BOOL ( *)(id, SEL))objc_msgSend)(sharedKeyboardInstance, hardwareKeyboardSEL);
    } @catch(__unused NSException *ex) {
        hardwareKeyboardAttached = NO;
    }
    
    return hardwareKeyboardAttached;
}

@end
