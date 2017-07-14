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
//Use GDFileManager file
import GD.SecureStore.File

class FileViewController: UIViewController {
    
    //File Names
    let textFilename = "SecureFile.txt"
    let folderName = "SecureFolder"
    let renamedFile = "NewSecureFile.txt"
    
    //Outlets
    @IBOutlet weak var textEditView: UITextView!
    @IBOutlet weak var saveToFileButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    //Actions
    //Save To File
    @IBAction func saveToFile(_ sender: Any) {
        
        let result = self.writeMyFile()
        
        if result {
            self.messageLabel.text = "Saved."
        } else {
            self.messageLabel.text = "Failed to save."
        }
        self.view.endEditing(true)
    }
    //Use GDFileManger to read/write data
    @IBAction func loadFromFile(_ sender: Any) {
        
        let filePath = self.documentsFolderPathForNamed(name: textFilename)
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        //Check if the File Exists
        if (fileManager.fileExists(atPath: filePath) == true) {
            
            print("DEBUG: File exists.")
            
            self.textEditView.text = String.init(data: fileManager.contents(atPath: filePath)!, encoding: .utf8)
            self.messageLabel.text = "Loaded."
            
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
            self.textEditView.text = "<Enter text here>"
            self.messageLabel.text = "Saved text file doesnt' exist."
        }
        self.view.endEditing(true)
    }
    
    //Clear All The TextFields
    @IBAction func clearText(_ sender: Any) {
        
        self.textEditView.text = "<Enter text here>"
        self.messageLabel.text = "Cleared text."
        
        self.view.endEditing(true)
    }
    
    //Create the folder
    @IBAction func createFolder(_ sender: Any) {
        
        //Get the Folders Path
        let folderPath = documentsFolderPathForNamed(name: self.folderName)
        
        //Create directory if it doesn't exist already.
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        //Check if the Folder Exists
        if fileManager.fileExists(atPath: folderPath) {
            messageLabel.text = "Folder Exists"
            
        } else {
            do {
                //Create directory
                try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
                messageLabel.text = "Folder Created"
                textEditView.text = "\(folderName) Folder Created"
            }
            catch {
                messageLabel.text = error.localizedDescription
            }
        }
    }
    
    //Delete the folder
    @IBAction func deleteFolder(_ sender: Any) {
        
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
                messageLabel.text = "Folder Deleted"
            }
            catch {
                messageLabel.text = error.localizedDescription
            }
        } else {
            messageLabel.text = "No Folder"
        }
    }
    
    //Move File To Folder
    @IBAction func moveFile(_ sender: Any) {
        
        //Move the directory and display its path
        
        //Get the Files Path
        let filePath = self.documentsFolderPathForNamed(name: textFilename)
        
        //Get the new Files Path
        let newFilePath = self.documentsFolderPathForNamed(name: "/\(folderName)/\(textFilename)")
        
        //Initialize GDFileManger to read
        let fileManager = GDFileManager.default()
        
        //Get the text from the existing file
        let text = String.init(data: fileManager.contents(atPath: filePath)!, encoding: .utf8)
        //Create file at new path
        fileManager.createFile(atPath: newFilePath, contents: text!.data(using: .utf8), attributes: nil)
        
        messageLabel.text = "File Moved To Folder"
        textEditView.text = "New File Path: \(newFilePath) \n Encrypted File Path: \(GDFileManager.getAbsoluteEncryptedPath(newFilePath)!)"
        
    }
    
    @IBAction func renameFile(_ sender: Any) {
        
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
                textEditView.text = "New File Path: \(renamedFilePath) \n Encrypted File Path: \(GDFileManager.getAbsoluteEncryptedPath(renamedFilePath)!)"
                messageLabel.text = "File Renamed"
            }
            catch {
                messageLabel.text = error.localizedDescription
            }
        }
    }
    
    //Delete the file
    @IBAction func DeleteFile(_ sender: Any) {
        
        //Delete the moved file in the new path.
        
        clearText(self)
        
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
            messageLabel.text = "File Deleted"
            textEditView.text = ""
        }
        catch {
            messageLabel.text = error.localizedDescription
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let text = self.textEditView.text
        let fileData = text?.data(using: .utf8)
        
        //Create a secure file uisng GDFileManager
        let fileCreated = fileManager.createFile(atPath: filePath, contents: fileData, attributes: nil)
        
        return fileCreated
    }
}
