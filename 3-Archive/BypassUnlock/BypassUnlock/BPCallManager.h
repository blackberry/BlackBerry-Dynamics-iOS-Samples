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

#import <Foundation/Foundation.h>
#import "BPIncallViewController.h"

typedef void (^simpleBlock)(void);

// App mediator
@interface BPCallManager : NSObject

@property (nonatomic, assign) BOOL appStarted;
@property (nonatomic, assign) BOOL appIdleLocked;
@property (nonatomic, copy) simpleBlock _Null_unspecified appUnlockCompletion;

+ (instancetype _Nonnull)sharedManager;

@end

@interface BPCallManager (BPCallSimulation)
- (void)simulateCall;
- (void)continueCallUsingViewController:(UIViewController *_Null_unspecified)viewController completion:(void (^ __nullable)(void))completion;
@end
