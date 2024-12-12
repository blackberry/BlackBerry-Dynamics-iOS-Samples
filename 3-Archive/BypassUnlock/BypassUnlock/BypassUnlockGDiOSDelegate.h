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
#import <BlackBerryDynamics/GD/GDiOS.h>

#import "LocalComplianceManager.h"
#import "BPStartViewController.h"
#import "AppDelegate.h"

@interface BypassUnlockGDiOSDelegate : NSObject <GDiOSDelegate>

@property (weak, nonatomic) BPStartViewController *rootViewController;
@property (weak, nonatomic) AppDelegate *appDelegate;
@property (assign,nonatomic,readonly) BOOL hasAuthorized;
@property (strong, nonatomic, readonly) LocalComplianceManager *localComplianceManager;

+(instancetype)sharedInstance;

@end
