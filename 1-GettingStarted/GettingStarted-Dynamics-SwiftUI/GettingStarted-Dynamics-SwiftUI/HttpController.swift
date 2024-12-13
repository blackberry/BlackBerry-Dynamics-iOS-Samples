/* Copyright (c) 2021 BlackBerry Ltd.
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

import SwiftUI
//Include BlackBerryDynamics Libraries
import BlackBerryDynamics.AuthenticationToken

class HttpController: NSObject, ObservableObject, URLSessionDelegate {

    @Published var urlText : String
    @Published var dataReceived : String
    
    override init() {
        //Start with public URL
        self.urlText = "http://www.example.com"
        self.dataReceived = "Data..."
    }
    
    // Requests the data from a specific URL. This can trigger authentication dialogs
    
    func connectToUrl() {
        // First get and check the URL.
        let url = smartURLForString(str: self.urlText)
        let success = (url != nil)
        
        // If the URL is bogus, let the user know.  Otherwise kick off the connection.
        if (!success) {
            
        }
        else {
            // Tell the UI we're receiving.
            
            requestData(url: self.urlText, relaxSSL: false)
        }
    }
    
    func smartURLForString(str : String) -> NSURL? {
        
        var result : NSURL? = nil
        
        let trimmedStr = str.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if trimmedStr.count != 0 {
            let schemeMarkerRange : NSRange = (trimmedStr as NSString).range(of: "://")
            if schemeMarkerRange.location == NSNotFound {
                result = NSURL(string: "http://\(trimmedStr)")!
            } else {
                let scheme = (trimmedStr as NSString).substring(with: NSRange.init(location: 0, length: schemeMarkerRange.location))
                if (scheme as NSString).compare("http", options: .caseInsensitive) == .orderedSame || (scheme as NSString).compare("https", options: .caseInsensitive) == .orderedSame {
                    result = NSURL(string: trimmedStr)!
                } else {
                    
                }
            }
        }
        return result
    }
    
    // Requests the data from a specific URL. This can trigger authentication dialogs
    
    func requestData(url : String, relaxSSL : Bool) {
        
        // Open the request using NSURLConnection or NSURLSession
        
        let nsUrl = URL(string: url)
        let urlRequest = URLRequest(url: nsUrl!)
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.init())
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            DispatchQueue.main.async {
                print(response ?? "No Response")
                print(error?.localizedDescription ?? "No Error")
                
                if data != nil {
                    self.dataReceived = String.init(data: data!, encoding: .utf8) ?? "Data Corrupted"
                }
                
//                self.getDataButton.isEnabled = true
            }
        })
        task.resume()
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        print("connection will send request for authentication challenge")
        
        let authMethod = challenge.protectionSpace.authenticationMethod
        print("Auth method in use: \(authMethod)")
        
        if authMethod == NSURLAuthenticationMethodHTTPBasic || authMethod == NSURLAuthenticationMethodHTTPDigest || authMethod == NSURLAuthenticationMethodNTLM || authMethod == NSURLAuthenticationMethodNegotiate {
                   } else if authMethod == NSURLAuthenticationMethodClientCertificate {
            // Do nothing - GD will automatically supply an appropriate client certificate
        } else if authMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                challenge.sender?.use(URLCredential.init(trust: challenge.protectionSpace.serverTrust!), for: challenge)
            }
            challenge.sender?.continueWithoutCredential(for: challenge)
        }
        
    }
}
