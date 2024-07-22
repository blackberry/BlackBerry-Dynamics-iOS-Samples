/* Copyright (c) 2021 BlackBerry Ltd.
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

import SwiftUI

// Add Secure SQLite/GDFileManager
import BlackBerryDynamics.SecureStore.File
import GD_C.SecureStore.SQLite

class DBController: ObservableObject {
    
    @Published var isBlueOn : Bool
    @Published var isRedOn : Bool
    @Published var isBlackOn : Bool
    @Published var isPinkOn : Bool
    @Published var isGreenOn : Bool
    
    private let SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS Colours(ColorID INTEGER, Favourite INTEGER);"
    
    private let SQL_ACCESS_DATA = "SELECT * FROM Colours";
    
    private var documentsDirectory = ""
    
    private var sqlite3Database : OpaquePointer? = nil
    
    private let tagsArray = [2,4,6,8,10]
    
    private let databaseFilename = "DB.sqlite"
    
    private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    init() {
        self.isBlueOn = false
        self.isRedOn = false
        self.isBlackOn = false
        self.isPinkOn = false
        self.isGreenOn = false
        self.initializeDB()
    }
    
    //Load Colours from Database
    func loadColours() {
        
        var statement: OpaquePointer? = nil
        //Execute Query
        if sqlite3_prepare_v2(sqlite3Database, SQL_ACCESS_DATA, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(sqlite3Database))
            print(errmsg)
        }
        //Get the data
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int64(statement, 0)
            if let name = sqlite3_column_text(statement, 1) {
                //update view
                let nameString = String(cString: name)
                if nameString == "0" {
                    setColorToggleValue(id: Int(id), isOn: false)
                } else {
                    setColorToggleValue(id: Int(id), isOn: true)
                }
            } else {
                print("Data not found")
            }
        }
    }
    
    //Save colours to Database
    func saveColours() {
        
        for i in tagsArray {
            
            let value = getColorToggleValue(id: i) ? 1 : 0
            
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
    func clearColours() {
        self.isBlueOn = false
        self.isRedOn = false
        self.isBlackOn = false
        self.isPinkOn = false
        self.isGreenOn = false
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
        
        //  if Database exists load colour values, else create Database
        
        if checkIfDataAvailable() {
            loadColours()
        } else {
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
    
    func setColorToggleValue(id : Int, isOn : Bool) {
        if (id == 2) {
            self.isBlueOn = isOn
        } else if (id == 4) {
            self.isRedOn = isOn
        } else if (id == 6) {
            self.isBlackOn = isOn
        } else if (id == 8) {
            self.isPinkOn = isOn
        } else if (id == 10) {
            self.isGreenOn = isOn
        }
    }
    
    func getColorToggleValue(id : Int) -> Bool {
        
        if (id == 2) {
            return self.isBlueOn
        } else if (id == 4) {
            return self.isRedOn
        } else if (id == 6) {
            return self.isBlackOn
        } else if (id == 8) {
            return self.isPinkOn
        } else if (id == 10) {
            return self.isGreenOn
        }
        
        return false
    }
}
