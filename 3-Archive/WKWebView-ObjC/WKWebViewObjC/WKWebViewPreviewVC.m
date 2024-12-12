  
/* Copyright (c) 2020 BlackBerry Limited.
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

#import "WKWebViewPreviewVC.h"
#import <WebKit/WebKit.h>
#import "GDURLSchemeHandler.h"

@interface WKWebViewPreviewVC () <WKNavigationDelegate, WKUIDelegate>

@end

@implementation WKWebViewPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.fileGDURL.lastPathComponent;
    
    // Create and load web view
    [self configureWKWebView];
}

- (void)configureWKWebView {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config setDataDetectorTypes:WKDataDetectorTypeAll];
    
    GDURLSchemeHandler *schemeHandler = [[GDURLSchemeHandler alloc] init];
    [config setURLSchemeHandler:schemeHandler forURLScheme:@"gd"];

    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [webView setNavigationDelegate:self];
    [self.view addSubview:webView];
        
    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[webView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0] setActive:YES];
    [[webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0] setActive:YES];
    [[webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0] setActive:YES];
    [[webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0] setActive:YES];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.fileGDURL];
    [webView loadRequest:request];
}

#pragma mark - WKWebView delegates

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

}

@end
