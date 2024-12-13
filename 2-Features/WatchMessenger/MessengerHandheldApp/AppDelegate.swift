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
import BlackBerryDynamics.Runtime
import WatchConnectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        MessengerHandheldAppGDiOSDelegate.sharedInstance.appDelegate = self
        GDiOS.sharedInstance().authorize(MessengerHandheldAppGDiOSDelegate.sharedInstance)
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("WCSession activation state: \(session.activationState)")
        }
        
        return true
    }
    
    // MARK: WCSessionDelegate
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("WCSession sessionReachabilityDidChange reachable \(session.isReachable)")
        DispatchQueue.main.async { [weak self] in
            if let vc = self?.findMainViewController() {
                vc.updateWatchStatusIcon()
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("WCSession activationDidComplete with state: \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession sessionDidDeactivate")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleMessageReceived(message)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        handleMessageReceived(message, replyHandler: replyHandler)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        handleMessageDataReceived(messageData)
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        handleMessageDataReceived(messageData, replyHandler: replyHandler)
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: (any Error)?) {
        print("Session delegate finished transfer of \(fileTransfer.file.fileURL)  - metadata: \(String(describing: fileTransfer.file.metadata)) - error \(error?.localizedDescription ?? "none") - outstanding transfers \(session.outstandingFileTransfers)")
    }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("Session delegate received file: \(file.fileURL) - metadata: \(String(describing: file.metadata))")
        
        let fileName = file.fileURL.lastPathComponent
        
        let newFileName = FileHelper.sharedInstance.saveFileFromWatch(fileName)

        let fileContent = FileHelper.sharedInstance.getContentOfFileFromWatchFolder(newFileName)
        print("Received file: \(fileName)\nsaved as \(newFileName)\nContent: \(fileContent)")
        
        DispatchQueue.main.async { [weak self] in
            if let vc = self?.findMainViewController() {
                vc.receivedFile(file: file)
            }
        }
    }
    
    // MARK: helper methods
    private func handleMessageReceived(_ message: [String: Any], replyHandler: (([String : Any]) -> Void)? = nil) {
        print("Session delegate received message: \(message) - handler \(replyHandler != nil)")
        DispatchQueue.main.async { [weak self] in
            if let vc = self?.findMainViewController() {
                vc.receivedMessage(message: message, replyHandler: replyHandler)
            }
        }
    }
    
    private func handleMessageDataReceived(_ messageData: Data, replyHandler: ((Data) -> Void)? = nil) {
        print("Session delegate received data: \(messageData) - handler \(replyHandler != nil)")
        DispatchQueue.main.async { [weak self] in
            if let vc = self?.findMainViewController() {
                vc.receivedMessageData(messageData: messageData, replyHandler: replyHandler)
            }
        }
    }
    
    func findMainViewController() -> MainViewController? {
        var vc = self.window?.rootViewController
        if let gtlvc = vc as? GTLauncherViewController {
            vc = gtlvc.baseViewController
        }
        if let nav = vc as? UINavigationController {
            vc = nav.visibleViewController
        }
        if let mvc = vc as? MainViewController {
            return mvc
        }
        return nil
    }
    
    func didAuthorize() -> Void {
        print(#file, #function)
        FileHelper.sharedInstance.initialiseMessageFile()
    }
}

