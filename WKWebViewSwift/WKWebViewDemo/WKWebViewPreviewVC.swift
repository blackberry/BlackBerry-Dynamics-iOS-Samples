  
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
import BlackBerryDynamics.SecureStore.File

class WKWebViewPreviewVC: UIViewController, WKNavigationDelegate, WKUIDelegate {

    
    struct Website : Decodable {
        var url: String
    }
    
    struct ResponseData: Decodable {
        var websites: [Website]
    }
    
    var fileGDURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fileGDURL?.lastPathComponent ?? "Preview"
        
        // Create and load web view
        self.configureWKWebView()
    }
    
    func loadJSON(gdURL fileURL: URL?) -> [Website]? {
                
        let fileManager = GDFileManager.default()
        
        
        // Use GDFileHandle to get data
        var fileHandle = GDFileHandle.init()
        do {
            fileHandle = try GDFileHandle.init(forReadingFrom: fileURL!)
        }
        catch {
            print(error.localizedDescription)
        }
        
        let resData = fileHandle.availableData

        
        let decoder = JSONDecoder()
        let jsonData = try! decoder.decode(ResponseData.self, from: resData)
        return jsonData.websites
        
      
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
        
        /*
            If it's a JSON File, expect it to contain a list of websites to load
         */
        if (fileUrl.pathExtension == "json") {
            
            
            /*
                Use secure storage to access the list of websites
             */
            let websites:[Website]? = loadJSON(gdURL: fileUrl)
            
            /* Currently loading in the first website of the JSON List
                for simiplicty sake. However, you can implement this however you'd like.
             */
            let webRequest = URLRequest(url: URL(string: websites![0].url)!)
            webView.load(webRequest)
        }
        /*
            Otherwise, load the file from secure storage and display it!
            webView.load(Request) will load anything from a website URL to a File @ URL
         */
        else {
            let fileURLRequest = URLRequest(url: fileUrl)
            webView.load(fileURLRequest)
        }
        
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
