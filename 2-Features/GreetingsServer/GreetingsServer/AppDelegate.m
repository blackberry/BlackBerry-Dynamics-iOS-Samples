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
#import "GreetingsServer-Swift.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self disableAnimationsInUITests];
    [GreetingsServerGDiOSDelegate shared].greetingsServerAppDelegate = self;
    [[GDiOS sharedInstance] authorize];

    return YES;
}

- (void)didAuthorize
{
    NSLog(@"%s", __FUNCTION__);
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    
    UISceneConfiguration *sceneConfig = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    sceneConfig.delegateClass = [GreetingsServerSceneDelegate class];
    sceneConfig.sceneClass = [UIWindowScene class];
    
    NSString *storyboardName = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? @"Main_iPhone" : @"Main_iPad";
    sceneConfig.storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
    return sceneConfig;
}

-(void)application:(UIApplication *)application didDiscardSceneSessions:(nonnull NSSet<UISceneSession *> *)sceneSessions {
    // Handle scene session discard
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
