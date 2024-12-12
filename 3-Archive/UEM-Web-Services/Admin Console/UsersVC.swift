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

class UsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //All objects
    var objectsArray = [AEXMLElement]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Get Users after the view is loaded
    override func viewDidAppear(_ animated: Bool) {
        EZLoadingActivity.show("Please Wait...", disableUI: true)
        Global.sharedInstance.MakeSoapApiCall(identifier: Constants.soapIdentifier.getUsers, completion: Completion)
    }
    
    //Called when the data is returned
    func Completion(data : Data?, response : URLResponse?, error : Error?) -> Void {
        
        EZLoadingActivity.hide(true, animated: true)
        
        if (response as! HTTPURLResponse).statusCode == 200 {
            let xmlDoc = try! AEXMLDocument(xml: data!, options: .init())
            objectsArray = xmlDoc.root["SOAP-ENV:Body"]["ns2:GetUsersResponse"]["ns2:users"].all!
            tableView.reloadData()
        } else {
            self.ShowAlert(title: "Error", message: "Wrong Information Entered")
        }
    }
    
    //MARK: Delegate and Datasource Functions
    //Returns the number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray.count
    }
    
    //Display data in the cell of the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = objectsArray[indexPath.row]["ns2:displayName"].value
        return cell
    }

    //Push a view controller when a row is selected in the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Global.sharedInstance.soapUser = objectsArray[indexPath.row]
        self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "soapUserVC"))!, animated: true)
    }
}
