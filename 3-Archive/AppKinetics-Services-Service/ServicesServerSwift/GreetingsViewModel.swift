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

open class GreetingsViewModel {
    
    fileprivate let service = Service.sharedInstance
    open weak var delegate: AlertsDelegate?
    
    init(delegate: AlertsDelegate) {
        print(#file, #function)
        self.delegate = delegate
        NotificationCenter.default.addObserver(self,
					selector: #selector(GreetingsViewModel.presentAlertForNotification(_:)),
					name: NSNotification.Name(rawValue: Constants.serviceClientDidReceiveFromNotificationIdentifier),
					object: nil)
    }
    
    deinit {
        print(#file, #function)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc fileprivate func presentAlertForNotification(_ notification: Notification) {
        
        if let error = notification.object as? Error {
            delegate?.presentAlert("Success", message: error.localizedDescription)
        } else if let error = notification.object as? NSError {
            // If error received present alert with error
            delegate?.presentAlert(error.domain, message: error.description)
        }
    }
    
    open func tryBringToFrontService() {
        do {
            try service.sendBringToFront()
        } catch let error as NSError {
            // Services could throw runtime execution errors, if app is not installed for example.
            delegate?.presentAlert(error.domain, message: error.localizedDescription)
        }
    }
    
}
