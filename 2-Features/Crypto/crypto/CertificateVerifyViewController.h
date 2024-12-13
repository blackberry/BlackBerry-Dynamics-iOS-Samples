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

NS_ASSUME_NONNULL_BEGIN

@interface CertificateVerifyViewController : UIViewController

    @property (weak, nonatomic) IBOutlet UIView* pageView;
    @property (weak, nonatomic) IBOutlet UILabel* detail;
    @property (weak, nonatomic) IBOutlet UILabel* moreDetail;
    @property (weak, nonatomic) IBOutlet UIButton* button;
    @property (weak, nonatomic) IBOutlet UILabel* hint;
    @property (weak, nonatomic) IBOutlet UIPageControl* page;
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView* activity;

    -(IBAction)onButtonDown:(id)sender;
    -(IBAction)onPageChange:(id)sender;
    -(IBAction)onSwipeLeft:(id)sender;
    -(IBAction)onSwipeRight:(id)sender;
    -(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue;

@end

NS_ASSUME_NONNULL_END
