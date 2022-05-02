/* Copyright (c) 2022 BlackBerry Ltd.
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
/* Using Cocoapods Package https://cocoapods.org/pods/SQLite.swift */
import SQLite

class DBViewController: UIViewController {
    
  
    @IBOutlet weak var greenSwitch: UISwitch!
    @IBOutlet weak var blackSwitch: UISwitch!
    @IBOutlet weak var redSwitch: UISwitch!
    @IBOutlet weak var pinkSwitch: UISwitch!
    @IBOutlet weak var blueSwitch: UISwitch!
    
    var switchDBMap: [String: UISwitch] = [:]
    var path:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchDBMap = ["Green": greenSwitch,
                       "Black": blackSwitch,
                       "Red" : redSwitch,
                       "Pink" :  pinkSwitch,
                       "Blue": blueSwitch ]
        //https://github.com/stephencelis/SQLite.swift/issues/635
        let databaseFileName = "dbtest.sqlite3"
        path = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(databaseFileName)"
        initializeDB()
    }
    
    //REFERENCE: This initalization is based on the sample code from https://cocoapods.org/pods/SQLite.swift
    func initializeDB() {
        do {
          
            let db = try Connection(path)
            
            let colors = Table("colors")
            let id = Expression<Int>("id")
            let name = Expression<String>("name")
            let enabled = Expression<Bool>("enabled")
            
            try db.run(colors.create { t in
                t.column(id, primaryKey:true)
                t.column(name, unique: true)
                t.column(enabled)
            })
            
            let colorList = ["Blue", "Red", "Pink", "Black", "Green"]
            
            for color in colorList {
                    
                let insert = colors.insert(name <- color, enabled <- false)
                let _ = try db.run(insert)
            }
            
            
        }
        catch {
            print("Unable to Initalize Database \(error)")
            
        }
    }
    
    //Load Colours deom Database
    @IBAction func loadColours(_ sender: Any) {

        do {
            let db = try Connection(path)
            let colors = Table("colors")
            let name = Expression<String>("name")
            let isEnabled = Expression<Bool>("enabled")

            for color in try db.prepare(colors) {
                let currSwitch = switchDBMap[color[name]]
                let state = color[isEnabled]
                currSwitch!.setOn(state, animated: true)
            }
        }
        catch {
            print ("Unable to update switches from database with error: \(error)")
        }
    }
    
    //Save colours to Database
    @IBAction func saveColours(_ sender: Any) {
        do {
        let db = try Connection(path)
        let colors = Table("colors")
        let name = Expression<String>("name")
        let isEnabled = Expression<Bool>("enabled")

        
        for (key, value) in switchDBMap {
                let colorUpdate = colors.filter(name == key)
            try db.run(colorUpdate.update(isEnabled <- value.isOn))
           }
        }
        catch {
            print("Unable to save color changes: \(error)")
        }
        
    }
    
    @IBAction func clearColours(_ sender: Any) {

        for (_,value) in switchDBMap {
            value.setOn(false, animated: true)
        }
    }
    
    

}
