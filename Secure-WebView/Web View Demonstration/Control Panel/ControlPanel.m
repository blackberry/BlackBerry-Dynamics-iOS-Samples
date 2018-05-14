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

#import "ControlPanel.h"
#include "Utilities.h"

@implementation ControlPanel

-(void) setWebViewController:(PanelWebViewController *) viewController {
    _webViewController = viewController;
}

-(void) setPanelWebView:(WKWebView *) webView {
    _panelWebView = webView;
    [_panelWebView.configuration.userContentController  
     addScriptMessageHandler:self name:@"controlPanel"];
    [_panelWebView loadHTMLString:[Utilities webPage:@"Control Panel Content"] 
                     baseURL:nil];
}

-(void)userContentController:(WKUserContentController *)userContentController 
     didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSString *command = [message.body objectForKey:@"command"];
    NSString *addressString = [message.body objectForKey:@"address"];
    NSURL *address = [NSURL URLWithString:addressString];
    if (!address.scheme) {
        address = [NSURL URLWithString:
                   [NSString stringWithFormat:@"https://%@", addressString]];
    }
    
    NSLog(@"\"%@\" %@ %@", command, address, address.scheme);
    if ([command isEqualToString:@"addressChange"] ||
        [command isEqualToString:@"load+inject"])
    {
        self.webViewController.injectOnFinish = YES;
        [self.webViewController load:address];
    }
    else if ([command isEqualToString:@"load"]) {
        self.webViewController.injectOnFinish = NO;
        [self.webViewController load:address];
    }
    else if ([command isEqualToString:@"inject"]) {
        [self.webViewController inject];
    }
}




@end
