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

/*
 
 This root view controller is the root for iPhone
 and is the master controller for iPad SplitViewController
 
 */

#import <UIKit/UIKit.h>
#import "ServiceController.h"

@interface RootViewController :UIViewController <ServiceControllerDelegate>

//For iPad SplitView - Detail Views
@property(strong, nonatomic) UINavigationController *detailNavController;
@property (weak, nonatomic) IBOutlet UIButton *bringToFrontButton;

- (IBAction)bringGreetingsClientToFrontButtonOnTouchUpInside:(id)sender;

@end
