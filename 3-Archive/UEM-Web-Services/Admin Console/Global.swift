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

import Foundation
import UIKit
import GD.SecureStore.File
import AEXML

//Extenstion to show the use the alert function only once in the Application
extension UIViewController {
    
    func ShowAlert(title :String, message : String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//Extention to get base64 encoding of a string
extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

//Singleton Class to use in the app so that view controllers can talk to each other
class Global : NSObject, URLSessionDelegate {
    static let sharedInstance: Global = { Global() }()
    
    let FileName = "UserInputs.txt"
    
    var connectedResponse = ""
    
    var url = ""
    
    var restHeaderString = ""
    
    var soapHeaderStringUserName = ""
    
    var groupsArray = [Groups]()
    
    var gOrA : Constants.groupOrApplication = Constants.groupOrApplication.null
    
    var applicationsArray = [Applications]()
    
    var soapUrl = ""
    
    var soapHost = ""
    
    var username = ""
    
    var password = ""
    
    var user = User(uName: "", fName: "", lName: "", dName: "", email: "")
    
    var soapUser = AEXMLElement.init(name: "sample")
    
    var soapDeviceState = AEXMLElement.init(name: "sample")
    
    //Function to make REST calls
    func MakeRESTAPICall(url :String, method: String, iden: Constants.restIdentifier , httpBody : String?, completion: @escaping (_ data : Data?,_ response : URLResponse? , _ error : Error?) -> Void) -> Void {
        
        let headervalue = restHeaderString
        
        let request : NSURLRequest = NSURLRequest(url: NSURL(string: url)! as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        
        let req = request.mutableCopy() as! NSMutableURLRequest
        
        req.cachePolicy = .reloadIgnoringCacheData
        
        URLCache.shared.removeAllCachedResponses()
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        req.httpMethod = method
        
        if iden == Constants.restIdentifier.checkServer {
            
        } else if iden == Constants.restIdentifier.getHeader {
            req.addValue("application/vnd.blackberry.authorizationrequest-v1+json", forHTTPHeaderField: "Content-Type")
            req.httpBody = httpBody!.data(using: .utf8)
        } else if iden == Constants.restIdentifier.withHeader {
            req.addValue(headervalue, forHTTPHeaderField: "Authorization")
        }
        let task = session.dataTask(with: req as URLRequest, completionHandler: {data, response, error -> Void in
            completion(data, response, error)
        })
        
        task.resume()
    }
    
    //Function to make SOAP calls
    func MakeSoapApiCall(identifier : Constants.soapIdentifier, completion: @escaping (_ data : Data?,_ response : URLResponse? , _ error : Error?) -> Void) -> Void {
        
        let loginString = String(format: "%@:%@", soapHeaderStringUserName, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        let url = NSURL(string: self.soapUrl)
        let theRequest = NSMutableURLRequest(url: url! as URL)
        theRequest.httpMethod = "POST"
        theRequest.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let soapElement = SoapXml()
        
        var xml = AEXMLDocument()
        
        if identifier == Constants.soapIdentifier.getUsers {
            xml = soapElement.XMLDataForUsers()
        } else if identifier == Constants.soapIdentifier.deviceWipe {
            xml = soapElement.XMLDataToWipeDevice()
        } else if identifier == Constants.soapIdentifier.userDetail {
            xml = soapElement.XMLDataToGetApplicationsDevice()
        } else if identifier == Constants.soapIdentifier.getAuthHeader {
            xml = soapElement.XMLDataToGetAuthHeader(username: username)
        }
        
        let msgLength = xml.xml.characters.count
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(soapHost, forHTTPHeaderField: "Host")
        theRequest.addValue("gzip,deflate", forHTTPHeaderField: "Accept-Encoding")
        theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        theRequest.addValue("Keep-Alive", forHTTPHeaderField: "Connection")
        theRequest.httpBody = xml.xml.data(using: String.Encoding.utf8, allowLossyConversion: false)
    
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: theRequest as URLRequest, completionHandler: {data, response, error -> Void in
            completion(data, response, error)
        })
        
        task.resume()
        
    }
    
    //Delegate method of URLSession to give SOAP API username and password
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
        let authMethod = challenge.protectionSpace.authenticationMethod
            if authMethod == NSURLAuthenticationMethodHTTPBasic {
            let cre = URLCredential.init(user: soapHeaderStringUserName, password: password, persistence: .forSession)
            completionHandler(.useCredential, cre)
        }
        
    }
    
    //Fetch values from a file
    func GetDefaults(completion: @escaping (_ values : NSDictionary) -> Void) {
        
        let filePath = documentsFolderPathForNamed(name: FileName)
        
        let fileManager = GDFileManager.default()
        
        if fileManager.fileExists(atPath: filePath) {
            let dictionaryData = fileManager.contents(atPath: filePath)!
            let dictionary  = try! PropertyListSerialization.propertyList(from: dictionaryData, options: .mutableContainers, format: nil) as! [String : String]
            completion(dictionary as NSDictionary)
            
        } else {
            let val = ["url":"","provider":"","auth":"","tenant":"","user":"","pass":""]
            let valData = try! PropertyListSerialization.data(fromPropertyList: val, format: .binary, options: 0) as Data
            fileManager.createFile(atPath: filePath, contents: valData, attributes: nil)
            completion(val as NSDictionary)
        }
    }
    
    //Save the values in a file
    func SaveValues(val : NSDictionary) {
        let filePath = documentsFolderPathForNamed(name: FileName)
        let fileManager = GDFileManager.default()
        let valData = try! PropertyListSerialization.data(fromPropertyList: val, format: .binary, options: 0) as Data
        fileManager.createFile(atPath: filePath, contents: valData, attributes: nil)
        
    }
    
    //Get the path where to store the file
    func documentsFolderPathForNamed(name : String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory.appending(name)
    }
}
