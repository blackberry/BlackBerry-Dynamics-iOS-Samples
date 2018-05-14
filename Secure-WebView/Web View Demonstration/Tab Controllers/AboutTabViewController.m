/* Copyright (c) 2016 BlackBerry Ltd.
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

#import "AboutTabViewController.h"
#include "Utilities.h"

#include "BBDDetector.h"
#include "BBDLoader.h"

@interface AboutWKDelegate : NSObject <WKNavigationDelegate> {}
@end

@implementation AboutWKDelegate
-(void)webView:(WKWebView *)webView 
didFinishNavigation:(WKNavigation *)navigation 
{
    NSString *message =  [BBDLoader settings];
    if (message == nil) {
        message = @"No BlackBerry Dynamics.";
    }
    message = [message stringByReplacingOccurrencesOfString:@"\n" 
                                                 withString:@"\\n"];
    NSString *js = [NSString stringWithFormat:@"main(\"%@\");", message];
    [webView 
     evaluateJavaScript:js
     completionHandler:^(id result, NSError *error) {
         NSLog(@"%s %@ %@", __FUNCTION__, result, error); 
     }];
}
@end

@interface AboutTabViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (nonatomic) AboutWKDelegate *wkDelegate;
@end

@implementation AboutTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@ BlackBerry Dynamics %@.", 
          [BBDDetector hasRuntime] ? @"With" : @"No",
          [BBDLoader settings]);

    if (self.wkDelegate == nil) {
        self.wkDelegate = [AboutWKDelegate new];
    }
    self.webView.navigationDelegate = self.wkDelegate;

    [self.webView loadRequest:[Utilities webPageRequest:@"About"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
