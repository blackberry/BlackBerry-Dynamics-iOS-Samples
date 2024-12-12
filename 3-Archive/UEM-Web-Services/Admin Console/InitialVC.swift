/* Copyright (c) 2017 BlackBerry Ltd.
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
import EZLoadingActivity
import AEXML

class InitialVC: UIViewController {

    @IBOutlet weak var urlText: UITextField!
    
    @IBOutlet weak var providerText: UITextField!
    
    @IBOutlet weak var authText: UITextField!
    
    @IBOutlet weak var tenantText: UITextField!
    
    @IBOutlet weak var usernameText: UITextField!
    
    @IBOutlet weak var passText: UITextField!
    
    var url = ""
    
    //Push view controller
    @IBAction func about(_ sender: UIButton) {
        self.present((self.storyboard?.instantiateViewController(withIdentifier: "aboutVC"))!, animated: true, completion: nil)
    }
    
    //Connect to the server to check if the server is up and running and the fields are correct
    @IBAction func connectButton(_ sender: UIButton) {
        
        if ((urlText.text?.isEmpty)! || (providerText.text?.isEmpty)! || (authText.text?.isEmpty)! || (tenantText.text?.isEmpty)! || (usernameText.text?.isEmpty)! || (passText.text?.isEmpty)!) {
            self.ShowAlert(title: "Alert", message: "All Fields Required")
        } else {
            
            let lastChar = urlText.text![urlText.text!.index(before: urlText.text!.endIndex)]
            
            if lastChar != "/" {
                urlText.text = urlText.text! + "/"
            }
            
            EZLoadingActivity.show("Please Wait", disableUI: true)
            
            url = urlText.text! + tenantText.text! + "/api/v1/util/ping"
            
            Global.sharedInstance.MakeRESTAPICall(url: url, method : "GET", iden: Constants.restIdentifier.withHeader, httpBody: nil, completion: CompletionCheckServer)
        }
        
    }
    
    //Fetch saved values
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.sharedInstance.GetDefaults(completion: {
            dictionary in
            self.urlText.text = dictionary.value(forKey: "url") as! String?
            self.authText.text = dictionary.value(forKey: "auth") as! String?
            self.providerText.text = dictionary.value(forKey: "provider") as! String?
            self.tenantText.text = dictionary.value(forKey: "tenant") as! String?
            self.usernameText.text = dictionary.value(forKey: "user") as! String?
            self.passText.text = dictionary.value(forKey: "pass") as! String?
        })
    }
    
    //Save the values to Global Class
    func Save(url : String) {
        
        let val = ["url":urlText.text!,"provider":providerText.text!,"auth":authText.text!,"tenant":tenantText.text!,"user":usernameText.text!,"pass":passText.text!]
        
        Global.sharedInstance.SaveValues(val: val as NSDictionary)
        
        Global.sharedInstance.url = url
    }
    
    //Called when server checking API returns and calls the get encoded username API
    func CompletionCheckServer(data : Data?, response : URLResponse?, error : Error?) -> Void {
        if (error == nil) {
            if (response as! HTTPURLResponse).statusCode == 200 {
                Global.sharedInstance.connectedResponse = String.init(data: data!, encoding: String.Encoding.utf8)!
                Global.sharedInstance.MakeRESTAPICall(url: url.replacingOccurrences(of: "ping", with: "authorization"), method: "POST", iden: Constants.restIdentifier.getHeader, httpBody: "{ \"provider\" : \"\(self.providerText.text!)\", \"username\" : \"\(self.usernameText.text!)\", \"password\" : \"\(self.passText.text!.toBase64())\" }", completion: CompletionGetEncodedUserName)
               
            } else {
                EZLoadingActivity.hide(false, animated: true)
                self.ShowAlert(title: "Error", message: "Check Data")
            }
        } else {
            EZLoadingActivity.hide(false, animated: true)
            self.ShowAlert(title: "Error", message: (error?.localizedDescription)! )
        
        }
    }
    
    //Called when the encoded username API returns and calls the SOAP API to get the encoded username
    func CompletionGetEncodedUserName(data : Data?, response : URLResponse?, error : Error?) -> Void {
    
        if (error == nil) {
            if (response as! HTTPURLResponse).statusCode == 200 {
                
                Global.sharedInstance.restHeaderString = String.init(data: data!, encoding: .utf8)!
                
                Global.sharedInstance.username = usernameText.text!
                
                let soapExtension = "/enterprise/admin/util/ws"
                
                let host = url.components(separatedBy: "/")
                
                Global.sharedInstance.soapUrl = "https://\(host[2])\(soapExtension)"
                
                Global.sharedInstance.soapHost = host[2]
                
                Global.sharedInstance.MakeSoapApiCall(identifier: Constants.soapIdentifier.getAuthHeader, completion: CompletionSoapAuthHeader)
            }
            else {
                EZLoadingActivity.hide(false, animated: true)
                self.ShowAlert(title: "Error", message: "Check Data")
            }
        }
        else {
            EZLoadingActivity.hide(false, animated: true)
            self.ShowAlert(title: "Error", message: (error?.localizedDescription)! )
        }
    }
    
    //Called when SOAP api returns the encoded username and pushes the view controller and saves the values in Global class
    func CompletionSoapAuthHeader(data : Data?, response : URLResponse?, error : Error?) -> Void {
        if (response as! HTTPURLResponse).statusCode == 200 {
            
            let xmlDoc = try! AEXMLDocument(xml: data!, options: .init())
            
            let soapExtension = "/enterprise/admin/ws"
            
            let host = url.components(separatedBy: "/")
            
            Global.sharedInstance.soapUrl = "https://\(host[2])\(soapExtension)"
            
            Global.sharedInstance.soapHost = host[2]
            
            Global.sharedInstance.password = passText.text!
            
            Global.sharedInstance.soapHeaderStringUserName = xmlDoc["SOAP-ENV:Envelope"]["SOAP-ENV:Body"]["ns2:GetEncodedUsernameResponse"]["ns2:encodedUsername"].value!
            
            self.Save(url : self.url)
            EZLoadingActivity.hide(true, animated: true)
            self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "secondViewController"))!, animated: true)
            
            
        } else {
            self.ShowAlert(title: "Error", message: "Wrong Information Entered")
        }
    }

}

