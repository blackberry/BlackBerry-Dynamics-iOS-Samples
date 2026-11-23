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

#import "WKWebViewObjCSceneDelegate.h"
#import "WKWebViewObjCGDiOSDelegate.h"
@import GD.Runtime;

@implementation WKWebViewObjCSceneDelegate

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

    [WKWebViewObjCGDiOSDelegate sharedInstance].sceneDelegate = self;
}

- (void)sceneDidDisconnect:(UIScene *)scene {
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
}

- (void)sceneWillResignActive:(UIScene *)scene {
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
}

- (void)launchApplicationUI {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *rootVC = [storyboard instantiateInitialViewController];
    self.window.rootViewController = rootVC;
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
