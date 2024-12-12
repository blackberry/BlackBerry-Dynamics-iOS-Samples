/* Copyright (c) 2018 BlackBerry Ltd.
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
import BlackBerryDynamics.Runtime
import BlackBerryDynamics.SecureStore.File
import BlackBerryDynamics.SecureStore.CoreData

class SecureCoreDataVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var tableDelegate : reloadTable!
    
    var coreDataContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    //Array to store the data for table view
    var dataArray = [NSManagedObject]()
    
    //load all the data from Core Data
    func fetch() {
        let notesFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        notesFetch.returnsObjectsAsFaults = false
        notesFetch.includesPropertyValues = false
        do {
            dataArray = try coreDataContext.fetch(notesFetch) as! [NSManagedObject]
        } catch {
            fatalError("Failed to fetch employees: \(error)")
        }
    }
    
    //respond to the touch event and resign the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.resignFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: TableView Delegates and DataSources
    //Return one more cell for Add Button Row
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetch()
        return dataArray.count + 1
    }
    
    //Create cell with data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addButtonCell", for: indexPath)
            let addButton = cell.viewWithTag(2) as! UIButton
            addButton.addTarget(self, action: #selector(SecureCoreDataVC.save), for: UIControlEvents.touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTableViewCell
            cell.textField?.delegate = self
            cell.textView?.delegate = self
            cell.textField?.tag = indexPath.row - 1
            cell.textView?.tag = indexPath.row - 1
            cell.textField?.text = (dataArray[indexPath.row - 1] as AnyObject).value(forKey: "title") as? String
            cell.textView?.text = (dataArray[indexPath.row - 1] as AnyObject).value(forKey: "detail") as? String
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else {
            return true
        }
    }
    
    //delete entry from Core Data
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            coreDataContext.delete(dataArray[indexPath.row - 1])
            do {
                try! coreDataContext.save()
            }
            self.tableDelegate.reloadTable()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //MARK: TextField and TextView Delegates
    //Resign Keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    //Resign Keyboard when return is pressed
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //Save if the TextField was changed
    func textFieldDidEndEditing(_ textField: UITextField) {
        dataArray[textField.tag].setValue(textField.text, forKey: "title")
        
        do {
            try coreDataContext.save()
        }
        catch let err as NSError {
            print(err.localizedDescription)
        }
    }
    
    //Save if the TextView was changed
    func textViewDidEndEditing(_ textView: UITextView) {
        dataArray[textView.tag].setValue(textView.text, forKey: "detail")
        do {
            try coreDataContext.save()
        }
        catch let err as NSError {
            print(err.localizedDescription)
        }
    }
    
    //Create a new entry
    @objc public func save() {
        let notes = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: coreDataContext)
        
        notes.setValue("New Note", forKey: "title")
        notes.setValue("Details", forKey: "detail")
        
        do {
            try coreDataContext.save()
            self.tableDelegate.reloadTable()
        }
        catch let err as NSError {
            print(err.localizedDescription)
        }
    }
}
