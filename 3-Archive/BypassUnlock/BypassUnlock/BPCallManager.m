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

#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIApplication.h>
#import "BPCallManager.h"
#import "AppDelegate.h"
#import "BypassUnlockGDiOSDelegate.h"

@interface BPCallManager ()

@property (nonatomic, readonly) AppDelegate *appDelegate;

@end

@implementation BPCallManager
@synthesize appIdleLocked, appStarted;

#pragma mark - Initialization

+ (instancetype)sharedManager {
    static BPCallManager* _callManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _callManager = [[self alloc] init];
    });
    return _callManager;
}

- (instancetype)init {
    self = [super init];

    return self;
}

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)setAppIdleLocked:(BOOL)isAppIdleLocked {
    BOOL allowCompletion = isAppIdleLocked != appIdleLocked && appIdleLocked && self.appUnlockCompletion != NULL;
    
    appIdleLocked = isAppIdleLocked;
    
    if ( allowCompletion ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.appUnlockCompletion();
            self.appUnlockCompletion = NULL;
        });
    }
}

- (void)setAppStarted:(BOOL)isAppStarted {
    BOOL allowCompletion = isAppStarted && !appStarted && self.appUnlockCompletion != NULL;
    
    appStarted = isAppStarted;
    
    if ( allowCompletion ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.appUnlockCompletion();
            self.appUnlockCompletion = NULL;
        });
    }
}

@end

#pragma mark - BPCallSimulation

@implementation BPCallManager (BPCallSimulation)

- (void)simulateCall {
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(simulateCall) withObject:nil waitUntilDone:NO];
        return;
    } else {
        UIViewController *incallViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"incallViewController"];
        
        [self continueCallUsingViewController:incallViewController completion:nil];
    }
}

- (void)continueCallUsingViewController:(UIViewController *)viewController completion:(void (^ _Nullable)(void))completion{

    void (^block)(void) = ^{
        
        UINavigationController *rootViewController = (UINavigationController *)[BypassUnlockGDiOSDelegate sharedInstance].rootViewController;
        UIViewController *incallViewController = viewController;
        
        /*
         * Checks if utility alert controller is presented then dismiss it previously and then present bypass view controller
         */
        if ( [rootViewController.presentedViewController isKindOfClass:[UIAlertController class]] ) {
            
            [rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
                [rootViewController presentViewController:incallViewController animated:YES completion:completion];
            }];
        
        /*
         * Or immediately present bypass view controller
         */
        } else {
            
            [rootViewController presentViewController:incallViewController animated:YES completion:completion];
            
        }
    };
    
    /*
     * Presenting bypass view controller if app is provisioned or unlocked from cold start.
     */
    if ( self.appStarted ) {
        
        block();
    
    /*
     * Or schedule its presenting
     */
    } else {
        
        self.appUnlockCompletion = block;
        
    }
}

@end
