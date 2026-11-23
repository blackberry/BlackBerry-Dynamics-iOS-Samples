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
 */

import UIKit
import BlackBerryDynamics.Runtime

@MainActor
@objc class GreetingsServerGDiOSDelegate: NSObject, GDiOSDelegate {
    
    @objc static let shared = GreetingsServerGDiOSDelegate()
    
    var hasAuthorized: Bool = false
    @objc var rootViewController: RootViewController?
    @objc var greetingsServerAppDelegate: AppDelegate?
    var gServiceSceneDelegate: GreetingsServerSceneDelegate?
    @objc var serviceController: ServiceController
    
    override init() {
        self.serviceController = ServiceController()
        super.init()
        addStateObserverUsingNotificationCenter()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setRootViewController(_ rootViewController: RootViewController) {
        self.rootViewController = rootViewController
        didAuthorize()
    }
    
    func setAppKineticsTableAppDelegate(_ greetingsClientAppDelegate: AppDelegate) {
        self.greetingsServerAppDelegate = greetingsClientAppDelegate
        didAuthorize()
    }
    
    func didAuthorize() {
        if hasAuthorized, let _ = rootViewController, let appDelegate = greetingsServerAppDelegate {
            appDelegate.didAuthorize()
        }
    }
    
    private func addStateObserverUsingNotificationCenter() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveStateChangeNotification(_:)),
                                               name: NSNotification.Name.GDStateChange,
                                               object: nil)
    }
    
    @objc func receiveStateChangeNotification(_ notification: Notification) {
        guard notification.name == NSNotification.Name.GDStateChange,
              let userInfo = notification.userInfo,
              let propertyName = userInfo[GDStateChangeKeyProperty] as? String,
              let state = userInfo[GDStateChangeKeyCopy] as? GDState else {
            return
        }
        
        switch propertyName {
        case GDKeyIsAuthorized:
            print("receiveStateChangeNotification - isAuthorized: \(state.isAuthorized ? "true" : "false")")
            handleStateChange(state)
        case GDKeyReasonNotAuthorized:
            print("receiveStateChangeNotification - reasonNotAuthorized: \(state.reasonNotAuthorized)")
        case GDKeyUserInterfaceState:
            print("receiveStateChangeNotification - userInterfaceState: \(state.userInterfaceState)")
        case GDKeyCurrentScreen:
            print("receiveStateChangeNotification - currentScreen: \(state.currentScreen)")
        default:
            break
        }
    }
    
    func handleStateChange(_ state: GDState) {
        if state.isAuthorized {
            print("gdState: authorized")
            onAuthorized()
        } else {
            let errorCode = state.reasonNotAuthorized
            print("gdState: not authorized, error:\(errorCode)")
            onNotAuthorized(errorCode)
        }
    }
    
    func onAuthorized() {
        if !hasAuthorized {
            hasAuthorized = true
            let storyboardName: String
            if UIDevice.current.userInterfaceIdiom == .phone {
                storyboardName = "Main_iPhone"
            } else {
                storyboardName = "Main_iPad"
            }
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            
            gServiceSceneDelegate?.window?.rootViewController = storyboard.instantiateInitialViewController()
                
            didAuthorize()
        }
    }
    
    func onNotAuthorized(_ code: GDAppResultCode) {
        switch code {
        case .errorActivationFailed,
             .errorProvisioningFailed,
             .errorPushConnectionTimeout,
             .errorSecurityError,
             .errorAppDenied,
             .errorAppVersionNotEntitled,
             .errorBlocked,
             .errorWiped,
             .errorRemoteLockout,
             .errorPasswordChangeRequired:
            print("gdState: not authorized, error:\(code)")
        case .errorIdleLockout:
            break // idle lockout is benign & informational
        default:
            assertionFailure("Unhandled not authorized event")
        }
    }
}
