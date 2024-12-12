/* Copyright (c) 2023 BlackBerry Ltd.
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

#import "AlertViewWithOKCancelAndInvocation.h"

/*
 * Alert helper class (extends UIAlertView) allowing invocation of a predefined selector upon tapping OK or Cancel.
 * It acts as the Alert view delegate and performs invocation of designated objects/selectors for each action.
 * It is very handy to keep code streamlined as UIAlertView is not modal.
 */


@implementation AlertViewWithOKCancelAndInvocation
{
    SEL selectorForOK;
    SEL selectorForCancel;
    id  targetForOKInvocation;
    id  targetForCancelInvocation;
    NSMutableArray *argumentsForInvocationForOKAction;
    NSMutableArray *argumentsForInvocationForCancelAction;
}

+ (id)initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
      okButtonTitle:(NSString *)okButtonTitle;
{
    AlertViewWithOKCancelAndInvocation* alertVC = [AlertViewWithOKCancelAndInvocation alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertVC doInvokeSelectorOk];
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Invoking Cancel action
        [alertVC doInvokeSelectorCancel];
    }]];
    return alertVC;
}

- (void)doInvokeSelector:(SEL)aSelector withObject:(id)object andArguments:(NSMutableArray*)arguments
{
    if (object==nil)
        return;
    NSMethodSignature *aSignature = [object methodSignatureForSelector:aSelector];
    NSInvocation *anInvocation = [NSInvocation invocationWithMethodSignature:aSignature];
    [anInvocation setSelector:aSelector];
    [anInvocation setTarget:object];
    NSInteger argIndex = 2; // parameter indexes start at 2 due to first 2 indices being fixed, i.e. obj and cmd
    for (id arg in arguments)
    {
        if ([arg isKindOfClass:[NSValue class]])
        {
            NSValue *currentValue = (NSValue*)arg;
            NSUInteger bufferSize = 0;
            NSGetSizeAndAlignment([currentValue objCType], &bufferSize, NULL);
            void* buffer = malloc(bufferSize);
            [currentValue getValue:buffer];
            [anInvocation setArgument:buffer atIndex:argIndex++];
            free (buffer);
        }
        else
        {
            void *pOrg = (__bridge void*)arg;
            [anInvocation setArgument:&pOrg atIndex:argIndex++];
        }
    }
    [anInvocation invoke];
}
- (void)prepareInvocationForOKButtonWithSelector:(SEL)aSelector withObject:(id)object andArguments:(id)argument, ...
{
    if (argumentsForInvocationForOKAction == nil)
    {
        argumentsForInvocationForOKAction = [[NSMutableArray alloc] init];
    }
    [argumentsForInvocationForOKAction removeAllObjects]; // remove any object left from any previous calls to this method
    selectorForOK = aSelector;
    targetForOKInvocation = object;
    va_list args;
    va_start(args, argument);
    for (id arg = argument; arg != nil; arg = va_arg(args, id))
    {
        [argumentsForInvocationForOKAction addObject:arg];
    }
    va_end(args);
}

- (void)prepareInvocationForCancelButtonWithSelector:(SEL)aSelector withObject:(id)object andArguments:(NSObject *)argument, ...
{
    if (argumentsForInvocationForCancelAction == nil)
    {
        argumentsForInvocationForCancelAction = [[NSMutableArray alloc] init];
    }
    [argumentsForInvocationForCancelAction removeAllObjects]; // remove any object left from any previous calls to this method
    selectorForCancel = aSelector;
    targetForCancelInvocation = object;
    va_list args;
    va_start(args, argument);
    for (id arg = argument; arg != nil; arg = va_arg(args, id))
    {
        [argumentsForInvocationForCancelAction addObject:arg];
    }
    va_end(args);
    
}
- (void) doInvokeSelectorCancel {
    // Invoking Cancel action
    [self doInvokeSelector:selectorForCancel withObject:targetForCancelInvocation andArguments:argumentsForInvocationForCancelAction];

}
// Alert view delegate call which will get executed upon user's interaction merely invokes our setup
- (void) doInvokeSelectorOk
{
    // Invoking OK action (or other button)
    [self doInvokeSelector:selectorForOK withObject:targetForOKInvocation andArguments:argumentsForInvocationForOKAction];
}

@end
