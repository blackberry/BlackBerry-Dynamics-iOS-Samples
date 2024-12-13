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

// MARK: Extensions

extension UIViewController: AlertsDelegate {
    
    public func presentConfirmationAlert(_ title: String, message: String, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Confirmation!", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil));
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action) -> Void in
            handler()
        }))
        DispatchQueue.main.async { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }

    public func presentAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil));
        DispatchQueue.main.async { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public func presentBlockingAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Working...", message: "Please wait for file-transfer complete", preferredStyle: UIAlertController.Style.alert)
        DispatchQueue.main.async { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
        return alert
    }
    
    public func dismissBlockingAlert(_ alert: UIAlertController) {
        print(#file, #function)
        delay(0.4) {
            alert.dismiss(animated: false, completion: nil)
        }
    }
    
    public func presentActionSheet(_ alertController: UIAlertController) {
        DispatchQueue.main.async { () -> Void in
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentEditingAlert(_ fromFileName: String, handler: @escaping (_ toFileName: String) -> Void?) {
        
        let alertController = UIAlertController(title: "Rename", message: "You could rename file", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let renameAction = UIAlertAction(title: "Rename", style: .default) { (action) in
            let text = alertController.textFields![0].text!
            handler(text)
        }
        alertController.addAction(renameAction)
        
        alertController.addTextField { (textField) in
            textField.text = fromFileName
            textField.keyboardType = .default
        }
        
        DispatchQueue.main.async { () -> Void in
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func previousViewController() -> UIViewController? {
        let stack = self.navigationController!.viewControllers as Array
		if stack.count > 1 {
			for i in (1..<stack.count).reversed() {
				if (stack[i] as UIViewController == self) {
					return stack[i-1]
				}
			}
		}
        return nil
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}

// MARK: Protocols

public protocol AlertsDelegate: AnyObject {
    func presentAlert(_ title: String, message: String)
    func presentConfirmationAlert(_ title: String, message: String, handler: @escaping () -> Void)
    func presentBlockingAlert() -> UIAlertController
    func dismissBlockingAlert(_ alert: UIAlertController)
    func presentActionSheet(_ alertController: UIAlertController)
}

public protocol ServiceTransferDelegate : AnyObject {
    func tryFileTransferToApplication(_ application: String, withVersion version: String, andName name: String)
}
