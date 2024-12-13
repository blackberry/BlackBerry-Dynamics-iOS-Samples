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

#import <UIKit/UIKit.h>
#import <BlackBerryDynamics/GD/GDServices.h>
#import "ServiceController.h"

@class ServiceController;

@interface RootViewController :UIViewController <ServiceControllerDelegate>

@property (strong, nonatomic) IBOutlet UIButton* testServiceButton;
@property (weak, nonatomic) IBOutlet UIButton *sayHelloButton;
@property (weak, nonatomic) IBOutlet UIButton *sayHelloPeerInFG;
@property (weak, nonatomic) IBOutlet UIButton *sayHelloNoFG;
@property (weak, nonatomic) IBOutlet UIButton *sendFilesButton;
@property (weak, nonatomic) IBOutlet UIButton *bringToFrontButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

- (IBAction)sayHelloToGreetingsServiceButtonOnTouchUpInside:(UIButton *)sender;
- (IBAction)bringGreetingsServiceToFrontButtonOnTouchUpInside:(id)sender;
- (IBAction)sendFilesToGreetingsServiceButtonOnTouchUpInside:(id)sender;
- (IBAction)getDateFromService:(id)sender;

@end
