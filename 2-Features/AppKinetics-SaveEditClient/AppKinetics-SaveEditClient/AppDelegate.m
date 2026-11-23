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

#import "AppDelegate.h"
#import "SaveEditClientGDiOSDelegate.h"
#import "AppKinetics_SaveEditClient-Swift.h"

@implementation AppDelegate


/**
	Remember to change the application ID and version on AppKinetics-SaveEditClient-Info.plist
 */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self disableAnimationsInUITests];
    self.serviceController = [ServiceController new];
    [SaveEditClientGDiOSDelegate sharedInstance].appDelegate = self;
    [[GDiOS sharedInstance] authorize:[SaveEditClientGDiOSDelegate sharedInstance]];

	return YES;
}

-(void)didAuthorize
{

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

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options
{
    UISceneConfiguration *configuration = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    configuration.delegateClass = [SaveEditClientSceneDelegate class];
    configuration.sceneClass = [UIWindowScene class];
    return configuration;
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions
{
}

@end
