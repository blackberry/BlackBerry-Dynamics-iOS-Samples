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
import AEXML
import EZLoadingActivity

class SoapApplicationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //All objects
    var objectsArray = [AEXMLElement]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EZLoadingActivity.show("Please Wait...", disableUI: true)
        loadData()
    }
    
    //Call API
    func loadData() {
        Global.sharedInstance.MakeSoapApiCall(identifier: Constants.soapIdentifier.userDetail, completion: Completion)
    }
    
    //Called when the data is recieved
    func Completion(data : Data?, response : URLResponse?, error : Error?) -> Void {
        //check if the data is recieved or not
        if error == nil && (response as? HTTPURLResponse)?.statusCode == 200 {
            
            //Pase XML and save in an Array
            let xmlDoc = try! AEXMLDocument(xml: data!, options: .init())
            objectsArray = xmlDoc.root["SOAP-ENV:Body"]["ns2:GetUsersDetailResponse"]["ns2:individualResponses"]["ns2:userDetail"]["ns2:applications"].all!
            EZLoadingActivity.hide(true, animated: true)
            tableView.reloadData()
            
        } else {
            EZLoadingActivity.hide(false, animated: true)
            var err = "Try Again"
            if error?.localizedDescription != nil {
                err = (error?.localizedDescription)! 
            }
            self.ShowAlert(title: "Error", message: err)
        }
    }
    
    //MARK: Delegate and Datasource Functions
    //Returns the number of Rows
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray.count
    }
    
    //Display data in the cell of the table
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = objectsArray[indexPath.row]["ns2:applicationAttributes"]["ns2:localeNameAndDescription"]["ns2:name"].value
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
