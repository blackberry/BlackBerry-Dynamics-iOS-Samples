/* Copyright (c) 2016 BlackBerry Ltd.
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

// Add Secure SQLite/GDFileManager
import GD.SecureStore.File
import GD_C.SecureStore.SQLite

class DBViewController: UIViewController {
    
    let SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS Colours(ColorID INTEGER, Favourite INTEGER);"
    
    let SQL_ACCESS_DATA = "SELECT * FROM Colours";
    
    var documentsDirectory = ""
    
    var sqlite3Database : OpaquePointer? = nil
    
    let tagsArray = [2,4,6,8,10]
    
    let databaseFilename = "DB.sqlite"
    
    let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    @IBOutlet weak var greenSwitch: UISwitch!
    @IBOutlet weak var blackSwitch: UISwitch!
    @IBOutlet weak var redSwitch: UISwitch!
    @IBOutlet weak var pinkSwitch: UISwitch!
    @IBOutlet weak var blueSwitch: UISwitch!
    
    //Load Colours deom Database
    @IBAction func loadColours(_ sender: Any) {
        
        var statement: OpaquePointer? = nil
        //Execute Query
        if sqlite3_prepare_v2(sqlite3Database, SQL_ACCESS_DATA, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
        //Get the data
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            //get the switch from view
            let switc = self.view.viewWithTag(Int(id)) as! UISwitch

            if let name = sqlite3_column_text(statement, 1) {
                //update view
                let nameString = String(cString: name)
                if nameString == "0" {
                    switc.setOn(false, animated: true)
                } else {
                    switc.setOn(true, animated: true)
                }
            } else {
                print("Data not found")
            }
        }
    }
    
    //Save colours to Database
    @IBAction func saveColours(_ sender: Any) {
        
        for i in tagsArray {
            
            let switc = self.view.viewWithTag(i) as! UISwitch
            
            var value = ""
            
            if switc.isOn {
                value = "1"
            } else {
                value = "0"
            }
            
            var updateStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(sqlite3Database, "UPDATE Colours SET Favourite = \(value) WHERE ColorID = \(i)", -1, &updateStatement, nil) == SQLITE_OK {
                if sqlite3_step(updateStatement) == SQLITE_DONE {
                    print("Successfully updated row.")
                } else {
                    print("Could not update row.")
                }
            } else {
                print("UPDATE statement could not be prepared")
            }
            sqlite3_finalize(updateStatement)
        }
    }
    
    //Reset the switches
    @IBAction func clearColours(_ sender: Any) {
        for i in [2,4,6,8,10] {
            let switc = self.view.viewWithTag(i) as! UISwitch
            switc.setOn(false, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeDB()
    }
    
    
    //Initialize the Database
    func initializeDB() {
        
        let fileURL = try! GDFileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(databaseFilename)
        
        print(GDFileManager.getAbsoluteEncryptedPath(fileURL.path)!)
        
        // Open secure SQL databse
        
        if sqlite3enc_open(fileURL.path, &sqlite3Database) != SQLITE_OK {
            print("error opening database")
        }
        
        //  Create database table if it doesn't exist.
        
        if !checkIfDataAvailable() {
            populateData()
        }
    }
    
    //Add initial data to Database
    func populateData() {
        
        if sqlite3_exec(sqlite3Database, SQL_CREATE_TABLE, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
        
        var statement: OpaquePointer? = nil
        
        for i in tagsArray {
            
            if sqlite3_prepare_v2(sqlite3Database, "insert into Colours values (?,?)", -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
                print(errmsg)
            }
            
            if sqlite3_bind_text(statement, 1, "\(i)", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
                print(errmsg)
            }
            
            if sqlite3_bind_text(statement, 2, "0", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
                print(errmsg)
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
                print(errmsg)
            }
            
            if sqlite3_finalize(statement) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
                print(errmsg)
            }
        }
    }
    
    //check if the table is empty or not
    func checkIfDataAvailable() -> Bool {
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(sqlite3Database, SQL_ACCESS_DATA, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
        
        var dataExists = false
        
        while sqlite3_step(statement) == SQLITE_ROW {
            dataExists = true
        }
        return dataExists
    }
    
    
}
