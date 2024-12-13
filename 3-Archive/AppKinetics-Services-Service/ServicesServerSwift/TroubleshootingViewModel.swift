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
import BlackBerryDynamics.SecureStore.File

open class TroubleshootingViewModel {
    open weak var delegate: AlertsDelegate?
    
    init(delegate: AlertsDelegate) {
        print(#file, #function)
        self.delegate = delegate
    }
    
    deinit {
        print(#file, #function)
    }
    
    func uploadHandler() -> Void? {
        print("upload")
        GDLogManager.sharedInstance().startUpload()
        return ()
    }
    
    
    func alertAction (_ title: String, message: String, sender: UIBarButtonItem, handler: @escaping () -> Void?) -> UIAlertAction {
        let alertAction = UIAlertAction(title: title, style: .default, handler: {
            action in
            let alertController = UIAlertController(title: "\(title)?", message: message, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: title, style: .default, handler: {action in
                handler()
            }))
            alertController.popoverPresentationController?.barButtonItem = sender
            
            self.delegate?.presentActionSheet(alertController)
            }
        )
        return alertAction
    }
    
    func troubleshoot(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Troubleshooting options", message: "You could upload or save logs", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(alertAction("Upload", message: "A snapshot of your logs will be taken now and uploaded to the server for troubleshooting.\nThe upload process may take some time but it will continue in the background whenever possible until all the logs have been uploaded.\n Do you want to upload the logs now?", sender: sender, handler: uploadHandler))
       
        alertController.popoverPresentationController?.barButtonItem = sender
        
        self.delegate?.presentActionSheet(alertController)
    }
}
