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

@interface SettingsViewController : UIViewController<UIGestureRecognizerDelegate>

//Creating as a property so they can be explicitly positioned on rotation
@property (strong, nonatomic) IBOutlet UISegmentedControl *requestSegControl;
@property (strong, nonatomic) IBOutlet UIButton *uploadLogsButton;
@property (strong, nonatomic) IBOutlet UILabel *requestAPILabel;
@property (strong, nonatomic) IBOutlet UILabel *troubleshootLabel;
@property (strong, nonatomic) IBOutlet UIButton *detailedLoggingButton;
@property (strong, nonatomic) IBOutlet UITextView *loggingStatus;
@property (strong, nonatomic) IBOutlet UIButton *refreshLoggingStatusButton;
@property (weak, nonatomic) IBOutlet UIButton *diagnosticButton;

- (IBAction)requestAPIChanged:(id)sender;
- (IBAction)uploadLogsPressed:(id)sender;
- (IBAction)detailedLoggingPressed:(id)sender;
- (IBAction)refreshLoggingStatusPressed:(id)sender;
- (IBAction)getApplicationConfig:(id)sender;
- (IBAction)getDiagnosticSettings:(id)sender;

- (void)updateStatusText;

@end
