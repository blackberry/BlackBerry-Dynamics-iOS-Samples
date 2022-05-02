/* Copyright (c) 2016 BlackBerry Ltd.
*
* Licensed under the Apache License, Version 2.0 (the "License")
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

import Foundation
import WebKit

class WKWebViewViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    let forwardBarItem = UIBarButtonItem(title: ">", style: .plain, target: self,
                                         action: #selector(forwardAction))
    let backBarItem = UIBarButtonItem(title: "<", style: .plain, target: self,
                                      action: #selector(backAction))
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
        
    }()
    
    @objc func forwardAction() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
        
    @objc func backAction() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    func setupUI() {
            self.view.backgroundColor = .white
            self.view.addSubview(webView)
            
            NSLayoutConstraint.activate([
                webView.topAnchor
                    .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                webView.leftAnchor
                    .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
                webView.bottomAnchor
                    .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                webView.rightAnchor
                    .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
            ])
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavItem()
        let myURL = URL(string: "https://www.blackberry.com/us/en/products/blackberry-dynamics/platform")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
        
    func setupNavItem() {
        self.navigationItem.leftBarButtonItem = backBarItem
        self.navigationItem.rightBarButtonItem = forwardBarItem
    }
        
    func setupNavBar() {
        self.navigationController?.navigationBar.tintColor = .white
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
