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

class SoapUserVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var loginNameText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var displayNameText: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //All elements
    var objectsArray = [AEXMLElement]()
    
    //Push view controller to show applications
    @IBAction func GetApplications(_ sender: Any) {
        self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "soapApplicationsVC"))!, animated: true)
    }
    
    //Display data
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameText.text = Global.sharedInstance.soapUser["ns2:displayName"].value
        emailText.text = Global.sharedInstance.soapUser["ns2:emailAddresses"].value
        loginNameText.text = Global.sharedInstance.soapUser["ns2:basLoginName"].value
        
    }
    
    //Add a label if no device is found
    override func viewDidLayoutSubviews() {
        if Global.sharedInstance.soapUser.xml.contains("ns2:devices") {
            objectsArray = Global.sharedInstance.soapUser["ns2:devices"].all!
            tableView.reloadData()
        } else {
            let label = UILabel(frame: tableView.frame)
            label.backgroundColor = UIColor.white
            label.textAlignment = .center
            label.text = "NO DEVICE"
            self.view.addSubview(label)
        }
    }
    
    //MARK: Delegate and Datasource Functions
    //Returns the number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = objectsArray[indexPath.row]["ns2:model"].value
        return cell
    }
    
    //Display header of the section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Devices"
    }
    
    //Push a new Navigation Controller when a row is selected 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Global.sharedInstance.soapDeviceState = objectsArray[indexPath.row]
        self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "deviceDetailVC"))!, animated: true)
    }
    
}
