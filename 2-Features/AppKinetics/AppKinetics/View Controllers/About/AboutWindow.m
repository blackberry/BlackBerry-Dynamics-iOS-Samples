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
#import "AppKineticsGDiOSDelegate.h"
#import "AppKinetics-Swift.h"

@interface AboutWindow ()

@property (nonatomic, strong) UIWindow *onDismissWindow;

@end

static AboutWindow *sActiveAboutOverlay = nil;

@implementation AboutWindow

+ (void)show
{
    AppKineticsSceneDelegate *sceneDelegate = [AppKineticsGDiOSDelegate sharedInstance].sceneDelegate;
    UIWindow *mainWindow = sceneDelegate.window;
    if (mainWindow == nil)
    {
        NSLog(@"AboutWindow: scene delegate window is nil");
        return;
    }

    if (sActiveAboutOverlay != nil)
    {
        NSLog(@"About window is already shown");
        return;
    }

    UIWindowScene *windowScene = mainWindow.windowScene;
    AboutWindow *instance = windowScene != nil
        ? [[AboutWindow alloc] initWithWindowScene:windowScene]
        : [[AboutWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
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
    instance.windowLevel = UIWindowLevelAlert;

    instance.onDismissWindow = mainWindow;
    sActiveAboutOverlay = instance;
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
    AboutWindow *window = sActiveAboutOverlay;
    if (![window isKindOfClass:[AboutWindow class]])
    {
        return;
    }
    UIWindow *onDismissWindow = window.onDismissWindow;

    // hide window
    [UIView animateWithDuration:0.4
                     animations:^
     {
         window.alpha = 0;
     }
                     completion:^(BOOL finished)
    {
        window.hidden = YES;
        sActiveAboutOverlay = nil;
        [onDismissWindow makeKeyAndVisible];
    }];
}

@end
