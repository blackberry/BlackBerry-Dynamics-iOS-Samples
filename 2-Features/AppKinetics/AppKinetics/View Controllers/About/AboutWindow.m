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

#import "AboutWindow.h"

#import "AboutViewController.h"
#import "AppDelegate.h"

@interface AboutWindow ()

@property (nonatomic, strong) UIWindow *onDismissWindow;

@end

@implementation AboutWindow

+ (void)show
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *appWindow = appDelegate.window;
    
    if ([appWindow isKindOfClass:[AboutWindow class]])
    {
        NSLog(@"About window is already shown");
        return;
    }
    
    AboutWindow *instance = [[AboutWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSString *storyboardName;
    // detect the device
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        storyboardName = @"Main_iPhone";
    } else {
        storyboardName = @"Main_iPad";
    }
    
    // set rootViewController for a new window instance
    UIStoryboard *uiStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    AboutViewController* vc = [uiStoryboard instantiateViewControllerWithIdentifier:@"aboutController"];
    instance.rootViewController = vc;
    
    instance.onDismissWindow = appWindow;
    // set new window as application window
    // it can be stored in another way,
    // but this is where Dynamics had problems in the past, before multiple windows support.
    appDelegate.window = instance;
    [instance makeKeyWindow];
    instance.hidden = NO;
    
    instance.alpha = 0;
    [UIView animateWithDuration:0.7 animations:^
    {
        instance.alpha = 1;
    }];
}

+ (void)hide
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    AboutWindow *window = (AboutWindow *)appDelegate.window;
    UIWindow *onDismissWindow = window.onDismissWindow;

    // hide window
    [UIView animateWithDuration:0.4
                     animations:^
     {
         window.alpha = 0;
     }
                     completion:^(BOOL finished)
    {
        appDelegate.window = onDismissWindow;
        [onDismissWindow makeKeyAndVisible];
    }];
}

@end
