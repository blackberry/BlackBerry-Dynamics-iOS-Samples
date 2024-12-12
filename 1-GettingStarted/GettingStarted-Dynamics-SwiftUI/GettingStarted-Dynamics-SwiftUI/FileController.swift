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
//Use GDFileManager file
import BlackBerryDynamics.SecureStore.File

class FileController: ObservableObject {
    
    @Published var statusUpdateMsg : String
    @Published var fileInfo : String
    
    //File Names
    private let textFilename = "SecureFile.txt"
    private let folderName = "SecureFolder"
    private let renamedFile = "NewSecureFile.txt"
    
    init() {
        self.statusUpdateMsg = "Status"
        self.fileInfo = "<Enter Text>"
    }
    
    //Actions
    //Save To File
    func saveToFile() {
        
        let result = self.writeMyFile()
        
        if result {
            self.statusUpdateMsg = "Saved to file."
        } else {
            self.statusUpdateMsg = "Failed to save."
        }
    }
    
    //Use GDFileManger to read/write data
    func loadFromFile() {
        
        let filePath = self.documentsFolderPathForNamed(name: textFilename)
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        //Check if the File Exists
        if (fileManager.fileExists(atPath: filePath) == true) {
            
            print("DEBUG: File exists.")
            
            self.fileInfo = String.init(data: fileManager.contents(atPath: filePath)!, encoding: .utf8) ?? ""
            self.statusUpdateMsg = "Loaded file."
            
            // Use GDFileHandle to get data
            var fileHandle = GDFileHandle.init()
            do {
                fileHandle = try GDFileHandle.init(forReadingFrom: URL.init(string: filePath)!)
            }
            catch {
                print(error.localizedDescription)
            }
            
            let resData = fileHandle.availableData
            
            let fileText = String.init(data: resData, encoding: .utf8)
            print(fileText!)
            
            // Display absolute file path
            let encryptedPath = GDFileManager.getAbsoluteEncryptedPath(filePath)
            print(encryptedPath!)
            
        } else {
            
            print("DEBUG: Saved text file doesnt' exist.")
            self.fileInfo = "<Enter Text>"
            self.statusUpdateMsg = "Saved text file doesnt' exist."
        }
    }
    
    //Clear All The TextFields
    func clearText() {
        
        self.fileInfo = "<Enter Text>"
        self.statusUpdateMsg = "Text Cleared."
    }
    
    //Create the folder
    func createFolder() {
        
        //Get the Folders Path
        let folderPath = documentsFolderPathForNamed(name: self.folderName)
        
        //Create directory if it doesn't exist already.
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        //Check if the Folder Exists
        if fileManager.fileExists(atPath: folderPath) {
            self.statusUpdateMsg = "Folder Exists"
            
        } else {
            do {
                //Create directory
                try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
                self.fileInfo = "\(folderName) Folder Created"
                self.statusUpdateMsg = "Folder Created"
            }
            catch {
                self.statusUpdateMsg = error.localizedDescription
            }
        }
    }
    
    //Delete the folder
    func deleteFolder() {
        
        //Delete the directory.
        
        //Get the Folders Path
        let folderPath = documentsFolderPathForNamed(name: self.folderName)
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        //Check if the Folder Exists
        if fileManager.fileExists(atPath: folderPath) {
            do {
                //Delete the Folder
                try fileManager.removeItem(atPath: folderPath)
                self.statusUpdateMsg = "Folder Deleted"
            }
            catch {
                self.statusUpdateMsg = error.localizedDescription
            }
        } else {
            self.statusUpdateMsg = "No Folder"
        }
    }
    
    //Move File To Folder
    func moveFile() {
        
        //Move the directory and display its path
        
        //Get the Files Path
        let filePath = self.documentsFolderPathForNamed(name: textFilename)
        
        //Get the new Files Path
        let newFilePath = self.documentsFolderPathForNamed(name: "/\(folderName)/\(textFilename)")
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        //Get the text from the existing file
        var text = ""
        if let fileContent = fileManager.contents(atPath: filePath) {
            text = String.init(data: fileContent, encoding: .utf8) ?? ""
        }
        
        //Create file at new path
        fileManager.createFile(atPath: newFilePath, contents: text.data(using: .utf8), attributes: nil)
        
        self.fileInfo = "New File Path: \(newFilePath) \n\nEncrypted File Path: \(GDFileManager.getAbsoluteEncryptedPath(newFilePath)!)"
        self.statusUpdateMsg = "File Moved To Folder"
        
    }
    
    func renameFile() {
        
         //Rename the directory.
        
        //Get the new File's Path
        let newFilePath = self.documentsFolderPathForNamed(name: "\(folderName)/\(textFilename)")
        
        //Get the renamed File's Path
        let renamedFilePath = self.documentsFolderPathForNamed(name: "/\(folderName)/\(renamedFile)")
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        //Check if the File Exists
        if fileManager.fileExists(atPath: newFilePath) {
            
            //Create the renamed file with the contents of the existing file
            fileManager.createFile(atPath: renamedFilePath, contents: fileManager.contents(atPath: newFilePath)!, attributes: nil)
            
            do {
                //Delete the existing file
                try fileManager.removeItem(atPath: newFilePath)
                self.fileInfo = "New File Path: \(renamedFilePath) \n Encrypted File Path: \(GDFileManager.getAbsoluteEncryptedPath(renamedFilePath)!)"
                self.statusUpdateMsg = "File Renamed"
            }
            catch {
                self.statusUpdateMsg = error.localizedDescription
            }
        }
    }
    
    //Delete the file
    func deleteFile() {
        
        //Delete the moved file in the new path.
        self.clearText()
        
        //Get the original File's Path
        let filePath = self.documentsFolderPathForNamed(name: textFilename)
        
        //Get the new File's Path
        let newFilePath = self.documentsFolderPathForNamed(name: "/\(folderName)/\(textFilename)")
        
        //Get the renamed File's Path
        let renamedFilePath = self.documentsFolderPathForNamed(name: "/\(folderName)/\(renamedFile)")
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        do {
            //Check if the original File Exists
            if fileManager.fileExists(atPath: filePath) {
                try fileManager.removeItem(atPath: filePath)
            }
            
            //Check if the new File Exists
            if fileManager.fileExists(atPath: newFilePath) {
                try fileManager.removeItem(atPath: newFilePath)
            }
            
            //Check if the renamed File Exists
            if fileManager.fileExists(atPath: renamedFilePath) {
                try fileManager.removeItem(atPath: renamedFilePath)
            }
            
            self.fileInfo = ""
            self.statusUpdateMsg = "File Deleted"
        }
        catch {
            self.statusUpdateMsg = error.localizedDescription
        }
    }
    
    func documentsFolderPathForNamed(name : String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory.appending(name)
    }
    
    func writeMyFile() -> Bool {
        
        // Delete the file if exists
        let filePath = documentsFolderPathForNamed(name: textFilename)
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        let fileData = self.fileInfo.data(using: .utf8)
        
        //Create a secure file uisng GDFileManager
        let fileCreated = fileManager.createFile(atPath: filePath, contents: fileData, attributes: nil)
        
        return fileCreated
    }
}
