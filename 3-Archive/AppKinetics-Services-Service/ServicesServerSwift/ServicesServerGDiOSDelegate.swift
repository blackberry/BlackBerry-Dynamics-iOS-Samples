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
import UIKit
import BlackBerryDynamics.Runtime


class ServicesServerGDiOSDelegate: NSObject, GDiOSDelegate {
    
    static let sharedInstance = ServicesServerGDiOSDelegate()
    weak var sceneDelegate: ServicesServerSceneDelegate?
    weak var appDelegate: AppDelegate? {
        didSet {
            didAuthorize()
        }
    }
    weak var rootViewController: UIViewController?{
        didSet {
            didAuthorize()
        }
    }
    
    var hasAuthorized:Bool = false
    
    
    fileprivate override init() {
        print("Initialize services' delegates", Service.sharedInstance)
        print(#file, #function)
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveStateChangeNotification(_:)), name: Notification.Name.GDStateChange, object: nil)
    }
    
    deinit {
        print(#file, #function)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func didAuthorize() -> Void {
        if (hasAuthorized && (rootViewController != nil) && (appDelegate != nil) ) {
            self.appDelegate!.didAuthorize()
        }
    }

    func handle(_ anEvent: GDAppEvent) {
        // Primary authorization path uses GDStateChange notifications; handle remains for protocol conformance.
    }
    
    @objc func receiveStateChangeNotification(_ notification: NSNotification) {
        if (notification.name == Notification.Name.GDStateChange) {
            let userInfo = notification.userInfo
            let propertyName = userInfo?[GDStateChangeKeyProperty] as! String
            let state = userInfo?[GDStateChangeKeyCopy] as! GDState
            
            // For the purposes of this example, we want to log a different message so that it is known
            // these calls are coming from Notification Center
            if (propertyName == GDKeyIsAuthorized) {
                print("receiveStateChangeNotification - isAuthorized: \(state.isAuthorized)")
                handleStateChange(state)
            } else if (propertyName == GDKeyReasonNotAuthorized) {
                print("receiveStateChangeNotification - reasonNotAuthorized: \(state.reasonNotAuthorized)")
            } else if (propertyName == GDKeyUserInterfaceState) {
                print("receiveStateChangeNotification - userInterfaceState: \(state.userInterfaceState)")
            } else if (propertyName == GDKeyCurrentScreen) {
                print("receiveStateChangeNotification - currentScreen: \(state.currentScreen)")
            }
        }
    }
    
    func handleStateChange(_ state: GDState) {
        if state.isAuthorized {
            print("gdState: authorized");
            onAuthorized()
        } else {
            print("gdState: not authorized, error \(state.reasonNotAuthorized)");
            onNotAuthorized(errorCode: state.reasonNotAuthorized)
        }
    }
    
    
    func onNotAuthorized(errorCode: GDAppResultCode) {
        // Handle the Good Libraries not authorized event
        switch errorCode {
        case .errorActivationFailed: break
        case .errorProvisioningFailed: break
        case .errorPushConnectionTimeout: break
        case .errorSecurityError: break
        case .errorAppDenied: break
        case .errorAppVersionNotEntitled: break
        case .errorBlocked: break
        case .errorWiped: break
        case .errorRemoteLockout: break
        case .errorPasswordChangeRequired:
            // an condition has occured denying authorization, an application may wish to log these events
            print("gdState: not authorized, error \(errorCode)")
        case .errorIdleLockout:
            // idle lockout is benign & informational
            break
        default: assert(false, "Unhandled not authorized event");
        }
    }
    
    func onAuthorized() {
        if (!hasAuthorized) {
            sceneDelegate?.launchApplicationUI()
            hasAuthorized = true
            didAuthorize()
        }
    }
}
