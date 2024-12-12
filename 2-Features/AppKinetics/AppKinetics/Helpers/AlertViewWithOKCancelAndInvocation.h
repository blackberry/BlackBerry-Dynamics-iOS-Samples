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

#import <UIKit/UIKit.h>

/*
 * Alert helper class (extends UIAlertView) allowing invocation of a predefined selector upon tapping OK or Cancel.
 * It acts as the Alert view delegate and performs invocation of designated objects/selectors for each action.
 * It is very handy to keep code streamlined as UIAlertView is not modal.
 */

@interface AlertViewWithOKCancelAndInvocation : UIAlertController

+ (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle  okButtonTitle:(NSString *)okButtonTitle;
- (void)prepareInvocationForCancelButtonWithSelector:(SEL)aSelector withObject:(id)object andArguments:(id)argument, ... NS_REQUIRES_NIL_TERMINATION;
- (void)prepareInvocationForOKButtonWithSelector:(SEL)aSelector withObject:(id)object andArguments:(id)argument, ... NS_REQUIRES_NIL_TERMINATION;

@end
