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

#import "AppDelegate.h"
#import <BlackBerryDynamics/GD/GDiOS.h>
#import "RSSReaderGDiOSDelegate.h"
#import "RSSReaderObjCSceneDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self disableAnimationsInUITests];
    [[GDiOS sharedInstance] authorize:[RSSReaderGDiOSDelegate sharedInstance]];

    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *config = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    config.delegateClass = [RSSReaderObjCSceneDelegate class];
    config.sceneClass = [UIWindowScene class];
    NSString *storyboardName = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? @"Main_iPhone" : @"Main_iPad";
    config.storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    return config;
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

- (void)disableAnimationsInUITests
{
    BOOL disableAnimations = [[[NSProcessInfo processInfo] arguments] containsObject:@"disableAnimations"];
    if (disableAnimations)
    {
        NSLog(@"Animations disabled in UITests");
        [UIView setAnimationsEnabled:false];
    }
}

@end
