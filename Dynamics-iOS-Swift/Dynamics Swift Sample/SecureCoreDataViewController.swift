/* Copyright (c) 2016 BlackBerry Ltd.
*
* Licensed under the Apache License, Version 2.0 (the "License")
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

import Foundation
import UIKit
import BlackBerryDynamics.Runtime
import BlackBerryDynamics.SecureStore.CoreData

class SecureCoreDataViewController: UIViewController {
    
    @IBOutlet weak var blueSwitch: UISwitch!
    @IBOutlet weak var redSwitch: UISwitch!
    @IBOutlet weak var pinkSwitch: UISwitch!
    @IBOutlet weak var blackSwitch: UISwitch!
    @IBOutlet weak var greenSwitch: UISwitch!
    
    var coreDataContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var colors:[Color]?
    
    //mapping a given string color to it's switch
    var uiSwitchColorMap: [String: UISwitch] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeColors()
    }
    
    func initalizeColors() {
        uiSwitchColorMap = ["Green": greenSwitch,
                       "Black": blackSwitch,
                       "Red" : redSwitch,
                       "Pink" :  pinkSwitch,
                       "Blue": blueSwitch ]

        if (fetchColors()) {
            for (key, _) in uiSwitchColorMap {
                
                //add Color to database if it isn't already in the database. IE. Populate empty DB.
                if !colors!.contains(where: {$0.name == key}) {
                    let newColor = Color(context: self.coreDataContext)
                    newColor.name = key
                    newColor.enabled = false
                    do {
                       try self.coreDataContext.save()
                    }
                    catch {
                        print("[init] unable to add new color to db \(error)")
                    }
                }
            }
        }
    }
    
    
    func fetchColors() -> Bool {
        do {
            colors = try coreDataContext.fetch(Color.fetchRequest())
            return true
        } catch {
            fatalError("Failed to fetch colors: \(error)")
        }
    }
    
    
    @IBAction func loadColors(_ sender: Any) {
        if (fetchColors()) {
            for color in colors! {
                print("color: \(color.name!) | \(color.enabled)")
                
                let currSwitch = uiSwitchColorMap[color.name!]
                let state = color.enabled
                currSwitch!.setOn(state, animated: true)
            }
            print("----------------------")
            
            if (colors!.isEmpty) {
                print("Colors is Empty")
            }
            
            
        }
    }
    @IBAction func saveColors(_ sender: Any) {
        
        //iterate over the switches and their key (their Name)
        for (key, value) in uiSwitchColorMap {
            
            let currColorEnabled = value.isOn
            let colorName = key
            
            //ensure local context us current before saving changes
            if (fetchColors()) {
            
                //find the database value that matches the on screen color
                if let colorInstance = colors!.first(where: {$0.name == key}) {
                    //set the database context value to that of the local on screen value
                    colorInstance.enabled = currColorEnabled
                
                    do {
                        //save the changes (update)
                        try self.coreDataContext.save()
                    }
                    catch {
                        print("Unable to save color changes \(error)")
                    }
                    
                } else {
                    print("Element \(colorName) could not be found")
                }
            
            }
        }
    }
    @IBAction func clearColors(_ sender: Any) {
        for (_,value) in uiSwitchColorMap {
            value.setOn(false, animated: true)
        }
    }
    
}
