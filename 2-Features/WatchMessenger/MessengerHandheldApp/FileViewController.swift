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
import UIKit
import WatchConnectivity
import CommonCrypto
import BlackBerryDynamics.SecureStore.File
import BlackBerryDynamics.Runtime


class FileViewController: UITableViewController {
    
    var fileList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshFileList()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell") {
            cell.textLabel?.text = fileList[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sendAction = UIAlertAction(title: "Send + Meta", style: .default, handler: { [weak self] action in
            self?.sendFileToWatch(indexPath: indexPath, sendMetadata: true)
        })
        let sendNoMetaAction = UIAlertAction(title: "Send w/o Meta", style: .default, handler: { [weak self] action in
            self?.sendFileToWatch(indexPath: indexPath, sendMetadata: false)
        })
        let deleteAction = UIAlertAction(title: "Delete file", style: .destructive, handler: { [weak self] action in
            self?.deleteFile(indexPath: indexPath)
        })
        let dismissAction = UIAlertAction(title:"Dismiss", style: .cancel, handler:nil)
        
        let fileContent = FileHelper.sharedInstance.getContentOfFileFromWatchFolder(fileList[indexPath.row])
        
        let alert = UIAlertController(title: fileList[indexPath.row], message:fileContent , preferredStyle: .alert)
        alert.addAction(sendAction)
        alert.addAction(sendNoMetaAction)
        alert.addAction(deleteAction)
        alert.addAction(dismissAction)
        self.present(alert, animated: true)
    }
    
    func sendFileToWatch(indexPath: IndexPath, sendMetadata: Bool) {
        let fileName = fileList[indexPath.row]
        let fileURL = URL(fileURLWithPath: FileHelper.sharedInstance.watchFilesFolder + fileName)
        var metadataDict: [String : Any]? = nil
        if sendMetadata {
            metadataDict = [
                "metadataString" : "string",
                "metadataNumbers" : 1.0,
                "metadataData" : "Utf8 encoded data string".data(using: .utf8) ?? Data(),
                "metadataArray" : ["stringArray", 2],
                "metadataDict" : ["metadataStringNested" : "nested string"]
            ]
        }
        
        let fileContent = FileHelper.sharedInstance.getContentOfFileFromWatchFolder(fileName)
        
        print("Sending file: \(fileName) - content: \(fileContent) - metadata: \(String(describing: metadataDict))")
        
        WCSession.default.transferFile(fileURL, metadata: metadataDict)
    }
    
    func deleteFile(indexPath: IndexPath) {
        FileHelper.sharedInstance.deleteFileFromWatchFolder(fileList[indexPath.row])
        self.refreshFileList()
    }
    
    func refreshFileList() {
        fileList = FileHelper.sharedInstance.getFilesFromWatchFolder()
        self.tableView.reloadData()
    }
    
    @IBAction func createTestFile() {
        FileHelper.sharedInstance.createFileInWatchFolder()
        refreshFileList()
    }
    
    @IBAction func clearFiles() {
        FileHelper.sharedInstance.resetFolderFilesFromWatch()
        refreshFileList()
    }
}
