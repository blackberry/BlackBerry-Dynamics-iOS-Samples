  
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

import UIKit
import WebKit

class WKWebViewPreviewVC: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var fileGDURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fileGDURL?.lastPathComponent ?? "Preview"
        
        // Create and load web view
        self.configureWKWebView()
    }
    
    func configureWKWebView() {
        let config = WKWebViewConfiguration()
        config.dataDetectorTypes = .all
        
        let schemeHandler = GDURLSchemeHandler()
        config.setURLSchemeHandler(schemeHandler, forURLScheme: "gd")
        
        let webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 1.0).isActive = true
        webView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.view.bottomAnchor, multiplier: 1.0).isActive = true
        webView.leadingAnchor.constraint(equalToSystemSpacingAfter: self.view.leadingAnchor, multiplier: 1.0).isActive = true
        webView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.view.trailingAnchor, multiplier: 1.0).isActive = true
        
        guard let fileUrl = self.fileGDURL else { return }
        let request = URLRequest(url: fileUrl)
        webView.load(request)
    }
    
    // MARK: - WKWebView delegates

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }

}
