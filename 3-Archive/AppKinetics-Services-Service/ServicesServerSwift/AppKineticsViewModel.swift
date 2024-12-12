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

import UIKit

open class AppKineticsViewModel {
    
    fileprivate let documents = Documents.sharedInstance
    open weak var delegate: AlertsDelegate?
    
    init(delegate: AlertsDelegate) {
        print(#file, #function)
        self.delegate = delegate
        NotificationCenter.default.addObserver(self,
					selector: #selector(AppKineticsViewModel.shouldSaveReceivedFile(_:)),
					name: NSNotification.Name(rawValue: Constants.serviceDidTransferedFileNotificationIdentifier),
					object: nil)
    }
	
    deinit {
        print(#file, #function)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func shouldSaveReceivedFile(_ notification: Notification) {
        if notification.object != nil {
            let filePathInInboxDirectory = notification.object as! String
            let fileName = URL(string: filePathInInboxDirectory)!.lastPathComponent
            let localFilePathToSave = Documents.directory + fileName
			
            if (Documents.returnFile(fileName) != nil) {
                delegate?.presentConfirmationAlert("Replace", message: "File exist. Are you sure to replace file?", handler: { () in
                    print("replacement")
                    self.documents.saveReceivedFile(filePathInInboxDirectory, to: localFilePathToSave)
                })
                return
            }
            
            print("new file received")
            self.documents.saveReceivedFile(filePathInInboxDirectory, to: localFilePathToSave)
        }
    }
    
    func count() -> Int {
        return documents.count()
    }
    
    func elementAtIndex(_ index: Int) -> String {
        return documents.elementAtIndex(index)
    }
    
    func edit(_ tableView: UITableView, indexPath: IndexPath) {
        let fileNameWithExtension = self.elementAtIndex(indexPath.row)
        let fileNameWithoutExtension = NSURL(string: fileNameWithExtension)!.deletingPathExtension!
        let fileExtension = URL(string: fileNameWithExtension)!.pathExtension
        let fileNameWithoutExtensionString = String(fileNameWithoutExtension.absoluteString)
        delegate?.presentEditingAlert(fileNameWithoutExtensionString, handler: { (fileNameWithoutExtension) in
            self.documents.rename(fileNameWithExtension, toFileName: fileNameWithoutExtension + ("." + fileExtension), index: indexPath.row)
        })
        tableView.setEditing(false, animated: false)
    }
    
    func delete(_ tableView: UITableView, indexPath: IndexPath) {
        delegate?.presentConfirmationAlert("Delete", message: "Are you sure to delete file?", handler: { () in
            self.documents.removeAtIndex(indexPath.row)
            if tableView.cellForRow(at: indexPath) != nil {
                tableView.deleteRows(at: [indexPath], with: .right)
            }
        })
    }
    
    
    

}
