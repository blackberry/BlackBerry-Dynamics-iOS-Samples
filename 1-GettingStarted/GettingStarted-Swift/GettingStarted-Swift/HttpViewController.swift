/* Copyright (c) 2022 BlackBerry Ltd.
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

class HttpViewController: UIViewController, URLSessionDelegate {
    
    var usernameText : UITextField?
    
    var passwordText : UITextField?
    
    @IBOutlet weak var getDataButton: UIButton!
    @IBOutlet weak var dataRecievedTextView: UITextView!
    
    @IBOutlet weak var urlText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Start with public URL
        self.urlText.text = "http://www.example.com"
        
    }
    
    //MARK: Request Control
    
    // Requests the data from a specific URL. This can trigger authentication dialogs
    
    @IBAction func connectToUrl(_ sender: Any) {
        // First get and check the URL.
        let url = smartURLForString(str: self.urlText.text!)
        let success = (url != nil)
        
        // If the URL is bogus, let the user know.  Otherwise kick off the connection.
        if (!success) {
            
        }
        else {
            // Tell the UI we're receiving.
            
            requestData(url: self.urlText.text!, relaxSSL: false)
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
        
        //Open the request using NSURLConnection or NSURLSession
        
        let nsUrl = URL(string: url)
        let urlRequest = URLRequest(url: nsUrl!)
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.init())
        
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            DispatchQueue.main.async {
                print(response ?? "No Response")
                print(error?.localizedDescription ?? "No Error")
                
                if data != nil {
                    self.dataRecievedTextView.text = String.init(data: data!, encoding: .utf8)
                }
                
                self.getDataButton.isEnabled = true;
            }
        })
        task.resume()
    }
    
}
