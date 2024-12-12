/* Copyright (c) 2023 BlackBerry Ltd.
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

import Foundation
import BlackBerryDynamics.SecureStore.File

open class Documents {
    
    static let sharedInstance = Documents()
    
    // List of filenames to show in table view
    fileprivate var list: Array<String> = Array() {
        didSet {
            // Update UI on documents create/update. On delete UI will be updated automaticly.
            if oldValue.count <= self.list.count {
                NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.documentsModelChangedNotificationIdentifier), object: nil)
            }
        }
    }
    
    fileprivate let manager = GDFileManager.default
    static let directory: String = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.relativePath + "/"
    
    init() {
        print(#file, #function)
        self.loadFiles()
    }
    
    deinit {
        print(#file, #function)

    }
    
    func count() -> Int {
        return list.count
    }
    
    func elementAtIndex(_ index: Int) -> String {
        return list[index]
    }
    
    // Create
    func saveReceivedFile(_ from: String, to: String) {       
        if self.manager.fileExists(atPath: to) {
            try! self.manager.removeItem(atPath: to)
        }
        
        try! self.manager.moveItem(atPath: from, toPath: to)
        let fileName = URL(string: from)!.lastPathComponent
        if !list.contains(fileName) {
            list.append(fileName)
            print("added")
        }
    }
        
    func defaultFiles() {
        let arrayOfFilesFromBundle = Bundle.main.urls(forResourcesWithExtension: "pdf", subdirectory: nil)!
        for fileInBundleURL in arrayOfFilesFromBundle  {
            let filename = fileInBundleURL.lastPathComponent
            if !self.manager.fileExists(atPath: Documents.directory + filename) {
                let data = try? Data(contentsOf: fileInBundleURL)
                self.manager.createFile(atPath: Documents.directory + filename, contents: data, attributes: nil)
            }
        }
    }
    
    // Read
    func loadFiles() {
        if !manager.fileExists(atPath: Documents.directory) {
            try! manager.createDirectory(atPath: Documents.directory, withIntermediateDirectories: true, attributes: nil)
        }
        do {
            var filesArray = try self.manager.contentsOfDirectory(atPath: Documents.directory)
            
            if (filesArray.count == 0) {
                // if there are empty secured store try to merge files from main bundle
                defaultFiles()
            }
            
            filesArray = try self.manager.contentsOfDirectory(atPath: Documents.directory)
            
            for filePath in filesArray {
                list.append(filePath)
            }
            
        } catch {
            print(error)
        }
        
        print("\(list) loaded")
    }
    
    class func returnFile(_ filename: String) -> Data? {
        return GDFileManager.default.contents(atPath: Documents.directory + filename)
    }
    
    // Delete
    func removeAtIndex(_ index: Int) {
        if list.endIndex >= index {
            try! self.manager.removeItem(atPath: Documents.directory + list[index])
            print("removed")
            list.remove(at: index)
        }
        else {
            print("Could not remove file. Array index out of range.")
        }
    }
    
    func removeFiles() {
        for filename in self.list  {
            try! self.manager.removeItem(atPath: Documents.directory + filename)
            list.removeAll()
        }
    }
}
