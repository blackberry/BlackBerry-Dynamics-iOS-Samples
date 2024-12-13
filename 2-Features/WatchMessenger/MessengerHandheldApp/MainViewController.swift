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

import UIKit
import WatchConnectivity
import CommonCrypto
import BlackBerryDynamics.SecureStore.File
import BlackBerryDynamics.Runtime


class MainViewController: UIViewController {
    
    private var messageCount = 0
    
    @IBOutlet weak var expectReplySwitch: UISwitch!
    @IBOutlet weak var watchImageView: UIImageView!
    @IBOutlet weak var policyImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var receivedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateWatchStatusIcon()
        
    }
    
    @IBAction func sendMessage() {
        
        handleSendMessageToWatch {
            let replyHandler = { [weak self] (reply: [String : Any]) -> Void in
                print("Reply message received \(reply)")
                self?.updateUiWith(message: reply["replyingToDevice"] as? String ?? "")
            }
            
            let contentsData = FileHelper.sharedInstance.getMessageFileContent()
            let text = "Hello \(messageCount) \(String(data: contentsData, encoding: .utf8) ?? "error reading file")"
            let image = #imageLiteral(resourceName: "speech-bubbles.png").pngData() ?? Data()
            let dictionary = ["text": text, "image": image] as [String : Any]
            let message = ["messageToWatch": dictionary]
            
            print("Sending message: \(message) - handler \(self.expectReplySwitch.isOn)")
            WCSession.default.sendMessage(message,
                                          replyHandler: self.expectReplySwitch.isOn ? replyHandler : nil,
                                          errorHandler: { [weak self] error in
                                            self?.updateUiWith(message: error.localizedDescription)
                                            print("Error \(error.localizedDescription)")
                                        })
        }
    }
    
    @IBAction func sendUserInfo() {
        handleSendWhenActivated {
            WCSession.default.transferUserInfo(["userInfo": messageCount])
        }
    }
    
    @IBAction func sendComplicationUserInfo() {
        handleSendWhenActivated {
            WCSession.default.transferCurrentComplicationUserInfo(["complication": messageCount])
        }
    }
    
    @IBAction func sendAppContext() {
        handleSendWhenActivated {
            do {
                try WCSession.default.updateApplicationContext(["context": messageCount])
            } catch {
                print("Failed to update application context \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func sendMessageData() {
        
        handleSendMessageToWatch {
            let replyHandler = { [weak self] (reply: Data) -> Void in
                print("Reply data received \(reply.count)")
                self?.updateUiWith(message: String(data: reply, encoding: .utf8) ?? "Invalid reply")
            }
            
            let imageData = #imageLiteral(resourceName: "speech-bubbles.png").pngData() ?? Data()
            print("Sending data \(imageData.count) - expect reply \(self.expectReplySwitch.isOn)")
            WCSession.default.sendMessageData(imageData,
                                              replyHandler: self.expectReplySwitch.isOn ? replyHandler : nil,
                                              errorHandler: { [weak self] error in
                self?.updateUiWith(message: error.localizedDescription)
                print("Error sendMessageDataToWatch \(error.localizedDescription)")
            })
        }
    }
    
    func updateWatchStatusIcon() {
        DispatchQueue.main.async { [weak self] in
            let allowed = MessengerHandheldAppGDiOSDelegate.sharedInstance.isWatchAllowed
            
            if (allowed) {
                self?.policyImageView.image = UIImage(systemName: "checkmark.icloud")
            } else {
                self?.policyImageView.image = UIImage(systemName: "icloud.slash")
            }
            
            let paired = WCSession.default.isPaired
            let installed = WCSession.default.isWatchAppInstalled
            let reachable = WCSession.default.isReachable
            
            if (paired && installed && reachable) {
                self?.watchImageView.image = UIImage(systemName: "applewatch.watchface")
            } else {
                self?.watchImageView.image = UIImage(systemName: "applewatch.slash")
            }
        }
    }
    
    private func updateUiWith(message: String, image: Data? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = message
            if image != nil {
                self?.receivedImageView.image = UIImage(data: image!)
            }
        }
    }
    
    private func handleSendWhenActivated(_ actions: () -> ()) {
        // will ensure delivery, must be called while activated.
        if (WCSession.default.activationState == WCSessionActivationState.activated) {
            actions()
            messageCount += 1
        } else {
            print("Session not active \(WCSession.default.activationState.rawValue)")
        }
    }
    
    private func handleSendMessageToWatch(_ actions: () -> ()) {
        let paired = WCSession.default.isPaired
        let installed = WCSession.default.isWatchAppInstalled
        let reachable = WCSession.default.isReachable
        let allowed = MessengerHandheldAppGDiOSDelegate.sharedInstance.isWatchAllowed
        
        print("Allowed: \(allowed), Paired: \(paired), Installed: \(installed), Reachable: \(reachable)")
        
        updateWatchStatusIcon()
        
        if (paired && installed && reachable && allowed) {
            actions()
            updateUiWith(message: "")
            messageCount += 1
        } else {
            var message = ""
            if (!allowed) {
                message =  "Policy doesn't allow wearables"
            } else {
                message =  "Cannot reach the watch: Paired: \(paired), Installed: \(installed), Reachable: \(reachable)"
            }
            
            let actionOK = UIAlertAction.init(title: "OK", style: .default)
            let alert = UIAlertController.init(title: "Cannot send message", message: message, preferredStyle: .alert)
            alert.addAction(actionOK)
            self.present(alert, animated: true)
        }
    }
    
    func receivedMessage(message: [String: Any], replyHandler: (([String : Any]) -> Void)? = nil)  {
        var receivedMessage = "Unexpected message"
        var receivedData: Data? = nil
        
        if let messageDict = message["sendingToDevice"] as? [String : Any] {
            receivedMessage = messageDict["text"] as! String
            receivedData = messageDict["image"] as? Data
            
        } else if let error = message["WatchDynamicsIntercepted"] as? NSError {
            receivedMessage = error.userInfo["WatchErrorUserInfoKey"] as? String ?? error.localizedDescription
        }
        updateUiWith(message: receivedMessage, image: receivedData)
        if replyHandler != nil {
            let reply = ["replyingToWatch" : "Ack: \(receivedMessage)"]
            print("Sending message reply \(reply)")
            replyHandler!(reply)
        }
    }

    func receivedMessageData(messageData: Data, replyHandler: ((Data) -> Void)? = nil) {
        let reply = "image rcvd \(messageData.count)"
        updateUiWith(message: reply, image: messageData)
        if replyHandler != nil {
            let replyData = reply.data(using: .utf8) ?? Data()
            print("Sending data reply \(replyData.count)")
            replyHandler!(replyData)
        }
    }
    
    func receivedFile(file: WCSessionFile) {
        DispatchQueue.main.async { [weak self] in
            self!.messageLabel.text = "received file: \(file.fileURL.lastPathComponent)"
        }
    }
}

