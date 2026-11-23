/* Copyright (c) 2026 BlackBerry Limited.
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

class WKWebViewGDiOSDelegate: NSObject, GDiOSDelegate {

    static let sharedInstance = WKWebViewGDiOSDelegate()

    weak var sceneDelegate: WKWebViewSceneDelegate?
    weak var applicationDelegate: AppDelegate?

    private var pendingRootViewController: UIViewController?

    var hasAuthorized = false

    func presentMainUIIfNeeded() {
        guard hasAuthorized, let root = pendingRootViewController else { return }
        guard let window = sceneDelegate?.window else { return }
        window.rootViewController = root
        pendingRootViewController = nil
        window.makeKeyAndVisible()
        notifyApplicationDelegateIfNeeded()
    }

    private func notifyApplicationDelegateIfNeeded() {
        guard hasAuthorized, pendingRootViewController == nil else { return }
        applicationDelegate?.didAuthorize()
    }

    // MARK: - BlackBerry Dynamics SDK Delegate Methods

    func handle(_ anEvent: GDAppEvent) {

        switch anEvent.type {
        case .authorized:
            onAuthorized(anEvent: anEvent)
        case .notAuthorized:
            onNotAuthorized(anEvent: anEvent)
        case .remoteSettingsUpdate:
            break
        case .servicesUpdate:
            break
        case .policyUpdate:
            break
        default:
            print("handleEvent \(anEvent.message)")
        }
    }

    func onNotAuthorized(anEvent: GDAppEvent) {
        switch anEvent.code {
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
            print("onNotAuthorized \(anEvent.message)")
        case .errorIdleLockout:
            break
        default:
            assertionFailure("Unhandled not authorized event")
        }
    }

    func onAuthorized(anEvent: GDAppEvent) {
        switch anEvent.code {
        case .errorNone:
            if !hasAuthorized {
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let rootViewController = mainStoryboard.instantiateInitialViewController() else { return }
                pendingRootViewController = rootViewController
                hasAuthorized = true
                presentMainUIIfNeeded()
            }
        default:
            assertionFailure("Authorized startup with an error")
        }
    }
}
