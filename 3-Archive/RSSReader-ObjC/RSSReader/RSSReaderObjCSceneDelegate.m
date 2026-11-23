/* Copyright (c) 2026 BlackBerry Ltd.
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

#import "RSSReaderObjCSceneDelegate.h"
#import "RSSReaderGDiOSDelegate.h"
#import "Utilities.h"
#import "RSSManager.h"
#import "constants.h"
#import <BlackBerryDynamics/GD/GDiOS.h>

@implementation RSSReaderObjCSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) {
        return;
    }
    UIWindowScene *windowScene = (UIWindowScene *)scene;

    if ([self isDynamicsVersionGreaterThanOrEqualv15]) {
        UIWindow *keyWin = windowScene.keyWindow;
        if (keyWin != nil) {
            self.window = keyWin;
        } else {
            self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
            [self.window makeKeyAndVisible];
        }
    } else {
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        [self.window makeKeyAndVisible];
    }

    [RSSReaderGDiOSDelegate sharedInstance].sceneDelegate = self;
}

- (void)sceneDidDisconnect:(UIScene *)scene {
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    GDAuthDelegateInfo *gdAuthDelegateInfo = [[GDiOS sharedInstance] getAuthDelegate];

    NSLog(@"sceneDidBecomeActive: getAuthDelegate Name = %@, address = %@, applicationId = %@, isAuthenticationDelegated = %@",
          gdAuthDelegateInfo.name, gdAuthDelegateInfo.address, gdAuthDelegateInfo.applicationId,
          gdAuthDelegateInfo.isAuthenticationDelegated ? @"YES" : @"NO");
}

- (void)sceneWillResignActive:(UIScene *)scene {
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
}

- (void)launchApplicationUI {
    self.window.tintColor = RGB(52.f, 69.f, 84.f);

    RSSReaderGDiOSDelegate *gdDelegate = [RSSReaderGDiOSDelegate sharedInstance];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        gdDelegate.navController = [[Utilities storyboard] instantiateViewControllerWithIdentifier:@"iPhoneNC"];
        self.window.rootViewController = gdDelegate.navController;
    } else {
        gdDelegate.splitViewController = [[Utilities storyboard] instantiateViewControllerWithIdentifier:@"SplitVC"];
        gdDelegate.navController = [gdDelegate.splitViewController.viewControllers firstObject];
        gdDelegate.detailNavigationController = [gdDelegate.splitViewController.viewControllers lastObject];
        self.window.rootViewController = gdDelegate.splitViewController;
    }
    [[RSSManager sharedRSSManager] setAlertPresenter:gdDelegate.navController];
}

- (BOOL)isDynamicsVersionGreaterThanOrEqualv15 {
    NSString *dynamicsVersion = [[GDiOS sharedInstance] getVersion];
    NSArray<NSString *> *versionComponents = [dynamicsVersion componentsSeparatedByString:@"."];
    if (versionComponents.count < 1) {
        return NO;
    }
    return [versionComponents[0] integerValue] >= 15;
}

@end
