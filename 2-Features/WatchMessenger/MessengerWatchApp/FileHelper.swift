/* Copyright (c) 2024 BlackBerry Ltd.
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
import BlackBerryDynamicsWatch

class FileHelper {
    
    private let messageFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.relativePath + "/messages.txt"
    private let appCachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.relativePath + "/"
    public let watchFilesFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.relativePath + "/WatchMessenger/"
    
    private let gdFileManager = GDFileManager.default()
    private let dateFormatter = DateFormatter()
    
    static let sharedInstance = FileHelper()
    
    init() {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
    }
    
    func initialiseMessageFile() {
        
        let now = "Watch \(dateFormatter.string(from: Date.now))"
        let fileData = now.data(using: .utf8)
        
        if (gdFileManager.fileExists(atPath: messageFilePath)) {
            do {
                try gdFileManager.removeItem(atPath: messageFilePath)
            } catch {
                print("Could not remove file")
            }
        }
        // Create file in Dynamics container with current time upon launch as content.
        // Retrieval of this time indicates that container can be accessed
        let result = gdFileManager.createFile(atPath: messageFilePath, contents: fileData, attributes: nil)
        print("Created file \(result)")
    }
    
    func getMessageFileContent() -> Data {
        return gdFileManager.contents(atPath: messageFilePath) ?? Data()
    }
    
    func getUniqueFileName(_ fileName: String, inFolder folder: String) -> String {
        let count = getFilesFromWatchFolder().filter({ $0.hasSuffix(fileName) }).count
        
        return "\(count + 1)-\(fileName)"
    }
    
    func saveFileFromWatch(_ fileName: String) -> String {
        createFolderFilesFromWatch()
        let fileSrcPath = appCachePath + fileName
        let newFileName = getUniqueFileName(fileName, inFolder: watchFilesFolder)
        let fileDstPath = watchFilesFolder + newFileName
        do {
            try gdFileManager.moveItem(atPath: fileSrcPath, toPath: fileDstPath)
            print("Saved file \(fileName) in folder \(watchFilesFolder)")
            
            return newFileName
        } catch {
            print("Could not move file from \(fileSrcPath) to \(fileDstPath) - \(error)")
            
            return fileName
        }
    }
    
    func getFilesFromWatchFolder() -> [String] {
        var files: [String] = []
        do {
            createFolderFilesFromWatch()
            files = try gdFileManager.contentsOfDirectory(atPath: watchFilesFolder)
        } catch  {
            print("Could not get list of files from \(watchFilesFolder) - \(error)")
        }
        return files
    }
    
    func getContentOfFileFromWatchFolder(_ filename: String) -> String {
        let fileData = gdFileManager.contents(atPath: watchFilesFolder + filename) ?? Data()
        return String(data:fileData, encoding:.utf8) ?? ""
    }
    
    func createFileInWatchFolder() -> Bool {
        let fileName = "WF-\(UUID()).txt"
        let fileContent = "\"\(fileName)\" created on \(dateFormatter.string(from: Date.now))"
        let fileData = fileContent.data(using: .utf8)
        return gdFileManager.createFile(atPath: watchFilesFolder + fileName, contents: fileData)
    }
    
    func deleteFileFromWatchFolder(_ filename: String) {
        let filePath = watchFilesFolder + filename
        do {
            try gdFileManager.removeItem(atPath: filePath)
        } catch {
             print("Could not remove file at \(filePath) - \(error)")
        }
    }
    
    func resetFolderFilesFromWatch() -> Bool {
        
        deleteFolderFilesFromWatch()
        createFolderFilesFromWatch()
        
        return true
    }
    
    func deleteFolderFilesFromWatch()  {
        do {
            if (gdFileManager.fileExists(atPath: watchFilesFolder)) {
                try gdFileManager.removeItem(atPath: watchFilesFolder)
            }
        } catch {
            print("Could not delete folder \(watchFilesFolder) - \(error)")
        }
    }
    
    func createFolderFilesFromWatch() {
        do {
            if (!gdFileManager.fileExists(atPath: watchFilesFolder)) {
                try gdFileManager.createDirectory(atPath: watchFilesFolder, withIntermediateDirectories: true)
            }
        } catch {
            print("Could not create folder \(watchFilesFolder) - \(error)")
        }
    }
    
}
