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

#import "UIWebTabViewController.h"
#include "Utilities.h"
#include "ControlPanel.h"

@interface UIWebDelegate : NSObject <UIWebViewDelegate> {}
@property (nonatomic, assign) BOOL injectOnFinish;
@end

@implementation UIWebDelegate
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.injectOnFinish) {
        [Utilities injectJSIntoUIWebView:webView fromResource:@"inject_css"];
    }
}
@end


@interface UIWebTabViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet WKWebView *controlPanelWebView;

@property (nonatomic) ControlPanel *controlPanel;
@property (nonatomic) UIWebDelegate *webDelegate;
@end

@implementation UIWebTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.controlPanel == nil) {
        self.controlPanel = [ControlPanel new];
    }
    self.controlPanel.webViewController = self;
    self.controlPanel.panelWebView = self.controlPanelWebView;

    if (self.webDelegate == nil) {
        self.webDelegate = [UIWebDelegate new];
    }
    self.webView.delegate = self.webDelegate;
    
    // Don't inject into the Welcome page, which is just a resource.
    self.webDelegate.injectOnFinish = NO;
    [self.webView loadHTMLString:[Utilities webPage:@"Welcome"] baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setInjectOnFinish:(BOOL)injectOnFinish {
    self.webDelegate.injectOnFinish = injectOnFinish;
}

-(void)load:(NSURL *)url {
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(void)inject {
    [Utilities injectJSIntoUIWebView:self.webView
                        fromResource:@"inject_css"];
}

@end
