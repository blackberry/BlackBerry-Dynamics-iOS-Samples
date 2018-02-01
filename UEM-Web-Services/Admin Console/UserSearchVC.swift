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

class UserSearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var url = ""
    
    var searchedData = NSArray()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    //Create the url
    override func viewDidLoad() {
        super.viewDidLoad()
        
        url = Global.sharedInstance.url.replacingOccurrences(of: "util/ping", with: "directories/users?includeExistingUsers=true&search=")
        searchBar.delegate = self
    }
    
    //MARK: Delegate and Datasource Functions
    //Returns the number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedData.count
    }
    
    //Display the data in the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = (searchedData.object(at: indexPath.row) as! NSDictionary).value(forKey: "displayName") as? String
        return cell
    }
    
    //Delegate method of the searchbar, called when the text is changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchedData = NSArray()
            tableView.reloadData()
        } else {
            Global.sharedInstance.MakeRESTAPICall(url: (url + searchText).replacingOccurrences(of: " ", with: "%20"), method: "GET", iden: Constants.restIdentifier.withHeader, httpBody: nil, completion: Completion)
        }
    }
    
    //Parse data and and push a view controller 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Global.sharedInstance.user = User(uName: (searchedData.object(at: indexPath.row) as! NSDictionary).value(forKey: "username") as! String, fName: (searchedData.object(at: indexPath.row) as! NSDictionary).value(forKey: "firstName") as! String, lName: (searchedData.object(at: indexPath.row) as! NSDictionary).value(forKey: "lastName") as! String, dName: (searchedData.object(at: indexPath.row) as! NSDictionary).value(forKey: "displayName") as! String, email: (searchedData.object(at: indexPath.row) as! NSDictionary).value(forKey: "emailAddress") as! String)
        
        self.navigationController?.pushViewController((self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsVC"))!, animated: true)
    }
    
    //Called when the user data is returned
    func Completion(data : Data?, response : URLResponse?, error : Error?) -> Void {
        if error == nil && (response as! HTTPURLResponse).statusCode == 200 {
            searchedData = try! (JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary).object(forKey: "directoryUsers") as! NSArray
            tableView.reloadData()
        } else {
            self.ShowAlert(title: "Error", message: "Try Again")
        }
    }
    

    
}
