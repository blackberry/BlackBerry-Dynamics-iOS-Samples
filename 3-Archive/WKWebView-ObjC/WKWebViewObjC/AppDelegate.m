  
/* Copyright (c) 2020 BlackBerry Limited.
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

#import "AppDelegate.h"
#import "WKWebViewObjCGDiOSDelegate.h"
#import "WKWebViewObjCSceneDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/**
    Remember to change the application ID and version on Info.plist
*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WKWebViewObjCGDiOSDelegate sharedInstance].appDelegate = self;
    [[GDiOS sharedInstance] authorize:[WKWebViewObjCGDiOSDelegate sharedInstance]];
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *config = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    config.delegateClass = [WKWebViewObjCSceneDelegate class];
    config.sceneClass = [UIWindowScene class];
    config.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return config;
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

- (void)didAuthorize {
    NSLog(@"%s", __FUNCTION__);
}

@end
