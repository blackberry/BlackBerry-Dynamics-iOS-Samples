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
import CoreData

class CoreDataViewController: UIViewController {
    
   
    @IBOutlet weak var greenSwitch: UISwitch!
    @IBOutlet weak var blackSwitch: UISwitch!
    @IBOutlet weak var redSwitch: UISwitch!
    @IBOutlet weak var pinkSwitch: UISwitch!
    @IBOutlet weak var blueSwitch: UISwitch!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var colors:[Color]? //<--- CONTEXT colors.save() ->>> Actual database
    
    var switchDBMap: [String: UISwitch] = [:]
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //https://stackoverflow.com/questions/30894026/how-to-implement-the-new-core-data-model-builder-unique-property-in-ios-9-0-be
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        initalizeColors()
    }
    
    func initalizeColors()  {
        switchDBMap = ["Green": greenSwitch,
                       "Black": blackSwitch,
                       "Red" : redSwitch,
                       "Pink" :  pinkSwitch,
                       "Blue": blueSwitch ]
        
        //ensure our local colors context matches that of the database before accidentally updating values
        if (fetchColors()) {
            //insert values as default false!
            for (key, _) in switchDBMap {
                
                //Ensure our color doesn't already exist to ensure we are not updating existing saved data
                if !colors!.contains(where: {$0.name == key}) {
                    let newColor = Color(context: self.context)
                    newColor.name = key
                    newColor.enabled = false
                    do {
                       try self.context.save()
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
            self.colors = try context.fetch(Color.fetchRequest())
            return true
        }
        catch {
            print("Unable to fetch Colors \(error)")
            return false
        }
        
    }
    
    //Load Colours deom Database
    @IBAction func loadColours(_ sender: Any) {
        if (fetchColors()) {
            for color in colors! {
                print("color: \(color.name!) | \(color.enabled)")
                
                let currSwitch = switchDBMap[color.name!]
                let state = color.enabled
                currSwitch!.setOn(state, animated: true)
            }
            print("----------------------")
            
            if (colors!.isEmpty) {
                print("Colors is Empty")
            }
        }
    
    }
    
    //Save colours to Database
    @IBAction func saveColours(_ sender: Any) {
        
        //iterate over the switches and their key (their Name)
        for (key, value) in switchDBMap {
            
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
                        try self.context.save()
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
    
    //Reset the switches
    @IBAction func clearColours(_ sender: Any) {
        for (_,value) in switchDBMap {
            value.setOn(false, animated: true)
        }
    }
}
