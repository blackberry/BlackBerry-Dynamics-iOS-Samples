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

import SwiftUI
import WatchConnectivity
import BlackBerryDynamicsWatch

@main
struct MessengerWatchApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                MainUIView()
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

class Messenger: NSObject, WCSessionDelegate, ObservableObject  {
    static let shared = Messenger()
    
    var messageCount = 0
    @Published var messageText = ""
    @Published var messageData = Data()
    @Published var watchState = "Not Set"
    @Published var files: [String] = []
    
    var wcSession: WCSession = .default
    var dynamicsWatch: DynamicsWatch?
    var isConnectionSecured = false
    var expectReply = true
    
    override init() {
        super.init()
        wcSession.delegate = self
        wcSession.activate()
    }
    
    // MARK: WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        dynamicsWatch = DynamicsWatch.sharedBBDWatchIOS()
        print("activation complete \(error?.localizedDescription ?? "noError"), reachable \(session.isReachable)")
        if (UserDefaults.standard.bool(forKey: "secureOnLaunch")) {
            secureCommunication()
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("sessionReachabilityDidChange reachable \(session.isReachable)")
        if (UserDefaults.standard.bool(forKey: "secureOnLaunch")) {
            secureCommunication()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleMessageReceived(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler:  @escaping ([String:Any]) -> Void) {
        handleMessageReceived(message, replyHandler: replyHandler)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        handleMessageDataReceived(messageData)
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        handleMessageDataReceived(messageData, replyHandler: replyHandler)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: ([String : Any])) {
        print("Session delegate received user info \(userInfo) - outstanding \(session.outstandingUserInfoTransfers)")
        
        var messageString = "Unexpected User Info"
        if let userInfo = userInfo["userInfo"] as? Int {
            messageString = "User info is \(userInfo)"
        } else if let complicationInfo = userInfo["complication"] as? Int {
            messageString = "Complication info is \(complicationInfo)"
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.messageText = messageString
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: ([String : Any])) {
        print("Session delegate received app context \(applicationContext)")
        
        DispatchQueue.main.async { [weak self] in
            var messageData = "empty"
            if let contextData = applicationContext["context"] as? Int {
                messageData = "\(contextData)"
            }
            self?.messageText = "Context is \(messageData)"
        }
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("Session delegate received file: \(file.fileURL) - metadata: \(String(describing: file.metadata))")
        
        let fileName = file.fileURL.lastPathComponent
        
        let newFileName = FileHelper.sharedInstance.saveFileFromWatch(fileName)

        let fileContent = FileHelper.sharedInstance.getContentOfFileFromWatchFolder(newFileName)
        print("Received file: \(fileName)\nsaved as \(newFileName)\nContent: \(fileContent)")
        
        refreshFileList()
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: (any Error)?) {
        print("Session delegate finished transfer of \(fileTransfer.file.fileURL)  - metadata: \(String(describing: fileTransfer.file.metadata)) - error \(error?.localizedDescription ?? "none") - outstanding transfers \(session.outstandingFileTransfers)")
    }
    
    // MARK: public functions
    
    func secureCommunication(_ actions: @escaping(() -> ()) = {}) {
        
        let reachable = wcSession.isReachable
        let installed = wcSession.isCompanionAppInstalled

        print("Reachable: \(reachable) Installed: \(installed)")
        
        if reachable && installed {
            
            if self.isConnectionSecured {
                actions()
            } else {
                dynamicsWatch!.secureCommunicationSession { [weak self] authOK in
                    self?.isConnectionSecured = authOK
                    DispatchQueue.main.async { [weak self] in
                        if authOK {
                            self?.messageText = "securing authOK \(authOK)"
                            
                            // do queued actions
                            FileHelper.sharedInstance.initialiseMessageFile()
                            actions()
                            
                        } else {
                            switch self?.dynamicsWatch!.watchCommunicationState() {
                            case .notAllowedByPolicy:
                                self?.messageText = "Not Allowed (Policy)"
                                break
                            case .notAllowedRemoteLocked:
                                self?.messageText = "Not Allowed (Locked)"
                                break
                            case .notAllowedIncompliant:
                                self?.messageText = "Not Allowed (Incompliant)"
                                break
                            case .securingFailed:
                                self?.messageText = "Failed"
                                break
                            case .needsWristDetected:
                                self?.messageText = "Wrist not detected"
                                break
                            case .needsConfirmOnWatch:
                                self?.messageText = "Received confirm code"
                                break
                            case .needsConfirmOnPhone:
                                self?.messageText = "Waiting for confirm"
                                break
                            case .needsFirstLaunch:
                                self?.messageText = "Cannot detect companion"
                                break
                            case .resetting:
                                self?.messageText = "Resetting"
                                break
                            default:
                                print("unexpected watchCommunicationState: \(self!.dynamicsWatch!.watchCommunicationState())")
                                //no-op
                            }
                        }
                        self?.updateWatchCommunicationString()
                    }
                }
            }
        }
    }
    
    func updateWatchCommunicationString() {
        var watchStateString = "Not Set"
        
        switch dynamicsWatch?.watchCommunicationState() {
        case .stateNotSet:
            watchStateString = "Not Set"
            break
        case .resetting:
            watchStateString = "Resetting"
            break
        case .ready:
            watchStateString = "Ready"
            break
        case .securingFailed:
            watchStateString = "Securing Failed"
            break
        case .notAllowedByPolicy:
            watchStateString = "Not Allowed (Policy)"
            break
        case .notAllowedRemoteLocked:
            watchStateString = "Not Allowed (Locked)"
            break
        case .notAllowedIncompliant:
            watchStateString = "Not Allowed (Incompliant)"
            break
        case .needsConfirmOnPhone:
            watchStateString = "Needs Their Confirmation"
            break
        case .needsConfirmOnWatch:
            watchStateString = "Needs My Confirmation"
            break
        case .needsWristDetected:
            watchStateString =  "Needs Wrist/Passcode"
            break
        case .needsFirstLaunch:
            watchStateString =  "Needs Launch"
            break
        default:
            watchStateString =  "Not Set"
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.watchState = watchStateString
        }
    }
    
    func sendMessage() {
        sendMessageInternal() { [weak self] in
            let replyHandler = { [weak self] (reply: [String : Any]) -> Void in
                print("Reply message received \(reply)")
                var outMessage = reply["replyingToWatch"] as? String ?? ""
                if let error = reply[WatchMessageErrorKey] as? NSError {
                    if (error.domain == WatchMessageErrorDomain) {
                        print("Error sending message code \(error.code) - info: \(error.userInfo[WatchMessageErrorUserInfoKey] as! String)")
                        
                        switch error.code {
                        case WatchMessageErrorPolicyNotAllowed:
                            outMessage = "Policy not allowed"
                            break
                        case WatchMessageErrorNeedsCommunicationSecured:
                            outMessage = "Cannot secure"
                            break
                        case WatchMessageErrorRemoteLocked:
                            outMessage = "Remote locked"
                            break
                        case WatchMessageErrorIncompliant:
                            outMessage = "Incompliant"
                            break
                        case WatchMessageErrorOther:
                            outMessage = "Not allowed"
                            break
                        default:
                            outMessage = "Unexpected"
                            break
                        }
                    } else {
                        outMessage = error.localizedDescription
                    }
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.messageText = outMessage
                }
            }
            
            let contentsData = FileHelper.sharedInstance.getMessageFileContent()
            let text = "Hello \(self!.messageCount) \(String(data: contentsData, encoding: .utf8) ?? "error reading file")"
            let image = #imageLiteral(resourceName: "support.png").pngData() ?? Data()
            let dictionary = ["text": text, "image": image] as [String : Any]
            let message = ["sendingToDevice": dictionary]
            
            print("Sending message: \(message) - handler \(self!.expectReply)")
            self?.wcSession.sendMessage(message,
                                       replyHandler: self!.expectReply ? replyHandler : nil,
                                       errorHandler: { error in
                                            DispatchQueue.main.async { [weak self] in
                                                self?.messageText = error.localizedDescription
                                            }
                                            print("Error \(error.localizedDescription)")
                                        })
        }
    }

    func sendMessageData() {
        sendMessageInternal() {
            let imageData = #imageLiteral(resourceName: "support.png").pngData() ?? Data()
            let replyHandler = {  [self] (reply: Data) in
                print("Reply data received \(reply.count)")
                DispatchQueue.main.async { [weak self] in
                    self?.messageText = String(data: reply, encoding: .utf8) ?? "Invalid reply"
                }
            }
            print("Sending data \(imageData.count) - handler \(self.expectReply)")
            self.wcSession.sendMessageData(imageData,
                                           replyHandler: self.expectReply ? replyHandler : nil,
                                           errorHandler: { error in
                                                DispatchQueue.main.async { [weak self] in
                                                    self?.messageText = error.localizedDescription
                                                }
                                                print("Error \(error.localizedDescription)")
                                            })
        }
    }
    
    func createFile(_ completion: @escaping ((Bool) -> ())) {
        secureCommunication({
            let result = FileHelper.sharedInstance.createFileInWatchFolder()
            completion(result)
        })
    }
    
    func refreshFileList() {
        secureCommunication({ [weak self] in
            self?.files = FileHelper.sharedInstance.getFilesFromWatchFolder()
        })
    }
    
    func deleteAllFiles(_ completion: @escaping ((Bool) -> ())) {
        secureCommunication({
            let result = FileHelper.sharedInstance.resetFolderFilesFromWatch()
            completion(result)
        })
    }
    
    // MARK: internal functions
    
    private func handleMessageReceived(_ message: [String : Any], replyHandler: (([String:Any]) -> Void)? = nil) {
        print("Received message: \(message) - handler \(replyHandler != nil)")
        DispatchQueue.main.async { [weak self] in
            
            var messageString = ""
            if let messageDict = message["messageToWatch"] as? [String : Any] {
                messageString = messageDict["text"] as! String
                self?.messageData = messageDict["image"] as! Data
                
            } else if let error = message["WatchDynamicsIntercepted"] as? NSError {
                messageString = error.userInfo["WatchErrorUserInfoKey"] as? String ?? error.localizedDescription
            }
            self?.messageText = messageString
            
            if replyHandler != nil {
                let reply = ["replyingToDevice" : "Ack: " + messageString]
                print("Sending message reply \(reply)")
                replyHandler!(reply)
            }
        }
    }
    
    private func handleMessageDataReceived(_ messageData: Data, replyHandler: ((Data) -> Void)? = nil) {
        print("Received data \(messageData) - handler \(replyHandler != nil)")
        DispatchQueue.main.async { [weak self] in
            self?.messageData = messageData
            self?.messageText = "image rcvd \(messageData.count)"
            
            if replyHandler != nil {
                let reply = self?.messageText.data(using: .utf8) ?? Data()
                print("Sending data reply \(reply)")
                replyHandler!(reply)
            }
        }
    }
    
    private func sendMessageInternal(_ actions: @escaping () -> ()) {
        messageCount += 1
        messageText = ""
        messageData = Data()
        
        secureCommunication(actions)
    }
}
