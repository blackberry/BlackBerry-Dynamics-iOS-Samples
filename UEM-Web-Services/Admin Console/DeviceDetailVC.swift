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

class DeviceDetailVC: UIViewController {

    @IBOutlet weak var modelText: UILabel!
    @IBOutlet weak var pVersionText: UILabel!
    @IBOutlet weak var policySentText: UILabel!
    @IBOutlet weak var imeiText: UILabel!
    @IBOutlet weak var lastContactedText: UILabel!
    
    //Call the API to delete a device
    @IBAction func deleteDevice(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are You Sure?", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            EZLoadingActivity.show("Please Wait...", disableUI: true)
            Global.sharedInstance.MakeSoapApiCall(identifier: Constants.soapIdentifier.deviceWipe, completion: self.Completion)
        })
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
        })
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    
    }
    
    //Parse data and show on the Labels
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modelText.text = Global.sharedInstance.soapDeviceState["ns2:model"].value
        pVersionText.text = Global.sharedInstance.soapDeviceState["ns2:platformVersion"].value
        policySentText.text = Global.sharedInstance.soapDeviceState["ns2:itPolicyDateSent"].value
        imeiText.text = Global.sharedInstance.soapDeviceState["ns2:imei"].value
        lastContactedText.text = Global.sharedInstance.soapDeviceState["ns2:lastContactDate"].value
    }

    //Called when device is deleted and the navigation controller pushes three View Controllers to reload the data.
    func Completion(data : Data?, response : URLResponse?, error : Error?) -> Void {
        if error == nil && (response as! HTTPURLResponse).statusCode == 200 {
            
            
            let xmlDoc = try! AEXMLDocument(xml: data!, options: .init())
            
            if xmlDoc.root["SOAP-ENV:Body"]["ns2:SetDevicesWipeResponse"]["ns2:returnStatus"]["ns2:code"].value == "SUCCESS" {
                EZLoadingActivity.hide(true, animated: true)
                
                _ = self.navigationController?.popViewController(animated: true)
                _ = self.navigationController?.popViewController(animated: true)
                _ = self.navigationController?.popViewController(animated: true)
            } else {
                EZLoadingActivity.hide(false, animated: true)
                
                let err = xmlDoc.root["SOAP-ENV:Body"]["ns2:SetDevicesWipeResponse"].xml
                
                self.ShowAlert(title: "Error", message: err)
            }
            
        } else {
            EZLoadingActivity.hide(false, animated: true)
            var err = "Try Again"
            if error?.localizedDescription != nil {
                err = (error?.localizedDescription)! 
            }
            self.ShowAlert(title: "Error", message: err)
        }
    }

}
