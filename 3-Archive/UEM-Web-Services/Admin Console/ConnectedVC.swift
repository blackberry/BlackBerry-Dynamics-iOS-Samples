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

class ConnectedVC: UIViewController {

    @IBOutlet weak var statusText: UILabel!
    
    @IBOutlet weak var applicationsOutlet: UIButton!
    
    @IBOutlet weak var groupsOutlet: UIButton!
    
    @IBOutlet weak var usersOutlet: UIButton!
    
    var url = ""

    var groupsArray = [Groups]()
    
    var applicationArray = [Applications]()
    
    //Get the groups with the REST API
    @IBAction func getGroups(_ sender: Any) {
        Global.sharedInstance.gOrA = Constants.groupOrApplication.group
        url = Global.sharedInstance.url.replacingOccurrences(of: "util/ping", with: "groups")
        EZLoadingActivity.show("Please Wait", disableUI: true)
        Global.sharedInstance.MakeRESTAPICall(url: url, method: "GET", iden: Constants.restIdentifier.withHeader, httpBody: nil,completion: Completion )
    }
    
    //Get the applications wuth the REST API
    @IBAction func getApplications(_ sender: Any) {
        Global.sharedInstance.gOrA = Constants.groupOrApplication.application
        url = Global.sharedInstance.url.replacingOccurrences(of: "util/ping", with: "applications")
        EZLoadingActivity.show("Please Wait", disableUI: true)
        Global.sharedInstance.MakeRESTAPICall(url: url, method: "GET", iden: Constants.restIdentifier.withHeader, httpBody: nil,completion: Completion )
    }
    
    //Show action sheet to choose between SOAP and REST API
    @IBAction func searchUsers(_ sender: Any) {
        
        let actionSheet: UIAlertController = UIAlertController(title: "Please select", message: "", preferredStyle: .actionSheet)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheet.addAction(cancelActionButton)
        
        let saveActionButton: UIAlertAction = UIAlertAction(title: "Use REST Api", style: .default)
        { action -> Void in
            self.RestApiUsers()
        }
        actionSheet.addAction(saveActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: "Use SOAP Api", style: .default)
        { action -> Void in
            self.SoapApiUsers()
        }
        actionSheet.addAction(deleteActionButton)
        
        actionSheet.popoverPresentationController?.sourceView = sender as? UIButton
        self.present(actionSheet, animated: true, completion: nil)

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusText.text = Global.sharedInstance.connectedResponse
    }
    
    //Called when data is returned either groups or applications
    func Completion(data : Data?, response : URLResponse?, error : Error?) -> Void {
        if error == nil && (response as! HTTPURLResponse).statusCode == 200 {
            
            EZLoadingActivity.hide(true, animated: true)
            
            if Global.sharedInstance.gOrA == Constants.groupOrApplication.application {
                let objectDictionary = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                applicationArray.removeAll(keepingCapacity: false)
                for obj in (objectDictionary.object(forKey: "applications") as! NSArray) {
                    applicationArray.append(Applications(guid: ((obj as! NSDictionary).object(forKey: "guid")) as! String, name: ((obj as! NSDictionary).object(forKey: "name")) as! String))
                }
                Global.sharedInstance.applicationsArray = self.applicationArray
            } else if Global.sharedInstance.gOrA == Constants.groupOrApplication.group {
                let objectDictionary = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                groupsArray.removeAll(keepingCapacity: false)
                for obj in (objectDictionary.object(forKey: "groups") as! NSArray) {
                    groupsArray.append(Groups(guid: ((obj as! NSDictionary).object(forKey: "guid")) as! String, name: ((obj as! NSDictionary).object(forKey: "name")) as! String, dl: ((obj as! NSDictionary).object(forKey: "directoryLinked")) as! Bool))
                }
                Global.sharedInstance.groupsArray = self.groupsArray
            }
            
            self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "responseViewController"))!, animated: true)
            
        } else {
            EZLoadingActivity.hide(false, animated: true)
            var err = "Try Again"
            if error?.localizedDescription != nil {
                err = (error?.localizedDescription)! 
            }
            self.ShowAlert(title: "Error", message: err)
        }
    }
    
    //Pushes the View Controller
    func RestApiUsers()  {
        self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "searchVC"))!, animated: true)
    }
    
    //Pushes the View COntroller 
    func SoapApiUsers() {
        self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "usersVC"))!, animated: true)
    }

}
