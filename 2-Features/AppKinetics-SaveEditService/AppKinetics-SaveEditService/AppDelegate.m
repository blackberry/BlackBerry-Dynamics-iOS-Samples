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
 */

#import "AppDelegate.h"
#import "SaveEditServiceGDiOSDelegate.h"
#import "AppKinetics_SaveEditService-Swift.h"

@implementation AppDelegate

/**
	Remember to change the application ID and version on AppKinetics-SaveEditService-Info.plist
 */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self disableAnimationsInUITests];
    [SaveEditServiceGDiOSDelegate sharedInstance].appDelegate = self;
    [[GDiOS sharedInstance] authorize:[SaveEditServiceGDiOSDelegate sharedInstance]];

	return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options
{
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    configuration.delegateClass = [SaveEditServiceSceneDelegate class];
    configuration.sceneClass = [UIWindowScene class];
    return configuration;
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions
{
}

-(void)didAuthorize
{
    NSLog(@"%s", __FUNCTION__);
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
