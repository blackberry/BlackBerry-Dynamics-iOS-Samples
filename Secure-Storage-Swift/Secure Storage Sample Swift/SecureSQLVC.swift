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
import GD.Runtime
import GD.SecureStore.File
import GD.SecureStore.CoreData
import GD.SecureStore.File
import GD_C.SecureStore.SQLite

class SecureSQLVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    var tableDelegate : reloadTable!
    let SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS Notes(id INTEGER, title varchar(255), detail varchar(255));"
    let SQL_ACCESS_DATA = "SELECT * FROM Notes";
    var sqlite3Database : OpaquePointer? = nil
    var dataArray = NSMutableArray()
    let databaseFilename = "DB.sqlite"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        makeSQL()
    }
    
    //MARK: TableView Delegates and DataSources
    //Return one more cell for Add Button Row
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count + 1
    }
    
    //Create a cell with data
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addButtonCell", for: indexPath)
            let addButton = cell.viewWithTag(2) as! UIButton
            addButton.addTarget(self, action: #selector(SecureSQLVC.saveToSql), for: UIControlEvents.touchUpInside)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTableViewCell
            cell.textField?.delegate = self
            cell.textView?.delegate = self
            cell.textField?.tag = (dataArray[indexPath.row - 1] as! NSDictionary).value(forKey: "id") as! Int
            cell.textView?.tag = (dataArray[indexPath.row - 1] as! NSDictionary).value(forKey: "id") as! Int
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
    
    //delete entry from SQL
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
            if sqlite3_exec(sqlite3Database, "DELETE FROM Notes WHERE id=\(cell.textField.tag);", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
                print(errmsg)
            }
            loadNotes()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    //Check and create the database
    func makeSQL() {
        //create SQL file
        let fileURL = try! GDFileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(databaseFilename)
        //open database connection
        if sqlite3enc_open(fileURL.path, &sqlite3Database) != SQLITE_OK {
            print("error opening database")
        }
        //create table
        if sqlite3_exec(sqlite3Database, SQL_CREATE_TABLE, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
        loadNotes()
    }
    
    //fetch data from the SQL database
    func loadNotes() {
        dataArray = NSMutableArray()
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(sqlite3Database, SQL_ACCESS_DATA, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            let dataDictonary = NSMutableDictionary()
            let id = Int(sqlite3_column_int64(statement, 0))
            dataDictonary.setValue(id, forKey: "id")
            if let name = sqlite3_column_text(statement, 1) {
                let nameString = String(cString: name)
                dataDictonary.setValue(nameString, forKey: "title")
                print(nameString)
            } else {
                print("Data not found")
            }
            if let name = sqlite3_column_text(statement, 2) {
                //update view
                let nameString = String(cString: name)
                dataDictonary.setValue(nameString, forKey: "detail")
                print(nameString)
            } else {
                print("Data not found")
            }
            dataArray.add(dataDictonary)
        }
        tableDelegate.reloadTable()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //Create a new entry to SQL
    @objc func saveToSql() {
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(sqlite3Database, "SELECT * FROM Notes WHERE id=( SELECT max(id) FROM Notes)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
        var id : Int = -1
        //add one to create a unique value in the database
        while sqlite3_step(statement) == SQLITE_ROW {
            id = Int(sqlite3_column_int64(statement, 0)) + 1
        }
        if sqlite3_exec(sqlite3Database, "INSERT INTO Notes (id, title, detail) VALUES (\(id), \"New Note\", \"Details\");", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
        loadNotes()
    }
    
    //MARK: TextField and TextView Delegates
    //Save if the TextField was changed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    //Save if the TextView was changed
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //Save if the TextField was changed
    func textFieldDidEndEditing(_ textField: UITextField) {
        if sqlite3_exec(sqlite3Database, "UPDATE Notes SET title = \"\(textField.text!)\"WHERE id = \(textField.tag);", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
    }
    
    //Save if the TextView was changed
    func textViewDidEndEditing(_ textView: UITextView) {
        if sqlite3_exec(sqlite3Database, "UPDATE Notes SET detail = \"\(textView.text!)\"WHERE id = \(textView.tag);", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
    }
}
