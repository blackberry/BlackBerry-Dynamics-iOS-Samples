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

#import "BaseAlertController.h"

@interface BaseAlertController ()

@property (nonatomic, strong) UIWindow *window;

@end

@implementation BaseAlertController

+ (void)showOkAlert:(NSString *)title message:(NSString *)message
{
    BaseAlertController *alertController = [BaseAlertController alertControllerWithTitle:title
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    /// OK
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [alertController presentAnimated:YES completion:nil];
}

- (void)presentAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion
{
    // Note: window is being deallocated on alert dismissing.
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    
    window.windowLevel = 1000;
    window.backgroundColor = [UIColor clearColor];
    window.rootViewController = [UIViewController new];
    window.hidden = NO;
    [window.rootViewController presentViewController:self animated:flag completion:completion];
    
}

@end
