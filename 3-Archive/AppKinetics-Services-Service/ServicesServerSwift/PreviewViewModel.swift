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

open class PreviewViewModel : ServiceTransferDelegate {
    
    open var file = String()
    open weak var delegate: AlertsDelegate?
    
    open var data = Data()
    open var url: URL?
    
    fileprivate let service = Service.sharedInstance
    fileprivate var blockingAlert: UIAlertController?
    
    init(file: String, delegate: AlertsDelegate) {
        print(#file, #function)
        self.file = file
        self.delegate = delegate
        
        self.data = Documents.returnFile(self.file)!
        self.url = URL(fileURLWithPath: Documents.directory + self.file)
    
        NotificationCenter.default.addObserver(self,
					selector: #selector(PreviewViewModel.presentAlertForError(_:)),
					name: NSNotification.Name(rawValue: Constants.serviceClientDidReceiveFromNotificationIdentifier),
					object: nil)
        // Block UI until sending file
        NotificationCenter.default.addObserver(self,
					selector: #selector(PreviewViewModel.presentBlockingAlert),
					name: NSNotification.Name(rawValue: Constants.serviceClientDidStartSendingToNotificationIdentifier),
					object: nil)
        NotificationCenter.default.addObserver(self,
					selector: #selector(PreviewViewModel.popBlockingAlert),
					name: NSNotification.Name(rawValue: Constants.serviceClientDidFinishSendingToNotificationIdentifier),
					object: nil)
    }
    
    deinit {
        print(#file, #function)
        NotificationCenter.default.removeObserver(self)
    }
	
    // MARK: - Notifications for alerts
    
    @objc fileprivate func presentBlockingAlert() {
        blockingAlert = self.delegate?.presentBlockingAlert()
    }
    
    @objc fileprivate func popBlockingAlert() {
        self.delegate?.dismissBlockingAlert(blockingAlert!)
    }
    
    @objc fileprivate func presentAlertForError(_ notification: Notification) {
        // Present alert for reply error messages from service provider
        
        if let error = notification.object as? NSError {
            self.delegate?.presentAlert(error.domain, message: error.localizedDescription)
        }
    }
    
    // MARK: - File-Transfer Delegate
    
    open func tryFileTransferToApplication(_ application: String, withVersion version: String, andName name: String) {
        let attachment = Documents.directory + file
        do {
            try service.sendToWithMethodFileTransfer(application, withAttachments: [attachment])
        } catch let error as NSError {
            // Services could throw runtime execution errors, if app is not installed for example.
            self.delegate?.presentAlert(error.domain, message: error.localizedDescription)
        }
    }
}
