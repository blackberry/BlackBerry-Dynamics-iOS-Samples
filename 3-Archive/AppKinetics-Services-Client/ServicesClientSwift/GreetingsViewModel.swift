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
					selector:#selector(GreetingsViewModel.presentAlertForNotification(_:)),
					name:NSNotification.Name(rawValue: Constants.serviceClientDidReceiveFromNotificationIdentifier),
					object:nil)
    }
    
    deinit {
        print(#file, #function)
        NotificationCenter.default.removeObserver(self)
    }
    
    func processProviderDetails(serviceButtons:[ServiceInfo]) {
        
        for serviceInfo in serviceButtons {
            
            let neededProvider = service.getProvidersForService(serviceId: serviceInfo.serviceId)
                .first(where: {
                    $0.services.contains(where: {
                        $0.identifier == serviceInfo.serviceId })
                })
            
            guard let provider = neededProvider else {
                serviceInfo.button?.isEnabled = false
                serviceInfo.button?.alpha = 0.4
                serviceInfo.applicationId = nil
                
                continue
            }
            serviceInfo.button?.isEnabled = true
            serviceInfo.button?.alpha = 1.0
            serviceInfo.applicationId = provider.identifier
        }
    }
	
    @objc fileprivate func presentAlertForNotification(_ notification: Notification) {
        
        if let error = notification.object as? NSError {
            delegate?.presentAlert(error.domain, message: error.localizedDescription)
        } else if let error = notification.object as? Error {
            delegate?.presentAlert("Error", message: error.localizedDescription)
        } else if let message = notification.object as? String {
            delegate?.presentAlert("Success", message: message)
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
    
    open func tryGreetMeService() {
        do {
            try service.sendToWithMethodGreetMe()
        } catch let error as NSError {
            // Services could throw runtime execution errors, if app is not installed for example.
            delegate?.presentAlert(error.domain, message: error.localizedDescription)
        }
    }
    
    open func tryGetDateAndTime() {
        do {
            try service.sendToWithMethodGetDateAndTime()
        } catch let error as NSError {
            // Services could throw runtime execution errors, if app is not installed for example.
            delegate?.presentAlert(error.domain, message: error.localizedDescription)
        }
    }
    
}
