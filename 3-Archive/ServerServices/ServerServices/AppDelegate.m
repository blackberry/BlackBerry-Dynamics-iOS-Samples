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
#import "MasterViewController.h"
#import "ServerServiceGDiOSDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self disableAnimationsInUITests];
    [ServerServiceGDiOSDelegate sharedInstance].appDelegate = self;
    [[GDiOS sharedInstance] authorize:[ServerServiceGDiOSDelegate sharedInstance]];
    
    return YES;
}

-(UIViewController *)getRootViewController
{
    UIViewController *rvc = self.window.rootViewController;
    if ([rvc isKindOfClass:[GTLauncherViewController class]]) {
        rvc = ((GTLauncherViewController *)rvc).baseViewController;
    }
    return rvc;
}

-(void)didAuthorize
{
    // Addition to custom navigation options based on configuration used in method onAuthorized: in ServerServiceGDiOSDelegate
    UINavigationController *navigationController = (UINavigationController *)[self getRootViewController];
    UIViewController *topViewController  = [navigationController topViewController];
    if([topViewController isKindOfClass:[MasterViewController class]]){
        MasterViewController *masterViewController = (MasterViewController *)topViewController;
        masterViewController.authenticated = YES;
        [masterViewController didAuthenticate];
    }
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
